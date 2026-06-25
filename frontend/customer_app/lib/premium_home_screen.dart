import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'api_service.dart';
import 'wallet_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'add_money_screen.dart';
import 'bills_screen.dart';
import 'qr_scanner_screen.dart';
import 'notification_screen.dart';
import 'services_screen.dart';

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

  // ── Design tokens ────────────────────────────────────────────────────────
  static const Color _blue    = Color(0xFF2563EB);
  static const Color _bgPage  = Color(0xFFF8FAFF);
  static const Color _textPri = Color(0xFF111827);
  static const Color _textSec = Color(0xFF6B7280);
  static const Color _green   = Color(0xFF16A34A);
  static const Color _border  = Color(0xFFE5E7EB);

  // ── State ────────────────────────────────────────────────────────────────
  Map<String, dynamic>? _wallet;
  bool _loading = true;
  bool _showBalance = true;
  int _navIndex = 0;

  late AnimationController _cardCtrl;
  late Animation<double>    _cardAnim;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    _cardCtrl = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _cardAnim = CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOutCubic);
    _cardCtrl.forward();
    _loadWallet();
  }

  @override
  void dispose() {
    _cardCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadWallet() async {
    try {
      final data = await ApiService.getWallet(widget.userId);
      if (mounted) setState(() { _wallet = data; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  double get _balance {
    final b = _wallet?['balance'];
    if (b == null) return 0.0;
    if (b is int) return b.toDouble();
    if (b is double) return b;
    return double.tryParse(b.toString()) ?? 0.0;
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String get _initials {
    final parts = widget.userName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : '?';
  }

  String get _upiId {
    final name = widget.userName.trim().toLowerCase().replaceAll(' ', '.');
    return '$name@obpay';
  }

  void _go(Widget screen) {
    HapticFeedback.lightImpact();
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  // ── Scaffold ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: _bgPage,
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: _blue, strokeWidth: 2.5))
          : RefreshIndicator(
              color: _blue,
              displacement: 60,
              onRefresh: _loadWallet,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics()),
                slivers: [
                  SliverToBoxAdapter(child: SizedBox(height: topPad + 12)),
                  SliverToBoxAdapter(child: _header()),
                  SliverToBoxAdapter(child: const SizedBox(height: 20)),
                  SliverToBoxAdapter(child: _walletCard()),
                  SliverToBoxAdapter(child: const SizedBox(height: 20)),
                  SliverToBoxAdapter(child: _quickActions()),
                  SliverToBoxAdapter(child: const SizedBox(height: 20)),
                  SliverToBoxAdapter(child: _billsSection()),
                  SliverToBoxAdapter(child: const SizedBox(height: 20)),
                  SliverToBoxAdapter(child: _offerBanner()),
                  SliverToBoxAdapter(child: const SizedBox(height: 20)),
                  SliverToBoxAdapter(child: _recentTransactions()),
                  SliverToBoxAdapter(child: const SizedBox(height: 100)),
                ],
              ),
            ),
      floatingActionButton: _scanFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _bottomNav(),
    );
  }

  // ── FAB ──────────────────────────────────────────────────────────────────
  Widget _scanFab() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        _go(QRScannerScreen(userId: widget.userId));
      },
      child: Container(
        width: 60, height: 60,
        decoration: BoxDecoration(
          color: _blue,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _blue.withValues(alpha: 0.38),
              blurRadius: 18, offset: const Offset(0, 5)),
          ],
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 22),
            SizedBox(height: 2),
            Text('Scan QR',
                style: TextStyle(color: Colors.white, fontSize: 8,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  // ── Bottom nav ────────────────────────────────────────────────────────────
  Widget _bottomNav() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      color: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      child: Container(
        height: 64,
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: _border, width: 1))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(0, Icons.home_rounded, Icons.home_outlined, 'Home'),
            _navItem(1, Icons.receipt_long_rounded,
                Icons.receipt_long_outlined, 'Payments'),
            const SizedBox(width: 58),
            _navItem(3, Icons.apps_rounded, Icons.apps_outlined, 'Services'),
            _navItem(4, Icons.person_rounded,
                Icons.person_outlined, 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _navItem(int idx, IconData active, IconData inactive, String label) {
    final sel = _navIndex == idx;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() => _navIndex = idx);
        if (idx == 1) { _go(HistoryScreen(userId: widget.userId)); }
        if (idx == 3) { _go(const ServicesScreen()); }
        if (idx == 4) {
          _go(ProfileScreen(
              userId: widget.userId,
              userName: widget.userName,
              phone: ''));
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(sel ? active : inactive,
                color: sel ? _blue : const Color(0xFFBCC1CD), size: 24),
            const SizedBox(height: 3),
            Text(label,
                style: TextStyle(
                  color: sel ? _blue : const Color(0xFFBCC1CD),
                  fontSize: 10,
                  fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                )),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _header() {
    return FadeInDown(
      duration: const Duration(milliseconds: 400),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => _go(ProfileScreen(
                  userId: widget.userId,
                  userName: widget.userName,
                  phone: '')),
              child: Container(
                width: 46, height: 46,
                decoration: const BoxDecoration(
                    color: _blue, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(_initials,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 17,
                        fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Hi, ${widget.userName.split(' ').first}',
                          style: const TextStyle(
                              color: _textPri, fontSize: 17,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(width: 4),
                      const Text('👋', style: TextStyle(fontSize: 15)),
                    ],
                  ),
                  const SizedBox(height: 1),
                  Text(_greeting,
                      style: const TextStyle(color: _textSec, fontSize: 12)),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _go(NotificationScreen(userId: widget.userId)),
              child: Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _border),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8, offset: const Offset(0, 2)),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.notifications_outlined,
                        color: _textPri, size: 22),
                    Positioned(
                      top: 9, right: 10,
                      child: Container(
                        width: 7, height: 7,
                        decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                            shape: BoxShape.circle),
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

  // ── Wallet card ───────────────────────────────────────────────────────────
  Widget _walletCard() {
    return FadeInDown(
      delay: const Duration(milliseconds: 100),
      duration: const Duration(milliseconds: 400),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ScaleTransition(
          scale: _cardAnim,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1D4ED8), Color(0xFF2563EB), Color(0xFF3B82F6)],
                stops: [0.0, 0.55, 1.0],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _blue.withValues(alpha: 0.30),
                  blurRadius: 24, offset: const Offset(0, 10)),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                // Monument illustration (right side, line art)
                Positioned(
                  right: 0, top: 0, bottom: 0,
                  child: SizedBox(
                    width: 135,
                    child: CustomPaint(
                      painter: _MonumentPainter(
                          color: Colors.white.withValues(alpha: 0.16))),
                  ),
                ),

                // Card content
                Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Brand row
                      Row(
                        children: [
                          Container(
                            width: 28, height: 28,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle),
                            child: const Icon(Icons.currency_rupee_rounded,
                                color: Colors.white, size: 15),
                          ),
                          const SizedBox(width: 8),
                          const Text('OneBharat Pay',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600)),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              setState(() => _showBalance = !_showBalance);
                            },
                            child: Icon(
                              _showBalance
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.white60, size: 20),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Balance
                      const Text('Total Balance',
                          style: TextStyle(
                              color: Colors.white60, fontSize: 12,
                              letterSpacing: 0.2)),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (c, a) =>
                                FadeTransition(opacity: a, child: c),
                            child: Text(
                              _showBalance
                                  ? '₹${_balance.toStringAsFixed(2)}'
                                  : '₹ ••••••',
                              key: ValueKey(_showBalance),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => _go(WalletScreen(userId: widget.userId)),
                            child: const Icon(Icons.chevron_right_rounded,
                                color: Colors.white54, size: 24),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // UPI ID
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: _upiId));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('UPI ID copied to clipboard'),
                                backgroundColor: _green,
                                duration: Duration(seconds: 2)));
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('UPI ID: ',
                                style: TextStyle(
                                    color: Colors.white54, fontSize: 12)),
                            Text(_upiId,
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 12,
                                    fontWeight: FontWeight.w500)),
                            const SizedBox(width: 6),
                            const Icon(Icons.copy_rounded,
                                color: Colors.white38, size: 13),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  _go(AddMoneyScreen(userId: widget.userId)),
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10)),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_rounded,
                                        color: _blue, size: 18),
                                    SizedBox(width: 6),
                                    Text('Add Money',
                                        style: TextStyle(
                                            color: _blue, fontSize: 13,
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  _go(WalletScreen(userId: widget.userId)),
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: Colors.white60, width: 1.5),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.account_balance_wallet_outlined,
                                        color: Colors.white, size: 16),
                                    SizedBox(width: 6),
                                    Text('Withdraw',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 13,
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
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

  // ── Quick Actions ─────────────────────────────────────────────────────────
  Widget _quickActions() {
    return FadeInUp(
      delay: const Duration(milliseconds: 150),
      duration: const Duration(milliseconds: 400),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _border),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Quick Actions',
                      style: TextStyle(
                          color: _textPri, fontSize: 14,
                          fontWeight: FontWeight.w700)),
                  GestureDetector(
                    onTap: () => _go(const ServicesScreen()),
                    child: const Text('See All',
                        style: TextStyle(
                            color: _blue, fontSize: 12,
                            fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _qAction(Icons.qr_code_scanner_rounded, 'Scan QR',
                      () => _go(QRScannerScreen(userId: widget.userId))),
                  _qAction(Icons.person_rounded, 'Pay Contact',
                      () => _go(WalletScreen(userId: widget.userId))),
                  _qAction(Icons.account_balance_rounded, 'Bank Transfer',
                      () => _go(WalletScreen(userId: widget.userId))),
                  _qAction(Icons.phone_android_rounded, 'Mobile Recharge',
                      () => _go(BillsScreen(userId: widget.userId))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _qAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 68,
        child: Column(
          children: [
            Container(
              width: 54, height: 54,
              decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(15)),
              child: Icon(icon, color: _blue, size: 24),
            ),
            const SizedBox(height: 8),
            Text(label,
                textAlign: TextAlign.center, maxLines: 2,
                style: const TextStyle(
                    color: _textPri, fontSize: 11,
                    fontWeight: FontWeight.w500, height: 1.3)),
          ],
        ),
      ),
    );
  }

  // ── Bill Payments & Recharges ─────────────────────────────────────────────
  Widget _billsSection() {
    final cats = [
      _Cat(Icons.phone_android_rounded,       'Mobile',       const Color(0xFF2563EB)),
      _Cat(Icons.electric_bolt_rounded,        'Electricity',  const Color(0xFFD97706)),
      _Cat(Icons.tv_rounded,                   'DTH',          const Color(0xFF7C3AED)),
      _Cat(Icons.local_fire_department_rounded,'Gas',          const Color(0xFFDC2626)),
      _Cat(Icons.directions_car_rounded,       'FASTag',       const Color(0xFF059669)),
    ];

    return FadeInUp(
      delay: const Duration(milliseconds: 200),
      duration: const Duration(milliseconds: 400),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Bill Payments & Recharges',
                    style: TextStyle(
                        color: _textPri, fontSize: 14,
                        fontWeight: FontWeight.w700)),
                GestureDetector(
                  onTap: () => _go(BillsScreen(userId: widget.userId)),
                  child: const Text('See All',
                      style: TextStyle(
                          color: _blue, fontSize: 12,
                          fontWeight: FontWeight.w500)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: cats.map((c) => GestureDetector(
                onTap: () => _go(BillsScreen(userId: widget.userId)),
                child: Column(
                  children: [
                    Container(
                      width: 54, height: 54,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _border),
                        boxShadow: [
                          BoxShadow(
                              color: c.color.withValues(alpha: 0.12),
                              blurRadius: 8, offset: const Offset(0, 3)),
                        ],
                      ),
                      child: Icon(c.icon, color: c.color, size: 24),
                    ),
                    const SizedBox(height: 7),
                    Text(c.label,
                        style: const TextStyle(
                            color: _textSec, fontSize: 11,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Offers & Rewards banner ───────────────────────────────────────────────
  Widget _offerBanner() {
    return FadeInUp(
      delay: const Duration(milliseconds: 250),
      duration: const Duration(milliseconds: 400),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Offers & Rewards',
                style: TextStyle(
                    color: _textPri, fontSize: 14,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFEEF2FF), Color(0xFFDBEAFE)],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Get up to ₹200 Cashback',
                            style: TextStyle(
                                color: Color(0xFF1E40AF), fontSize: 16,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        const Text('On your next payment',
                            style: TextStyle(
                                color: Color(0xFF3B82F6), fontSize: 12)),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                              color: _blue,
                              borderRadius: BorderRadius.circular(20)),
                          child: const Text('View Offers',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(Icons.card_giftcard_rounded,
                            color: Color(0xFF2563EB), size: 40),
                        Positioned(
                          top: 10, right: 10,
                          child: Container(
                            width: 20, height: 20,
                            decoration: const BoxDecoration(
                                color: Color(0xFFFBBF24),
                                shape: BoxShape.circle),
                            child: const Icon(Icons.attach_money_rounded,
                                color: Colors.white, size: 13),
                          ),
                        ),
                      ],
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

  // ── Recent Transactions ───────────────────────────────────────────────────
  Widget _recentTransactions() {
    final txns = [
      _Tx(Icons.arrow_downward_rounded, 'Money Received',
          'From Amit Verma', '+₹1,250.00', true, 'Today, 09:30 AM'),
      _Tx(Icons.arrow_upward_rounded, 'Paid to Priya Sharma',
          'UPI · 9876543210', '-₹500.00', false, 'Today, 09:20 AM'),
      _Tx(Icons.phone_android_rounded, 'Mobile Recharge',
          'Airtel · 9876543210', '-₹199.00', false, 'Yesterday, 07:45 PM'),
    ];

    return FadeInUp(
      delay: const Duration(milliseconds: 300),
      duration: const Duration(milliseconds: 400),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recent Transactions',
                    style: TextStyle(
                        color: _textPri, fontSize: 14,
                        fontWeight: FontWeight.w700)),
                GestureDetector(
                  onTap: () => _go(HistoryScreen(userId: widget.userId)),
                  child: const Text('See All',
                      style: TextStyle(
                          color: _blue, fontSize: 12,
                          fontWeight: FontWeight.w500)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _border),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: txns.length,
                separatorBuilder: (_, _) =>
                    const Divider(height: 1, indent: 68,
                        color: Color(0xFFF3F4F6)),
                itemBuilder: (_, i) => _txTile(txns[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _txTile(_Tx tx) {
    final iconBg    = tx.isCredit
        ? const Color(0xFFDCFCE7) : const Color(0xFFEFF6FF);
    final iconColor = tx.isCredit ? _green : _blue;
    final amtColor  = tx.isCredit ? _green : _textPri;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(14)),
            child: Icon(tx.icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.name,
                    style: const TextStyle(
                        color: _textPri, fontSize: 13,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('${tx.detail}  ·  ${tx.time}',
                    style: const TextStyle(
                        color: _textSec, fontSize: 11)),
              ],
            ),
          ),
          Text(tx.amount,
              style: TextStyle(
                  color: amtColor, fontSize: 13,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

// ── Small data helpers ────────────────────────────────────────────────────────
class _Cat {
  final IconData icon; final String label; final Color color;
  const _Cat(this.icon, this.label, this.color);
}

class _Tx {
  final IconData icon; final String name; final String detail;
  final String amount; final bool isCredit; final String time;
  const _Tx(this.icon, this.name, this.detail, this.amount, this.isCredit, this.time);
}

// ── India Gate monument — line-art CustomPainter ──────────────────────────────
class _MonumentPainter extends CustomPainter {
  final Color color;
  const _MonumentPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    void l(double x1, double y1, double x2, double y2) =>
        canvas.drawLine(Offset(x1, y1), Offset(x2, y2), p);

    // Base steps
    l(0, h,         w, h);
    l(w*.06, h*.90, w*.94, h*.90);
    l(w*.12, h*.82, w*.88, h*.82);

    // Outer pillars
    l(w*.06, h*.90, w*.06, h*.22);
    l(w*.18, h*.82, w*.18, h*.22);
    l(w*.94, h*.90, w*.94, h*.22);
    l(w*.82, h*.82, w*.82, h*.22);

    // Top main beam
    l(w*.06, h*.22, w*.94, h*.22);
    l(w*.06, h*.16, w*.94, h*.16);

    // Upper attic
    l(w*.18, h*.16, w*.18, h*.08);
    l(w*.82, h*.16, w*.82, h*.08);
    l(w*.18, h*.08, w*.82, h*.08);

    // Crown
    l(w*.36, h*.08, w*.36, h*.02);
    l(w*.64, h*.08, w*.64, h*.02);
    l(w*.36, h*.02, w*.64, h*.02);

    // Inner arch pillars (left pair)
    l(w*.30, h*.82, w*.30, h*.48);
    l(w*.38, h*.82, w*.38, h*.48);
    // Inner arch pillars (right pair)
    l(w*.62, h*.82, w*.62, h*.48);
    l(w*.70, h*.82, w*.70, h*.48);

    // Arch cross-beams
    l(w*.30, h*.48, w*.38, h*.48);
    l(w*.62, h*.48, w*.70, h*.48);

    // Central arch (semicircle)
    final cx = w * .50;
    final cy = h * .48;
    final r  = w * .12;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      math.pi, math.pi, false, p);

    // Arch gap lines
    l(w*.38, h*.48, cx - r, h*.48);
    l(cx + r, h*.48, w*.62, h*.48);
  }

  @override
  bool shouldRepaint(_MonumentPainter o) => false;
}
