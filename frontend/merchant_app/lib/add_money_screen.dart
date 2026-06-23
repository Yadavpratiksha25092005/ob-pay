import 'package:flutter/material.dart';

class MerchantAddMoneyScreen extends StatefulWidget {
  final String userId;
  final String balance;

  const MerchantAddMoneyScreen({
    super.key,
    required this.userId,
    required this.balance,
  });

  @override
  State<MerchantAddMoneyScreen> createState() =>
      _MerchantAddMoneyScreenState();
}

class _MerchantAddMoneyScreenState
    extends State<MerchantAddMoneyScreen> {
  static const Color bgPage = Color(0xFFF0F4FF);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color blue = Color(0xFF3D5AF1);
  static const Color textDark = Color(0xFF1A202C);
  static const Color textLight = Color(0xFF718096);

  int selectedMethod = 0;
  final amountController = TextEditingController();
  bool isLoading = false;
  bool isSuccess = false;

  final List<Map<String, dynamic>> methods = [
    {'title': 'UPI', 'subtitle': 'Pay via any UPI app', 'icon': Icons.account_balance_wallet_rounded, 'color': const Color(0xFF6C63FF)},
    {'title': 'Net Banking', 'subtitle': 'All major banks supported', 'icon': Icons.account_balance_rounded, 'color': const Color(0xFF3D5AF1)},
    {'title': 'Debit Card', 'subtitle': 'Visa, Mastercard, RuPay', 'icon': Icons.credit_card_rounded, 'color': const Color(0xFF48BB78)},
    {'title': 'Credit Card', 'subtitle': 'All cards accepted', 'icon': Icons.credit_score_rounded, 'color': const Color(0xFFED8936)},
  ];

  final List<int> quickAmounts = [500, 1000, 2000, 5000, 10000, 25000];

  Future<void> addMoney() async {
    if (amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter amount')),
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
          icon: const Icon(Icons.arrow_back_rounded,
              color: Color(0xFF1A202C)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Add Money',
            style: TextStyle(
                color: Color(0xFF1A202C),
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
          // Current balance
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A56DB), Color(0xFF3D5AF1)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: blue.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Current Balance',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12)),
                    Text('₹ ${widget.balance}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.white,
                      size: 24),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Amount input
          const Text('Enter Amount',
              style: TextStyle(
                  color: textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: bgCard,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                ),
              ],
            ),
            child: TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textDark),
              decoration: const InputDecoration(
                hintText: '0',
                hintStyle: TextStyle(
                    color: Color(0xFFCBD5E0),
                    fontSize: 28,
                    fontWeight: FontWeight.bold),
                prefixIcon: Padding(
                  padding: EdgeInsets.only(left: 16, top: 14),
                  child: Text('₹',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3D5AF1))),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                    horizontal: 16, vertical: 18),
              ),
              onChanged: (val) => setState(() {}),
            ),
          ),

          const SizedBox(height: 14),

          // Quick amounts
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: quickAmounts.map((amt) {
              final isSelected =
                  amountController.text == amt.toString();
              return GestureDetector(
                onTap: () => setState(
                    () => amountController.text = amt.toString()),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? blue : bgCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? blue
                          : Colors.grey.shade200,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Text('₹$amt',
                      style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : textDark,
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Payment method
          const Text('Payment Method',
              style: TextStyle(
                  color: textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          Container(
            decoration: BoxDecoration(
              color: bgCard,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              children: methods.asMap().entries.map((entry) {
                final i = entry.key;
                final method = entry.value;
                final isSelected = selectedMethod == i;
                final color = method['color'] as Color;
                return GestureDetector(
                  onTap: () => setState(() => selectedMethod = i),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? blue.withOpacity(0.04)
                          : Colors.transparent,
                      borderRadius: i == 0
                          ? const BorderRadius.vertical(
                              top: Radius.circular(16))
                          : i == methods.length - 1
                              ? const BorderRadius.vertical(
                                  bottom: Radius.circular(16))
                              : BorderRadius.zero,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                          child: Icon(
                              method['icon'] as IconData,
                              color: color,
                              size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(method['title'] as String,
                                  style: TextStyle(
                                      color: textDark,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      fontSize: 14)),
                              Text(method['subtitle'] as String,
                                  style: const TextStyle(
                                      color: textLight,
                                      fontSize: 12)),
                            ],
                          ),
                        ),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? blue
                                  : Colors.grey.shade300,
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? Container(
                                  margin: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                    color: blue,
                                    shape: BoxShape.circle,
                                  ),
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 24),

          // Add money button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: isLoading ? null : addMoney,
              style: ElevatedButton.styleFrom(
                backgroundColor: blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.white)
                  : Text(
                      amountController.text.isEmpty
                          ? 'Add Money'
                          : 'Add ₹${amountController.text}',
                      style: const TextStyle(
                          fontSize: 17,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_rounded,
                  size: 14, color: Color(0xFF718096)),
              SizedBox(width: 4),
              Text('100% Secure Payment',
                  style: TextStyle(
                      color: Color(0xFF718096), fontSize: 12)),
            ],
          ),
          const SizedBox(height: 20),
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
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: Color(0xFFEAF3DE),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded,
                  size: 54, color: Color(0xFF3B6D11)),
            ),
            const SizedBox(height: 24),
            const Text('Money Added Successfully!',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textDark)),
            const SizedBox(height: 8),
            Text('₹${amountController.text} added to your wallet',
                style:
                    const TextStyle(color: textLight, fontSize: 15)),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: bgCard,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  _receiptRow('Amount', '₹${amountController.text}'),
                  _receiptRow('Method', methods[selectedMethod]['title'] as String),
                  _receiptRow('Status', 'Success'),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text('Done',
                    style: TextStyle(
                        fontSize: 17,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
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
          Text(label,
              style:
                  const TextStyle(color: textLight, fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  color: textDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}