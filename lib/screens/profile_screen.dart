import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gowes_store/providers/auth_provider.dart';
import 'package:gowes_store/screens/login_screen.dart';
import 'package:gowes_store/screens/address_screen.dart';
import 'package:gowes_store/screens/payment_methods_screen.dart';
import 'package:gowes_store/screens/security_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _base64Image;
  final Color themeColor = const Color(0xFFD35400);

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;
    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _base64Image = prefs.getString('profile_image_${user.id}');
      });
    }
  }

  Future<void> _pickProfileImage() async {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;
    if (user == null) return;

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 256,
        maxHeight: 256,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64String = base64Encode(bytes);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_image_${user.id}', base64String);

        setState(() {
          _base64Image = base64String;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Foto profil berhasil diperbarui!")),
          );
        }
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal mengambil gambar: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Profil Saya",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
        ),
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Oval profile header panel
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Orange background shape
                        Container(
                          width: 280,
                          height: 180,
                          decoration: BoxDecoration(
                            color: themeColor,
                            borderRadius: const BorderRadius.all(Radius.elliptical(280, 180)),
                          ),
                        ),
                        // Inner content
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: _pickProfileImage,
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 40,
                                    backgroundColor: Colors.white,
                                    child: CircleAvatar(
                                      radius: 36,
                                      backgroundColor: Colors.grey.shade200,
                                      backgroundImage: _base64Image != null
                                          ? MemoryImage(base64Decode(_base64Image!))
                                          : const NetworkImage(
                                              "https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=256&auto=format&fit=crop",
                                            ) as ImageProvider,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.camera_alt,
                                        size: 14,
                                        color: themeColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              user.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),



                  // Account Settings Panel
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "PENGATURAN AKUN",
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade600, letterSpacing: 1.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: Column(
                        children: [
                          _buildSettingsTile(
                            icon: Icons.location_on_outlined,
                            title: "Alamat Saya",
                            subtitle: "Kelola alamat pengiriman sepeda",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const AddressScreen()),
                              );
                            },
                          ),
                          Divider(height: 1, color: Colors.grey.shade100),
                          _buildSettingsTile(
                            icon: Icons.credit_card_outlined,
                            title: "Metode Pembayaran",
                            subtitle: "Kartu Kredit, E-Wallet, Cicilan",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const PaymentMethodsScreen()),
                              );
                            },
                          ),
                          Divider(height: 1, color: Colors.grey.shade100),
                          _buildSettingsTile(
                            icon: Icons.security_outlined,
                            title: "Keamanan",
                            subtitle: "Kata sandi & Autentikasi 2FA",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const SecurityScreen()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Logout Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await authProvider.logout();
                        if (context.mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                            (route) => false,
                          );
                        }
                      },
                      icon: const Icon(Icons.logout, color: Colors.redAccent, size: 18),
                      label: const Text(
                        "LOGOUT",
                        style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.0),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: Colors.redAccent, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Version details
                  const Text(
                    "GowesStore v2.4.8",
                    style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                  const Text(
                    "Dibuat untuk performa tanpa batas.",
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF2C3E50)),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
      onTap: onTap,
    );
  }
}
