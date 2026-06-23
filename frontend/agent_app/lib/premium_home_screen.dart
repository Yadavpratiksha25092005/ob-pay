import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'api_service.dart';
import 'cashin_screen.dart';
import 'cashout_screen.dart';
import 'history_screen.dart';
import 'performance_screen.dart';
import 'customer_screen.dart';
import 'profile_screen.dart';
import 'notification_screen.dart';

class PremiumHomeScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String phone;

  const PremiumHomeScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.phone,
  });

  @override
  State<PremiumHomeScreen> createState() => _PremiumHomeScreenState();
}

class _PremiumHomeScreenState extends State<PremiumHomeScreen> {
  Map<String, dynamic>? wallet;
  bool isLoading = true;
  bool showBalance = true;
  int totalTransactions = 0;
  double totalCommission = 0;
  int _currentIndex = 0;

  static const Color green = Color(0xFF00897B);
  static const Color darkGreen = Color(0xFF004D40);
  static const Color bgPage = Color(0xFFF5F5F5);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1A202C);
  static const Color textLight = Color(0xFF718096);

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
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

  double get balance {
    if (wallet == null) return 0.0;
    final b = wallet!['balance'];
    if (b == null) return 0.0;
    if (b is int) return b.toDouble();
    if (b is double) return b;
    return double.tryParse(b.toString()) ?? 0.0;
  }

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgPage,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildAppBar(),
                    _buildBalanceCard(),
                    const SizedBox(height: 16),
                    _buildStatsRow(),
                    const SizedBox(height: 16),
                    _buildQuickActions(),
                    const SizedBox(height: 16),
                    _buildPerformanceCard(),
                    const SizedBox(height: 16),
                    _buildRecentTransactions(),
                    const SizedBox(height: 16),
                    _buildTargetCard(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => AgentProfileScreen(
                      userId: widget.userId,
                      userName: widget.userName,
                      phone: widget.phone,
                    ))),
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [darkGreen, green]),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  widget.userName.isNotEmpty
                      ? widget.userName[0].toUpperCase()
                      : 'A',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$greeting 👋',
                    style: const TextStyle(
                        color: textLight, fontSize: 12)),
                Text(widget.userName,
                    style: const TextStyle(
                        color: textDark,
                        fontSize: 17,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => AgentNotificationScreen(
                      userId: widget.userId,
                    ))),
            child: Stack(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: bgCard,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 8)
                    ],
                  ),
                  child: const Icon(Icons.notifications_outlined,
                      color: textDark, size: 22),
                ),
                Positioned(
                  top: 8, right: 8,
                  child: Container(
                    width: 8, height: 8,
                    decoration: const BoxDecoration(
                        color: Colors.red, shape: BoxShape.circle),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 6, height: 6,
                  decoration: const BoxDecoration(
                      color: Colors.green, shape: BoxShape.circle),
                ),
                const SizedBox(width: 4),
                const Text('Active',
                    style: TextStyle(
                        color: darkGreen,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF004D40), Color(0xFF00897B)],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: darkGreen.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -30, right: -20,
              child: Container(
                width: 130, height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.07),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.account_balance_wallet,
                            color: Colors.white70, size: 16),
                        const SizedBox(width: 6),
                        Text('Agent Wallet',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 13)),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => setState(
                          () => showBalance = !showBalance),
                      child: Icon(
                        showBalance
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Colors.white70, size: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    showBalance
                        ? '₹ ${balance.toStringAsFixed(2)}'
                        : '₹ ••••••',
                    key: ValueKey(showBalance),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 4),
                Text('Agent ID: ${widget.userId.substring(0, 8).toUpperCase()}',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _balanceStat('$totalTransactions', 'Transactions'),
                    const SizedBox(width: 24),
                    _balanceStat(
                        '₹${totalCommission.toStringAsFixed(0)}',
                        'Commission'),
                    const SizedBox(width: 24),
                    _balanceStat('4.8★', 'Rating'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _balanceStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: TextStyle(
                color: Colors.white.withOpacity(0.6), fontSize: 10)),
      ],
    );
  }

  Widget _buildStatsRow() {
    final stats = [
      {'title': 'Today', 'value': '₹2,450', 'change': '+12%', 'up': true, 'color': const Color(0xFF00897B)},
      {'title': 'This Week', 'value': '₹14,200', 'change': '+8%', 'up': true, 'color': const Color(0xFF3D5AF1)},
      {'title': 'Customers', 'value': '28', 'change': '+3', 'up': true, 'color': const Color(0xFFED8936)},
      {'title': 'Pending', 'value': '₹800', 'change': '-2%', 'up': false, 'color': const Color(0xFFE91E63)},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 1.8,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        children: stats.map((s) {
          final color = s['color'] as Color;
          final up = s['up'] as bool;
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: bgCard,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8)
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(s['title'] as String,
                        style: const TextStyle(
                            color: textLight, fontSize: 11)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: up
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(s['change'] as String,
                          style: TextStyle(
                              color: up
                                  ? const Color(0xFF3B6D11)
                                  : Colors.red,
                              fontSize: 9,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const Spacer(),
                Text(s['value'] as String,
                    style: TextStyle(
                        color: color,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {'icon': Icons.add_circle_rounded, 'label': 'Cash In', 'color': const Color(0xFF00897B), 'bg': const Color(0xFFE0F2F1)},
      {'icon': Icons.remove_circle_rounded, 'label': 'Cash Out', 'color': const Color(0xFFE91E63), 'bg': const Color(0xFFFCE4EC)},
      {'icon': Icons.person_add_rounded, 'label': 'New Customer', 'color': const Color(0xFF3D5AF1), 'bg': const Color(0xFFEEEDFE)},
      {'icon': Icons.history_rounded, 'label': 'History', 'color': const Color(0xFFED8936), 'bg': const Color(0xFFFFF3E0)},
      {'icon': Icons.trending_up_rounded, 'label': 'Performance', 'color': const Color(0xFF9F7AEA), 'bg': const Color(0xFFF3E5F5)},
      {'icon': Icons.qr_code_rounded, 'label': 'My QR', 'color': const Color(0xFF00B5D8), 'bg': const Color(0xFFE0F7FA)},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Actions',
              style: TextStyle(
                  color: textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            childAspectRatio: 1.0,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: actions.map<Widget>((action) {
              final color = action['color'] as Color;
              final bg = action['bg'] as Color;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  final label = action['label'] as String;
                  if (label == 'Cash In') {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (_) => CashInScreen(
                              agentUserId: widget.userId)));
                  } else if (label == 'Cash Out') {
                    Navigator.push(context, MaterialPageRoute(
                 builder: (_) => CashOutScreen(
      agentUserId: widget.userId,
      agentPhone: widget.phone)));
                  } else if (label == 'History') {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (_) =>
                            HistoryScreen(userId: widget.userId)));
                  } else if (label == 'Performance') {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (_) => PerformanceScreen(
                              userId: widget.userId,
                              userName: widget.userName,
                            )));
                  } else if (label == 'New Customer') {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (_) => CustomerScreen(
                              agentId: widget.userId)));
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: bgCard,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 3))
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 52, height: 52,
                        decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(16)),
                        child: Icon(action['icon'] as IconData,
                            color: color, size: 26),
                      ),
                      const SizedBox(height: 8),
                      Text(action['label'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: textDark,
                              fontSize: 11,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => PerformanceScreen(
                  userId: widget.userId,
                  userName: widget.userName,
                ))),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3D5AF1), Color(0xFF00B5D8)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFF3D5AF1).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 5))
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Performance Score',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 4),
                    const Text('87/100',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: 0.87,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Top 15% of agents this month! 🏆',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 11)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                children: [
                  Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.emoji_events_rounded,
                        color: Color(0xFFFFD700), size: 32),
                  ),
                  const SizedBox(height: 8),
                  const Text('Gold Agent',
                      style: TextStyle(
                          color: Color(0xFFFFD700),
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentTransactions() {
    final txs = [
      {'name': 'Rahul Kumar', 'type': 'Cash In', 'amount': '₹2,000', 'time': '10:30 AM', 'isCredit': true},
      {'name': 'Priya Sharma', 'type': 'Cash Out', 'amount': '₹500', 'time': '11:15 AM', 'isCredit': false},
      {'name': 'Amit Singh', 'type': 'Cash In', 'amount': '₹1,500', 'time': '12:00 PM', 'isCredit': true},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Transactions',
                  style: TextStyle(
                      color: textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) =>
                        HistoryScreen(userId: widget.userId))),
                child: const Text('See all',
                    style: TextStyle(
                        color: Color(0xFF00897B),
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: bgCard,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10)
              ],
            ),
            child: Column(
              children: txs.map((tx) {
                final isCredit = tx['isCredit'] as bool;
                return Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: isCredit
                              ? const Color(0xFFE0F2F1)
                              : const Color(0xFFFCE4EC),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isCredit
                              ? Icons.arrow_downward_rounded
                              : Icons.arrow_upward_rounded,
                          color: isCredit ? green : Colors.red,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tx['name'] as String,
                                style: const TextStyle(
                                    color: textDark,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14)),
                            Text(tx['type'] as String,
                                style: const TextStyle(
                                    color: textLight, fontSize: 12)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(tx['amount'] as String,
                              style: TextStyle(
                                  color: isCredit ? green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                          Text(tx['time'] as String,
                              style: const TextStyle(
                                  color: textLight, fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: bgCard,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04), blurRadius: 10)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.flag_rounded,
                    color: Color(0xFF00897B), size: 20),
                SizedBox(width: 8),
                Text('Monthly Target',
                    style: TextStyle(
                        color: textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Collections',
                    style: TextStyle(color: textLight, fontSize: 13)),
                const Text('₹14,200 / ₹50,000',
                    style: TextStyle(
                        color: textDark,
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: 0.284,
                backgroundColor: Colors.grey.shade100,
                valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF00897B)),
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 4),
            const Text('28.4% completed — Keep going! 💪',
                style: TextStyle(color: textLight, fontSize: 11)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Customers',
                    style: TextStyle(color: textLight, fontSize: 13)),
                const Text('28 / 100',
                    style: TextStyle(
                        color: textDark,
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: 0.28,
                backgroundColor: Colors.grey.shade100,
                valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF3D5AF1)),
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 4),
            const Text('28% completed — 72 more to go!',
                style: TextStyle(color: textLight, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -5))
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.home_rounded, 'Home'),
              _navItem(1, Icons.swap_horiz_rounded, 'Transactions'),
              _navItem(2, Icons.trending_up_rounded, 'Performance'),
              _navItem(3, Icons.people_rounded, 'Customers'),
              _navItem(4, Icons.person_rounded, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
        if (index == 1) {
          Navigator.push(context, MaterialPageRoute(
              builder: (_) => HistoryScreen(userId: widget.userId)));
        } else if (index == 2) {
          Navigator.push(context, MaterialPageRoute(
              builder: (_) => PerformanceScreen(
                    userId: widget.userId,
                    userName: widget.userName,
                  )));
        } else if (index == 3) {
          Navigator.push(context, MaterialPageRoute(
              builder: (_) => CustomerScreen(agentId: widget.userId)));
        } else if (index == 4) {
          Navigator.push(context, MaterialPageRoute(
              builder: (_) => AgentProfileScreen(
                    userId: widget.userId,
                    userName: widget.userName,
                    phone: widget.phone,
                  )));
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF00897B).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: isSelected
                    ? const Color(0xFF00897B)
                    : Colors.black38,
                size: 24),
            const SizedBox(height: 3),
            Text(label,
                style: TextStyle(
                    color: isSelected
                        ? const Color(0xFF00897B)
                        : Colors.black38,
                    fontSize: 10,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}