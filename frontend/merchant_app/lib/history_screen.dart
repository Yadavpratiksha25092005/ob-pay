import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  double totalReceived = 0;
  late TabController _tabController;

  static const Color bgPage = Color(0xFFF5F5F5);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color blue = Color(0xFF3D5AF1);
  static const Color textDark = Color(0xFF1A202C);
  static const Color textLight = Color(0xFF718096);

  final List<String> tabs = ['All', 'Received', 'Sent', 'Refunds'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
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
      final list = data['payments'] ?? [];
      double total = 0;
      for (var p in list) {
        if (p['receiver_user_id'] == widget.userId) {
          total += (p['amount'] as num).toDouble();
        }
      }
      setState(() {
        payments = list;
        totalReceived = total;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  String _formatTime(dynamic createdAt) {
    if (createdAt == null) return 'Recently';
    try {
      final dt = DateTime.parse(createdAt.toString());
      final now = DateTime.now();
      final diff = now.difference(dt);
      final hour = dt.hour;
      final min = dt.minute.toString().padLeft(2, '0');
      final ampm = hour < 12 ? 'AM' : 'PM';
      final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      if (diff.inDays == 0) return 'Today, $hour12:$min $ampm';
      if (diff.inDays == 1) return 'Yesterday, $hour12:$min $ampm';
      return '${diff.inDays} Days Ago';
    } catch (e) {
      return 'Recently';
    }
  }

  List<dynamic> get receivedPayments =>
      payments.where((p) => p['receiver_user_id'] == widget.userId).toList();

  List<dynamic> get sentPayments =>
      payments.where((p) => p['sender_user_id'] == widget.userId).toList();

  // Dummy refunds
  final List<Map<String, dynamic>> refunds = [
    {'name': 'Amazon India', 'amount': '450', 'time': 'Today, 09:15 AM'},
    {'name': 'Flipkart', 'amount': '299', 'time': 'Yesterday, 02:30 PM'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgPage,
      appBar: AppBar(
        backgroundColor: bgCard,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1A202C)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Transactions',
            style: TextStyle(
                color: Color(0xFF1A202C),
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded, color: Color(0xFF1A202C)),
            onPressed: () => _showFilter(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.black45,
          indicator: BoxDecoration(
            color: blue,
            borderRadius: BorderRadius.circular(20),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          tabs: tabs.map((tab) => Text(tab,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))).toList(),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildList(payments, showAll: true),
                _buildList(receivedPayments, isReceived: true),
                _buildList(sentPayments, isReceived: false),
                _buildRefunds(),
              ],
            ),
    );
  }

  Widget _buildList(List<dynamic> list, {bool showAll = false, bool isReceived = true}) {
    if (list.isEmpty) return _buildEmpty();

    return Column(
      children: [
        // Summary card
        Container(
          width: double.infinity,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A56DB), Color(0xFF3D5AF1)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: blue.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      showAll ? 'Total Revenue' : isReceived ? 'Total Received' : 'Total Sent',
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹ ${totalReceived.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Transactions', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                  const SizedBox(height: 4),
                  Text('${list.length}',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),

        // List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final p = list[index];
              final isRec = p['receiver_user_id'] == widget.userId;
              final amount = (p['amount'] as num).toDouble();
              final desc = p['description']?.toString() ?? '';

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: bgCard,
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
                      decoration: BoxDecoration(
                        color: isRec
                            ? const Color(0xFFE8F5E9)
                            : const Color(0xFFFCE4EC),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isRec
                            ? Icons.arrow_downward_rounded
                            : Icons.arrow_upward_rounded,
                        color: isRec
                            ? const Color(0xFF48BB78)
                            : const Color(0xFFE91E63),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isRec ? 'Customer Payment' : 'Payment Sent',
                            style: const TextStyle(
                                color: textDark,
                                fontWeight: FontWeight.w600,
                                fontSize: 14),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            desc.isNotEmpty ? desc : (isRec ? 'Received' : 'Sent'),
                            style: const TextStyle(color: textLight, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${isRec ? '+' : '-'}₹ ${amount.toStringAsFixed(2)}',
                          style: TextStyle(
                              color: isRec
                                  ? const Color(0xFF48BB78)
                                  : const Color(0xFFE91E63),
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAF3DE),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('Success',
                                  style: TextStyle(
                                      color: Color(0xFF3B6D11),
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 6),
                            Text(_formatTime(p['created_at']),
                                style: const TextStyle(
                                    color: textLight, fontSize: 10)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // End indicator
        const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Text("You've reached the end 🎉",
              style: TextStyle(color: Colors.black38, fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildRefunds() {
    if (refunds.isEmpty) return _buildEmpty();
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: refunds.length,
      itemBuilder: (context, index) {
        final r = refunds[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: bgCard,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 46, height: 46,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF3E0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.keyboard_return_rounded,
                    color: Color(0xFFED8936), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r['name'] as String,
                        style: const TextStyle(
                            color: textDark,
                            fontWeight: FontWeight.w600,
                            fontSize: 14)),
                    Text(r['time'] as String,
                        style: const TextStyle(color: textLight, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('- ₹ ${r['amount']}',
                      style: const TextStyle(
                          color: Color(0xFFED8936),
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAEEDA),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('Refunded',
                        style: TextStyle(
                            color: Color(0xFF854F0B),
                            fontSize: 9,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
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
                  backgroundColor: blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
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
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: options.map((opt) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFEEEDFE),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(opt,
                style: const TextStyle(color: blue, fontSize: 12)),
          )).toList(),
        ),
      ],
    );
  }
}