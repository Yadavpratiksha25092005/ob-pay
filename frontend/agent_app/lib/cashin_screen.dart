import 'package:flutter/material.dart';
import 'api_service.dart';
import 'main.dart' show themeNotifier;

class CashInScreen extends StatefulWidget {
  final String agentUserId;

  const CashInScreen({super.key, required this.agentUserId});

  @override
  State<CashInScreen> createState() => _CashInScreenState();
}

class _CashInScreenState extends State<CashInScreen> {
  final phoneController = TextEditingController();
  final amountController = TextEditingController();
  bool isLoading = false;
  String? message;
  bool isSuccess = false;

  Future<void> doCashIn() async {
    if (phoneController.text.isEmpty || amountController.text.isEmpty) {
      setState(() {
        message = 'Phone and amount are required';
        isSuccess = false;
      });
      return;
    }

    setState(() => isLoading = true);

    try {
      final result = await ApiService.sendMoney(
        senderUserId: widget.agentUserId,
        receiverPhone: phoneController.text,
        amount: double.parse(amountController.text),
        description: 'Cash In by Agent',
      );

      setState(() {
        if (result['payment_id'] != null) {
          message = '✅ Cash In successful! ₹${amountController.text} added to customer wallet';
          isSuccess = true;
          phoneController.clear();
          amountController.clear();
        } else {
          message = result['error'] ?? 'Cash In failed';
          isSuccess = false;
        }
      });
    } catch (e) {
      setState(() {
        message = 'Error: $e';
        isSuccess = false;
      });
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF004D40),
        title: const Text('Cash In',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (_, mode, __) => IconButton(
              icon: Icon(
                mode == ThemeMode.light ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: Colors.white,
              ),
              onPressed: () {
                themeNotifier.value = mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
              },
              tooltip: mode == ThemeMode.light ? 'Dark mode' : 'Light mode',
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF004D40).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFF004D40).withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info, color: Color(0xFF004D40)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Customer gives you cash — you add money to their wallet',
                      style: TextStyle(color: Color(0xFF004D40)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text('Customer Details',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Customer Phone Number',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount (₹)',
                prefixIcon: const Icon(Icons.currency_rupee),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Quick amounts
            const Text('Quick Amount:',
                style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Row(
              children: [500, 1000, 2000, 5000].map((amt) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: OutlinedButton(
                    onPressed: () {
                      amountController.text = amt.toString();
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF004D40)),
                    ),
                    child: Text('₹$amt',
                        style: const TextStyle(
                            color: Color(0xFF004D40))),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            if (message != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSuccess
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSuccess ? Colors.green : Colors.red,
                  ),
                ),
                child: Text(
                  message!,
                  style: TextStyle(
                    color: isSuccess
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : doCashIn,
                icon: const Icon(Icons.add_circle, color: Colors.white),
                label: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Cash In',
                        style: TextStyle(
                            fontSize: 18, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004D40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}