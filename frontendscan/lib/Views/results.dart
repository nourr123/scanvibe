import 'dart:ui';
import 'package:flutter/material.dart';

class ResultsPage extends StatelessWidget {
  const ResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final String product = args['product'] ?? 'Produit inconnu';
    final double score = args['score'] ?? 0.0;
    final int reviews = args['reviews'] ?? 0;
    final List positives = args['positives'] ?? [];
    final List negatives = args['negatives'] ?? [];
    final List alternatives = args['alternatives'] ?? [];

    Color scoreColor;
    if (score >= 4.0) {
      scoreColor = const Color(0xFF4CAF50);
    } else if (score >= 2.5) {
      scoreColor = const Color(0xFFFF9800);
    } else {
      scoreColor = const Color(0xFFF44336);
    }

    final padB = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: Stack(
        children: [
          // 🔹 Dégradé de fond
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFA8C3BC), Color(0xFFEAF3F1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // 🔹 Blobs flous
          Positioned(top: -90, left: -70, child: _blob(const Color(0xFF79A59B), 280, .22)),
          Positioned(bottom: -110, right: -80, child: _blob(const Color(0xFF0E4D47), 340, .18)),

          // 🔹 Contenu
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 🔹 Header
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(.88),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.auto_awesome, color: Color(0xFFA8C3BC)),
                          ),
                          const SizedBox(width: 12),
                          const Text('ScanVibe', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                        ],
                      ),
                      const SizedBox(height: 18),

                      const Text(
                        'Analyse du produit',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.black87),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Découvrez les points forts, points faibles et alternatives recommandées.',
                        style: TextStyle(fontSize: 14.5, color: Colors.black54),
                      ),
                      const SizedBox(height: 20),

                      // 🔹 Produit analysé
                      _styledCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Produit analysé",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: Colors.black87.withOpacity(.7),
                                )),
                            const SizedBox(height: 8),
                            Text(product,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 🔹 Score global
                      _styledCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text("Score global",
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                            const SizedBox(height: 12),
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: CircularProgressIndicator(
                                    value: score / 5,
                                    backgroundColor: Colors.grey.shade300,
                                    valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                                    strokeWidth: 8,
                                  ),
                                ),
                                Text(
                                  score.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: scoreColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text("Basé sur $reviews avis",
                                style: const TextStyle(color: Colors.black54, fontSize: 13)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 🔹 Points positifs
                      if (positives.isNotEmpty) _section("Points positifs", Colors.green, positives, true),
                      // 🔹 Points négatifs
                      if (negatives.isNotEmpty) _section("Points négatifs", Colors.red, negatives, false),
                      // 🔹 Alternatives
                      if (alternatives.isNotEmpty) _section("Alternatives recommandées", Colors.purple, alternatives, null),

                      const SizedBox(height: 22),

                      // 🔹 Boutons
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black87,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text("RETOUR HOME",
                                    style: TextStyle(
                                        fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text("DÉCONNEXION",
                                    style: TextStyle(
                                        fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: padB + 12),
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

  // 🔹 Card stylée
  Widget _styledCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 12,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: child,
    );
  }

  // 🔹 Section dynamique
  Widget _section(String title, Color color, List items, bool? isPositive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(title,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: color)),
        ),
        const SizedBox(height: 10),
        ...items.map((item) => _itemCard(item.toString(), color, isPositive)).toList(),
        const SizedBox(height: 16),
      ],
    );
  }

  // 🔹 Item
  Widget _itemCard(String text, Color color, bool? isPositive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          if (isPositive != null)
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isPositive ? Colors.green.withOpacity(.1) : Colors.red.withOpacity(.1),
              ),
              child: Icon(
                isPositive ? Icons.check_rounded : Icons.close_rounded,
                size: 16,
                color: isPositive ? Colors.green : Colors.red,
              ),
            ),
          if (isPositive != null) const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14, height: 1.4))),
        ],
      ),
    );
  }

  // 🔹 Blob décoratif
  Widget _blob(Color base, double size, double opacity) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(width: size, height: size, color: base.withOpacity(opacity)),
      ),
    );
  }
}
