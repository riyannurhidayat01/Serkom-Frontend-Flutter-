import 'package:flutter/material.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final Color themeColor = const Color(0xFFD35400);

  bool _is2faEnabled = false;
  bool _obscureOldPass = true;
  bool _obscureNewPass = true;
  bool _obscureConfirmPass = true;

  final _formKey = GlobalKey<FormState>();
  final _oldPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  final List<Map<String, dynamic>> _activeSessions = [
    {
      "device": "Chrome Browser (Windows 11)",
      "location": "Jakarta, Indonesia (Sesi Ini)",
      "time": "Aktif sekarang",
      "icon": Icons.computer_outlined,
      "isCurrent": true
    },
    {
      "device": "Samsung Galaxy S21",
      "location": "Bandung, Indonesia",
      "time": "Aktif 2 jam yang lalu",
      "icon": Icons.phone_android_outlined,
      "isCurrent": false
    }
  ];

  void _showChangePasswordSuccess() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text("Berhasil"),
            ],
          ),
          content: const Text("Kata sandi akun Anda telah berhasil diperbarui."),
          actions: [
            TextButton(
              onPressed: () {
                _oldPassCtrl.clear();
                _newPassCtrl.clear();
                _confirmPassCtrl.clear();
                Navigator.pop(context);
              },
              child: Text("OK", style: TextStyle(color: themeColor, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _terminateAllOtherSessions() {
    setState(() {
      _activeSessions.removeWhere((session) => !session["isCurrent"]);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Berhasil keluar dari semua perangkat lain!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Color(0xFF2C3E50)),
        title: const Text(
          "Keamanan Akun",
          style: TextStyle(color: Color(0xFF2C3E50), fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section: Two-Factor Authentication
            const Text(
              "AUTENTIKASI 2-LANGKAH",
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.0),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: SwitchListTile(
                activeThumbColor: themeColor,
                title: const Text(
                  "Autentikasi Dua Faktor (2FA)",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF2C3E50)),
                ),
                subtitle: const Text(
                  "Amankan akun Anda dengan verifikasi tambahan ketika login di perangkat baru.",
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
                value: _is2faEnabled,
                onChanged: (val) {
                  setState(() {
                    _is2faEnabled = val;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        val ? "2FA diaktifkan!" : "2FA dinonaktifkan!",
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),

            // Section: Change Password
            const Text(
              "UBAH KATA SANDI",
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.0),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100),
              ),
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _oldPassCtrl,
                      obscureText: _obscureOldPass,
                      decoration: InputDecoration(
                        labelText: "Kata Sandi Lama",
                        suffixIcon: IconButton(
                          icon: Icon(_obscureOldPass ? Icons.visibility_off : Icons.visibility, size: 20),
                          onPressed: () => setState(() => _obscureOldPass = !_obscureOldPass),
                        ),
                      ),
                      validator: (value) => value == null || value.isEmpty ? "Kata sandi lama wajib diisi" : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _newPassCtrl,
                      obscureText: _obscureNewPass,
                      decoration: InputDecoration(
                        labelText: "Kata Sandi Baru",
                        suffixIcon: IconButton(
                          icon: Icon(_obscureNewPass ? Icons.visibility_off : Icons.visibility, size: 20),
                          onPressed: () => setState(() => _obscureNewPass = !_obscureNewPass),
                        ),
                      ),
                      validator: (value) =>
                          value == null || value.length < 6 ? "Kata sandi baru minimal 6 karakter" : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _confirmPassCtrl,
                      obscureText: _obscureConfirmPass,
                      decoration: InputDecoration(
                        labelText: "Konfirmasi Kata Sandi Baru",
                        suffixIcon: IconButton(
                          icon: Icon(_obscureConfirmPass ? Icons.visibility_off : Icons.visibility, size: 20),
                          onPressed: () => setState(() => _obscureConfirmPass = !_obscureConfirmPass),
                        ),
                      ),
                      validator: (value) {
                        if (value != _newPassCtrl.text) {
                          return "Konfirmasi kata sandi tidak cocok";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _showChangePasswordSuccess();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                        minimumSize: const Size(double.infinity, 45),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text(
                        "Simpan Sandi Baru",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Section: Active Sessions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "SESI PERANGKAT AKTIF",
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.0),
                ),
                if (_activeSessions.length > 1)
                  GestureDetector(
                    onTap: _terminateAllOtherSessions,
                    child: Text(
                      "Keluarkan Perangkat Lain",
                      style: TextStyle(color: themeColor, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _activeSessions.length,
                separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade100),
                itemBuilder: (context, index) {
                  final session = _activeSessions[index];
                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(session["icon"], color: const Color(0xFF2C3E50)),
                    ),
                    title: Text(
                      session["device"],
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2C3E50), fontSize: 13),
                    ),
                    subtitle: Text(
                      "${session["location"]} • ${session["time"]}",
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
