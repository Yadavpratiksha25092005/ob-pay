import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'api_service.dart';
import 'main.dart' show themeNotifier;

class CashOutScreen extends StatefulWidget {
  final String agentUserId;
  final String agentPhone;

  const CashOutScreen({
    super.key,
    required this.agentUserId,
    required this.agentPhone,
  });

  @override
  State<CashOutScreen> createState() => _CashOutScreenState();
}

class _CashOutScreenState extends State<CashOutScreen> {
  static const Color red = Color(0xFFE91E63);
  Color bgPage = const Color(0xFFF5F5F5);
  Color bgCard = Colors.white;
  Color textDark = const Color(0xFF1A202C);
  Color textLight = const Color(0xFF718096);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    bgPage = isDark ? const Color(0xFF0B1437) : const Color(0xFFF5F5F5);
    bgCard = isDark ? const Color(0xFF111C44) : Colors.white;
    textDark = isDark ? Colors.white : const Color(0xFF1A202C);
    textLight = isDark ? Colors.white60 : const Color(0xFF718096);
  }

  final phoneController = TextEditingController();
  final amountController = TextEditingController();
  final pinController = TextEditingController();
  bool isLoading = false;
  bool isSuccess = false;
  String? errorMessage;
  String? txId;

  final List<int> quickAmounts = [500, 1000, 2000, 5000];

  Future<void> doCashOut() async {
  if (phoneController.text.isEmpty || amountController.text.isEmpty) {
    setState(() => errorMessage = 'Please fill all fields');
    return;
  }

  setState(() {
    isLoading = true;
    errorMessage = null;
  });

  try {
    // Pehle customer ka userId get karo
    final userResult = await ApiService.getUserByPhone(phoneController.text);
    final customerUserId = userResult['id'] ?? userResult['user']?['id'];

    if (customerUserId == null) {
      setState(() {
        errorMessage = 'Customer not found';
        isLoading = false;
      });
      return;
    }

    // Customer agent ko payment karta hai
    final result = await ApiService.sendMoney(
      senderUserId: customerUserId,
      receiverPhone: widget.agentPhone,
      amount: double.parse(amountController.text),
      description: 'Cash Out via Agent',
    );

    if (result['payment_id'] != null) {
      setState(() {
        isSuccess = true;
        txId = result['payment_id'];
        isLoading = false;
      });
      HapticFeedback.heavyImpact();
    } else {
      setState(() {
        errorMessage = result['error'] ?? 'Cash Out failed';
        isLoading = false;
      });
    }
  } catch (e) {
    setState(() {
      errorMessage = 'Error: $e';
      isLoading = false;
    });
  }
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
        title: const Text('Cash Out',
            style: TextStyle(
                color: Color(0xFF1A202C),
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        actions: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (_, mode, __) => IconButton(
              icon: Icon(
                mode == ThemeMode.light ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              ),
              onPressed: () {
                themeNotifier.value = mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
              },
              tooltip: mode == ThemeMode.light ? 'Dark mode' : 'Light mode',
            ),
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
          // Info banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: red.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: red.withOpacity(0.2)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_rounded, color: Color(0xFFE91E63), size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Customer ka wallet debit hoga — aap unhe cash denge',
                    style: TextStyle(color: Color(0xFFE91E63), fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Customer phone
          Text('Customer Phone',
              style: TextStyle(color: textLight, fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: bgCard,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
            ),
            child: TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Enter customer phone number',
                hintStyle: TextStyle(color: Colors.black38),
                prefixIcon: Icon(Icons.phone_rounded, color: Color(0xFFE91E63)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Amount
          Text('Amount (₹)',
              style: TextStyle(color: textLight, fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: bgCard,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
            ),
            child: Row(
              children: [
                Text('₹', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textDark)),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textDark),
                    decoration: const InputDecoration(
                      hintText: '0',
                      hintStyle: TextStyle(color: Colors.black26, fontSize: 28, fontWeight: FontWeight.bold),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Quick amounts
          Row(
            children: quickAmounts.map((amt) {
              final isSelected = amountController.text == amt.toString();
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => amountController.text = amt.toString()),
                  child: Container(
                    margin: EdgeInsets.only(right: amt != 5000 ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? red : bgCard,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isSelected ? red : Colors.grey.shade200),
                    ),
                    child: Text('₹$amt',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: isSelected ? Colors.white : red,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              );
            }).toList(),
          ),

          if (errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Colors.red, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(errorMessage!, style: TextStyle(color: Colors.red.shade700, fontSize: 13))),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: isLoading ? null : doCashOut,
              style: ElevatedButton.styleFrom(
                backgroundColor: red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      amountController.text.isEmpty
                          ? 'Cash Out'
                          : 'Cash Out ₹${amountController.text}',
                      style: const TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),

          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_rounded, size: 14, color: Colors.black38),
              SizedBox(width: 4),
              Text('Secure Transaction', style: TextStyle(color: Colors.black38, fontSize: 12)),
            ],
          ),
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
              decoration: const BoxDecoration(color: Color(0xFF00C853), shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded, size: 54, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text('₹ ${amountController.text}',
                style: TextStyle(fontSize: 44, fontWeight: FontWeight.bold, color: textDark)),
            const SizedBox(height: 8),
            Text('Cash Out for ${phoneController.text}',
                style: const TextStyle(fontSize: 16, color: Colors.black54)),
            const SizedBox(height: 8),
            const Text('Give cash to customer now!',
                style: TextStyle(fontSize: 14, color: Color(0xFFE91E63), fontWeight: FontWeight.w500)),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _receiptRow('Customer', phoneController.text),
                  _receiptRow('Amount', '₹${amountController.text}'),
                  _receiptRow('TX ID', txId?.substring(0, 8).toUpperCase() ?? 'N/A'),
                  _receiptRow('Status', '✅ Success'),
                  _receiptRow('Commission', '₹2.50 earned'),
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
                  backgroundColor: const Color(0xFF00897B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text('Done', style: TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold)),
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
          Text(label, style: const TextStyle(color: Colors.black45, fontSize: 13)),
          Text(value, style: TextStyle(color: textDark, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}