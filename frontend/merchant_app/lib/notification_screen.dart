import 'package:flutter/material.dart';

class MerchantNotificationScreen extends StatefulWidget {
  final String userId;
  const MerchantNotificationScreen({super.key, required this.userId});

  @override
  State<MerchantNotificationScreen> createState() =>
      _MerchantNotificationScreenState();
}

class _MerchantNotificationScreenState
    extends State<MerchantNotificationScreen> {
  static const Color bgPage = Color(0xFFF0F4FF);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color blue = Color(0xFF3D5AF1);
  static const Color textDark = Color(0xFF1A202C);
  static const Color textLight = Color(0xFF718096);

  final List<Map<String, dynamic>> notifications = [
    {'title': 'Payment Received!', 'message': '₹ 1,250 received from Rohit Sharma via UPI', 'time': '10:24 AM', 'category': 'payment', 'isRead': false, 'icon': Icons.arrow_downward_rounded, 'color': Color(0xFF48BB78), 'bg': Color(0xFFE8F5E9)},
    {'title': 'Settlement Processed', 'message': '₹ 8,750 settled to your HDFC bank account', 'time': '09:15 AM', 'category': 'settlement', 'isRead': false, 'icon': Icons.account_balance_rounded, 'color': Color(0xFF3D5AF1), 'bg': Color(0xFFEEEDFE)},
    {'title': 'Payment Received!', 'message': '₹ 650 received from Priya Patel via UPI', 'time': 'Yesterday', 'category': 'payment', 'isRead': true, 'icon': Icons.arrow_downward_rounded, 'color': Color(0xFF48BB78), 'bg': Color(0xFFE8F5E9)},
    {'title': 'Refund Issued', 'message': '₹ 450 refund issued to Amazon India', 'time': 'Yesterday', 'category': 'refund', 'isRead': true, 'icon': Icons.keyboard_return_rounded, 'color': Color(0xFFED8936), 'bg': Color(0xFFFFF3E0)},
    {'title': 'KYC Approved!', 'message': 'Your business KYC has been approved successfully', 'time': '2 days ago', 'category': 'kyc', 'isRead': true, 'icon': Icons.verified_rounded, 'color': Color(0xFF9F7AEA), 'bg': Color(0xFFF3E5F5)},
    {'title': 'New Feature Available', 'message': 'Analytics dashboard is now available for your account', 'time': '3 days ago', 'category': 'promo', 'isRead': true, 'icon': Icons.star_rounded, 'color': Color(0xFFF6AD55), 'bg': Color(0xFFFFF3E0)},
  ];

  int get unreadCount =>
      notifications.where((n) => n['isRead'] == false).length;

  void markAllRead() {
    setState(() {
      for (var n in notifications) {
        n['isRead'] = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final today = notifications.where((n) =>
        n['time'] == 'Today' ||
        n['time'].toString().contains('AM') ||
        n['time'].toString().contains('PM')).toList();
    final earlier = notifications.where((n) =>
        !n['time'].toString().contains('AM') &&
        !n['time'].toString().contains('PM')).toList();

    return Scaffold(
      backgroundColor: bgPage,
      appBar: AppBar(
        backgroundColor: bgCard,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1A202C)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const Text('Notifications',
                style: TextStyle(
                    color: Color(0xFF1A202C),
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            if (unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('$unreadCount',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: markAllRead,
              child: Text('Mark all read',
                  style: TextStyle(color: blue, fontSize: 12)),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (today.isNotEmpty) ...[
            _groupLabel('Today'),
            ...today.map((n) => _notificationCard(n)),
          ],
          if (earlier.isNotEmpty) ...[
            _groupLabel('Earlier'),
            ...earlier.map((n) => _notificationCard(n)),
          ],
        ],
      ),
    );
  }

  Widget _groupLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Color(0xFF718096),
            letterSpacing: 0.8),
      ),
    );
  }

  Widget _notificationCard(Map<String, dynamic> n) {
    final isRead = n['isRead'] as bool;
    final color = n['color'] as Color;
    final bg = n['bg'] as Color;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isRead ? bgCard : const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRead
              ? Colors.black.withOpacity(0.06)
              : blue.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(n['icon'] as IconData, color: color, size: 22),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(n['title'] as String,
                  style: TextStyle(
                      color: textDark,
                      fontWeight: isRead
                          ? FontWeight.normal
                          : FontWeight.w600,
                      fontSize: 14)),
            ),
            if (!isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF3D5AF1),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(n['message'] as String,
                style: const TextStyle(
                    color: Color(0xFF718096), fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Text(n['time'] as String,
                style: const TextStyle(
                    color: Color(0xFFA0AEC0), fontSize: 11)),
          ],
        ),
        onTap: () {
          setState(() => n['isRead'] = true);
        },
      ),
    );
  }
}