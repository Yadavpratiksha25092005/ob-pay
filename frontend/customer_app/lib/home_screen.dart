import 'package:flutter/material.dart';
import 'api_service.dart';
import 'wallet_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'add_money_screen.dart';
import 'bills_screen.dart';
import 'kyc_screen.dart';
import 'qr_scanner_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const HomeScreen({
    super.key,
    required this.userId,
    required this.userName,
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

  double get balance {
    if (wallet == null) return 0.0;
    final b = wallet!['balance'];
    if (b == null) return 0.0;
    if (b is int) return b.toDouble();
    if (b is double) return b;
    return double.tryParse(b.toString()) ?? 0.0;
  }

  double get dailyLimit {
    if (wallet == null) return 10000.0;
    final d = wallet!['daily_limit'];
    if (d == null) return 10000.0;
    if (d is int) return d.toDouble();
    if (d is double) return d;
    return double.tryParse(d.toString()) ?? 10000.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C63FF),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('OB Pay',
                style: TextStyle(color: Colors.white, fontSize: 18)),
            Text('Welcome, ${widget.userName}!',
                style: const TextStyle(
                    color: Colors.white70, fontSize: 13)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: loadWallet,
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(
                    userId: widget.userId,
                    userName: widget.userName,
                    phone: '',
                  ),
                ),
              );
            },
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
                        colors: [Color(0xFF6C63FF), Color(0xFF4CAF50)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Wallet Balance',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 8),
                        Text(
                          '₹ ${balance.toStringAsFixed(2)}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Daily Limit: ₹ ${dailyLimit.toStringAsFixed(0)}',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Quick Actions Row 1
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
                        icon: Icons.send,
                        label: 'Send',
                        color: const Color(0xFF6C63FF),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WalletScreen(
                                userId: widget.userId,
                              ),
                            ),
                          );
                        },
                      ),
                      _ActionButton(
                        icon: Icons.qr_code_scanner,
                        label: 'Scan',
                        color: const Color(0xFF4CAF50),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => QRScannerScreen(
                                userId: widget.userId,
                              ),
                            ),
                          );
                        },
                      ),
                      _ActionButton(
                        icon: Icons.add_circle,
                        label: 'Add Money',
                        color: const Color(0xFFFF9800),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddMoneyScreen(
                                userId: widget.userId,
                              ),
                            ),
                          );
                        },
                      ),
                      _ActionButton(
                        icon: Icons.receipt_long,
                        label: 'History',
                        color: const Color(0xFFE91E63),
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
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Quick Actions Row 2
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _ActionButton(
                        icon: Icons.receipt,
                        label: 'Bills',
                        color: Colors.teal,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BillsScreen(
                                userId: widget.userId,
                              ),
                            ),
                          );
                        },
                      ),
                      _ActionButton(
                        icon: Icons.phone_android,
                        label: 'Recharge',
                        color: Colors.indigo,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BillsScreen(
                                userId: widget.userId,
                              ),
                            ),
                          );
                        },
                      ),
                      _ActionButton(
                        icon: Icons.verified_user,
                        label: 'KYC',
                        color: Colors.purple,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => KYCScreen(
                                userId: widget.userId,
                              ),
                            ),
                          );
                        },
                      ),
                      _ActionButton(
                        icon: Icons.person,
                        label: 'Profile',
                        color: Colors.brown,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProfileScreen(
                                userId: widget.userId,
                                userName: widget.userName,
                                phone: '',
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // User ID Card
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFF6C63FF),
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(widget.userName),
                      subtitle: Text(
                        widget.userId,
                        style: const TextStyle(fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.verified,
                          color: Color(0xFF4CAF50)),
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