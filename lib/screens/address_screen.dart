import 'package:flutter/material.dart';
import 'dart:math';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final Color themeColor = const Color(0xFFD35400);

  final List<Map<String, dynamic>> _addresses = [
    {
      "id": "1",
      "label": "Rumah",
      "isDefault": true,
      "name": "Riyan Nurhidayat",
      "phone": "0812-3456-7890",
      "address": "Jl. Pegangsaan Timur No. 56, RT.01/RW.01, Cikini, Kec. Menteng, Kota Jakarta Pusat, DKI Jakarta 10320",
      "latitude": -6.1982,
      "longitude": 106.8424
    },
    {
      "id": "2",
      "label": "Kantor",
      "isDefault": false,
      "name": "Riyan Nurhidayat (Gowes Store)",
      "phone": "0898-7654-3210",
      "address": "Gedung Cyber 2 Lantai 18, Jl. H. R. Rasuna Said No.X-5, Kuningan Timur, Kec. Setiabudi, Kota Jakarta Selatan, DKI Jakarta 12950",
      "latitude": -6.2238,
      "longitude": 106.8302
    }
  ];

  void _addNewAddress(String label, String name, String phone, String address, double lat, double lng) {
    setState(() {
      _addresses.add({
        "id": DateTime.now().toString(),
        "label": label,
        "isDefault": _addresses.isEmpty,
        "name": name,
        "phone": phone,
        "address": address,
        "latitude": lat,
        "longitude": lng
      });
    });
  }

  void _setAsDefault(String id) {
    setState(() {
      for (var addr in _addresses) {
        addr["isDefault"] = addr["id"] == id;
      }
    });
  }

  void _deleteAddress(String id) {
    setState(() {
      _addresses.removeWhere((addr) => addr["id"] == id);
    });
  }

  void _showAddAddressSheet() {
    final formKey = GlobalKey<FormState>();
    final labelCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final addressCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        double currentLat = -6.175392;
        double currentLng = 106.827153;
        final mapSearchCtrl = TextEditingController();

        return StatefulBuilder(
          builder: (context, setModalState) {
            void _onMapSearch() {
              final query = mapSearchCtrl.text.trim().toLowerCase();
              if (query.isEmpty) return;
              
              double newLat = currentLat;
              double newLng = currentLng;
              String resolvedAddress = "";

              if (query.contains("cikini")) {
                newLat = -6.1982;
                newLng = 106.8424;
                resolvedAddress = "Jl. Cikini Raya, Cikini, Kec. Menteng, Kota Jakarta Pusat, DKI Jakarta 10330";
              } else if (query.contains("kuningan")) {
                newLat = -6.2238;
                newLng = 106.8302;
                resolvedAddress = "Jl. H. R. Rasuna Said, Kuningan Timur, Kec. Setiabudi, Kota Jakarta Selatan, DKI Jakarta 12950";
              } else if (query.contains("menteng")) {
                newLat = -6.2012;
                newLng = 106.8294;
                resolvedAddress = "Jl. Menteng Raya, Kec. Menteng, Kota Jakarta Pusat, DKI Jakarta 10310";
              } else if (query.contains("monas") || query.contains("gambir")) {
                newLat = -6.175392;
                newLng = 106.827153;
                resolvedAddress = "Jl. Medan Merdeka Barat, Gambir, Kec. Gambir, Kota Jakarta Pusat, DKI Jakarta 10110";
              } else {
                final r = Random();
                newLat = -6.175392 + (r.nextDouble() - 0.5) * 0.05;
                newLng = 106.827153 + (r.nextDouble() - 0.5) * 0.05;
                resolvedAddress = "Hasil pencarian Google Maps untuk: ${mapSearchCtrl.text}";
              }

              setModalState(() {
                currentLat = newLat;
                currentLng = newLng;
                if (resolvedAddress.isNotEmpty) {
                  addressCtrl.text = resolvedAddress;
                }
              });
            }

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
                        const SizedBox(height: 20),
                        const Text(
                          "Tambah Alamat Baru",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
                        ),
                        const SizedBox(height: 16),
                        // --- Google Maps Locator Block ---
                        const Text(
                          "Google Maps Pinpoint",
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: mapSearchCtrl,
                                decoration: const InputDecoration(
                                  hintText: "Cari lokasi di Google Maps...",
                                  prefixIcon: Icon(Icons.search, size: 20),
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                textInputAction: TextInputAction.search,
                                onFieldSubmitted: (_) => _onMapSearch(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _onMapSearch,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2C3E50),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text("Cari", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                            color: Colors.grey.shade100,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              children: [
                                Image.network(
                                  "https://static-maps.yandex.ru/1.x/?ll=$currentLng,$currentLat&z=15&l=map&size=450,200",
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Icon(Icons.map_outlined, color: Colors.grey, size: 48),
                                    );
                                  },
                                ),
                                const Center(
                                  child: Icon(
                                    Icons.location_pin,
                                    color: Colors.red,
                                    size: 36,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Koordinat: ${currentLat.toStringAsFixed(6)}, ${currentLng.toStringAsFixed(6)}",
                          style: const TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: labelCtrl,
                          decoration: const InputDecoration(
                            labelText: "Label Alamat (cth: Rumah, Kantor, Kost)",
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => value == null || value.isEmpty ? "Label wajib diisi" : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: nameCtrl,
                          decoration: const InputDecoration(
                            labelText: "Nama Penerima",
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => value == null || value.isEmpty ? "Nama wajib diisi" : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: phoneCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: "Nomor Telepon",
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => value == null || value.isEmpty ? "Nomor telepon wajib diisi" : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: addressCtrl,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: "Alamat Lengkap",
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                          validator: (value) => value == null || value.isEmpty ? "Alamat lengkap wajib diisi" : null,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              _addNewAddress(
                                labelCtrl.text,
                                nameCtrl.text,
                                phoneCtrl.text,
                                addressCtrl.text,
                                currentLat,
                                currentLng,
                              );
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Alamat berhasil ditambahkan!")),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeColor,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Simpan Alamat", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
          "Alamat Saya",
          style: TextStyle(color: Color(0xFF2C3E50), fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: _addresses.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text("Belum ada alamat pengiriman", style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _addresses.length,
              itemBuilder: (context, index) {
                final addr = _addresses[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: addr["isDefault"] ? themeColor : Colors.grey.shade200,
                      width: addr["isDefault"] ? 1.5 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  addr["label"],
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF2C3E50)),
                                ),
                                const SizedBox(width: 8),
                                if (addr["isDefault"])
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: themeColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      "Utama",
                                      style: TextStyle(color: themeColor, fontSize: 9, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                              ],
                            ),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == "default") {
                                  _setAsDefault(addr["id"]);
                                } else if (value == "delete") {
                                  _deleteAddress(addr["id"]);
                                }
                              },
                              icon: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
                              itemBuilder: (context) => [
                                if (!addr["isDefault"])
                                  const PopupMenuItem(
                                    value: "default",
                                    child: Text("Jadikan Utama"),
                                  ),
                                const PopupMenuItem(
                                  value: "delete",
                                  child: Text("Hapus Alamat", style: TextStyle(color: Colors.redAccent)),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          addr["name"],
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF2C3E50)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          addr["phone"],
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          addr["address"],
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.4),
                        ),
                        if (addr["latitude"] != null && addr["longitude"] != null) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  "https://static-maps.yandex.ru/1.x/?ll=${addr["longitude"]},${addr["latitude"]}&z=14&l=map&size=100,60",
                                  width: 100,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const SizedBox(),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Google Maps Pinpoint",
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "Lat: ${addr["latitude"]}, Lng: ${addr["longitude"]}",
                                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: _showAddAddressSheet,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              "Tambah Alamat Baru",
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
