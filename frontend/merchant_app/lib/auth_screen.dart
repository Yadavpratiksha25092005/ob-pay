import 'package:flutter/material.dart';
import 'api_service.dart';
import 'premium_home_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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
  final businessController = TextEditingController();

  static const Color blue = Color(0xFF3D5AF1);

  void toggleMode() => setState(() => isLogin = !isLogin);

  String? _validate() {
    final phone = phoneController.text.trim();
    final pin = pinController.text.trim();
    if (phone.isEmpty) return 'Phone number required';
    if (!RegExp(r'^\d{10}$').hasMatch(phone)) return 'Phone must be exactly 10 digits';
    if (pin.isEmpty) return 'PIN required';
    if (!RegExp(r'^\d{4,6}$').hasMatch(pin)) return 'PIN must be 4 to 6 digits';
    if (!isLogin) {
      final name = nameController.text.trim();
      if (name.length < 2) return 'Owner name must be at least 2 characters';
      if (businessController.text.trim().isEmpty) return 'Business name required';
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
          businessName: businessController.text.trim(),
        );
      }

      if (result['token'] != null || result['user_id'] != null) {
        String userId = result['user']?['id'] ?? result['user_id'];
        String userName = result['user']?['full_name'] ?? nameController.text;
        if (!isLogin) {
          await ApiService.createWallet(userId);
        }
// FCM token save karo
try {
  final fcmToken = await FirebaseMessaging.instance.getToken();
  if (fcmToken != null && userId != null) {
    await ApiService.saveFCMToken(userId: userId, token: fcmToken);
  }
} catch (e) {
  print('FCM token error: $e');
}

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PremiumHomeScreen(
              userId: userId,
              userName: userName,
              phone: phoneController.text,
            ),
          ),
        );
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
                  Colors.black.withOpacity(0.5),
                  Colors.black.withOpacity(0.85),
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
                    // Logo
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withOpacity(0.3), width: 2),
                      ),
                      child: const Icon(Icons.store_rounded,
                          size: 42, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    const Text('OB Pay Business',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1)),
                    const Text('Merchant Portal',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 14)),

                    const SizedBox(height: 32),

                    // Card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.2), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
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
                                ? 'Login to your merchant account'
                                : 'Register your business',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13),
                          ),
                          const SizedBox(height: 20),

                          if (!isLogin) ...[
                            _buildField('Owner Name', nameController,
                                Icons.person_rounded),
                            const SizedBox(height: 14),
                            _buildField('Business Name', businessController,
                                Icons.store_rounded),
                            const SizedBox(height: 14),
                            _buildField('Business Email', emailController,
                                Icons.email_rounded,
                                keyboardType: TextInputType.emailAddress),
                            const SizedBox(height: 14),
                          ],

                          _buildField('Phone Number', phoneController,
                              Icons.phone_rounded,
                              keyboardType: TextInputType.phone),
                          const SizedBox(height: 14),
                          _buildField('PIN', pinController,
                              Icons.lock_rounded,
                              obscureText: true,
                              keyboardType: TextInputType.number),
                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : handleSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: blue,
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

                          const SizedBox(height: 8),
                          Center(
                            child: TextButton(
                              onPressed: toggleMode,
                              child: Text(
                                isLogin
                                    ? 'New merchant? Register here'
                                    : 'Already registered? Login',
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

  Widget _buildField(
    String label,
    TextEditingController controller,
    IconData icon, {
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