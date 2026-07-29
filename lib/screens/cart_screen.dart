import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:gowes_store/providers/cart_provider.dart';
import 'package:gowes_store/providers/transaction_provider.dart';
import 'package:gowes_store/screens/main_layout.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  final _promoController = TextEditingController();
  bool _promoApplied = false;
  double _discount = 0.0;

  String _selectedPaymentName = "Visa (**** 4892)";
  String _selectedPaymentType = "card";

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      "name": "Visa (**** 4892)",
      "type": "card",
      "icon": Icons.credit_card,
    },
    {
      "name": "GoPay (0812-****-7890)",
      "type": "wallet",
      "icon": Icons.wallet_outlined,
    },
    {
      "name": "OVO (0812-****-7890)",
      "type": "wallet",
      "icon": Icons.wallet_outlined,
    },
  ];

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  void _applyPromo() {
    if (_promoController.text.trim().toUpperCase() == "GOWESSALE") {
      setState(() {
        _promoApplied = true;
        _discount = 50000.0; // flat discount of 50K Rupiah
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Kode promo berhasil diterapkan! Potongan Rp 50.000.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Kode promo tidak valid.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _checkout(CartProvider cartProvider, TransactionProvider txProvider) async {
    if (cartProvider.cart == null || cartProvider.cart!.items.isEmpty) return;
    
    // Adjust total if promo applied
    final originalCart = cartProvider.cart!;
    final success = await txProvider.checkout(originalCart);
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Pesanan berhasil dibuat!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        // Clear cart provider state
        await cartProvider.clearCart();
        
        // Navigate to Order History Screen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainLayout(initialTab: 2)),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(txProvider.errorMessage ?? 'Gagal membuat pesanan.'),
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
    final cartProvider = context.watch<CartProvider>();
    final txProvider = context.watch<TransactionProvider>();
    final themeColor = const Color(0xFFD35400);

    final cartResponse = cartProvider.cart;
    final hasItems = cartResponse != null && cartResponse.items.isNotEmpty;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Keranjang Belanja",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
        ),
        actions: [
          if (hasItems)
            TextButton(
              onPressed: () => cartProvider.clearCart(),
              child: const Text("Hapus Semua", style: TextStyle(color: Colors.redAccent)),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: cartProvider.isLoading && cartResponse == null
          ? const Center(child: CircularProgressIndicator())
          : !hasItems
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      const Text(
                        "Keranjang Anda Kosong",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Tambahkan beberapa produk ke keranjang belanja Anda.",
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => const MainLayout(initialTab: 0)),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("BELANJA SEKARANG", style: TextStyle(color: Colors.white)),
                      )
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Total items subtitle
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "My Cart - ${cartProvider.itemCount} Items Added",
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                      ),
                    ),
                    // Items List
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: cartResponse.items.length,
                        itemBuilder: (context, index) {
                          final item = cartResponse.items[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.01),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  // Image
                                  Container(
                                    height: 80,
                                    width: 80,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3F3F5),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        item.product.imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            const Icon(Icons.directions_bike, color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Detail & controls
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.product.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
                                        ),
                                        Text(
                                          item.product.category,
                                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          _formatter.format(item.product.price),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: themeColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Quantity adjuster
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                        onPressed: () => cartProvider.removeFromCart(item.product.id),
                                      ),
                                      Row(
                                        children: [
                                          _buildQtyButton(
                                            icon: Icons.remove,
                                            onTap: () {
                                              if (item.quantity > 1) {
                                                cartProvider.updateQuantity(item.product.id, item.quantity - 1);
                                              } else {
                                                cartProvider.removeFromCart(item.product.id);
                                              }
                                            },
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                            child: Text(
                                              item.quantity.toString(),
                                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          _buildQtyButton(
                                            icon: Icons.add,
                                            onTap: () => cartProvider.updateQuantity(item.product.id, item.quantity + 1),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    // Order calculations
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, -3),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            "Order Summary",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
                          ),
                          const SizedBox(height: 8),
                          _buildSummaryRow("Subtotal", _formatter.format(cartResponse.subtotal)),
                          _buildSummaryRow("Estimated Shipping", _formatter.format(cartResponse.shipping)),
                          _buildSummaryRow("Tax (11%)", _formatter.format(cartResponse.tax)),
                          if (_promoApplied)
                            _buildSummaryRow("Discount", "- ${_formatter.format(_discount)}", isDiscount: true),
                          const Divider(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Total Amount",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
                              ),
                              Text(
                                _formatter.format(cartResponse.totalAmount - _discount),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: themeColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Promo Input Box
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F3F5),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: TextField(
                                    controller: _promoController,
                                    textCapitalization: TextCapitalization.characters,
                                    decoration: const InputDecoration(
                                      hintText: "Promo Code",
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      hintStyle: TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: _applyPromo,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2C3E50),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                ),
                                child: const Text("APPLY", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Payment Method Selection Section
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Metode Pembayaran",
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
                            ),
                          ),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: _selectPaymentMethod,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F3F5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon(_getSelectedPaymentIcon(), color: themeColor),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _selectedPaymentName,
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2C3E50)),
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Checkout Now Button
                          ElevatedButton(
                            onPressed: txProvider.isLoading ? null : () => _checkout(cartProvider, txProvider),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: themeColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: txProvider.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Text(
                                        "CHECKOUT NOW",
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(Icons.arrow_forward, size: 16),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: isDiscount ? Colors.green : const Color(0xFF2C3E50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 14, color: Colors.grey.shade700),
      ),
    );
  }

  void _selectPaymentMethod() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Pilih Metode Pembayaran",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
              ),
              const SizedBox(height: 16),
              ..._paymentMethods.map((method) => ListTile(
                leading: Icon(method["icon"] as IconData, color: const Color(0xFFD35400)),
                title: Text(method["name"] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
                trailing: _selectedPaymentName == method["name"]
                    ? const Icon(Icons.check_circle, color: Color(0xFFD35400))
                    : null,
                onTap: () {
                  setState(() {
                    _selectedPaymentName = method["name"] as String;
                    _selectedPaymentType = method["type"] as String;
                  });
                  Navigator.pop(context);
                },
              )),
            ],
          ),
        );
      },
    );
  }

  IconData _getSelectedPaymentIcon() {
    final method = _paymentMethods.firstWhere((m) => m["name"] == _selectedPaymentName, orElse: () => _paymentMethods[0]);
    return method["icon"] as IconData;
  }
}
