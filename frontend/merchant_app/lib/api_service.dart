import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
static const String userBaseUrl = 'https://obpay-api-gateway.onrender.com';
static const String paymentBaseUrl = 'https://obpay-api-gateway.onrender.com';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('merchant_token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('merchant_token');
  }

  static Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('merchant_user_id', userId);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('merchant_user_id');
  }

  // Merchant register
  static Future<Map<String, dynamic>> register({
    required String phone,
    required String fullName,
    required String email,
    required String pin,
    required String businessName,
  }) async {
    final response = await http.post(
      Uri.parse('$userBaseUrl/api/v1/users/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone': phone,
        'full_name': fullName,
        'email': email,
        'pin': pin,
        'business_name': businessName,
        'role': 'merchant',
      }),
    );
    return jsonDecode(response.body);
  }

  // Merchant login
  static Future<Map<String, dynamic>> login({
    required String phone,
    required String pin,
  }) async {
    final response = await http.post(
      Uri.parse('$userBaseUrl/api/v1/users/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone': phone,
        'pin': pin,
      }),
    );
    final data = jsonDecode(response.body);
    if (data['token'] != null) {
      await saveToken(data['token']);
      await saveUserId(data['user']['id']);
    }
    return data;
  }

  // Get wallet
  static Future<Map<String, dynamic>> getWallet(String userId) async {
    final response = await http.get(
      Uri.parse('$paymentBaseUrl/api/v1/wallet/$userId'),
      headers: {'Content-Type': 'application/json'},
    );
    return jsonDecode(response.body);
  }

  // Create wallet
  static Future<Map<String, dynamic>> createWallet(String userId) async {
    final response = await http.post(
      Uri.parse('$paymentBaseUrl/api/v1/wallet/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId}),
    );
    return jsonDecode(response.body);
  }

  // Payment history
  static Future<Map<String, dynamic>> getPaymentHistory(String userId) async {
    final response = await http.get(
      Uri.parse('$paymentBaseUrl/api/v1/payments/history/$userId'),
      headers: {'Content-Type': 'application/json'},
    );
    return jsonDecode(response.body);
  }
  // Analytics
static Future<Map<String, dynamic>> getAnalytics(String userId, {String period = 'month'}) async {
  final response = await http.get(
    Uri.parse('$userBaseUrl/api/v1/analytics/$userId?period=$period'),
    headers: {'Content-Type': 'application/json'},
  );
  return jsonDecode(response.body);
}
static Future<void> saveFCMToken({
  required String userId,
  required String token,
}) async {
  try {
    await http.post(
Uri.parse('$userBaseUrl/api/v1/users/fcm-token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'fcm_token': token,
      }),
    );
  } catch (e) {
    print('FCM token save error: $e');
  }
}
}