import 'package:flutter/material.dart';
import 'api_service.dart';

class AddMoneyScreen extends StatefulWidget {
  final String userId;

  const AddMoneyScreen({super.key, required this.userId});

  @override
  State<AddMoneyScreen> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends State<AddMoneyScreen> {
  static const Color purple = Color(0xFF6C63FF);
  static const Color bgPage = Color(0xFFF2F4F7);

  final amountController = TextEditingController();
  bool isLoading = false;
  bool isSuccess = false;
  String? paidAmount;

  final List<int> quickAmounts = [500, 1000, 2000, 5000];

  final List<Map<String, dynamic>> methods = [
    {'title': 'UPI', 'subtitle': 'GPay, PhonePe, Paytm', 'icon': Icons.account_balance_wallet_rounded, 'color': const Color(0xFF6C63FF)},
    {'title': 'Debit Card', 'subtitle': 'Visa, Mastercard, RuPay', 'icon': Icons.credit_card_rounded, 'color': const Color(0xFF48BB78)},
    {'title': 'Credit Card', 'subtitle': 'All cards accepted', 'icon': Icons.credit_score_rounded, 'color': const Color(0xFFED8936)},
    {'title': 'Net Banking', 'subtitle': 'All major banks', 'icon': Icons.account_balance_rounded, 'color': const Color(0xFF00B5D8)},
  ];

 Future<void> addMoney() async {
  if (amountController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter amount')),
    );
    return;
  }
  final amount = double.tryParse(amountController.text) ?? 0;
  if (amount <= 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter valid amount')),
    );
    return;
  }
  setState(() => isLoading = true);
  try {
    final result = await ApiService.addMoneyToWallet(
      userId: widget.userId,
      amount: amount,              
    );
    if (result['new_balance'] != null) {
      setState(() {
        isLoading = false;
        isSuccess = true;
        paidAmount = amountController.text;
      });
    } else {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'] ?? 'Failed to add money')),
        );
      }
    }
  } catch (e) {
    setState(() => isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgPage,
      appBar: isSuccess
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text('Add Money',
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
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
          // Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF3D5AF1)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: purple.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Add Money to Wallet',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Instant • Secure • Free',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 13)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.account_balance_wallet_rounded,
                      color: Colors.white, size: 32),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Amount input
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05), blurRadius: 15),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Enter Amount',
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('₹',
                        style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                        decoration: const InputDecoration(
                          hintText: '0',
                          hintStyle: TextStyle(
                              color: Colors.black26,
                              fontSize: 36,
                              fontWeight: FontWeight.bold),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(color: Colors.grey.shade200),
                const SizedBox(height: 12),

                // Quick amounts
                Row(
                  children: quickAmounts.map((amt) {
                    final isSelected = amountController.text == amt.toString();
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(
                            () => amountController.text = amt.toString()),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? purple
                                : const Color(0xFFF0F0FF),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? purple
                                  : Colors.grey.shade200,
                            ),
                          ),
                          child: Text(
                            '₹$amt',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color:
                                    isSelected ? Colors.white : purple,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Payment methods
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04), blurRadius: 8),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pay Using',
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: methods.map((m) {
                    final color = m['color'] as Color;
                    return Column(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(m['icon'] as IconData,
                              color: color, size: 24),
                        ),
                        const SizedBox(height: 6),
                        Text(m['title'] as String,
                            style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 11,
                                fontWeight: FontWeight.w500)),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Pay button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isLoading ? null : addMoney,
              style: ElevatedButton.styleFrom(
                backgroundColor: purple,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      amountController.text.isEmpty
                          ? 'Add Money'
                          : 'Add ₹${amountController.text}',
                      style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
            ),
          ),

          const SizedBox(height: 12),

          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_rounded, size: 14, color: Colors.black38),
              SizedBox(width: 4),
              Text('100% Secure • Powered by Razorpay',
                  style: TextStyle(color: Colors.black38, fontSize: 12)),
            ],
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                        color: Color(0xFF00C853), shape: BoxShape.circle),
                    child: const Icon(Icons.check_rounded,
                        color: Colors.white, size: 64),
                  ),
                  const SizedBox(height: 28),
                  Text('₹ ${paidAmount ?? '0'}',
                      style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: -1)),
                  const SizedBox(height: 8),
                  const Text('Added to OB Wallet!',
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          _receiptRow('Amount', '₹${paidAmount ?? '0'}'),
                          _divider(),
                          _receiptRow('Payment', 'UPI / Card'),
                          _divider(),
                          _receiptRow('Wallet', 'OB Wallet'),
                          _divider(),
                          _receiptRow('Status', 'Success ✅'),
                          _divider(),
                          _receiptRow('Date',
                              DateTime.now().toString().substring(0, 10)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: purple,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('Done',
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _receiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.black45, fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _divider() => Divider(height: 1, color: Colors.grey.shade200);
}