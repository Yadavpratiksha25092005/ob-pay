import 'package:flutter/material.dart';
import 'api_service.dart';

class NotificationScreen extends StatefulWidget {
  final String userId;

  const NotificationScreen({super.key, required this.userId});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<dynamic> notifications = [];
  bool isLoading = true;
  int unreadCount = 0;

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    try {
      final data = await ApiService.getNotifications(widget.userId);
      setState(() {
        notifications = data['notifications'] ?? [];
        unreadCount = notifications
            .where((n) => n['is_read'] == false)
            .length;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> markAllRead() async {
    try {
      await ApiService.markAllNotificationsRead(widget.userId);
      setState(() {
        for (var n in notifications) {
          n['is_read'] = true;
        }
        unreadCount = 0;
      });
    } catch (e) {}
  }

  IconData _getIcon(String category) {
    switch (category) {
      case 'payment': return Icons.payment_rounded;
      case 'kyc': return Icons.verified_user_rounded;
      case 'security': return Icons.security_rounded;
      case 'promo': return Icons.local_offer_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  Color _getColor(String category) {
    switch (category) {
      case 'payment': return const Color(0xFF185FA5);
      case 'kyc': return const Color(0xFF3B6D11);
      case 'security': return const Color(0xFFA32D2D);
      case 'promo': return const Color(0xFF854F0B);
      default: return const Color(0xFF3C3489);
    }
  }

  Color _getBg(String category) {
    switch (category) {
      case 'payment': return const Color(0xFFE6F1FB);
      case 'kyc': return const Color(0xFFEAF3DE);
      case 'security': return const Color(0xFFFCEBEB);
      case 'promo': return const Color(0xFFFAEEDA);
      default: return const Color(0xFFEEEDFE);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C63FF),
        title: Row(
          children: [
            const Text('Notifications',
                style: TextStyle(color: Colors.white)),
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
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: markAllRead,
              child: const Text('Mark all read',
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
            ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: loadNotifications,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? _buildEmpty()
              : _buildList(),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFEEEDFE),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.notifications_off_rounded,
                size: 40, color: Color(0xFF6C63FF)),
          ),
          const SizedBox(height: 16),
          const Text('No notifications yet',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87)),
          const SizedBox(height: 8),
          const Text('You\'re all caught up!',
              style: TextStyle(color: Colors.black45)),
        ],
      ),
    );
  }

  Widget _buildList() {
    // Group by date
    final today = <dynamic>[];
    final earlier = <dynamic>[];

    for (var n in notifications) {
      final createdAt = DateTime.tryParse(n['created_at'] ?? '');
      if (createdAt != null &&
          DateTime.now().difference(createdAt).inHours < 24) {
        today.add(n);
      } else {
        earlier.add(n);
      }
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (today.isNotEmpty) ...[
          _buildGroupLabel('Today'),
          ...today.map((n) => _buildNotificationCard(n)),
        ],
        if (earlier.isNotEmpty) ...[
          _buildGroupLabel('Earlier'),
          ...earlier.map((n) => _buildNotificationCard(n)),
        ],
      ],
    );
  }

  Widget _buildGroupLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.black45,
            letterSpacing: 0.8),
      ),
    );
  }

  Widget _buildNotificationCard(dynamic notification) {
    final isRead = notification['is_read'] == true;
    final category = notification['category'] ?? 'general';
    final color = _getColor(category);
    final bg = _getBg(category);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : const Color(0xFFF0EFFE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRead
              ? Colors.black.withOpacity(0.06)
              : const Color(0xFF6C63FF).withOpacity(0.2),
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
          child: Icon(_getIcon(category), color: color, size: 22),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                notification['title'] ?? '',
                style: TextStyle(
                    fontWeight:
                        isRead ? FontWeight.normal : FontWeight.w500,
                    fontSize: 14,
                    color: Colors.black87),
              ),
            ),
            if (!isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF6C63FF),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification['message'] ?? '',
              style: const TextStyle(
                  color: Colors.black54, fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    category.toUpperCase(),
                    style: TextStyle(
                        color: color,
                        fontSize: 9,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () async {
          if (!isRead) {
            await ApiService.markNotificationRead(
                notification['id']);
            setState(() {
              notification['is_read'] = true;
              unreadCount = unreadCount > 0 ? unreadCount - 1 : 0;
            });
          }
        },
      ),
    );
  }
}