import 'dart:ui';
import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final padB = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "À propos",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Dégradé de fond
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFA8C3BC), Color(0xFFEAF3F1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Blobs décoratifs
          Positioned(top: -80, left: -60, child: _blob(const Color(0xFF79A59B), 260, .20)),
          Positioned(bottom: -90, right: -70, child: _blob(const Color(0xFF0E4D47), 300, .18)),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 120),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(.85),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.auto_awesome, color: Color(0xFFA8C3BC)),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/welcome'),
                        child: const Text(
                          "ScanVibe",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _infoCard(
                    icon: Icons.info_outline_rounded,
                    title: "Qu’est-ce que ScanVibe ?",
                    description:
                    "Une application qui aide à évaluer rapidement la qualité d’un produit à partir des avis.",
                  ),
                  const SizedBox(height: 18),
                  _infoCard(
                    icon: Icons.qr_code_scanner_rounded,
                    title: "Comment ça marche ?",
                    description:
                    "Scannez un ticket/étiquette ou entrez un nom. Nous analysons les avis et fournissons une note, un résumé et des points clés.",
                  ),
                  const SizedBox(height: 18),
                  _infoCard(
                    icon: Icons.lock_outline_rounded,
                    title: "Authentification",
                    description:
                    "Connectez-vous pour profiter de toutes les fonctionnalités et d’une expérience personnalisée.",
                  ),
                ],
              ),
            ),
          ),

          // Bouton bas
          Positioned(
            left: 20,
            right: 20,
            bottom: padB + 16,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 6,
              ),
              child: const Text("Se connecter",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  /// Carte d'info
  Widget _infoCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x22000000), blurRadius: 12, offset: Offset(0, 6))
        ],
        border: Border.all(color: Colors.black12),
      ),
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFA8C3BC).withOpacity(.22),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF0E4D47), size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87)),
                const SizedBox(height: 8),
                Text(description,
                    style: const TextStyle(fontSize: 15, color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Blob décoratif
  Widget _blob(Color base, double size, double opacity) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(width: size, height: size, color: base.withOpacity(opacity)),
      ),
    );
  }
}
