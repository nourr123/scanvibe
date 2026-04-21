import 'dart:ui';
import 'package:flutter/material.dart';

class HomeHub extends StatefulWidget {
  const HomeHub({super.key});
  @override
  State<HomeHub> createState() => _HomeHubState();
}

class _HomeHubState extends State<HomeHub> {
  bool _showTip = false;

  @override
  Widget build(BuildContext context) {
    final padB = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.black87),
            onPressed: () => Navigator.pushNamed(context, '/about'),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFA8C3BC), Color(0xFFEAF3F1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(top: -80, left: -60, child: _blob(const Color(0xFF79A59B), 260, .20)),
          Positioned(bottom: -90, right: -70, child: _blob(const Color(0xFF0E4D47), 300, .18)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(.85),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.auto_awesome, color: Color(0xFFA8C3BC)),
                      ),
                      const SizedBox(width: 10),
                      Text("ScanVibe",
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    "Analyse d’avis, en un clin d’œil",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.black87),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Scannez un ticket ou entrez le nom du produit pour obtenir une note et un résumé.",
                    style: TextStyle(fontSize: 15, color: Colors.black54, height: 1.35),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Column(
                      children: [
                        _ActionCard(
                          title: "Scanner un ticket",
                          icon: Icons.document_scanner_rounded,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0E4D47), Color(0xFF3D8B80)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          onTap: () => Navigator.pushNamed(context, '/scan_ocr'),
                          darkText: false,
                        ),
                        const SizedBox(height: 16),
                        _ActionCard(
                          title: "Entrer le nom manuellement",
                          icon: Icons.edit_note_rounded,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF79A59B), Color(0xFFA8C3BC)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          onTap: () => Navigator.pushNamed(context, '/manual'),
                          darkText: true,
                        ),
                        SizedBox(height: padB + 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 20,
            bottom: padB + 20,
            child: GestureDetector(
              onTap: () => setState(() => _showTip = !_showTip),
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(23),
                  boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 12, offset: Offset(0, 6))],
                  border: Border.all(color: Colors.black12),
                ),
                child: const Icon(Icons.lightbulb_outline, color: Colors.black87),
              ),
            ),
          ),
          Positioned(
            left: 76,
            right: 20,
            bottom: padB + 24,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              opacity: _showTip ? 1 : 0,
              child: _tipPill(
                icon: Icons.lightbulb_outline,
                text: "Astuce : si le scan échoue, utilisez la saisie manuelle.",
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

  Widget _tipPill({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.95),
        borderRadius: BorderRadius.circular(40),
        boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 8)],
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.black87),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.icon,
    required this.gradient,
    required this.onTap,
    required this.darkText,
  });

  final String title;
  final IconData icon;
  final LinearGradient gradient;
  final VoidCallback onTap;
  final bool darkText;

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w700,
      color: darkText ? Colors.black87 : Colors.white,
    );

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 95,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: gradient,
          boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 12, offset: Offset(0, 6))],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: darkText ? Colors.white.withOpacity(.25) : Colors.white.withOpacity(.18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 30, color: darkText ? Colors.black87 : Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(title, style: titleStyle, maxLines: 1, overflow: TextOverflow.ellipsis)),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 18, color: darkText ? Colors.black87 : Colors.white),
          ],
        ),
      ),
    );
  }
}
