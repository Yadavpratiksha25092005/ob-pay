import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:fl_chart/fl_chart.dart';
import 'api_service.dart';
import 'qr_screen.dart';
import 'history_screen.dart';
import 'settlement_screen.dart';
import 'analytics_screen.dart';
import 'refund_screen.dart';
import 'notification_screen.dart';
import 'profile_screen.dart';
import 'add_money_screen.dart';
import 'support_screen.dart';
import 'merchant_qr_scanner_screen.dart';
import 'kyc_screen.dart';

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

class _PremiumHomeScreenState extends State<PremiumHomeScreen>
    with TickerProviderStateMixin {
  Map<String, dynamic>? wallet;
  bool isLoading = true;
  bool showBalance = true;
  String selectedPeriod = 'Weekly';
  int _selectedNav = 0;
  bool _drawerOpen = false;
  bool kycPending = true;

  static const Color bgPage = Color(0xFFF5F5F5);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color bgSidebar = Color(0xFF0A1128);
  static const Color blue = Color(0xFF3D5AF1);
  static const Color cyan = Color(0xFF00B5D8);
  static const Color textDark = Color(0xFF1A202C);
  static const Color textMid = Color(0xFF4A5568);
  static const Color textLight = Color(0xFF718096);

  final Map<String, List<double>> chartData = {
    'Daily': [800, 1200, 600, 1800, 900, 2100, 800],
    'Weekly': [1200, 2500, 800, 3200, 1800, 4500, 2100],
    'Monthly': [8200, 12400, 9800, 16200, 11000, 14500, 18000],
  };

  final Map<String, List<String>> chartLabels = {
    'Daily': ['9am', '11am', '1pm', '3pm', '5pm', '7pm', '9pm'],
    'Weekly': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    'Monthly': ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'],
  };

  final Map<String, String> chartTotals = {
    'Daily': '₹ 8,200',
    'Weekly': '₹ 68,750',
    'Monthly': '₹ 90,300',
  };

  final List<Map<String, dynamic>> navItems = [
    {'icon': Icons.dashboard_rounded, 'label': 'Dashboard'},
    {'icon': Icons.receipt_long_rounded, 'label': 'Transactions'},
    {'icon': Icons.qr_code_rounded, 'label': 'My QR'},
    {'icon': Icons.account_balance_rounded, 'label': 'Settlements'},
    {'icon': Icons.trending_up_rounded, 'label': 'Analytics'},
    {'icon': Icons.keyboard_return_rounded, 'label': 'Refunds'},
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    loadWallet();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkKYC());
  }

  Future<void> _checkKYC() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.verified_user_rounded, color: Color(0xFF3D5AF1)),
            SizedBox(width: 10),
            Text('KYC Required'),
          ],
        ),
        content: const Text(
          'Complete your KYC verification to access all features of OB Pay Business.',
          style: TextStyle(color: Color(0xFF718096)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later',
                style: TextStyle(color: Color(0xFF718096))),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      MerchantKYCScreen(userId: widget.userId),
                ),
              );
              if (result == true) {
                setState(() => kycPending = false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3D5AF1),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Complete KYC',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
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

  String getBalance() {
    try {
      if (wallet == null) return '0.00';
      final b = wallet!['balance'];
      if (b == null) return '0.00';
      double val = 0.0;
      if (b is int) val = b.toDouble();
      else if (b is double) val = b;
      else val = double.tryParse(b.toString()) ?? 0.0;
      return val.toStringAsFixed(2);
    } catch (e) {
      return '0.00';
    }
  }

  double getBalanceDouble() {
    try {
      if (wallet == null) return 0.0;
      final b = wallet!['balance'];
      if (b == null) return 0.0;
      if (b is int) return b.toDouble();
      if (b is double) return b;
      return double.tryParse(b.toString()) ?? 0.0;
    } catch (e) {
      return 0.0;
    }
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
          : Stack(
              children: [
                SafeArea(
                  child: Column(
                    children: [
                      _buildTopBar(),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildGreeting(),
                              const SizedBox(height: 16),
                              if (kycPending) _buildKYCBanner(),
                              if (kycPending) const SizedBox(height: 16),
                              _buildBalanceCard(),
                              const SizedBox(height: 16),
                              _buildQuickActions(),
                              const SizedBox(height: 16),
                              _buildKPIRow(),
                              const SizedBox(height: 16),
                              _buildRevenueChart(),
                              const SizedBox(height: 16),
                              _buildRecentTransactions(),
                              const SizedBox(height: 16),
                              _buildFooter(),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_drawerOpen)
                  GestureDetector(
                    onTap: () => setState(() => _drawerOpen = false),
                    child:
                        Container(color: Colors.black.withOpacity(0.5)),
                  ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  left: _drawerOpen ? 0 : -260,
                  top: 0,
                  bottom: 0,
                  child: _buildSidebar(),
                ),
              ],
            ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      color: bgCard,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => setState(() => _drawerOpen = !_drawerOpen),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: bgPage,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Icon(Icons.menu_rounded, color: textDark, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => showSearch(
                  context: context,
                  delegate: MerchantSearchDelegate()),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: bgPage,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    Icon(Icons.search_rounded, color: textLight, size: 18),
                    const SizedBox(width: 8),
                    Text('Search...',
                        style: TextStyle(color: textLight, fontSize: 14)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => MerchantNotificationScreen(
                        userId: widget.userId))),
            child: Stack(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: bgPage,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Icon(Icons.notifications_outlined,
                      color: textDark, size: 20),
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
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => MerchantProfileScreen(
                          userId: widget.userId,
                          userName: widget.userName,
                          phone: widget.phone,
                        ))),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [blue, cyan]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  widget.userName.isNotEmpty
                      ? widget.userName[0].toUpperCase()
                      : 'M',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreeting() {
    return FadeInDown(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$greeting, ${widget.userName}! 👋',
              style: const TextStyle(
                  color: textDark,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text("Here's what's happening with your business today.",
              style: TextStyle(color: textLight, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildKYCBanner() {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) =>
                    MerchantKYCScreen(userId: widget.userId)));
        if (result == true) {
          setState(() => kycPending = false);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3E0),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: const Color(0xFFED8936).withOpacity(0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_rounded,
                color: Color(0xFFED8936), size: 22),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('KYC Pending!',
                      style: TextStyle(
                          color: Color(0xFF854F0B),
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                  Text('Complete KYC to unlock all features',
                      style: TextStyle(
                          color: Color(0xFF854F0B), fontSize: 11)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFED8936),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Complete Now',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return FadeInDown(
      delay: const Duration(milliseconds: 100),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A56DB), Color(0xFF3D5AF1)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: blue.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 8))
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
                    color: Colors.white.withOpacity(0.07)),
              ),
            ),
            Positioned(
              bottom: -40, right: 40,
              child: Container(
                width: 160, height: 160,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.04)),
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
                        Text('Available Balance',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 13)),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            setState(() => showBalance = !showBalance);
                          },
                          child: Icon(
                            showBalance
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Colors.white70, size: 16,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.green.withOpacity(0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.circle,
                              color: Colors.greenAccent, size: 7),
                          SizedBox(width: 4),
                          Text('Active',
                              style: TextStyle(
                                  color: Colors.greenAccent,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    showBalance
                        ? '₹ ${getBalance()}'
                        : '₹ ••••••',
                    key: ValueKey(showBalance),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.trending_up_rounded,
                        color: Colors.greenAccent, size: 14),
                    const SizedBox(width: 4),
                    Text('+12.5% from yesterday',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12)),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("Today's Earnings",
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 10)),
                        Text('₹ ${getBalance()}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => SettlementScreen(
                                    userId: widget.userId,
                                    balance: getBalanceDouble()))),
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(vertical: 11),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12)),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.account_balance_rounded,
                                  color: blue, size: 16),
                              SizedBox(width: 6),
                              Text('Withdraw Funds',
                                  style: TextStyle(
                                      color: blue,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => MerchantAddMoneyScreen(
                                    userId: widget.userId,
                                    balance: getBalance()))),
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(vertical: 11),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.3)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_rounded,
                                  color: Colors.white, size: 16),
                              SizedBox(width: 6),
                              Text('Add Money',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {'icon': Icons.qr_code_scanner_rounded, 'label': 'Scan QR', 'color': const Color(0xFF6C63FF), 'bg': const Color(0xFFEEEDFE)},
      {'icon': Icons.qr_code_rounded, 'label': 'My QR', 'color': const Color(0xFF00B5D8), 'bg': const Color(0xFFE0F7FA)},
      {'icon': Icons.list_alt_rounded, 'label': 'Transactions', 'color': const Color(0xFF48BB78), 'bg': const Color(0xFFE8F5E9)},
      {'icon': Icons.account_balance_rounded, 'label': 'Settlement', 'color': const Color(0xFFED8936), 'bg': const Color(0xFFFFF3E0)},
      {'icon': Icons.arrow_downward_rounded, 'label': 'Withdraw', 'color': const Color(0xFF9F7AEA), 'bg': const Color(0xFFF3E5F5)},
      {'icon': Icons.bar_chart_rounded, 'label': 'Analytics', 'color': const Color(0xFFFC8181), 'bg': const Color(0xFFFCEBEB)},
      {'icon': Icons.keyboard_return_rounded, 'label': 'Refunds', 'color': const Color(0xFF68D391), 'bg': const Color(0xFFE8F5E9)},
      {'icon': Icons.verified_user_rounded, 'label': 'KYC', 'color': const Color(0xFF9F7AEA), 'bg': const Color(0xFFF3E5F5)},
    ];

    return FadeInUp(
      delay: const Duration(milliseconds: 150),
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
            crossAxisCount: 4,
            childAspectRatio: 0.85,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: actions.map<Widget>((action) {
              final color = action['color'] as Color;
              final bg = action['bg'] as Color;
              return GestureDetector(
                onTap: () async {
                  HapticFeedback.lightImpact();
                  final label = action['label'] as String;
                  if (label == 'Scan QR') {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (_) => MerchantQRScannerScreen(
                            userId: widget.userId)));
                  } else if (label == 'My QR') {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (_) => QRScreen(
                            userId: widget.userId,
                            userName: widget.userName,
                            phone: widget.phone)));
                  } else if (label == 'Transactions') {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (_) =>
                            HistoryScreen(userId: widget.userId)));
                  } else if (label == 'Settlement' ||
                      label == 'Withdraw') {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (_) => SettlementScreen(
                            userId: widget.userId,
                            balance: getBalanceDouble())));
                  } else if (label == 'Analytics') {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (_) =>
                            AnalyticsScreen(userId: widget.userId)));
                  } else if (label == 'Refunds') {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (_) =>
                            RefundScreen(userId: widget.userId)));
                  } else if (label == 'KYC') {
                    final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => MerchantKYCScreen(
                                userId: widget.userId)));
                    if (result == true) {
                      setState(() => kycPending = false);
                    }
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: bgCard,
                    borderRadius: BorderRadius.circular(16),
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
                        width: 48, height: 48,
                        decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(14)),
                        child: Icon(action['icon'] as IconData,
                            color: color, size: 22),
                      ),
                      const SizedBox(height: 8),
                      Text(action['label'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: textMid,
                              fontSize: 10,
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

  Widget _buildKPIRow() {
    final kpis = [
      {'title': "Today's Revenue", 'value': '₹ ${getBalance()}', 'change': '+10.5%', 'up': true, 'color': const Color(0xFF48BB78), 'icon': Icons.arrow_downward_rounded},
      {'title': 'Total Transactions', 'value': '128', 'change': '+15.3%', 'up': true, 'color': cyan, 'icon': Icons.receipt_long_rounded},
      {'title': 'Pending Settlements', 'value': '₹ 8,750', 'change': '-8.2%', 'up': false, 'color': const Color(0xFFED8936), 'icon': Icons.pending_rounded},
      {'title': 'Successful Settlements', 'value': '₹ 16,680', 'change': '+22.5%', 'up': true, 'color': const Color(0xFF9F7AEA), 'icon': Icons.check_circle_rounded},
    ];

    return FadeInUp(
      delay: const Duration(milliseconds: 200),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 1.6,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        children: kpis.map<Widget>((kpi) {
          final color = kpi['color'] as Color;
          final up = kpi['up'] as bool;
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: bgCard,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8)),
                      child: Icon(kpi['icon'] as IconData,
                          color: color, size: 16),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: up
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(kpi['change'] as String,
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
                Text(kpi['value'] as String,
                    style: const TextStyle(
                        color: textDark,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(kpi['title'] as String,
                    style: const TextStyle(
                        color: textLight, fontSize: 10)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRevenueChart() {
    final data = chartData[selectedPeriod]!;
    final labels = chartLabels[selectedPeriod]!;

    return FadeInUp(
      delay: const Duration(milliseconds: 250),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: bgCard,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 15,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Revenue Overview',
                          style: TextStyle(
                              color: textDark,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        children: [
                          Text(chartTotals[selectedPeriod]!,
                              style: const TextStyle(
                                  color: textDark,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('+16.7%',
                                style: TextStyle(
                                    color: Color(0xFF3B6D11),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)),
                          ),
                          Text('this week',
                              style: TextStyle(
                                  color: textLight, fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  children:
                      ['Daily', 'Weekly', 'Monthly'].map((p) {
                    return GestureDetector(
                      onTap: () =>
                          setState(() => selectedPeriod = p),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: selectedPeriod == p
                              ? blue
                              : bgPage,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(p,
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: selectedPeriod == p
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: selectedPeriod == p
                                    ? Colors.white
                                    : textLight)),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 130,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 2000,
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
                          final idx = value.toInt();
                          if (idx < 0 || idx >= labels.length)
                            return const SizedBox();
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(labels[idx],
                                style: TextStyle(
                                    fontSize: 10, color: textLight)),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: data
                          .asMap()
                          .entries
                          .map((e) =>
                              FlSpot(e.key.toDouble(), e.value))
                          .toList(),
                      isCurved: true,
                      gradient: const LinearGradient(
                          colors: [blue, cyan]),
                      barWidth: 2.5,
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            blue.withOpacity(0.2),
                            Colors.transparent
                          ],
                        ),
                      ),
                      dotData: FlDotData(
                        show: true,
                        getDotPainter:
                            (spot, percent, bar, index) =>
                                FlDotCirclePainter(
                                    radius: 3,
                                    color: blue,
                                    strokeWidth: 1.5,
                                    strokeColor: bgCard),
                      ),
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

  Widget _buildRecentTransactions() {
    final transactions = [
      {'name': 'Rohit Sharma', 'sub': 'UPI Payment', 'amount': '₹ 1,250', 'time': '10:24 AM', 'status': 'Success', 'color': const Color(0xFF6C63FF)},
      {'name': 'Priya Patel', 'sub': 'UPI Payment', 'amount': '₹ 650', 'time': '09:48 AM', 'status': 'Success', 'color': const Color(0xFF48BB78)},
      {'name': 'Amazon India', 'sub': 'Refund', 'amount': '₹ 450', 'time': '09:15 AM', 'status': 'Refund', 'color': const Color(0xFFED8936)},
      {'name': 'Vikram Singh', 'sub': 'UPI Payment', 'amount': '₹ 2,200', 'time': 'Yesterday', 'status': 'Success', 'color': const Color(0xFF9F7AEA)},
      {'name': 'Neha Verma', 'sub': 'UPI Payment', 'amount': '₹ 1,100', 'time': 'Yesterday', 'status': 'Success', 'color': cyan},
    ];

    return FadeInUp(
      delay: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: bgCard,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 15,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
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
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              HistoryScreen(userId: widget.userId))),
                  child: Text('View All',
                      style: TextStyle(color: blue, fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...transactions.map<Widget>((tx) {
              final status = tx['status'] as String;
              Color statusColor;
              Color statusBg;
              if (status == 'Success') {
                statusColor = const Color(0xFF3B6D11);
                statusBg = const Color(0xFFEAF3DE);
              } else if (status == 'Refund') {
                statusColor = const Color(0xFF854F0B);
                statusBg = const Color(0xFFFAEEDA);
              } else {
                statusColor = Colors.red;
                statusBg = const Color(0xFFFCEBEB);
              }
              final color = tx['color'] as Color;
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          shape: BoxShape.circle),
                      child: Center(
                        child: Text((tx['name'] as String)[0],
                            style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
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
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13)),
                          Text(tx['sub'] as String,
                              style: const TextStyle(
                                  color: textLight, fontSize: 11)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(tx['amount'] as String,
                            style: const TextStyle(
                                color: textDark,
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                  color: statusBg,
                                  borderRadius:
                                      BorderRadius.circular(10)),
                              child: Text(status,
                                  style: TextStyle(
                                      color: statusColor,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 6),
                            Text(tx['time'] as String,
                                style: const TextStyle(
                                    color: textLight, fontSize: 10)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [blue.withOpacity(0.08), cyan.withOpacity(0.05)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: blue.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [blue, cyan]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.shield_rounded,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Secure. Fast. Reliable.',
                    style: TextStyle(
                        color: textDark,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
                Text('OB Pay trusted by 100K+ merchants',
                    style: TextStyle(color: textLight, fontSize: 10)),
              ],
            ),
          ),
          Row(
            children: [
              _FooterStat('100K+', 'Merchants'),
              const SizedBox(width: 12),
              _FooterStat('99.9%', 'Uptime'),
              const SizedBox(width: 12),
              _FooterStat('24/7', 'Support'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 240,
      color: bgSidebar,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      gradient:
                          const LinearGradient(colors: [blue, cyan]),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.account_balance_wallet,
                        color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Text('OneBharat Pay',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const Divider(color: Colors.white12, height: 1),
            const SizedBox(height: 8),
            ...navItems.map<Widget>((item) {
              final i = navItems.indexOf(item);
              final isSelected = _selectedNav == i;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedNav = i;
                    _drawerOpen = false;
                  });
                  final label = item['label'] as String;
                  if (label == 'Transactions') {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (_) =>
                            HistoryScreen(userId: widget.userId)));
                  } else if (label == 'My QR') {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (_) => QRScreen(
                            userId: widget.userId,
                            userName: widget.userName,
                            phone: widget.phone)));
                  } else if (label == 'Settlements') {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (_) => SettlementScreen(
                            userId: widget.userId,
                            balance: getBalanceDouble())));
                  } else if (label == 'Analytics') {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (_) =>
                            AnalyticsScreen(userId: widget.userId)));
                  } else if (label == 'Refunds') {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (_) =>
                            RefundScreen(userId: widget.userId)));
                  }
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 2),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? blue.withOpacity(0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(color: blue.withOpacity(0.3))
                        : null,
                  ),
                  child: Row(
                    children: [
                      Icon(item['icon'] as IconData,
                          color: isSelected
                              ? cyan
                              : Colors.white.withOpacity(0.5),
                          size: 18),
                      const SizedBox(width: 12),
                      Text(item['label'] as String,
                          style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.5),
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w500
                                  : FontWeight.normal)),
                    ],
                  ),
                ),
              );
            }).toList(),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _FooterStat extends StatelessWidget {
  final String value;
  final String label;

  const _FooterStat(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Color(0xFF1A202C),
                fontSize: 12,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(
                color: Color(0xFF718096), fontSize: 9)),
      ],
    );
  }
}

class MerchantSearchDelegate extends SearchDelegate {
  static const Color blue = Color(0xFF3D5AF1);
  static const Color textDark = Color(0xFF1A202C);
  static const Color textLight = Color(0xFF718096);

  final List<Map<String, dynamic>> searchItems = [
    {'title': 'Rohit Sharma', 'sub': 'UPI Payment • ₹1,250', 'icon': Icons.person_rounded, 'color': Color(0xFF6C63FF)},
    {'title': 'Priya Patel', 'sub': 'UPI Payment • ₹650', 'icon': Icons.person_rounded, 'color': Color(0xFF48BB78)},
    {'title': 'Settlement — HDFC', 'sub': 'Bank Transfer • ₹8,750', 'icon': Icons.account_balance_rounded, 'color': Color(0xFF3D5AF1)},
    {'title': 'Amazon India', 'sub': 'Refund • ₹450', 'icon': Icons.keyboard_return_rounded, 'color': Color(0xFFED8936)},
    {'title': 'Vikram Singh', 'sub': 'UPI Payment • ₹2,200', 'icon': Icons.person_rounded, 'color': Color(0xFF9F7AEA)},
    {'title': 'Neha Verma', 'sub': 'UPI Payment • ₹1,100', 'icon': Icons.person_rounded, 'color': Color(0xFF00B5D8)},
  ];

  @override
  String get searchFieldLabel => 'Search transactions, customers...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme:
          const AppBarTheme(backgroundColor: Colors.white, elevation: 0),
      inputDecorationTheme:
          const InputDecorationTheme(border: InputBorder.none),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear_rounded,
              color: Color(0xFF718096)),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_rounded,
          color: Color(0xFF1A202C)),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildList();

  @override
  Widget buildSuggestions(BuildContext context) => _buildList();

  Widget _buildList() {
    final results = query.isEmpty
        ? searchItems
        : searchItems
            .where((item) =>
                item['title']
                    .toString()
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                item['sub']
                    .toString()
                    .toLowerCase()
                    .contains(query.toLowerCase()))
            .toList();

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded,
                size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('No results for "$query"',
                style: const TextStyle(
                    color: Color(0xFF718096), fontSize: 15)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        final color = item['color'] as Color;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(item['icon'] as IconData,
                    color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['title'] as String,
                        style: const TextStyle(
                            color: Color(0xFF1A202C),
                            fontWeight: FontWeight.w500,
                            fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(item['sub'] as String,
                        style: const TextStyle(
                            color: Color(0xFF718096), fontSize: 12)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.grey.shade300, size: 14),
            ],
          ),
        );
      },
    );
  }
}