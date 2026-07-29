import 'package:flutter/material.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final Color themeColor = const Color(0xFFD35400);

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      "id": "1",
      "type": "card",
      "brand": "Visa",
      "holder": "RIYAN NURHIDAYAT",
      "number": "**** **** **** 4892",
      "expiry": "12/28",
      "bgColor": [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)]
    },
    {
      "id": "2",
      "type": "wallet",
      "name": "GoPay",
      "connected": true,
      "phone": "0812-****-7890",
      "icon": Icons.wallet_outlined,
      "bgColor": Color(0xFFE8F5E9),
      "accentColor": Color(0xFF2E7D32)
    },
    {
      "id": "3",
      "type": "wallet",
      "name": "OVO",
      "connected": true,
      "phone": "0812-****-7890",
      "icon": Icons.wallet_outlined,
      "bgColor": Color(0xFFF3E5F5),
      "accentColor": Color(0xFF7B1FA2)
    }
  ];

  void _addNewCard(String holder, String number, String expiry) {
    setState(() {
      _paymentMethods.add({
        "id": DateTime.now().toString(),
        "type": "card",
        "brand": "Mastercard",
        "holder": holder.toUpperCase(),
        "number": "**** **** **** ${number.substring(number.length - 4)}",
        "expiry": expiry,
        "bgColor": [Color(0xFF8E2DE2), Color(0xFF4A00E0)]
      });
    });
  }

  void _addNewWallet(String name, String phone) {
    Color bg = Colors.grey.shade100;
    Color accent = Colors.grey;

    if (name.toLowerCase() == "dana") {
      bg = const Color(0xFFE3F2FD);
      accent = const Color(0xFF1565C0);
    } else if (name.toLowerCase() == "shopeepay") {
      bg = const Color(0xFFFBE9E7);
      accent = const Color(0xFFD84315);
    }

    setState(() {
      _paymentMethods.add({
        "id": DateTime.now().toString(),
        "type": "wallet",
        "name": name,
        "connected": true,
        "phone": phone.replaceRange(4, phone.length - 4, "****"),
        "icon": Icons.account_balance_wallet_outlined,
        "bgColor": bg,
        "accentColor": accent
      });
    });
  }

  void _deleteMethod(String id) {
    setState(() {
      _paymentMethods.removeWhere((method) => method["id"] == id);
    });
  }

  void _showAddMethodSheet() {
    int selectedTab = 0; // 0 for Card, 1 for Wallet
    final formKey = GlobalKey<FormState>();
    final cardHolderCtrl = TextEditingController();
    final cardNumberCtrl = TextEditingController();
    final cardExpiryCtrl = TextEditingController();
    final cardCvvCtrl = TextEditingController();

    final walletPhoneCtrl = TextEditingController();
    String walletType = "DANA";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ChoiceChip(
                                label: const Center(child: Text("Kartu Debit/Kredit")),
                                selected: selectedTab == 0,
                                onSelected: (val) {
                                  if (val) setModalState(() => selectedTab = 0);
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ChoiceChip(
                                label: const Center(child: Text("E-Wallet")),
                                selected: selectedTab == 1,
                                onSelected: (val) {
                                  if (val) setModalState(() => selectedTab = 1);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        if (selectedTab == 0) ...[
                          TextFormField(
                            controller: cardHolderCtrl,
                            decoration: const InputDecoration(
                              labelText: "Nama Pemegang Kartu",
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) => value == null || value.isEmpty ? "Wajib diisi" : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: cardNumberCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "Nomor Kartu",
                              border: OutlineInputBorder(),
                              hintText: "16 digit angka",
                            ),
                            validator: (value) => value == null || value.length < 16 ? "Nomor kartu tidak valid" : null,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: cardExpiryCtrl,
                                  decoration: const InputDecoration(
                                    labelText: "Masa Berlaku (MM/YY)",
                                    border: OutlineInputBorder(),
                                    hintText: "12/28",
                                  ),
                                  validator: (value) => value == null || value.isEmpty ? "Wajib diisi" : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: cardCvvCtrl,
                                  keyboardType: TextInputType.number,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                    labelText: "CVV",
                                    border: OutlineInputBorder(),
                                    hintText: "3 digit",
                                  ),
                                  validator: (value) => value == null || value.length < 3 ? "Tidak valid" : null,
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          DropdownButtonFormField<String>(
                            value: walletType,
                            decoration: const InputDecoration(
                              labelText: "Pilih E-Wallet",
                              border: OutlineInputBorder(),
                            ),
                            items: ["DANA", "ShopeePay"].map((String val) {
                              return DropdownMenuItem<String>(
                                value: val,
                                child: Text(val),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setModalState(() => walletType = val);
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: walletPhoneCtrl,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: "Nomor HP Terdaftar",
                              border: OutlineInputBorder(),
                              hintText: "0812xxxxxx",
                            ),
                            validator: (value) => value == null || value.length < 10 ? "Nomor HP tidak valid" : null,
                          ),
                        ],
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              if (selectedTab == 0) {
                                _addNewCard(
                                  cardHolderCtrl.text,
                                  cardNumberCtrl.text,
                                  cardExpiryCtrl.text,
                                );
                              } else {
                                _addNewWallet(
                                  walletType,
                                  walletPhoneCtrl.text,
                                );
                              }
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Metode pembayaran berhasil ditambahkan!")),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeColor,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Simpan Metode Pembayaran", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
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
          "Metode Pembayaran",
          style: TextStyle(color: Color(0xFF2C3E50), fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _paymentMethods.length,
        itemBuilder: (context, index) {
          final method = _paymentMethods[index];
          if (method["type"] == "card") {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: method["bgColor"],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (method["bgColor"] as List<Color>).first.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Decorative circle on card
                  Positioned(
                    right: -50,
                    top: -50,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              method["brand"],
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
                            ),
                            GestureDetector(
                              onTap: () => _deleteMethod(method["id"]),
                              child: const Icon(Icons.delete_outline, color: Colors.white70),
                            ),
                          ],
                        ),
                        Text(
                          method["number"],
                          style: const TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 2.0, fontWeight: FontWeight.w500),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("NAMA PEMILIK", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 9)),
                                const SizedBox(height: 2),
                                Text(method["holder"], style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("BERLAKU S/D", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 9)),
                                const SizedBox(height: 2),
                                Text(method["expiry"], style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            // E-Wallet style
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.01),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: method["bgColor"],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(method["icon"], color: method["accentColor"]),
                ),
                title: Text(
                  method["name"],
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2C3E50), fontSize: 14),
                ),
                subtitle: Text(
                  method["phone"],
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: (method["accentColor"] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Tersambung",
                        style: TextStyle(color: method["accentColor"], fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.link_off_outlined, color: Colors.grey, size: 20),
                      onPressed: () => _deleteMethod(method["id"]),
                      tooltip: "Putuskan sambungan",
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: _showAddMethodSheet,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              "Tambah Metode Pembayaran",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: themeColor,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ),
    );
  }
}
