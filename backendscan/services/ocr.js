// services/ocr.js
import Tesseract from 'tesseract.js';

export async function extractText(imagePath) {
  const { data: { text } } = await Tesseract.recognize(imagePath, 'eng');
  return text.trim();
}
