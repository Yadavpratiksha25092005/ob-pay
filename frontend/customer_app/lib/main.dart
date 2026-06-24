import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'auth_screen.dart';
import 'premium_home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const OBPayApp());
}

class OBPayApp extends StatelessWidget {
  const OBPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, child) {
        return MaterialApp(
          title: 'OB Pay',
          debugShowCheckedModeBanner: false,
          themeMode: mode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6C63FF),
            ),
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFFF2F4F7),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6C63FF),
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFF0B1437),
            cardColor: const Color(0xFF111C44),
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final _secureStorage = const FlutterSecureStorage();
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );
    _animController.forward();
    _setupFCM();
    _checkAndAuthenticate();
  }

  Future<void> _setupFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    String? token = await messaging.getToken();
    print('FCM Token: $token');

    if (token != null) {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? '';
      if (userId.isNotEmpty) {
        await ApiService.saveFCMToken(userId: userId, token: token);
      }
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground message: ${message.notification?.title}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.notifications_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(message.notification?.title ?? 'OB Pay',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      Text(message.notification?.body ?? '',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF6C63FF),
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _checkAndAuthenticate() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    try {
      final savedUserId = await _secureStorage.read(key: 'user_id');
      if (savedUserId == null) {
        _goToAuth();
        return;
      }
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      if (canCheckBiometrics && isDeviceSupported) {
        final authenticated = await _localAuth.authenticate(
          localizedReason: 'Verify your identity to access OB Pay',
        );
        if (authenticated && mounted) {
          final savedName = await _secureStorage.read(key: 'user_name');
          _goToHome(savedUserId, savedName ?? 'User');
        } else {
          _goToAuth();
        }
      } else {
        _goToAuth();
      }
    } catch (e) {
      _goToAuth();
    }
  }

  void _goToAuth() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AuthScreen()),
    );
  }

  void _goToHome(String userId, String userName) {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PremiumHomeScreen(
          userId: userId,
          userName: userName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Stack(
          children: [
            Positioned(
              top: -80, left: -80,
              child: Container(
                width: 280, height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF3D5AF1).withOpacity(0.15),
                ),
              ),
            ),
            Positioned(
              top: 60, right: -60,
              child: Container(
                width: 200, height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF9F7AEA).withOpacity(0.12),
                ),
              ),
            ),
            Positioned(
              bottom: -60, right: -40,
              child: Container(
                width: 260, height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF6C63FF).withOpacity(0.12),
                ),
              ),
            ),
            Positioned(
              bottom: 80, left: -60,
              child: Container(
                width: 180, height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/ob_pay_logo.png',
                    width: double.infinity,
                    height: 280,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Secure. Simple. Bharat.',
                    style: TextStyle(
                        color: Color(0xFF4A5568),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 80),
                  const Icon(Icons.fingerprint_rounded,
                      size: 52, color: Color(0xFF6C63FF)),
                  const SizedBox(height: 12),
                  const Text(
                    'Verifying identity...',
                    style: TextStyle(
                        color: Color(0xFF718096), fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}