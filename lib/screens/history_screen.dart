import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:gowes_store/models/transaction.dart';
import 'package:gowes_store/providers/transaction_provider.dart';
import 'package:gowes_store/services/api_service.dart';
import 'package:gowes_store/providers/cart_provider.dart';
import 'package:gowes_store/models/product.dart';
import 'package:gowes_store/screens/main_layout.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  String _selectedTab = "Semua";

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
      Provider.of<TransactionProvider>(context, listen: false).fetchTransactionHistory()
    );
  }

  @override
  Widget build(BuildContext context) {
    final txProvider = context.watch<TransactionProvider>();
    final themeColor = const Color(0xFFD35400);

    // Filter transactions list based on active tab selection
    List<Transaction> filteredTransactions = txProvider.transactions;
    if (_selectedTab != "Semua") {
      filteredTransactions = txProvider.transactions
          .where((t) => t.status.toLowerCase() == _selectedTab.toLowerCase())
          .toList();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Riwayat Pesanan",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
        ),
      ),
      body: Column(
        children: [
          // Filter Tabs Horizontal List
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Riwayat Transaksi",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Pantau status pengiriman dan riwayat belanja sepeda Anda.",
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          
          // Custom Tab Row
          Container(
            height: 40,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildTabChip("Semua", themeColor),
                _buildTabChip("Selesai", themeColor),
                _buildTabChip("Dikirim", themeColor),
                _buildTabChip("Dibatalkan", themeColor),
              ],
            ),
          ),
          
          // List view
          Expanded(
            child: txProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredTransactions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.network(
                              "${ApiService.baseUrl}/static/images/empty_history.png",
                              height: 180,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.assignment_outlined, size: 60, color: Colors.grey.shade300);
                              },
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Tidak ada transaksi ${_selectedTab == 'Semua' ? '' : 'dengan status ' + _selectedTab}",
                              style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: filteredTransactions.length,
                        itemBuilder: (context, index) {
                          final tx = filteredTransactions[index];
                          final firstItem = tx.items.isNotEmpty ? tx.items[0] : null;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header: Order ID, Status, Date
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          tx.orderId,
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          tx.date,
                                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                    _buildStatusBadge(tx.status),
                                  ],
                                ),
                                const Divider(height: 20),
                                
                                // First Item Details
                                if (firstItem != null)
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          firstItem.imageUrl.startsWith("http")
                                              ? firstItem.imageUrl
                                              : "${ApiService.baseUrl}${firstItem.imageUrl}",
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Container(
                                            width: 60,
                                            height: 60,
                                            color: Colors.grey.shade100,
                                            child: const Icon(Icons.shopping_bag_outlined, color: Colors.grey),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              firstItem.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "${firstItem.quantity} unit x ${_formatter.format(firstItem.price)}",
                                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                
                                // Extra items count label
                                if (tx.items.length > 1)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      "+ ${tx.items.length - 1} produk lainnya",
                                      style: const TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                
                                const Divider(height: 20),
                                
                                // Bottom block: Total price and actions
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text("TOTAL BELANJA", style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 2),
                                        Text(
                                          _formatter.format(tx.totalAmount),
                                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: themeColor),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: _buildActionsForStatus(context, tx, themeColor),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabChip(String tabName, Color themeColor) {
    final isSelected = _selectedTab == tabName;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = tabName;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? themeColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? themeColor : Colors.grey.shade200),
        ),
        child: Text(
          tabName,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    
    switch (status.toLowerCase()) {
      case 'selesai':
        bg = Colors.green.shade50;
        fg = Colors.green.shade700;
        break;
      case 'dikirim':
        bg = Colors.blue.shade50;
        fg = Colors.blue.shade700;
        break;
      case 'dibatalkan':
        bg = Colors.red.shade50;
        fg = Colors.red.shade700;
        break;
      default:
        bg = Colors.grey.shade100;
        fg = Colors.grey.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: fg,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  List<Widget> _buildActionsForStatus(BuildContext context, Transaction tx, Color themeColor) {
    final textStyle = const TextStyle(fontSize: 11, fontWeight: FontWeight.bold);
    
    if (tx.status.toLowerCase() == 'selesai') {
      return [
        Row(
          children: [
            TextButton(
              onPressed: () => _showDetailSheet(context, tx),
              child: Text("Detail", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ),
            const SizedBox(width: 4),
            ElevatedButton(
              onPressed: () => _handleBeliLagi(context, tx),
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: Text("Beli Lagi", style: textStyle),
            ),
          ],
        )
      ];
    } else if (tx.status.toLowerCase() == 'dikirim') {
      return [
        Row(
          children: [
            TextButton(
              onPressed: () => _showDetailSheet(context, tx),
              child: Text("Detail", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ),
            const SizedBox(width: 4),
            ElevatedButton(
              onPressed: () {
                // Mock Lacak flow
                _showLacakSheet(context, tx, themeColor);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C3E50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: Text("Lacak", style: textStyle),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            OutlinedButton(
              onPressed: () async {
                final confirmed = await _showConfirmDialog(
                  context, 
                  "Batalkan Pesanan", 
                  "Apakah Anda yakin ingin membatalkan pesanan ini?"
                );
                if (confirmed && context.mounted) {
                  await Provider.of<TransactionProvider>(context, listen: false)
                      .updateTransactionStatus(tx.id, "Dibatalkan");
                }
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Batalkan Pesanan", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () async {
                final confirmed = await _showConfirmDialog(
                  context, 
                  "Pesanan Selesai", 
                  "Apakah Anda yakin pesanan sudah selesai diterima?"
                );
                if (confirmed && context.mounted) {
                  await Provider.of<TransactionProvider>(context, listen: false)
                      .updateTransactionStatus(tx.id, "Selesai");
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: const Text("Pesanan Selesai", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ],
        )
      ];
    } else {
      // Dibatalkan
      return [
        Row(
          children: [
            OutlinedButton(
              onPressed: () => _showDetailSheet(context, tx),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: Text("Detail", style: TextStyle(color: Colors.grey.shade700, fontSize: 11)),
            ),
          ],
        )
      ];
    }
  }

  Future<bool> _showConfirmDialog(BuildContext context, String title, String content) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Ya, Yakin", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<void> _handleBeliLagi(BuildContext context, Transaction tx) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      for (var item in tx.items) {
        final product = Product(
          id: item.productId,
          name: item.name,
          category: "",
          price: item.price,
          rating: 4.8,
          reviewsCount: 100,
          description: "",
          specifications: ProductSpecs(frame: "", gears: ""),
          imageUrl: item.imageUrl,
        );
        await cartProvider.addToCart(product, quantity: item.quantity);
      }

      if (context.mounted) {
        Navigator.of(context).pop(); // pop loading indicator
        
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainLayout(initialTab: 1)),
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // pop loading indicator
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan produk ke keranjang: $e')),
        );
      }
    }
  }

  void _showDetailSheet(BuildContext context, Transaction tx) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.85,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: 20),
                  Text("Detail Pesanan ${tx.orderId}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("Tanggal: ${tx.date}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const Divider(height: 30),
                  const Text("Produk", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 12),
                  ...tx.items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text("${item.name} (x${item.quantity})", style: const TextStyle(fontSize: 13))),
                        Text(_formatter.format(item.price * item.quantity), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  )),
                  const Divider(height: 30),
                  _buildDetailRow("Subtotal", _formatter.format(tx.subtotal)),
                  _buildDetailRow("Pengiriman", _formatter.format(tx.shipping)),
                  _buildDetailRow("Pajak (11%)", _formatter.format(tx.tax)),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total Pembayaran", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(_formatter.format(tx.totalAmount), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFD35400))),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showLacakSheet(BuildContext context, Transaction tx, Color themeColor) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Lacak Pengiriman - ${tx.orderId}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text("Kurir: J&T Cargo (Estimasi Besok)", style: TextStyle(fontSize: 12, color: Colors.grey)),
              const Divider(height: 24),
              _buildTrackingStep("Paket diserahkan ke kurir", "28 Jul 2026 - 10:15 WIB", true, false),
              _buildTrackingStep("Pesanan dikonfirmasi oleh GowesStore", "28 Jul 2026 - 09:30 WIB", true, true),
              _buildTrackingStep("Menunggu pembayaran diverifikasi", "28 Jul 2026 - 09:20 WIB", false, true),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(val, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildTrackingStep(String title, String subtitle, bool isActive, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(
              isActive ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isActive ? const Color(0xFFD35400) : Colors.grey,
              size: 20,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isActive ? const Color(0xFFD35400) : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 14, fontWeight: isActive ? FontWeight.bold : FontWeight.normal, color: isActive ? const Color(0xFF2C3E50) : Colors.grey)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}
