// services/sentiment.js
import fs from 'fs';
import path from 'path';
import * as url from 'url';

let ort = null;
let session = null;
let tokenizer = null;

function resolveFromProject(rel) {
  const __dirname = path.dirname(url.fileURLToPath(import.meta.url));
  return path.resolve(__dirname, '..', rel);
}

async function ensureOrt() {
  if (!ort) {
    ort = (await import('onnxruntime-node')).default ?? (await import('onnxruntime-node'));
  }
}

async function ensureSession() {
  if (session) return session;
  const modelPath = process.env.MODEL_PATH || './onnx_model/model.onnx';
  const resolved = resolveFromProject(modelPath);
  if (!fs.existsSync(resolved)) throw new Error(`Model not found at ${resolved}`);
  await ensureOrt();
  session = await ort.InferenceSession.create(resolved, { executionProviders: ['cpu'] });
  console.log(`[sentiment] ONNX model loaded: ${resolved}`);
  return session;
}

async function ensureTokenizer() {
  if (tokenizer) return tokenizer;
  const { Tokenizer } = await import('tokenizers'); // <-- le bon package
  const tokPath = resolveFromProject('./onnx_model/tokenizer.json');
  tokenizer = await Tokenizer.fromFile(tokPath);
  return tokenizer;
}

function softmax(arr) {
  const m = Math.max(...arr);
  const exps = arr.map(x => Math.exp(x - m));
  const s = exps.reduce((a, b) => a + b, 0);
  return exps.map(x => x / s);
}

export async function classifySentiment(text, { locale = 'fr' } = {}) {
  try {
    const s = await ensureSession();
    const t = await ensureTokenizer();

    const enc = t.encode(String(text || ''));
    // Entrées communes pour les modèles BERT-like en ONNX
    const inputIds = BigInt64Array.from(enc.ids.map(n => BigInt(n)));
    const attnMask = BigInt64Array.from((enc.attentionMask ?? new Array(enc.ids.length).fill(1)).map(n => BigInt(n)));

    const feeds = {
      input_ids: new ort.Tensor('int64', inputIds, [1, inputIds.length]),
      attention_mask: new ort.Tensor('int64', attnMask, [1, attnMask.length]),
      // Ajoute token_type_ids si ton modèle le demande :
      // token_type_ids: new ort.Tensor('int64', BigInt64Array.from(new Array(inputIds.length/1).fill(0n)), [1, inputIds.length]),
    };

    const out = await s.run(feeds);
    // Adapte le nom de sortie à ton modèle (souvent 'logits')
    const logits = out.logits?.data ?? out.output?.data;
    if (!logits) throw new Error('No logits in ONNX output');

    const probs = softmax(Array.from(logits));
    // Binaire [neg, pos] → score = prob(pos)
    const score = probs.length >= 2 ? probs[1] : 0.5;

    return {
      sentimentScore: score,
      avgRating: 1 + score * 4, // 1..5
      summary: score >= 0.5 ? 'Globalement positif.' : 'Globalement négatif.',
      pros: score >= 0.5 ? ['Bon ressenti global'] : [],
      cons: score < 0.5 ? ['Quelques points négatifs'] : [],
      confidence: Math.max(...probs),
    };
  } catch (e) {
    console.error('classifySentiment failed:', e?.message || e);
    // Fallback simple si tu veux éviter l’erreur dure
    return {
      sentimentScore: 0.5,
      avgRating: 3,
      summary: 'Analyse basique (fallback)',
      pros: [],
      cons: [],
      confidence: 0,
    };
  }
}
