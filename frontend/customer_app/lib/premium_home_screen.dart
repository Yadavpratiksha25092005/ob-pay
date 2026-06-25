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
import 'my_qr_screen.dart';
import 'notification_screen.dart';

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
  late AnimationController _cardController;
  late Animation<double> _cardAnimation;

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
  void dispose() {
    _cardController.dispose();
    super.dispose();
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

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
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
      floatingActionButton: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          Navigator.push(context, MaterialPageRoute(
              builder: (_) => QRScannerScreen(userId: widget.userId)));
        },
        child: Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF11998E).withValues(alpha: 0.5),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.qr_code_scanner_rounded,
              color: Colors.white, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: Colors.white,
        elevation: 8,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.home_rounded, 'Home'),
              _navItem(1, Icons.receipt_long_rounded, 'Transactions'),
              const SizedBox(width: 60),
              _navItem(3, Icons.person_rounded, 'Profile'),
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
        } else if (index == 3) {
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
                    style: const TextStyle(color: Colors.black54, fontSize: 12)),
                Text(widget.userName,
                    style: const TextStyle(
                        color: Colors.black87,
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.notifications_outlined,
                      color: Colors.black87, size: 22),
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
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.account_balance_wallet, color: Colors.white, size: 13),
                                SizedBox(width: 5),
                                Text('OB Wallet', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
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
                                showBalance ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                color: Colors.white, size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text('Total Balance',
                          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                      const SizedBox(height: 4),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        child: Text(
                          showBalance ? '₹ ${balance.toStringAsFixed(2)}' : '₹ ••••••',
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
                              Text('Daily Limit',
                                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11)),
                              Text('₹ ${wallet?['daily_limit'] ?? 10000}',
                                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.circle, color: Colors.greenAccent, size: 8),
                                SizedBox(width: 5),
                                Text('Active', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
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
      {'icon': Icons.verified_user_rounded, 'label': 'KYC', 'color': const Color(0xFF9C27B0), 'bg': const Color(0xFFF3E5F5), 'screen': 'kyc'},
      {'icon': Icons.qr_code_rounded, 'label': 'My QR', 'color': const Color(0xFF6C63FF), 'bg': const Color(0xFFEEEDFE), 'screen': 'myqr'},
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
                } else if (screen == 'bills' || screen == 'recharge') {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (_) => BillsScreen(userId: widget.userId)));
                } else if (screen == 'kyc') {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (_) => KYCScreen(userId: widget.userId)));
                } else if (screen == 'myqr') {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (_) => MyQRScreen(
                            userId: widget.userId,
                            userName: widget.userName,
                          )));
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
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
                      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
                      child: Icon(action['icon'] as IconData, color: color, size: 24),
                    ),
                    const SizedBox(height: 8),
                    Text(action['label'] as String,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.black87,
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
            color: Colors.white,
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
                  const Text('Spending Overview',
                      style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEEDFE),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('This Week',
                        style: TextStyle(color: Color(0xFF6C63FF), fontSize: 11, fontWeight: FontWeight.w500)),
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
                        color: Colors.grey.withOpacity(0.1), strokeWidth: 1),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(days[value.toInt() % 7],
                                  style: const TextStyle(fontSize: 11, color: Colors.black38)),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: const [
                          FlSpot(0, 200), FlSpot(1, 500), FlSpot(2, 300),
                          FlSpot(3, 800), FlSpot(4, 400), FlSpot(5, 900), FlSpot(6, 600),
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
            color: Colors.white,
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
                  const Text('Recent Transactions',
                      style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => HistoryScreen(userId: widget.userId))),
                    child: const Text('See all',
                        style: TextStyle(color: Color(0xFF6C63FF), fontSize: 13, fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...transactions.map((tx) {
                final isCredit = tx['isCredit'] as bool;
                final color = isCredit ? const Color(0xFF00C853) : const Color(0xFFE91E63);
                final bg = isCredit ? const Color(0xFFE8F5E9) : const Color(0xFFFCE4EC);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
                        child: Icon(tx['icon'] as IconData, color: color, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tx['name'] as String,
                                style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 14)),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(tx['category'] as String,
                                      style: const TextStyle(color: Colors.black45, fontSize: 10)),
                                ),
                                const SizedBox(width: 6),
                                Text(tx['time'] as String,
                                    style: const TextStyle(color: Colors.black38, fontSize: 11)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Text(tx['amount'] as String,
                          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 22),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('+12%', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text('₹1,248', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    const Text('Total Spent', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const Text('This month', style: TextStyle(color: Colors.white60, fontSize: 10)),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.arrow_downward_rounded, color: Colors.white, size: 22),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('+8%', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text('₹2,500', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    const Text('Received', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const Text('This month', style: TextStyle(color: Colors.white60, fontSize: 10)),
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
                const Text('Offers & Rewards',
                    style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(),
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
                        Icon(offer['icon'] as IconData, color: Colors.white70, size: 22),
                        const Spacer(),
                        Text(offer['title'] as String,
                            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(offer['subtitle'] as String,
                            style: const TextStyle(color: Colors.white70, fontSize: 11)),
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