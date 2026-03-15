import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user.dart';
import 'resident_dashboard.dart';
import 'admin/dashboard/admin_dashboard.dart';
import 'security_dashboard.dart';
import 'service_dashboard.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showMessage('Veuillez remplir tous les champs', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    final response = await ApiService.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (response['success'] == true) {
      final User user = response['user'];
      Widget dashboard;

      switch (user.role) {
        case 'resident':
          dashboard = ResidentDashboard(user: user);
          break;
        case 'agent_securite':
          dashboard = SecurityDashboard(user: user);
          break;
        case 'agent_service':
          dashboard = ServiceDashboard(user: user);
          break;
        case 'admin':
dashboard = AdminDashboard(userName: user.nom);  // Passez uniquement le nom  // Passez uniquement le nom          break;
        default:
          _showMessage('Rôle inconnu', Colors.red);
          return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => dashboard),
      );
    } else {
      _showMessage(response['message'] ?? 'Erreur de connexion', Colors.red);
    }
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/building.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.4), // Changé pour rendre l'arrière-plan plus clair et transparent
              BlendMode.overlay, // Changé le mode de fusion
            ),
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  SizedBox(height: 36),

                  // ── Logo SANS conteneur ────────────────────────
                  Center(
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 450,
                      height: 450,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.apartment,
                          size: 20,
                          color: Color(0xFF0F2B4B),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 20),

                  // ── Titre ───────────────────────────────────────
                  Text(
                    'CONNEXION',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0D1F3C), // Retour à la couleur foncée
                      letterSpacing: 1.5,
                    ),
                  ),

                  SizedBox(height: 36),

                  // ── Champ Identifiant / Email ───────────────────
                  _buildInputField(
                    controller: _emailController,
                    hint: 'Identifiant / Email',
                    prefixIcon: Icons.person_outline,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  SizedBox(height: 14),

                  // ── Champ Mot de passe ──────────────────────────
                  _buildInputField(
                    controller: _passwordController,
                    hint: 'Mot de passe',
                    prefixIcon: Icons.lock_outline,
                    obscure: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),

                  // ── Mot de passe oublié ─────────────────────────
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _showMessage(
                        'Instructions envoyées par email',
                        Color(0xFF1A4B7A),
                      ),
                      child: Text(
                        'Mot de passe oublié ?',
                        style: TextStyle(
                          color: Color(0xFF0D1F3C), // Retour à la couleur foncée
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 6),

                  // ── Bouton SE CONNECTER ─────────────────────────
                  _isLoading
                      ? CircularProgressIndicator(color: Color(0xFF2E7D32))
                      : SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF3CB043),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 3,
                            ),
                            child: Text(
                              'SE CONNECTER',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),

                  SizedBox(height: 24),

                  // ── OU CONNECTEZ-VOUS AVEC ──────────────────────
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade400)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'OU CONNECTEZ-VOUS AVEC',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade400)),
                    ],
                  ),

                  SizedBox(height: 16),

                  // ── Icônes sociales ─────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton(
                        icon: Icons.apple,
                        color: Colors.black,
                        onTap: () => _showMessage(
                            'Apple Sign In bientôt disponible', Colors.black),
                      ),
                      SizedBox(width: 20),
                      _buildSocialButton(
                        letter: 'G',
                        letterColor: Color(0xFFDB4437),
                        onTap: () => _showMessage(
                            'Google Sign In bientôt disponible',
                            Color(0xFFDB4437)),
                      ),
                      SizedBox(width: 20),
                      _buildSocialButton(
                        letter: 'in',
                        letterColor: Color(0xFF0077B5),
                        bgColor: Color(0xFF0077B5),
                        letterColorOverride: Colors.white,
                        onTap: () => _showMessage(
                            'LinkedIn Sign In bientôt disponible',
                            Color(0xFF0077B5)),
                      ),
                    ],
                  ),

                  SizedBox(height: 24),

                  // ── Créer un compte ─────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Pas encore de compte ? ",
                        style: TextStyle(
                            color: Colors.grey.shade700, fontSize: 13),
                      ),
                      GestureDetector(
                        onTap: () => _showMessage(
                          'Fonctionnalité bientôt disponible',
                          Color(0xFF1A4B7A),
                        ),
                        child: Text(
                          "S'inscrire",
                          style: TextStyle(
                            color: Color(0xFF0D1F3C),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscure,
        style: TextStyle(fontSize: 15, color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: Icon(prefixIcon, color: Colors.grey.shade500, size: 20),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Color(0xFF1A4B7A), width: 1.5),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    IconData? icon,
    String? letter,
    Color? letterColor,
    Color? color,
    Color? bgColor,
    Color? letterColorOverride,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: bgColor ?? Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
          border:
              bgColor == null ? Border.all(color: Colors.grey.shade200) : null,
        ),
        child: Center(
          child: icon != null
              ? Icon(icon,
                  color: letterColorOverride ?? color ?? Colors.black, size: 26)
              : Text(
                  letter!,
                  style: TextStyle(
                    color: letterColorOverride ?? letterColor ?? Colors.black,
                    fontSize: letter.length == 1 ? 22 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}