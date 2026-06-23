import 'package:flutter/material.dart';
import 'api_service.dart';

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

  final List<String> tabs = ['All', 'Received', 'Sent', 'Paid Bills', 'Recharge'];

  static const Color purple = Color(0xFF6C63FF);
  static const Color bgPage = Color(0xFFF2F4F7);

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
    super.dispose();
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
    if (selectedTab == 'Sent') {
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
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Transactions',
            style: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.black87),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_rounded, color: Colors.black87),
            onPressed: () => _showFilter(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.black45,
          indicator: BoxDecoration(
            color: purple,
            borderRadius: BorderRadius.circular(20),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          tabs: tabs.map((tab) => Text(tab,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))).toList(),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildAllTransactions(),
                _buildPaymentsList(
                    payments.where((p) => p['receiver_user_id'] == widget.userId).toList(),
                    isReceived: true),
                _buildPaymentsList(
                    payments.where((p) => p['sender_user_id'] == widget.userId).toList(),
                    isReceived: false),
                _buildSpecialList(dummyBills, 'bills'),
                _buildSpecialList(dummyRecharges, 'recharge'),
              ],
            ),
    );
  }

Widget _buildAllTransactions() {
  if (payments.isEmpty && dummyBills.isEmpty) return _buildEmpty();

  return ListView(
    padding: const EdgeInsets.all(16),
    children: [
      // Real payments
      if (payments.isNotEmpty) ...[
        _groupHeader('Payments'),
        ...payments.map((p) {
          final isSender = p['sender_user_id'] == widget.userId;
          return _transactionCard({
            'name': isSender ? 'Money Sent' : 'Money Received',
            'sub': p['description']?.toString().isNotEmpty == true
                ? p['description']
                : isSender ? 'Paid to user' : 'Money Received',
            'amount': p['amount']?.toString() ?? '0',
            'time': _formatTime(p['created_at']),
            'isCredit': !isSender,
            'icon': isSender
                ? Icons.arrow_upward_rounded
                : Icons.arrow_downward_rounded,
            'color': isSender
                ? const Color(0xFFE91E63)
                : const Color(0xFF00C853),
            'bg': isSender
                ? const Color(0xFFFCE4EC)
                : const Color(0xFFE8F5E9),
          });
        }),
      ],

      // Dummy bills
      _groupHeader('Bill Payments'),
      ...dummyBills.map((b) => _transactionCard({
        'name': b['name'],
        'sub': 'Bill Payment',
        'amount': b['amount'],
        'time': b['time'],
        'isCredit': false,
        'icon': b['icon'],
        'color': b['color'],
        'bg': (b['color'] as Color).withOpacity(0.1),
      })),

      // Dummy recharges
      _groupHeader('Recharges'),
      ...dummyRecharges.map((r) => _transactionCard({
        'name': r['name'],
        'sub': 'Recharge',
        'amount': r['amount'],
        'time': r['time'],
        'isCredit': false,
        'icon': r['icon'],
        'color': r['color'],
        'bg': (r['color'] as Color).withOpacity(0.1),
      })),
    ],
  );
}

Widget _groupHeader(String title) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8, top: 4),
    child: Text(
      title.toUpperCase(),
      style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.black38,
          letterSpacing: 0.8),
    ),
  );
}

Widget _buildPaymentsList(List<dynamic> list, {required bool isReceived}) {
  if (list.isEmpty) return _buildEmpty();
  return ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: list.length,
    itemBuilder: (context, index) {
      final p = list[index];
      final desc = p['description']?.toString() ?? '';
      return _transactionCard({
        'name': isReceived ? 'Money Received' : 'Money Sent',
        'sub': desc.isNotEmpty ? desc : (isReceived ? 'Money Received' : 'Money Sent'),
          'amount': p['amount']?.toString() ?? '0',
          'time': _formatTime(p['created_at']),
          'isCredit': isReceived,
          'icon': isReceived ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
          'color': isReceived ? const Color(0xFF00C853) : const Color(0xFFE91E63),
          'bg': isReceived ? const Color(0xFFE8F5E9) : const Color(0xFFFCE4EC),
        });
      },
    );
  }

  Widget _buildSpecialList(List<Map<String, dynamic>> list, String type) {
    if (list.isEmpty) return _buildEmpty();
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return _transactionCard({
          'name': item['name'],
          'sub': type == 'bills' ? 'Bill Payment' : 'Recharge',
          'amount': item['amount'],
          'time': item['time'],
          'isCredit': false,
          'icon': item['icon'],
          'color': item['color'],
          'bg': (item['color'] as Color).withOpacity(0.1),
        });
      },
    );
  }

  Widget _transactionCard(Map<String, dynamic> item) {
    final isCredit = item['isCredit'] as bool;
    final color = item['color'] as Color;
    final bg = item['bg'] as Color;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(item['icon'] as IconData, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['name'] as String,
                    style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(item['sub'] as String,
                          style: const TextStyle(color: Colors.black45, fontSize: 10)),
                    ),
                    const SizedBox(width: 6),
                    Text(item['time'] as String,
                        style: const TextStyle(color: Colors.black38, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isCredit ? '+' : '-'}₹${item['amount']}',
                style: TextStyle(
                    color: isCredit ? const Color(0xFF00C853) : const Color(0xFFE91E63),
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3DE),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('Paid',
                    style: TextStyle(
                        color: Color(0xFF3B6D11),
                        fontSize: 9,
                        fontWeight: FontWeight.w500)),
              ),
            ],
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
          Icon(Icons.receipt_long_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('No transactions yet',
              style: TextStyle(fontSize: 16, color: Colors.black45)),
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
      if (diff.inMinutes < 60) return 'Today, ${dt.hour}:${dt.minute.toString().padLeft(2, '0')} ${dt.hour < 12 ? 'AM' : 'PM'}';
      if (diff.inDays == 0) return 'Today, ${dt.hour}:${dt.minute.toString().padLeft(2, '0')} ${dt.hour < 12 ? 'AM' : 'PM'}';
      if (diff.inDays == 1) return 'Yesterday, ${dt.hour}:${dt.minute.toString().padLeft(2, '0')} ${dt.hour < 12 ? 'AM' : 'PM'}';
      return '${diff.inDays} days ago';
    } catch (e) {
      return 'Recently';
    }
  }

  void _showFilter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filter Transactions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _filterChips('Date Range', ['Today', 'This Week', 'This Month', 'Custom']),
            const SizedBox(height: 12),
            _filterChips('Amount', ['< ₹500', '₹500-2000', '> ₹2000']),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: purple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Apply Filter',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: options.map((opt) => GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0FF),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(opt, style: const TextStyle(color: purple, fontSize: 12)),
            ),
          )).toList(),
        ),
      ],
    );
  }
}