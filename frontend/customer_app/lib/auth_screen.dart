import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';
import 'premium_home_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'admin_dashboard_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  bool isLoading = false;

  final phoneController = TextEditingController();
  final pinController = TextEditingController();
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  final LocalAuthentication _localAuth = LocalAuthentication();
  final _secureStorage = const FlutterSecureStorage();
  bool _biometricAvailable = false;

  static const Color purple = Color(0xFF6C63FF);

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      setState(() => _biometricAvailable = isAvailable && isSupported);
    } catch (e) {
      setState(() => _biometricAvailable = false);
    }
  }

  Future<void> _authenticateWithBiometric() async {
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Use fingerprint to login to OB Pay',
      );
      if (authenticated) {
        final savedUserId = await _secureStorage.read(key: 'user_id');
        final savedName = await _secureStorage.read(key: 'user_name');
        final savedRole = await _secureStorage.read(key: 'role') ?? 'customer';
        if (savedUserId != null && mounted) {
          if (savedRole == 'admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => AdminDashboardScreen(
                  userId: savedUserId,
                  userName: savedName ?? 'Admin',
                ),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => PremiumHomeScreen(
                  userId: savedUserId,
                  userName: savedName ?? 'User',
                ),
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please login with PIN first'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Biometric error: $e')),
        );
      }
    }
  }

  String? _validate() {
    final phone = phoneController.text.trim();
    final pin = pinController.text.trim();
    if (phone.isEmpty) return 'Phone number required';
    if (!RegExp(r'^\d{10}$').hasMatch(phone)) return 'Phone must be exactly 10 digits';
    if (pin.isEmpty) return 'PIN required';
    if (!RegExp(r'^\d{4,6}$').hasMatch(pin)) return 'PIN must be 4 to 6 digits';
    if (!isLogin) {
      final name = nameController.text.trim();
      if (name.length < 2) return 'Name must be at least 2 characters';
      final email = emailController.text.trim();
      if (email.isNotEmpty && !RegExp(r'^[\w.%+\-]+@[\w.\-]+\.[a-zA-Z]{2,}$').hasMatch(email)) {
        return 'Invalid email format';
      }
    }
    return null;
  }

  Future<void> handleSubmit() async {
    final validationError = _validate();
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validationError), backgroundColor: Colors.red.shade700),
      );
      return;
    }
    setState(() => isLoading = true);
    try {
      Map<String, dynamic> result;
      if (isLogin) {
        result = await ApiService.login(
          phone: phoneController.text.trim(),
          pin: pinController.text.trim(),
        );
      } else {
        result = await ApiService.register(
          phone: phoneController.text.trim(),
          fullName: nameController.text.trim(),
          email: emailController.text.trim(),
          pin: pinController.text.trim(),
        );
      }

      if (result['token'] != null || result['user_id'] != null) {
        final userId = result['user']?['id'] ?? result['user_id'];
        final userName = result['user']?['full_name'] ?? nameController.text;
        final role = result['user']?['role'] ?? 'customer';
        await _secureStorage.write(key: 'user_id', value: userId);
        await _secureStorage.write(key: 'user_name', value: userName);
        await _secureStorage.write(key: 'phone', value: phoneController.text);
        await _secureStorage.write(key: 'role', value: role);
        if (result['token'] != null) {
          await _secureStorage.write(key: 'token', value: result['token']);
        }

        // FCM token save karo
        try {
          final fcmToken = await FirebaseMessaging.instance.getToken();
          if (fcmToken != null && userId != null) {
            await ApiService.saveFCMToken(userId: userId, token: fcmToken);
          }
        } catch (e) {
          debugPrint('FCM token error: $e');
        }

        if (!mounted) return;
        if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => AdminDashboardScreen(
                userId: userId,
                userName: userName,
              ),
            ),
          );
        } else {
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
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'] ?? 'Something went wrong')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
    setState(() => isLoading = false);
  }

  void toggleMode() => setState(() => isLogin = !isLogin);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          SizedBox.expand(
            child: Image.asset(
              'assets/images/auth_bg.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Dark overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  Colors.black.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Logo + Title
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3), width: 2),
                      ),
                      child: const Icon(Icons.account_balance_wallet_rounded,
                          size: 42, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    const Text('OB Pay',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1)),
                    const Text('Secure. Simple. Bharat.',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 14)),

                    const SizedBox(height: 32),

                    // Card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                            color: Colors.black.withValues(alpha: 0.2), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isLogin ? 'Welcome Back! 👋' : 'Create Account',
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isLogin
                                ? 'Login to your OB Pay account'
                                : 'Register a new account',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13),
                          ),
                          const SizedBox(height: 20),

                          if (!isLogin) ...[
                            _buildField(
                              controller: nameController,
                              label: 'Full Name',
                              icon: Icons.person_rounded,
                            ),
                            const SizedBox(height: 14),
                            _buildField(
                              controller: emailController,
                              label: 'Email',
                              icon: Icons.email_rounded,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 14),
                          ],

                          _buildField(
                            controller: phoneController,
                            label: 'Phone Number',
                            icon: Icons.phone_rounded,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 14),
                          _buildField(
                            controller: pinController,
                            label: 'PIN',
                            icon: Icons.lock_rounded,
                            obscureText: true,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 20),

                          // Login button
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : handleSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: purple,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                              ),
                              child: isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : Text(
                                      isLogin ? 'Login' : 'Register',
                                      style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                            ),
                          ),

                          // Biometric
                          if (_biometricAvailable && isLogin) ...[
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: OutlinedButton.icon(
                                onPressed: _authenticateWithBiometric,
                                icon: const Icon(Icons.fingerprint_rounded,
                                    color: Colors.white, size: 26),
                                label: const Text('Login with Fingerprint',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500)),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.white54),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 8),
                          Center(
                            child: TextButton(
                              onPressed: toggleMode,
                              child: Text(
                                isLogin
                                    ? 'New account? Register here'
                                    : 'Already have an account? Login',
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white30),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white30),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
      ),
    );
  }
}