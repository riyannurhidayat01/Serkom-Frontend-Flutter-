import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gowes_store/providers/cart_provider.dart';
import 'package:gowes_store/screens/home_screen.dart';
import 'package:gowes_store/screens/cart_screen.dart';
import 'package:gowes_store/screens/history_screen.dart';
import 'package:gowes_store/screens/profile_screen.dart';

class MainLayout extends StatefulWidget {
  final int initialTab;
  const MainLayout({super.key, this.initialTab = 0});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late int _selectedIndex;

  final List<Widget> _pages = [
    const HomeScreen(),
    const CartScreen(),
    const HistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTab;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final themeColor = const Color(0xFFD35400);

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: themeColor,
          unselectedItemColor: Colors.grey.shade400,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          elevation: 0,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Badge(
                label: Text(cartProvider.itemCount.toString()),
                isLabelVisible: cartProvider.itemCount > 0,
                backgroundColor: themeColor,
                child: const Icon(Icons.shopping_bag_outlined),
              ),
              activeIcon: Badge(
                label: Text(cartProvider.itemCount.toString()),
                isLabelVisible: cartProvider.itemCount > 0,
                backgroundColor: themeColor,
                child: const Icon(Icons.shopping_bag),
              ),
              label: 'Cart',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history),
              label: 'History',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
