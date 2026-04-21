import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ScanOCRPage extends StatefulWidget {
  const ScanOCRPage({super.key});

  @override
  State<ScanOCRPage> createState() => _ScanOCRPageState();
}

class _ScanOCRPageState extends State<ScanOCRPage> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) setState(() => _selectedImage = File(pickedFile.path));
  }

  Future<void> _analyze() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez sélectionner une image.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1️⃣ OCR : envoi image
      final uriOCR = Uri.parse("http://10.0.2.2:5000/ocr");
      var request = http.MultipartRequest("POST", uriOCR);
      request.files.add(await http.MultipartFile.fromPath('image', _selectedImage!.path));
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final productName = data['product_name'] ?? "";

        if (productName.isEmpty) throw Exception("Produit non détecté");

        // 2️⃣ Analyse
        final uriAnalyze = Uri.parse("http://10.0.2.2:5000/analyze");
        final analyzeResponse = await http.post(
          uriAnalyze,
          headers: {"Content-Type": "application/json"},
          body: json.encode({"product_name": productName}),
        );

        if (analyzeResponse.statusCode == 200) {
          final analyzeData = json.decode(analyzeResponse.body);

          if (!mounted) return;
          Navigator.pushNamed(
            context,
            "/results",
            arguments: {
              "product": analyzeData["product"],
              "score": analyzeData["score"] ?? 0.0,
              "reviews": analyzeData["total_reviews"] ?? 0,
              "positives": analyzeData["positives"] ?? [],
              "negatives": analyzeData["negatives"] ?? [],
              "alternatives": analyzeData["alternatives"] ?? [],
            },
          );
        } else {
          throw Exception("Erreur analyse : ${analyzeResponse.body}");
        }
      } else {
        throw Exception("Erreur OCR : ${response.body}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de l'analyse : $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final padB = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: Stack(
        children: [
          // 🔹 Fond dégradé + blobs
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFA8C3BC), Color(0xFFEAF3F1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(top: -90, left: -70, child: _blob(const Color(0xFF79A59B), 280, .22)),
          Positioned(bottom: -110, right: -80, child: _blob(const Color(0xFF0E4D47), 340, .18)),

          // 🔹 UI
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 10, 22, 22),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(.88),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.document_scanner, color: Color(0xFFA8C3BC)),
                          ),
                          const SizedBox(width: 12),
                          const Text('ScanVibe',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const Text('Analyse Produit',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.black87)),
                      const SizedBox(height: 8),
                      const Text('Scannez ou importez une image pour analyser les avis.',
                          style: TextStyle(fontSize: 15, color: Colors.black54)),
                      const SizedBox(height: 22),

                      // Image preview
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: _selectedImage == null
                            ? const Center(
                            child: Icon(Icons.image_search, color: Colors.white70, size: 64))
                            : ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(_selectedImage!, fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Boutons photo/galerie
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black87,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              icon: const Icon(Icons.photo_camera),
                              label: const Text("Caméra"),
                              onPressed: () => _pickImage(ImageSource.camera),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black87,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              icon: const Icon(Icons.photo_library),
                              label: const Text("Galerie"),
                              onPressed: () => _pickImage(ImageSource.gallery),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Bouton Analyser
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade800,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          icon: const Icon(Icons.analytics),
                          label: _isLoading
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : const Text("Analyser",
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w700)),
                          onPressed: _isLoading ? null : _analyze,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Bouton Annuler
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(Icons.close),
                        label: const Text("Annuler"),
                        onPressed: () => Navigator.pop(context),
                      ),
                      SizedBox(height: padB + 8),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _blob(Color base, double size, double opacity) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          width: size,
          height: size,
          color: base.withOpacity(opacity),
        ),
      ),
    );
  }
}
