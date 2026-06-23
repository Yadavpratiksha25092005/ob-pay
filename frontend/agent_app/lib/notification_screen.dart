import 'package:flutter/material.dart';

class AgentNotificationScreen extends StatefulWidget {
  final String userId;

  const AgentNotificationScreen({super.key, required this.userId});

  @override
  State<AgentNotificationScreen> createState() =>
      _AgentNotificationScreenState();
}

class _AgentNotificationScreenState
    extends State<AgentNotificationScreen> {
  static const Color green = Color(0xFF00897B);
  static const Color bgPage = Color(0xFFF5F5F5);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1A202C);
  static const Color textLight = Color(0xFF718096);

  final List<Map<String, dynamic>> notifications = [
    {'title': 'Cash In Successful!', 'message': '₹2,000 Cash In for Rahul Kumar completed.', 'time': '10:30 AM', 'isRead': false, 'icon': Icons.arrow_downward_rounded, 'color': Color(0xFF00897B), 'bg': Color(0xFFE0F2F1)},
    {'title': 'Commission Earned!', 'message': 'You earned ₹2.5 commission on last transaction.', 'time': '10:35 AM', 'isRead': false, 'icon': Icons.monetization_on_rounded, 'color': Color(0xFFED8936), 'bg': Color(0xFFFFF3E0)},
    {'title': 'New Customer Registered', 'message': 'Priya Sharma has been successfully registered.', 'time': '11:00 AM', 'isRead': false, 'icon': Icons.person_add_rounded, 'color': Color(0xFF3D5AF1), 'bg': Color(0xFFEEEDFE)},
    {'title': 'Target Achievement!', 'message': 'You have completed 28% of your monthly target.', 'time': 'Yesterday', 'isRead': true, 'icon': Icons.flag_rounded, 'color': Color(0xFF9F7AEA), 'bg': Color(0xFFF3E5F5)},
    {'title': 'Performance Update', 'message': 'Your performance score is 87/100. Keep it up!', 'time': 'Yesterday', 'isRead': true, 'icon': Icons.trending_up_rounded, 'color': Color(0xFF00B5D8), 'bg': Color(0xFFE0F7FA)},
    {'title': 'Cash Out Successful!', 'message': '₹500 Cash Out for Priya Sharma completed.', 'time': '2 days ago', 'isRead': true, 'icon': Icons.arrow_upward_rounded, 'color': Color(0xFFE91E63), 'bg': Color(0xFFFCE4EC)},
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
    final today = notifications
        .where((n) =>
            n['time'].toString().contains('AM') ||
            n['time'].toString().contains('PM'))
        .toList();
    final earlier = notifications
        .where((n) =>
            !n['time'].toString().contains('AM') &&
            !n['time'].toString().contains('PM'))
        .toList();

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
                  style: TextStyle(color: green, fontSize: 12)),
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
      child: Text(label.toUpperCase(),
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFF718096),
              letterSpacing: 0.8)),
    );
  }

  Widget _notificationCard(Map<String, dynamic> n) {
    final isRead = n['isRead'] as bool;
    final color = n['color'] as Color;
    final bg = n['bg'] as Color;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isRead ? bgCard : const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRead
              ? Colors.black.withOpacity(0.06)
              : green.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03), blurRadius: 8)
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 46, height: 46,
          decoration: BoxDecoration(
              color: bg, borderRadius: BorderRadius.circular(14)),
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
                width: 8, height: 8,
                decoration: const BoxDecoration(
                    color: Color(0xFF00897B), shape: BoxShape.circle),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(n['message'] as String,
                style: const TextStyle(
                    color: textLight, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Text(n['time'] as String,
                style: const TextStyle(
                    color: Color(0xFFA0AEC0), fontSize: 11)),
          ],
        ),
        onTap: () => setState(() => n['isRead'] = true),
      ),
    );
  }
}