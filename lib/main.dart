import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gowes_store/providers/auth_provider.dart';
import 'package:gowes_store/providers/cart_provider.dart';
import 'package:gowes_store/providers/product_provider.dart';
import 'package:gowes_store/providers/transaction_provider.dart';
import 'package:gowes_store/screens/login_screen.dart';
import 'package:gowes_store/screens/main_layout.dart';
import 'package:gowes_store/screens/onboarding_screen.dart';

class FirebaseConfig {
  static bool isFirebaseInitialized = false;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    FirebaseConfig.isFirebaseInitialized = true;
  } catch (e) {
    debugPrint("Firebase initialization skipped/failed: $e");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xFFD35400); // GowesStore Orange

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, CartProvider>(
          create: (_) => CartProvider(),
          update: (_, auth, cart) => cart!..updateToken(auth.token),
        ),
        ChangeNotifierProxyProvider<AuthProvider, TransactionProvider>(
          create: (_) => TransactionProvider(),
          update: (_, auth, tx) => tx!..updateToken(auth.token),
        ),
      ],
      child: MaterialApp(
        title: 'GowesStore',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: themeColor,
            primary: themeColor,
            secondary: const Color(0xFF2C3E50),
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            iconTheme: IconThemeData(color: Color(0xFF2C3E50)),
            titleTextStyle: TextStyle(
              color: Color(0xFF2C3E50),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _hasSeenOnboarding = false;
  bool _checkingOnboarding = true;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _hasSeenOnboarding = prefs.getBool('seen_onboarding') ?? false;
        _checkingOnboarding = false;
      });
    } catch (e) {
      setState(() {
        _checkingOnboarding = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final themeColor = const Color(0xFFD35400);

    if (_checkingOnboarding) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // If app is currently reading login state from cache, show loading splash screen
    if (authProvider.isLoading && authProvider.token == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.directions_bike_rounded,
                  size: 80,
                  color: themeColor,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "GowesStore",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: themeColor,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      );
    }

    if (authProvider.isAuthenticated) {
      return const MainLayout();
    } else {
      if (!_hasSeenOnboarding) {
        return OnboardingScreen(
          onFinished: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('seen_onboarding', true);
            setState(() {
              _hasSeenOnboarding = true;
            });
          },
        );
      } else {
        return const LoginScreen();
      }
    }
  }
}
