import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SettlementScreen extends StatefulWidget {
  final String userId;
  final double? balance;

  const SettlementScreen({
    super.key,
    required this.userId,
    this.balance,
  });

  @override
  State<SettlementScreen> createState() => _SettlementScreenState();
}

class _SettlementScreenState extends State<SettlementScreen> {
  static const Color bgPage = Color(0xFFF5F5F5);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color blue = Color(0xFF3D5AF1);
  static const Color textDark = Color(0xFF1A202C);
  static const Color textLight = Color(0xFF718096);

  final amountController = TextEditingController();
  bool isLoading = false;
  bool isSuccess = false;
  int selectedAmountIndex = 1;

  final List<int> quickAmounts = [1000, 5000, 10000, 25000];

  final List<Map<String, dynamic>> recentSettlements = [
    {'amount': '₹ 2,500', 'date': 'Yesterday', 'status': 'Completed', 'bank': 'HDFC Bank •••• 4567'},
    {'amount': '₹ 1,800', 'date': '2 days ago', 'status': 'Completed', 'bank': 'HDFC Bank •••• 4567'},
    {'amount': '₹ 3,200', 'date': '3 days ago', 'status': 'Pending', 'bank': 'HDFC Bank •••• 4567'},
  ];

  double get safeBalance => widget.balance ?? 0.0;

  Future<void> withdraw() async {
    if (amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter amount')),
      );
      return;
    }
    final amount = double.tryParse(amountController.text) ?? 0;
    if (amount <= 0 || amount > safeBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid amount')),
      );
      return;
    }
    setState(() => isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      isLoading = false;
      isSuccess = true;
    });
  }

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
        title: const Text('Withdraw Funds',
            style: TextStyle(color: Color(0xFF1A202C), fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.verified_user_rounded, color: Color(0xFF3D5AF1)),
            onPressed: () {},
          ),
        ],
      ),
      body: isSuccess ? _buildSuccess() : _buildForm(),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Balance Card
          Container(
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
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Available Balance',
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
                const SizedBox(height: 8),
                Text('₹ ${safeBalance.toStringAsFixed(2)}',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {},
                  child: Row(
                    children: [
                      Text('View Details',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 13,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios_rounded,
                          color: Colors.white.withOpacity(0.8), size: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Withdraw To
          const Text('Withdraw To',
              style: TextStyle(color: textDark, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
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
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8EAF6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.account_balance_rounded,
                      color: Color(0xFF3D5AF1), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('HDFC Bank',
                          style: TextStyle(
                              color: textDark,
                              fontWeight: FontWeight.w600,
                              fontSize: 15)),
                      Text('•••• •••• •••• 4567',
                          style: TextStyle(color: textLight, fontSize: 13)),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded,
                    color: Colors.grey.shade300, size: 14),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Enter Amount
          const Text('Enter Amount',
              style: TextStyle(color: textDark, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: bgCard,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
              ],
            ),
            child: Row(
              children: [
                const Text('₹',
                    style: TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold, color: textDark)),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold, color: textDark),
                    decoration: const InputDecoration(
                      hintText: '0',
                      hintStyle: TextStyle(
                          color: Colors.black26, fontSize: 28, fontWeight: FontWeight.bold),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() =>
                      amountController.text = safeBalance.toStringAsFixed(0)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Max',
                        style: TextStyle(
                            color: blue, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Quick amounts
          Row(
            children: quickAmounts.asMap().entries.map((entry) {
              final i = entry.key;
              final amt = entry.value;
              final isSelected = selectedAmountIndex == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedAmountIndex = i;
                      amountController.text = amt.toString();
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: i < 3 ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? blue : bgCard,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? blue : Colors.grey.shade200,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Text(
                      '₹${amt >= 1000 ? '${amt ~/ 1000}K' : amt}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: isSelected ? Colors.white : blue,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Withdraw button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: isLoading ? null : withdraw,
              style: ElevatedButton.styleFrom(
                backgroundColor: blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      amountController.text.isEmpty
                          ? 'Withdraw Now'
                          : 'Withdraw ₹${amountController.text}',
                      style: const TextStyle(
                          fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),

          const SizedBox(height: 10),

          // Info
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline_rounded, size: 14, color: Colors.black38),
              SizedBox(width: 4),
              Text(
                'Money will be transferred to your bank account within',
                style: TextStyle(color: Colors.black38, fontSize: 12),
              ),
            ],
          ),
          const Center(
            child: Text('24 hours',
                style: TextStyle(
                    color: textDark, fontSize: 12, fontWeight: FontWeight.bold)),
          ),

          const SizedBox(height: 24),

          // Recent Settlements
          const Text('Recent Settlements',
              style: TextStyle(color: textDark, fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          ...recentSettlements.map((s) {
            final status = s['status'] as String;
            final isCompleted = status == 'Completed';
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: bgCard,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? const Color(0xFFE8F5E9)
                          : const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.account_balance_rounded,
                      color: isCompleted ? const Color(0xFF48BB78) : const Color(0xFFED8936),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s['amount'] as String,
                            style: const TextStyle(
                                color: textDark, fontWeight: FontWeight.bold, fontSize: 15)),
                        Text(s['bank'] as String,
                            style: const TextStyle(color: textLight, fontSize: 12)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? const Color(0xFFEAF3DE)
                              : const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(status,
                            style: TextStyle(
                                color: isCompleted
                                    ? const Color(0xFF3B6D11)
                                    : const Color(0xFF854F0B),
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 4),
                      Text(s['date'] as String,
                          style: const TextStyle(color: textLight, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100, height: 100,
              decoration: const BoxDecoration(
                  color: Color(0xFFEAF3DE), shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded,
                  size: 54, color: Color(0xFF3B6D11)),
            ),
            const SizedBox(height: 24),
            const Text('Withdrawal Initiated!',
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: textDark)),
            const SizedBox(height: 8),
            Text('₹${amountController.text} will be credited to your HDFC Bank account within 24 hours.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: textLight, fontSize: 14)),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: bgCard,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
                ],
              ),
              child: Column(
                children: [
                  _receiptRow('Amount', '₹${amountController.text}'),
                  _receiptRow('Bank', 'HDFC Bank •••• 4567'),
                  _receiptRow('Status', 'Processing'),
                  _receiptRow('Expected', 'Within 24 hours'),
                  _receiptRow('Date', DateTime.now().toString().substring(0, 10)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text('Done',
                    style: TextStyle(
                        fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _receiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: textLight, fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  color: textDark, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}