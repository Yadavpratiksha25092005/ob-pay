import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String userBaseUrl = 'http://192.168.1.29:8000';
  static const String paymentBaseUrl = 'http://192.168.1.29:8000';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('agent_token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('agent_token');
  }

  static Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('agent_user_id', userId);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('agent_user_id');
  }

  static Future<Map<String, dynamic>> login({
    required String phone,
    required String pin,
  }) async {
    final response = await http.post(
      Uri.parse('$userBaseUrl/api/v1/users/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'pin': pin}),
    );
    final data = jsonDecode(response.body);
    if (data['token'] != null) {
      await saveToken(data['token']);
      await saveUserId(data['user']['id']);
    }
    return data;
  }

  static Future<Map<String, dynamic>> register({
    required String phone,
    required String fullName,
    required String email,
    required String pin,
    required String area,
  }) async {
    final response = await http.post(
      Uri.parse('$userBaseUrl/api/v1/users/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone': phone,
        'full_name': fullName,
        'email': email,
        'pin': pin,
        'area': area,
        'role': 'agent',
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getWallet(String userId) async {
    final response = await http.get(
      Uri.parse('$paymentBaseUrl/api/v1/wallet/$userId'),
      headers: {'Content-Type': 'application/json'},
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> createWallet(String userId) async {
    final response = await http.post(
      Uri.parse('$paymentBaseUrl/api/v1/wallet/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> sendMoney({
    String? senderUserId,
    String? senderPhone,
    required String receiverPhone,
    required double amount,
    required String description,
  }) async {
    final response = await http.post(
      Uri.parse('$paymentBaseUrl/api/v1/payments/send'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        if (senderUserId != null) 'sender_user_id': senderUserId,
        if (senderPhone != null) 'sender_phone': senderPhone,
        'receiver_phone': receiverPhone,
        'amount': amount,
        'description': description,
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getUserByPhone(String phone) async {
    final response = await http.get(
      Uri.parse('$userBaseUrl/api/v1/users/phone/$phone'),
      headers: {'Content-Type': 'application/json'},
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getPaymentHistory(String userId) async {
    final response = await http.get(
      Uri.parse('$paymentBaseUrl/api/v1/payments/history/$userId'),
      headers: {'Content-Type': 'application/json'},
    );
    return jsonDecode(response.body);
  }
}