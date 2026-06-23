import 'package:flutter/material.dart';
import 'api_service.dart';
import 'cashin_screen.dart';
import 'cashout_screen.dart';
import 'history_screen.dart';

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
  int totalTransactions = 0;
  double totalCommission = 0;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final walletData = await ApiService.getWallet(widget.userId);
      final historyData = await ApiService.getPaymentHistory(widget.userId);
      final payments = historyData['payments'] ?? [];

      setState(() {
        wallet = walletData;
        totalTransactions = payments.length;
        totalCommission = totalTransactions * 2.5;
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
        backgroundColor: const Color(0xFF004D40),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('OB Pay Agent',
                style: TextStyle(color: Colors.white, fontSize: 16)),
            Text('Welcome, ${widget.userName}!',
                style: const TextStyle(
                    color: Colors.white70, fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: loadData,
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
                        colors: [Color(0xFF004D40), Color(0xFF00796B)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Agent Wallet Balance',
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
                        Text('Agent ID: ${widget.userId.substring(0, 8)}...',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                const Icon(Icons.swap_horiz,
                                    color: Color(0xFF004D40), size: 32),
                                const SizedBox(height: 8),
                                Text('$totalTransactions',
                                    style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold)),
                                const Text('Transactions',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                const Icon(Icons.monetization_on,
                                    color: Colors.orange, size: 32),
                                const SizedBox(height: 8),
                                Text(
                                    '₹ ${totalCommission.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold)),
                                const Text('Commission',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Quick Actions
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Quick Actions',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _ActionButton(
                        icon: Icons.add_circle,
                        label: 'Cash In',
                        color: const Color(0xFF004D40),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CashInScreen(
                                agentUserId: widget.userId,
                              ),
                            ),
                          );
                        },
                      ),
                      _ActionButton(
                        icon: Icons.remove_circle,
                        label: 'Cash Out',
                        color: Colors.red,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CashOutScreen(
                                agentUserId: widget.userId,
                              ),
                            ),
                          );
                        },
                      ),
                      _ActionButton(
                        icon: Icons.history,
                        label: 'History',
                        color: Colors.blue,
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
                        icon: Icons.person,
                        label: 'Profile',
                        color: Colors.orange,
                        onTap: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Agent Info Card
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFF004D40),
                        child: Icon(Icons.support_agent,
                            color: Colors.white),
                      ),
                      title: Text(widget.userName),
                      subtitle: Text(widget.phone),
                      trailing: const Icon(Icons.verified,
                          color: Color(0xFF004D40)),
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