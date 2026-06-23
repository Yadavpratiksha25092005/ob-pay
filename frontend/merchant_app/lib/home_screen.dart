import 'package:flutter/material.dart';
import 'api_service.dart';
import 'qr_screen.dart';
import 'history_screen.dart';
import 'settlement_screen.dart';
import 'analytics_screen.dart';
import 'refund_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String phone;

  const HomeScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.phone,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? wallet;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadWallet();
  }

  Future<void> loadWallet() async {
    try {
      final data = await ApiService.getWallet(widget.userId);
      setState(() {
        wallet = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('OB Pay Business',
                style: TextStyle(color: Colors.white, fontSize: 16)),
            Text('Welcome, ${widget.userName}!',
                style: const TextStyle(
                    color: Colors.white70, fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: loadWallet,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Balance Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Business Wallet Balance',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 8),
                        Text(
                          wallet != null
                              ? '₹ ${wallet!['balance'].toStringAsFixed(2)}'
                              : '₹ 0.00',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Phone: ${widget.phone}',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Quick Actions
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Quick Actions',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 12),

                  // Row 1
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _ActionButton(
                        icon: Icons.qr_code,
                        label: 'My QR',
                        color: const Color(0xFF1A237E),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => QRScreen(
                                userId: widget.userId,
                                userName: widget.userName,
                                phone: widget.phone,
                              ),
                            ),
                          );
                        },
                      ),
                      _ActionButton(
                        icon: Icons.history,
                        label: 'Transactions',
                        color: const Color(0xFF4CAF50),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HistoryScreen(
                                userId: widget.userId,
                              ),
                            ),
                          );
                        },
                      ),
                      _ActionButton(
                        icon: Icons.account_balance,
                        label: 'Settlement',
                        color: const Color(0xFFFF9800),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SettlementScreen(
                                userId: widget.userId,
                                balance: wallet?['balance']?.toDouble() ?? 0.0,
                              ),
                            ),
                          );
                        },
                      ),
                      _ActionButton(
                        icon: Icons.bar_chart,
                        label: 'Analytics',
                        color: const Color(0xFFE91E63),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AnalyticsScreen(
                                userId: widget.userId,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

// Row 2
Row(
  mainAxisAlignment: MainAxisAlignment.spaceAround,
  children: [
    _ActionButton(
      icon: Icons.replay,
      label: 'Refunds',
      color: Colors.red,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RefundScreen(
              userId: widget.userId,
            ),
          ),
        );
      },
    ),
    _ActionButton(
      icon: Icons.support_agent,
      label: 'Support',
      color: Colors.teal,
      onTap: () {},
    ),
    _ActionButton(
      icon: Icons.description,
      label: 'Reports',
      color: Colors.purple,
      onTap: () {},
    ),
    _ActionButton(
      icon: Icons.settings,
      label: 'Settings',
      color: Colors.grey,
      onTap: () {},
    ),
  ],
),

                  const SizedBox(height: 24),

                  // Merchant Info Card
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFF1A237E),
                        child: Icon(Icons.store, color: Colors.white),
                      ),
                      title: Text(widget.userName),
                      subtitle: Text(widget.phone),
                      trailing: const Icon(Icons.verified,
                          color: Color(0xFF4CAF50)),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Today's Summary
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Today's Summary",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceAround,
                            children: [
                              _SummaryTile(
                                label: 'Received',
                                value:
                                    '₹ ${wallet?['balance'] ?? 0}',
                                color: Colors.green,
                                icon: Icons.arrow_downward,
                              ),
                              _SummaryTile(
                                label: 'Pending',
                                value: '₹ 0',
                                color: Colors.orange,
                                icon: Icons.pending,
                              ),
                              _SummaryTile(
                                label: 'Settled',
                                value: '₹ 0',
                                color: Colors.blue,
                                icon: Icons.check_circle,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: color)),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _SummaryTile({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 16)),
        Text(label,
            style:
                const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}