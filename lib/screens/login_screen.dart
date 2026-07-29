import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gowes_store/main.dart';
import 'package:gowes_store/providers/auth_provider.dart';
import 'package:gowes_store/screens/register_screen.dart';
import 'package:gowes_store/screens/main_layout.dart';
import 'package:gowes_store/services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (mounted) {
      if (success) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainLayout()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Gagal masuk. Silakan coba lagi.'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  void _showGoogleEmailChooser() {
    final mockAccounts = [
      {
        "name": "RIYAN",
        "email": "riyannurhidayat297@gmail.com",
        "avatar": "R",
        "avatarColor": Colors.blue.shade700
      },
      {
        "name": "HIDAYAT",
        "email": "riyannewskull@gmail.com",
        "avatar": "H",
        "avatarColor": Colors.green.shade700
      },
      {
        "name": "Gowes Rider",
        "email": "gowesrider@gmail.com",
        "avatar": "G",
        "avatarColor": Colors.purple.shade700
      }
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Google Branding Header
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "G",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    Text(
                      "o",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const Text(
                      "o",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                    const Text(
                      "g",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const Text(
                      "l",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      "e",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Pilih akun",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "untuk melanjutkan ke GowesStore",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              
              // Account List
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: mockAccounts.length,
                  itemBuilder: (context, index) {
                    final acc = mockAccounts[index];
                    return Column(
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                          leading: CircleAvatar(
                            backgroundColor: acc["avatarColor"] as Color,
                            foregroundColor: Colors.white,
                            radius: 18,
                            child: Text(
                              acc["avatar"] as String,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                          title: Text(
                            acc["name"] as String,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          subtitle: Text(
                            acc["email"] as String,
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                          ),
                          onTap: () {
                            Navigator.pop(context); // Close chooser sheet
                            _executeGoogleLogin(
                              acc["name"] as String,
                              acc["email"] as String,
                            );
                          },
                        ),
                        if (index < mockAccounts.length - 1)
                          const Divider(height: 1, indent: 48),
                      ],
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 4),
              const Divider(),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                leading: CircleAvatar(
                  backgroundColor: Colors.grey.shade100,
                  radius: 18,
                  child: const Icon(Icons.add, color: Color(0xFF2C3E50), size: 18),
                ),
                title: const Text(
                  "Gunakan akun lain",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context); // Close chooser sheet
                  _showCustomEmailInputDialog();
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _showCustomEmailInputDialog() {
    final emailController = TextEditingController();
    final localFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Gunakan Akun Lain", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: Form(
            key: localFormKey,
            child: TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: "nama@gmail.com",
                labelText: "Email Google (Gmail)",
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Email tidak boleh kosong";
                }
                if (!value.trim().endsWith("@gmail.com")) {
                  return "Harus menggunakan akun Gmail (@gmail.com)";
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("BATAL", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                if (!localFormKey.currentState!.validate()) return;
                final email = emailController.text.trim();
                Navigator.pop(context); // Close dialog
                
                // Get name from email local part
                final name = email.split('@')[0].toUpperCase();
                _executeGoogleLogin(name, email);
              },
              child: const Text("LANJUT", style: TextStyle(color: Color(0xFFD35400), fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _executeGoogleLogin(String name, String email) async {
    // Show a loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    String finalEmail = email;
    String finalName = name;
    final password = "googlepassword123";

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    bool success = false;

    // Check if real Firebase Authentication is initialized and configured
    if (FirebaseConfig.isFirebaseInitialized) {
      try {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser != null) {
          final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
          final fb.AuthCredential credential = fb.GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
          
          final fb.UserCredential userCredential = 
              await fb.FirebaseAuth.instance.signInWithCredential(credential);
          final fb.User? fbUser = userCredential.user;
          if (fbUser != null) {
            finalEmail = fbUser.email ?? email;
            finalName = fbUser.displayName ?? name;
          }
        }
      } catch (e) {
        debugPrint("Real Firebase Auth failed: $e. Falling back to mock authentication.");
      }
    }

    // Authenticate with the backend
    success = await authProvider.login(finalEmail, password);

    if (!success) {
      // User doesn't exist, try to register
      try {
        final regResponse = await ApiService.register(finalName, finalEmail, password);
        if (regResponse.statusCode == 200 || regResponse.statusCode == 201) {
          // Registration succeeded, now login
          success = await authProvider.login(finalEmail, password);
        }
      } catch (_) {
        // Handle error silently
      }
    }

    if (mounted) {
      Navigator.of(context).pop(); // Dismiss loading dialog

      if (success) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainLayout()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Masuk dengan Google sebagai $finalEmail berhasil!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Gagal masuk dengan Google.'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final themeColor = const Color(0xFFD35400); // GowesStore Orange

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30),
              // Brand Logo
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: themeColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.directions_bike_rounded,
                        size: 60,
                        color: themeColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "GowesStore",
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: themeColor,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "PERFORMANCE GEAR",
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3.0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              // Greeting Text
              const Text(
                "Selamat Datang Kembali",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                "Masuk untuk melanjutkan perjalanan Anda.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              // Login Form
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Email Field
                    const Text(
                      "EMAIL",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty || !value.contains('@')) {
                          return 'Masukkan alamat email yang valid';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: "rider@example.com",
                        prefixIcon: const Icon(Icons.email_outlined),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: themeColor, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Password Field
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "PASSWORD",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            letterSpacing: 1.0,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Dummy forget password
                          },
                          child: Text(
                            "Lupa Password?",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: themeColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      validator: (value) {
                        if (value == null || value.isEmpty || value.length < 6) {
                          return 'Password minimal 6 karakter';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: "••••••••",
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: themeColor, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // Submit Button
              ElevatedButton(
                onPressed: authProvider.isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: authProvider.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            "MASUK",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.bolt, size: 18),
                        ],
                      ),
              ),
              const SizedBox(height: 30),
              // Social Login divider
              Row(
                children: const [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "ATAU MASUK DENGAN",
                      style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 20),
              // Social logins
              OutlinedButton.icon(
                onPressed: _showGoogleEmailChooser,
                icon: const Icon(Icons.g_mobiledata_rounded, color: Colors.red, size: 32),
                label: const Text(
                  "Masuk dengan Google",
                  style: TextStyle(
                    color: Color(0xFF2C3E50),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              const SizedBox(height: 40),
              // Register Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Belum punya akun? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const RegisterScreen()),
                      );
                    },
                    child: Text(
                      "Daftar di sini",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: themeColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
