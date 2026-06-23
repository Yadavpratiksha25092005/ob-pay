import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
static const String userBaseUrl = 'https://obpay-api-gateway.onrender.com';
static const String paymentBaseUrl = 'https://obpay-api-gateway.onrender.com';
  // Token save karo
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // Token get karo
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // User register
  static Future<Map<String, dynamic>> register({
    required String phone,
    required String fullName,
    required String email,
    required String pin,
  }) async {
    final response = await http.post(
      Uri.parse('$userBaseUrl/api/v1/users/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone': phone,
        'full_name': fullName,
        'email': email,
        'pin': pin,
        'role': 'customer',
      }),
    );
    return jsonDecode(response.body);
  }

  // User login
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
    }
    return data;
  }

  // Wallet get karo
  static Future<Map<String, dynamic>> getWallet(String userId) async {
    final response = await http.get(
      Uri.parse('$paymentBaseUrl/api/v1/wallet/$userId'),
      headers: {'Content-Type': 'application/json'},
    );
    return jsonDecode(response.body);
  }

  // Wallet create karo
  static Future<Map<String, dynamic>> createWallet(String userId) async {
    final response = await http.post(
      Uri.parse('$paymentBaseUrl/api/v1/wallet/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId}),
    );
    return jsonDecode(response.body);
  }

  // Paisa bhejo
  static Future<Map<String, dynamic>> sendMoney({
    required String senderUserId,
    required String receiverPhone,
    required double amount,
    required String description,
  }) async {
    final response = await http.post(
      Uri.parse('$paymentBaseUrl/api/v1/payments/send'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'sender_user_id': senderUserId,
        'receiver_phone': receiverPhone,
        'amount': amount,
        'description': description,
      }),
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
  // Get notifications
static Future<Map<String, dynamic>> getNotifications(String userId) async {
  final response = await http.get(
    Uri.parse('$userBaseUrl/api/v1/notifications/user/$userId'),
    headers: {'Content-Type': 'application/json'},
  );
  return jsonDecode(response.body);
}

// Mark single notification read
static Future<void> markNotificationRead(String notificationId) async {
  await http.put(
    Uri.parse('$userBaseUrl/api/v1/notifications/item/$notificationId/read'),
    headers: {'Content-Type': 'application/json'},
  );
}

// Mark all notifications read
static Future<void> markAllNotificationsRead(String userId) async {
  await http.put(
    Uri.parse('$userBaseUrl/api/v1/notifications/user/$userId/read-all'),
    headers: {'Content-Type': 'application/json'},
  );
}

// Get unread count
static Future<int> getUnreadCount(String userId) async {
  final response = await http.get(
    Uri.parse('$userBaseUrl/api/v1/notifications/user/$userId/unread'),
    headers: {'Content-Type': 'application/json'},
  );
  final data = jsonDecode(response.body);
  return data['unread_count'] ?? 0;
}

// Get rewards
static Future<Map<String, dynamic>> getRewards(String userId) async {
  final response = await http.get(
    Uri.parse('$userBaseUrl/api/v1/rewards/$userId'),
    headers: {'Content-Type': 'application/json'},
  );
  return jsonDecode(response.body);
}

// Add points
static Future<Map<String, dynamic>> addPoints({
  required String userId,
  required int points,
  required String description,
}) async {
  final response = await http.post(
    Uri.parse('$userBaseUrl/api/v1/rewards/add'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'user_id': userId,
      'points': points,
      'description': description,
    }),
  );
  return jsonDecode(response.body);
}

// Redeem points
static Future<Map<String, dynamic>> redeemPoints({
  required String userId,
  required int points,
}) async {
  final response = await http.post(
    Uri.parse('$userBaseUrl/api/v1/rewards/redeem'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'user_id': userId,
      'points': points,
    }),
  );
  return jsonDecode(response.body);
}

// Get offers
static Future<Map<String, dynamic>> getOffers() async {
  final response = await http.get(
    Uri.parse('$userBaseUrl/api/v1/offers'),
    headers: {'Content-Type': 'application/json'},
  );
  return jsonDecode(response.body);
}

static Future<Map<String, dynamic>> addMoneyToWallet({
  required String userId,
  required double amount,
}) async {
  final response = await http.post(
    Uri.parse('$paymentBaseUrl/api/v1/wallet/add-money'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'user_id': userId,
      'amount': amount,
    }),
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

// Admin APIs
static Future<List<dynamic>> getAllUsers() async {
  try {
    final response = await http.get(
      Uri.parse('$userBaseUrl/api/v1/admin/users'),
    );
    final data = jsonDecode(response.body);
    return data['users'] ?? [];
  } catch (e) {
    return [];
  }
}

static Future<List<dynamic>> getAllTransactions() async {
  try {
    final response = await http.get(
      Uri.parse('$userBaseUrl/api/v1/admin/transactions'),
    );
    final data = jsonDecode(response.body);
    return data['payments'] ?? [];
  } catch (e) {
    return [];
  }
}

static Future<Map<String, dynamic>> getAdminStats() async {
  try {
    final response = await http.get(
      Uri.parse('$userBaseUrl/api/v1/admin/stats'),
    );
    return jsonDecode(response.body);
  } catch (e) {
    return {};
  }
}

static Future<void> sendNotification({
  required String userId,
  required String title,
  required String message,
}) async {
  try {
    await http.post(
      Uri.parse('$userBaseUrl/api/v1/notifications/send'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'title': title,
        'message': message,
        'type': 'push',
        'category': 'admin',
      }),
    );
  } catch (e) {
    print('Send notification error: $e');
  }
}

// ─── Beneficiaries / Contacts ────────────────────────────────────────────────

static Future<List<dynamic>> getBeneficiaries(String userId) async {
  try {
    final response = await http.get(
      Uri.parse('$userBaseUrl/api/v1/beneficiaries/$userId'),
    );
    final data = jsonDecode(response.body);
    return data['beneficiaries'] ?? [];
  } catch (e) {
    return [];
  }
}

static Future<Map<String, dynamic>> addBeneficiary({
  required String userId,
  required String name,
  required String phone,
  String nickname = '',
}) async {
  try {
    final response = await http.post(
      Uri.parse('$userBaseUrl/api/v1/beneficiaries'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'name': name,
        'phone': phone,
        'nickname': nickname,
      }),
    );
    return jsonDecode(response.body);
  } catch (e) {
    return {'error': e.toString()};
  }
}

static Future<bool> deleteBeneficiary(String id) async {
  try {
    final response = await http.delete(
      Uri.parse('$userBaseUrl/api/v1/beneficiaries/$id'),
    );
    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}

static Future<bool> updateBeneficiaryNickname(String id, String nickname) async {
  try {
    final response = await http.put(
      Uri.parse('$userBaseUrl/api/v1/beneficiaries/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nickname': nickname}),
    );
    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}
}