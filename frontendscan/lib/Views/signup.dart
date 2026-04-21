import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  // --- Controllers ---
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _nameController = TextEditingController();
  final _firstNameController = TextEditingController();

  // --- State ---
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _errorMessage;

  // --- Signup Method ---
  Future<void> _signup() async {
    // Vérification des champs
    if (_nameController.text.trim().isEmpty ||
        _firstNameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmController.text.isEmpty) {
      setState(() =>
      _errorMessage = 'Tous les champs sont obligatoires. Veuillez remplir tous les champs.');
      return;
    }

    // Vérification format email
    final emailRegex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!emailRegex.hasMatch(_emailController.text.trim())) {
      setState(() => _errorMessage = 'Format d\'email invalide.');
      return;
    }

    // Vérification mot de passe
    if (_passwordController.text.length < 6) {
      setState(() => _errorMessage = 'Le mot de passe doit contenir au moins 6 caractères.');
      return;
    }

    if (_passwordController.text != _confirmController.text) {
      setState(() => _errorMessage = 'Les mots de passe ne correspondent pas.');
      return;
    }

    // Lancement de la requête
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final url = Uri.parse('http://10.0.2.2:3000/api/auth/signup');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
          'confirmPassword': _confirmController.text,
          'name': _nameController.text.trim(),
          'firstName': _firstNameController.text.trim(),
        }),
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Utilisateur créé avec succès'),
            backgroundColor: Colors.green,
            duration: Duration(milliseconds: 900),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 900));

        if (!mounted) return;
        Navigator.pop(context);
      } else {
        final data = jsonDecode(response.body);
        final backendMessage = data['message'] ?? data['error'] ?? '';
        setState(() => _errorMessage = _mapBackendError(backendMessage));
      }
    } catch (_) {
      setState(() {
        _isLoading = false;
        _errorMessage =
        'Erreur de connexion au serveur. Veuillez vérifier votre connexion internet.';
      });
    }
  }

  // --- Mapper les erreurs Backend ---
  String _mapBackendError(String backendMessage) {
    final messageLower = backendMessage.toString().toLowerCase();

    if (messageLower.contains('existe déjà') || messageLower.contains('already exists')) {
      return 'Un compte avec cette adresse email existe déjà.';
    } else if (messageLower.contains('email')) {
      return 'Format d\'email invalide.';
    } else if (messageLower.contains('mot de passe')) {
      return 'Le mot de passe ne respecte pas les critères de sécurité.';
    } else if (messageLower.contains('firstname') || messageLower.contains('prénom')) {
      return 'Le prénom est obligatoire.';
    } else if (messageLower.contains('name')) {
      return 'Le nom est obligatoire.';
    } else if (messageLower.contains('requis') || messageLower.contains('required')) {
      return 'Tous les champs sont obligatoires.';
    } else if (messageLower.contains('correspondent pas')) {
      return 'Les mots de passe ne correspondent pas.';
    }
    return backendMessage.toString().trim().isNotEmpty
        ? backendMessage.toString()
        : 'Erreur lors de l\'inscription.';
  }

  // --- UI ---
  @override
  Widget build(BuildContext context) {
    final padB = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Fond en dégradé
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
          Positioned(top: -90, left: -70, child: _blob(const Color(0xFF79A59B), 280, .22)),
          Positioned(bottom: -110, right: -80, child: _blob(const Color(0xFF0E4D47), 340, .18)),

          // Contenu principal
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 10, 22, 22),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // --- Header ---
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(.88),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.person_add_alt_1,
                                color: Color(0xFFA8C3BC)),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'ScanVibe',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // --- Titre ---
                      const Text(
                        'Créer un compte',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Rejoignez ScanVibe et analysez vos produits en un clin d’œil.',
                        style: TextStyle(fontSize: 14.5, color: Colors.black54),
                      ),
                      const SizedBox(height: 22),

                      // --- Champs ---
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _nameController,
                              textInputAction: TextInputAction.next,
                              decoration: _inputDecoration(
                                label: 'Nom',
                                icon: Icons.person_outline,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _firstNameController,
                              textInputAction: TextInputAction.next,
                              decoration: _inputDecoration(
                                label: 'Prénom',
                                icon: Icons.badge_outlined,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: _inputDecoration(
                          label: 'Email',
                          icon: Icons.email_outlined,
                        ),
                      ),
                      const SizedBox(height: 14),

                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.next,
                        decoration: _inputDecoration(
                          label: 'Mot de passe',
                          icon: Icons.lock_outline,
                          suffix: IconButton(
                            icon: Icon(
                                _obscurePassword ? Icons.visibility : Icons.visibility_off),
                            onPressed: () =>
                                setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      TextField(
                        controller: _confirmController,
                        obscureText: _obscureConfirm,
                        decoration: _inputDecoration(
                          label: 'Confirmer le mot de passe',
                          icon: Icons.lock_person_outlined,
                          suffix: IconButton(
                            icon: Icon(
                                _obscureConfirm ? Icons.visibility : Icons.visibility_off),
                            onPressed: () =>
                                setState(() => _obscureConfirm = !_obscureConfirm),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // --- Erreur ---
                      if (_errorMessage != null) _errorBox(),

                      const SizedBox(height: 14),

                      // --- Bouton ---
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black87,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: _isLoading ? null : _signup,
                          child: _isLoading
                              ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : const Text(
                            "S'inscrire",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // --- Lien vers login ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Vous avez déjà un compte ? ",
                              style: TextStyle(color: Colors.black87)),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Text(
                              'Connectez-vous',
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
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

  // --- Widgets Helpers ---

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black87),
      prefixIcon: Icon(icon, color: Colors.black87),
      suffixIcon: suffix,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.55), // fond un peu foncé
    );
  }

  Widget _errorBox() {
    return Container(
      width: double.infinity,
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
