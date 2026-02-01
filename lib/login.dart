import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'register.dart';
import 'home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();

    // Listener: kalau login Google / manual berhasil → ke Home
    supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    });
  }

  // ================= LOGIN MANUAL =================
  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // ===== VALIDASI =====
    if (email.isEmpty || password.isEmpty) {
      _showMessage("Email dan password wajib diisi");
      return;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      _showMessage("Format email tidak valid");
      return;
    }

    if (password.length < 6) {
      _showMessage("Password minimal 6 karakter");
      return;
    }

    setState(() => _loading = true);

    try {
      await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      _showMessage(e.message);
    } catch (_) {
      _showMessage("Login gagal, coba lagi");
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  // ================= LOGIN GOOGLE =================
  Future<void> _loginWithGoogle() async {
    try {
      await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.flutter://login-callback',
      );
    } catch (e) {
      _showMessage("Google Sign-In gagal");
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              Image.asset(
                "assets/images/logo.png",
                width: 160,
                height: 160,
              ),
              const SizedBox(height: 30),
              _inputField("Email", controller: _emailController),
              const SizedBox(height: 12),
              _inputField(
                "Kata Sandi",
                controller: _passwordController,
                isPassword: true,
                obscure: _obscurePassword,
                onToggle: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              const SizedBox(height: 20),
              _actionButton(
                text: "Masuk",
                isLoading: _loading,
                onPressed: _login,
              ),
              const SizedBox(height: 12),
              _actionButton(
                text: "Daftar",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RegisterScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 15),
              const Text("Atau",
                  style: TextStyle(fontSize: 14, color: Colors.black)),
              const SizedBox(height: 15),
              _googleButton(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  // ================= GOOGLE BUTTON =================
  Widget _googleButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0089B2),
          foregroundColor: Colors.black,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: Colors.black),
          ),
        ),
        onPressed: _loginWithGoogle,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/google_logo.png",
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 12),
            const Text(
              "Masuk dengan Google",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= INPUT FIELD =================
  Widget _inputField(
    String hint, {
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggle,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? obscure : false,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.black, width: 1.5),
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: onToggle,
              )
            : null,
      ),
    );
  }

  // ================= BUTTON =================
  Widget _actionButton({
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0089B2),
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: Colors.black),
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.black,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }
}
