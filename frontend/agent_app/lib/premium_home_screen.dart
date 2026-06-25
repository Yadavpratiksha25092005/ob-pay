import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:fl_chart/fl_chart.dart';
import 'api_service.dart';
import 'wallet_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'add_money_screen.dart';
import 'bills_screen.dart';
import 'kyc_screen.dart';
import 'qr_scanner_screen.dart';
import 'notification_screen.dart';
<<<<<<< HEAD
import 'agent_qr_screen.dart';
=======
import 'settings_screen.dart';
import 'rewards_screen.dart';
import 'contacts_screen.dart';
>>>>>>> 1599325dc4419b4965a88810dc274c34cfc0e110
import 'main.dart' show themeNotifier;

class PremiumHomeScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const PremiumHomeScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<PremiumHomeScreen> createState() => _PremiumHomeScreenState();
}

class _PremiumHomeScreenState extends State<PremiumHomeScreen>
    with TickerProviderStateMixin {
  Map<String, dynamic>? wallet;
  bool isLoading = true;
  bool showBalance = true;
  int _currentIndex = 0;
<<<<<<< HEAD

  static const Color green = Color(0xFF00897B);
  static const Color darkGreen = Color(0xFF004D40);
  Color bgPage = const Color(0xFFF5F5F5);
  Color bgCard = Colors.white;
  Color textDark = const Color(0xFF1A202C);
  Color textLight = const Color(0xFF718096);
=======
  late AnimationController _cardController;
  late Animation<double> _cardAnimation;
>>>>>>> 1599325dc4419b4965a88810dc274c34cfc0e110

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _cardAnimation = CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOutBack,
    );
    _cardController.forward();
    loadWallet();
  }

  @override
<<<<<<< HEAD
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    bgPage = isDark ? const Color(0xFF0B1437) : const Color(0xFFF5F5F5);
    bgCard = isDark ? const Color(0xFF111C44) : Colors.white;
    textDark = isDark ? Colors.white : const Color(0xFF1A202C);
    textLight = isDark ? Colors.white60 : const Color(0xFF718096);
  }

  Future<void> loadData() async {
=======
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }

  Future<void> loadWallet() async {
>>>>>>> 1599325dc4419b4965a88810dc274c34cfc0e110
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

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Color get _bgPage => Theme.of(context).scaffoldBackgroundColor;
  Color get _bgCard => Theme.of(context).cardColor;
  Color get _textDark => Theme.of(context).brightness == Brightness.dark
      ? Colors.white
      : const Color(0xFF1A202C);
  Color get _textLight => Theme.of(context).brightness == Brightness.dark
      ? Colors.white60
      : const Color(0xFF718096);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgPage,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildAppBar(),
                    _buildWalletCard(),
                    const SizedBox(height: 20),
                    _buildQuickActions(),
                    const SizedBox(height: 20),
                    _buildScanButton(),
                    const SizedBox(height: 20),
                    _buildSpendingChart(),
                    const SizedBox(height: 20),
                    _buildRecentTransactions(),
                    const SizedBox(height: 20),
                    _buildAnalyticsCards(),
                    const SizedBox(height: 20),
                    _buildOffersSection(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: _bgCard,
          boxShadow: [
            BoxShadow(
<<<<<<< HEAD
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8)
          ],
        ),
        child: Icon(
          mode == ThemeMode.light
              ? Icons.dark_mode_rounded
              : Icons.light_mode_rounded,
          color: textDark,
          size: 22,
        ),
      ),
    );
  },
),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$greeting 👋',
                    style: TextStyle(
                        color: textLight, fontSize: 12)),
                Text(widget.userName,
                    style: TextStyle(
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
                  child: Icon(Icons.notifications_outlined,
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
                        style: TextStyle(
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
          Text('Quick Actions',
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
                  } else if (label == 'My QR') {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (_) => AgentQRScreen(
                              userId: widget.userId,
                              userName: widget.userName,
                              phone: widget.phone,
                            )));
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
                          style: TextStyle(
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
              Text('Recent Transactions',
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
                                style: TextStyle(
                                    color: textDark,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14)),
                            Text(tx['type'] as String,
                                style: TextStyle(
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
                              style: TextStyle(
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
            Row(
              children: [
                const Icon(Icons.flag_rounded,
                    color: Color(0xFF00897B), size: 20),
                const SizedBox(width: 8),
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
                Text('Collections',
                    style: TextStyle(color: textLight, fontSize: 13)),
                Text('₹14,200 / ₹50,000',
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
            Text('28.4% completed — Keep going! 💪',
                style: TextStyle(color: textLight, fontSize: 11)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Customers',
                    style: TextStyle(color: textLight, fontSize: 13)),
                Text('28 / 100',
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
            Text('28% completed — 72 more to go!',
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
=======
>>>>>>> 1599325dc4419b4965a88810dc274c34cfc0e110
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(0, Icons.home_rounded, 'Home'),
                _navItem(1, Icons.receipt_long_rounded, 'Transactions'),
                _scanButton2(),
                _navItem(3, Icons.star_rounded, 'Rewards'),
                _navItem(4, Icons.person_rounded, 'Profile'),
              ],
            ),
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
        } else if (index == 3) {
          Navigator.push(context, MaterialPageRoute(
              builder: (_) => RewardsScreen(userId: widget.userId)));
        } else if (index == 4) {
          Navigator.push(context, MaterialPageRoute(
              builder: (_) => ProfileScreen(
                    userId: widget.userId,
                    userName: widget.userName,
                    phone: '',
                  )));
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF6C63FF).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: isSelected ? const Color(0xFF6C63FF) : Colors.black38,
                size: 24),
            const SizedBox(height: 3),
            Text(label,
                style: TextStyle(
                    color: isSelected
                        ? const Color(0xFF6C63FF)
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

  Widget _scanButton2() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        Navigator.push(context, MaterialPageRoute(
            builder: (_) => QRScannerScreen(userId: widget.userId)));
      },
      child: Container(
        width: 56, height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF11998E).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.qr_code_scanner_rounded,
            color: Colors.white, size: 26),
      ),
    );
  }

  Widget _buildAppBar() {
    return FadeInDown(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => ProfileScreen(
                        userId: widget.userId,
                        userName: widget.userName,
                        phone: '',
                      ))),
              child: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF3D5AF1)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C63FF).withOpacity(0.3),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 22),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$greeting 👋',
                      style: TextStyle(color: _textLight, fontSize: 12)),
                  Text(widget.userName,
                      style: TextStyle(
                          color: _textDark,
                          fontSize: 17,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => NotificationScreen(userId: widget.userId))),
              child: Stack(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: _bgCard,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(Icons.notifications_outlined,
                        color: _textDark, size: 22),
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
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => SettingsScreen(userId: widget.userId))),
              child: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: _bgCard,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(Icons.settings_outlined,
                    color: _textDark, size: 22),
              ),
            ),
            const SizedBox(width: 8),
            ValueListenableBuilder<ThemeMode>(
              valueListenable: themeNotifier,
              builder: (context, mode, child) {
                return GestureDetector(
                  onTap: () {
                    themeNotifier.value = mode == ThemeMode.light
                        ? ThemeMode.dark
                        : ThemeMode.light;
                  },
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: _bgCard,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      mode == ThemeMode.light
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      color: _textDark,
                      size: 22,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletCard() {
    return FadeInDown(
      delay: const Duration(milliseconds: 200),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: ScaleTransition(
          scale: _cardAnimation,
          child: Container(
            width: double.infinity,
            height: 210,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF6C63FF), Color(0xFF3D5AF1), Color(0xFF1E3A8A)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withOpacity(0.45),
                  blurRadius: 25,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -30, right: -20,
                  child: Container(
                    width: 140, height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.07),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -40, left: 10,
                  child: Container(
                    width: 160, height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.05),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.account_balance_wallet,
                                    color: Colors.white, size: 13),
                                SizedBox(width: 5),
                                Text('OB Wallet',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              setState(() => showBalance = !showBalance);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                showBalance
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: Colors.white, size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Text('Total Balance',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 4),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        child: Text(
                          showBalance
                              ? '₹ ${balance.toStringAsFixed(2)}'
                              : '₹ ••••••',
                          key: ValueKey(showBalance),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Daily Limit',
                                  style: TextStyle(
                                      color: Colors.white60, fontSize: 11)),
                              Text(
                                  '₹ ${wallet?['daily_limit'] ?? 10000}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.circle,
                                    color: Colors.greenAccent, size: 8),
                                SizedBox(width: 5),
                                Text('Active',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {'icon': Icons.send_rounded, 'label': 'Send', 'color': const Color(0xFF6C63FF), 'bg': const Color(0xFFEEEDFE), 'screen': 'send'},
      {'icon': Icons.add_circle_rounded, 'label': 'Add Money', 'color': const Color(0xFFFF9800), 'bg': const Color(0xFFFFF3E0), 'screen': 'add'},
      {'icon': Icons.history_rounded, 'label': 'History', 'color': const Color(0xFFE91E63), 'bg': const Color(0xFFFCE4EC), 'screen': 'history'},
      {'icon': Icons.receipt_rounded, 'label': 'Bills', 'color': const Color(0xFF009688), 'bg': const Color(0xFFE0F2F1), 'screen': 'bills'},
      {'icon': Icons.people_rounded, 'label': 'Contacts', 'color': const Color(0xFF00897B), 'bg': const Color(0xFFE0F2F1), 'screen': 'contacts'},
      {'icon': Icons.verified_user_rounded, 'label': 'KYC', 'color': const Color(0xFF9C27B0), 'bg': const Color(0xFFF3E5F5), 'screen': 'kyc'},
    ];

    return FadeInUp(
      delay: const Duration(milliseconds: 300),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: GridView.count(
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
                final screen = action['screen'] as String;
                if (screen == 'send') {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (_) => WalletScreen(userId: widget.userId)));
                } else if (screen == 'add') {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (_) => AddMoneyScreen(userId: widget.userId)));
                } else if (screen == 'history') {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (_) => HistoryScreen(userId: widget.userId)));
                } else if (screen == 'bills') {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (_) => BillsScreen(userId: widget.userId)));
                } else if (screen == 'contacts') {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (_) => ContactsScreen(userId: widget.userId)));
                } else if (screen == 'kyc') {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (_) => KYCScreen(userId: widget.userId)));
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _bgCard,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
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
                          color: color, size: 24),
                    ),
                    const SizedBox(height: 8),
                    Text(action['label'] as String,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: _textDark,
                            fontSize: 12,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildScanButton() {
    return FadeInUp(
      delay: const Duration(milliseconds: 350),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            Navigator.push(context, MaterialPageRoute(
                builder: (_) => QRScannerScreen(userId: widget.userId)));
          },
          child: Container(
            width: double.infinity,
            height: 58,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF11998E).withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.qr_code_scanner, color: Colors.white, size: 24),
                SizedBox(width: 10),
                Text('Scan & Pay',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpendingChart() {
    return FadeInUp(
      delay: const Duration(milliseconds: 400),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _bgCard,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Spending Overview',
                      style: TextStyle(
                          color: _textDark,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEEDFE),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('This Week',
                        style: TextStyle(
                            color: Color(0xFF6C63FF),
                            fontSize: 11,
                            fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 150,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 300,
                      getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.grey.withOpacity(0.1),
                          strokeWidth: 1),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                  days[value.toInt() % 7],
                                  style: TextStyle(
                                      fontSize: 11, color: _textLight)),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: const [
                          FlSpot(0, 200), FlSpot(1, 500),
                          FlSpot(2, 300), FlSpot(3, 800),
                          FlSpot(4, 400), FlSpot(5, 900), FlSpot(6, 600),
                        ],
                        isCurved: true,
                        gradient: const LinearGradient(
                            colors: [Color(0xFF6C63FF), Color(0xFF3D5AF1)]),
                        barWidth: 3,
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color(0xFF6C63FF).withOpacity(0.15),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, bar, index) =>
                              FlDotCirclePainter(
                                  radius: 4,
                                  color: const Color(0xFF6C63FF),
                                  strokeWidth: 2,
                                  strokeColor: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentTransactions() {
    final transactions = [
      {'name': 'Money Received', 'amount': '+₹500', 'isCredit': true, 'icon': Icons.arrow_downward_rounded, 'time': '2 min ago', 'category': 'Transfer'},
      {'name': 'Money Sent', 'amount': '-₹200', 'isCredit': false, 'icon': Icons.arrow_upward_rounded, 'time': '1 hour ago', 'category': 'Transfer'},
      {'name': 'Electricity Bill', 'amount': '-₹299', 'isCredit': false, 'icon': Icons.electric_bolt, 'time': '3 hours ago', 'category': 'Bills'},
      {'name': 'Jio Recharge', 'amount': '-₹149', 'isCredit': false, 'icon': Icons.phone_android, 'time': 'Yesterday', 'category': 'Recharge'},
    ];

    return FadeInUp(
      delay: const Duration(milliseconds: 500),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _bgCard,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recent Transactions',
                      style: TextStyle(
                          color: _textDark,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) =>
                            HistoryScreen(userId: widget.userId))),
                    child: const Text('See all',
                        style: TextStyle(
                            color: Color(0xFF6C63FF),
                            fontSize: 13,
                            fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...transactions.map((tx) {
                final isCredit = tx['isCredit'] as bool;
                final color = isCredit
                    ? const Color(0xFF00C853)
                    : const Color(0xFFE91E63);
                final bg = isCredit
                    ? const Color(0xFFE8F5E9)
                    : const Color(0xFFFCE4EC);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(14)),
                        child: Icon(tx['icon'] as IconData,
                            color: color, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tx['name'] as String,
                                style: TextStyle(
                                    color: _textDark,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14)),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(tx['category'] as String,
                                      style: TextStyle(
                                          color: _textLight, fontSize: 10)),
                                ),
                                const SizedBox(width: 6),
                                Text(tx['time'] as String,
                                    style: TextStyle(
                                        color: _textLight, fontSize: 11)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Text(tx['amount'] as String,
                          style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsCards() {
    return FadeInUp(
      delay: const Duration(milliseconds: 600),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6B6B).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.arrow_upward_rounded,
                            color: Colors.white, size: 22),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          child: Text('+12%',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text('₹1,248',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                    Text('Total Spent',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 12)),
                    Text('This month',
                        style: TextStyle(
                            color: Colors.white60, fontSize: 10)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF11998E).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.arrow_downward_rounded,
                            color: Colors.white, size: 22),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          child: Text('+8%',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text('₹2,500',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                    Text('Received',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 12)),
                    Text('This month',
                        style: TextStyle(
                            color: Colors.white60, fontSize: 10)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOffersSection() {
    final offers = [
      {'title': '10% Cashback', 'subtitle': 'On mobile recharge', 'colors': [const Color(0xFF6C63FF), const Color(0xFF3D5AF1)], 'icon': Icons.phone_android},
      {'title': '5% Off', 'subtitle': 'On electricity bills', 'colors': [const Color(0xFFFF6B35), const Color(0xFFFF9800)], 'icon': Icons.electric_bolt},
      {'title': 'Free Transfer', 'subtitle': 'Send up to ₹1000', 'colors': [const Color(0xFF11998E), const Color(0xFF38EF7D)], 'icon': Icons.send},
    ];

    return FadeInUp(
      delay: const Duration(milliseconds: 700),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Offers & Rewards',
                    style: TextStyle(
                        color: _textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) =>
                          RewardsScreen(userId: widget.userId))),
                  child: const Text('View All',
                      style: TextStyle(
                          color: Color(0xFF6C63FF),
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 115,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: offers.length,
                itemBuilder: (context, index) {
                  final offer = offers[index];
                  final colors = offer['colors'] as List<Color>;
                  return Container(
                    width: 165,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: colors,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: colors[0].withOpacity(0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(offer['icon'] as IconData,
                            color: Colors.white70, size: 22),
                        const Spacer(),
                        Text(offer['title'] as String,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(offer['subtitle'] as String,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}