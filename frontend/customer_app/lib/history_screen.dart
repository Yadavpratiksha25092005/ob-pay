import 'package:flutter/material.dart';
import 'api_service.dart';
import 'theme_toggle.dart';

class HistoryScreen extends StatefulWidget {
  final String userId;

  const HistoryScreen({super.key, required this.userId});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  List<dynamic> payments = [];
  bool isLoading = true;
  String selectedTab = 'All';
  late TabController _tabController;
  String _searchQuery = '';
  bool _showSearch = false;
  final TextEditingController _searchController = TextEditingController();

  final List<String> tabs = ['All', 'Received', 'Paid', 'Added Money'];

  // Design tokens
  static const Color primary = Color(0xFF2563EB);
  static const Color bgPage = Color(0xFFF8FAFF);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color colorGreen = Color(0xFF16A34A);
  static const Color colorRed = Color(0xFFDC2626);
  static const Color borderColor = Color(0xFFE5E7EB);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
    _tabController.addListener(() {
      setState(() => selectedTab = tabs[_tabController.index]);
    });
    loadHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<dynamic> _applySearch(List<dynamic> list) {
    if (_searchQuery.isEmpty) return list;
    final q = _searchQuery.toLowerCase();
    return list.where((p) {
      final id = (p['id'] ?? '').toString().toLowerCase();
      final desc = (p['description'] ?? '').toString().toLowerCase();
      final amount = (p['amount'] ?? '').toString().toLowerCase();
      final date = _formatTime(p['created_at']).toLowerCase();
      return id.contains(q) || desc.contains(q) || amount.contains(q) || date.contains(q);
    }).toList();
  }

  Future<void> loadHistory() async {
    try {
      final data = await ApiService.getPaymentHistory(widget.userId);
      setState(() {
        payments = data['payments'] ?? [];
        isLoading = false;
      });
      print('Payments loaded: ${payments.length}');
      print('First payment: ${payments.isNotEmpty ? payments[0] : 'none'}');
    } catch (e) {
      print('Error: $e');
      setState(() => isLoading = false);
    }
  }

  List<dynamic> get filteredPayments {
    if (selectedTab == 'All') return payments;
    if (selectedTab == 'Received') {
      return payments.where((p) => p['receiver_user_id'] == widget.userId).toList();
    }
    if (selectedTab == 'Paid') {
      return payments.where((p) => p['sender_user_id'] == widget.userId).toList();
    }
    return payments;
  }

  // Dummy data for Bills and Recharge tabs
  final List<Map<String, dynamic>> dummyBills = [
    {'name': 'MSEDCL Electricity', 'amount': '650', 'time': 'Yesterday, 11:20 AM', 'icon': Icons.electric_bolt_rounded, 'color': Color(0xFFFF9800)},
    {'name': 'Jio Fiber Broadband', 'amount': '999', 'time': '2 days ago, 09:00 AM', 'icon': Icons.wifi_rounded, 'color': Color(0xFF009688)},
    {'name': 'Piped Gas Bill', 'amount': '480', 'time': '1 week ago', 'icon': Icons.local_fire_department_rounded, 'color': Color(0xFFFF5722)},
  ];

  final List<Map<String, dynamic>> dummyRecharges = [
    {'name': 'Mobile Recharge (Jio)', 'amount': '199', 'time': 'Yesterday, 08:50 PM', 'icon': Icons.phone_android_rounded, 'color': Color(0xFF0070C0)},
    {'name': 'Mobile Recharge (Airtel)', 'amount': '299', 'time': '3 days ago', 'icon': Icons.phone_android_rounded, 'color': Color(0xFFE40000)},
    {'name': 'DTH Recharge (Tata Play)', 'amount': '349', 'time': '1 week ago', 'icon': Icons.tv_rounded, 'color': Color(0xFF003087)},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgPage,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: _showSearch
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search by ID, amount, description, date...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                ),
                style: const TextStyle(color: textPrimary, fontSize: 15),
                onChanged: (v) => setState(() => _searchQuery = v),
              )
            : const Text(
                'Transactions',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
        actions: [
          ThemeToggleButton(),
  SizedBox(width: 8),
          IconButton(
            icon: Icon(
              _showSearch ? Icons.close_rounded : Icons.search_rounded,
              color: textPrimary,
            ),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchQuery = '';
                  _searchController.clear();
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_rounded, color: textPrimary),
            onPressed: () => _showFilter(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: primary,
              unselectedLabelColor: textSecondary,
              indicator: const UnderlineTabIndicator(
                borderSide: BorderSide(color: primary, width: 2),
                insets: EdgeInsets.symmetric(horizontal: 0),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelPadding: const EdgeInsets.symmetric(horizontal: 20),
              tabs: tabs
                  .map((tab) => Tab(
                        child: Text(
                          tab,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: primary))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildAllTransactions(),
                _buildPaymentsList(
                  payments
                      .where((p) => p['receiver_user_id'] == widget.userId)
                      .toList(),
                  isReceived: true,
                ),
                _buildPaymentsList(
                  payments
                      .where((p) => p['sender_user_id'] == widget.userId)
                      .toList(),
                  isReceived: false,
                ),
                _buildAddedMoneyEmpty(),
              ],
            ),
    );
  }

  Widget _buildAllTransactions() {
    final filtered = _applySearch(payments);
    if (filtered.isEmpty && dummyBills.isEmpty && dummyRecharges.isEmpty) {
      return _buildEmpty();
    }

    // Date-bucket helpers
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final yesterdayStart = todayStart.subtract(const Duration(days: 1));
    final thisWeekStart = todayStart.subtract(Duration(days: now.weekday - 1));
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));

    final List<dynamic> todayItems = [];
    final List<dynamic> yesterdayItems = [];
    final List<dynamic> thisWeekItems = [];
    final List<dynamic> lastWeekItems = [];
    final List<dynamic> olderItems = [];

    for (final p in filtered) {
      DateTime? dt;
      try {
        if (p['created_at'] != null) {
          dt = DateTime.parse(p['created_at'].toString());
        }
      } catch (_) {}

      if (dt == null) {
        olderItems.add(p);
      } else if (!dt.isBefore(todayStart)) {
        todayItems.add(p);
      } else if (!dt.isBefore(yesterdayStart)) {
        yesterdayItems.add(p);
      } else if (!dt.isBefore(thisWeekStart)) {
        thisWeekItems.add(p);
      } else if (!dt.isBefore(lastWeekStart)) {
        lastWeekItems.add(p);
      } else {
        olderItems.add(p);
      }
    }

    Widget paymentCard(dynamic p) {
      final isSender = p['sender_user_id'] == widget.userId;
      return _transactionCard({
        'name': isSender ? 'Money Sent' : 'Money Received',
        'sub': p['description']?.toString().isNotEmpty == true
            ? p['description']
            : isSender
                ? 'Paid to user'
                : 'Money Received',
        'amount': p['amount']?.toString() ?? '0',
        'time': _formatTime(p['created_at']),
        'isCredit': !isSender,
        'isPayment': true,
        'icon': isSender
            ? Icons.arrow_upward_rounded
            : Icons.arrow_downward_rounded,
      });
    }

    Widget billCard(Map<String, dynamic> b) => _transactionCard({
          'name': b['name'],
          'sub': 'Bill Payment',
          'amount': b['amount'],
          'time': b['time'],
          'isCredit': false,
          'isPayment': false,
          'icon': b['icon'],
          'billColor': b['color'],
        });

    Widget rechargeCard(Map<String, dynamic> r) => _transactionCard({
          'name': r['name'],
          'sub': 'Recharge',
          'amount': r['amount'],
          'time': r['time'],
          'isCredit': false,
          'isPayment': false,
          'icon': r['icon'],
          'billColor': r['color'],
        });

    final List<Widget> sectionWidgets = [];

    if (todayItems.isNotEmpty) {
      sectionWidgets.add(_groupHeader('Today'));
      sectionWidgets.addAll(todayItems.map(paymentCard));
    }

    // Yesterday: real payments + dummyBills
    final bool hasYesterday = yesterdayItems.isNotEmpty || dummyBills.isNotEmpty;
    if (hasYesterday) {
      sectionWidgets.add(_groupHeader('Yesterday'));
      sectionWidgets.addAll(yesterdayItems.map(paymentCard));
      sectionWidgets.addAll(dummyBills.map(billCard));
    }

    // This Week: real payments + dummyRecharges
    final bool hasThisWeek = thisWeekItems.isNotEmpty || dummyRecharges.isNotEmpty;
    if (hasThisWeek) {
      sectionWidgets.add(_groupHeader('This Week'));
      sectionWidgets.addAll(thisWeekItems.map(paymentCard));
      sectionWidgets.addAll(dummyRecharges.map(rechargeCard));
    }

    if (lastWeekItems.isNotEmpty) {
      sectionWidgets.add(_groupHeader('Last Week'));
      sectionWidgets.addAll(lastWeekItems.map(paymentCard));
    }

    if (olderItems.isNotEmpty) {
      sectionWidgets.add(_groupHeader('Older'));
      sectionWidgets.addAll(olderItems.map(paymentCard));
    }

    if (sectionWidgets.isEmpty) return _buildEmpty();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: sectionWidgets,
    );
  }

  Widget _groupHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textSecondary,
        ),
      ),
    );
  }

  Widget _buildPaymentsList(List<dynamic> list, {required bool isReceived}) {
    final filtered = _applySearch(list);
    if (filtered.isEmpty) return _buildEmpty();
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final p = filtered[index];
        final desc = p['description']?.toString() ?? '';
        return _transactionCard({
          'name': isReceived ? 'Money Received' : 'Money Sent',
          'sub': desc.isNotEmpty
              ? desc
              : (isReceived ? 'Money Received' : 'Money Sent'),
          'amount': p['amount']?.toString() ?? '0',
          'time': _formatTime(p['created_at']),
          'isCredit': isReceived,
          'isPayment': true,
          'icon': isReceived
              ? Icons.arrow_downward_rounded
              : Icons.arrow_upward_rounded,
        });
      },
    );
  }

  Widget _transactionCard(Map<String, dynamic> item) {
    final isCredit = item['isCredit'] as bool;
    final bool isPayment = item['isPayment'] as bool? ?? true;
    final IconData icon = item['icon'] as IconData;

    // Determine icon bg/color
    Color iconBg;
    Color iconColor;
    if (isPayment) {
      if (isCredit) {
        iconBg = const Color(0xFFDCFCE7);
        iconColor = colorGreen;
      } else {
        iconBg = const Color(0xFFEFF6FF);
        iconColor = primary;
      }
    } else {
      // Bill or recharge — use per-item color tinted
      final billColor = item['billColor'] as Color? ?? primary;
      iconBg = billColor.withValues(alpha: 0.12);
      iconColor = billColor;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] as String,
                  style: const TextStyle(
                    color: textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item['sub'] as String,
                        style: const TextStyle(
                            color: textSecondary, fontSize: 10),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item['time'] as String,
                      style: const TextStyle(
                          color: textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            '${isCredit ? '+' : '-'}₹${item['amount']}',
            style: TextStyle(
              color: isCredit ? colorGreen : colorRed,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddedMoneyEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance_wallet_rounded,
              size: 72, color: primary.withValues(alpha: 0.18)),
          const SizedBox(height: 16),
          const Text(
            'No top-ups yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Money added to your wallet will appear here',
            style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_rounded,
              size: 72, color: primary.withValues(alpha: 0.18)),
          const SizedBox(height: 16),
          const Text(
            'No transactions yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(dynamic createdAt) {
    if (createdAt == null) return 'Recently';
    try {
      final dt = DateTime.parse(createdAt.toString());
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 60) {
        return 'Today, ${dt.hour}:${dt.minute.toString().padLeft(2, '0')} ${dt.hour < 12 ? 'AM' : 'PM'}';
      }
      if (diff.inDays == 0) {
        return 'Today, ${dt.hour}:${dt.minute.toString().padLeft(2, '0')} ${dt.hour < 12 ? 'AM' : 'PM'}';
      }
      if (diff.inDays == 1) {
        return 'Yesterday, ${dt.hour}:${dt.minute.toString().padLeft(2, '0')} ${dt.hour < 12 ? 'AM' : 'PM'}';
      }
      return '${diff.inDays} days ago';
    } catch (e) {
      return 'Recently';
    }
  }

  void _showFilter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Transactions',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textPrimary),
            ),
            const SizedBox(height: 16),
            _filterChips(
                'Date Range', ['Today', 'This Week', 'This Month', 'Custom']),
            const SizedBox(height: 12),
            _filterChips('Amount', ['< ₹500', '₹500-2000', '> ₹2000']),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text(
                  'Apply Filter',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChips(String label, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: textPrimary)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: options
              .map((opt) => GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: borderColor),
                      ),
                      child: Text(opt,
                          style: const TextStyle(
                              color: primary, fontSize: 12)),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}
