import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ManualInputPage extends StatefulWidget {
  const ManualInputPage({super.key});

  @override
  State<ManualInputPage> createState() => _ManualInputPageState();
}

class _ManualInputPageState extends State<ManualInputPage> {
  final TextEditingController _controller = TextEditingController();
  String? _manualProductName;
  bool _isAnalyzing = false;
  String? _errorMessage;

  OutlineInputBorder _outline(Color c) =>
      OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: c, width: 1.2));

  Future<void> _analyzeProduct() async {
    FocusScope.of(context).unfocus();

    final productToAnalyze = _manualProductName;

    if (productToAnalyze == null || productToAnalyze.trim().isEmpty) {
      setState(() => _errorMessage = "⚠️ Veuillez entrer un nom de produit.");
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
    });

    try {
      final analysis = await ApiService.analyzeProduct(productToAnalyze);

      if (analysis == null || analysis.isEmpty) {
        setState(() => _errorMessage = "❌ Désolé, ce produit n'existe pas dans notre base.");
        return;
      }

      final resultsArgs = {
        'product': analysis['product'] ?? 'Produit inconnu',
        'score': (analysis['score'] ?? 0.0).toDouble(),
        'reviews': analysis['total_reviews'] ?? 0,
        'positives': analysis['positives'] ?? [],
        'negatives': analysis['negatives'] ?? [],
        'alternatives': analysis['alternatives'] ?? [],
      };

      if (!mounted) return;
      Navigator.pushNamed(context, '/results', arguments: resultsArgs);
    } catch (e) {
      setState(() => _errorMessage = "Erreur lors de l'analyse : $e");
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final padB = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Fond dégradé
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFA8C3BC), Color(0xFFEAF3F1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Blobs flous
          Positioned(top: -100, left: -70, child: _blob(const Color(0xFF79A59B), 280, .22)),
          Positioned(bottom: -120, right: -80, child: _blob(const Color(0xFF0E4D47), 340, .18)),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
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
                            child: const Icon(Icons.search, color: Color(0xFFA8C3BC)),
                          ),
                          const SizedBox(width: 12),
                          const Text("ScanVibe",
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        "Analyse manuelle",
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.black87),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Entrez un produit et accédez à une analyse instantanée.",
                        style: TextStyle(fontSize: 14.5, color: Colors.black54),
                      ),
                      const SizedBox(height: 26),

                      // Champ produit
                      TextField(
                        controller: _controller,
                        onChanged: (value) => setState(() => _manualProductName = value),
                        onSubmitted: (_) => _isAnalyzing ? null : _analyzeProduct(),
                        decoration: InputDecoration(
                          labelText: "Nom du produit",
                          prefixIcon: const Icon(Icons.shopping_bag_outlined),
                          border: _outline(Colors.black26),
                          enabledBorder: _outline(Colors.black26),
                          focusedBorder: _outline(Colors.black54),
                          filled: true,
                          fillColor: Colors.grey.shade200,
                        ),
                      ),

                      const SizedBox(height: 14),

                      if (_errorMessage != null)
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEBEE),
                            border: Border.all(color: const Color(0xFFEF9A9A)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.redAccent),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(color: Colors.black87),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Bouton d'analyse
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black87,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: (_manualProductName != null &&
                              _manualProductName!.trim().isNotEmpty &&
                              !_isAnalyzing)
                              ? _analyzeProduct
                              : null,
                          child: _isAnalyzing
                              ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : const Text(
                            "Analyser le produit",
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),

                      SizedBox(height: padB + 10),
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
        child: Container(width: size, height: size, color: base.withOpacity(opacity)),
      ),
    );
  }
}
