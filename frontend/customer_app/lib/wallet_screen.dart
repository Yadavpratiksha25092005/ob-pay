import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'api_service.dart';

class WalletScreen extends StatefulWidget {
  final String userId;
  final String? receiverPhone;

  const WalletScreen({
    super.key,
    required this.userId,
    this.receiverPhone,
  });

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with TickerProviderStateMixin {
  late final TextEditingController phoneController;
  final amountController = TextEditingController();
  final noteController = TextEditingController();
  bool isLoading = false;
  bool isSuccess = false;
  String? errorMessage;
  String? paymentId;
  List<dynamic> _contacts = [];

  late AnimationController _checkController;
  late AnimationController _scaleController;
  late Animation<double> _checkAnimation;
  late Animation<double> _scaleAnimation;

  final List<int> quickAmounts = [100, 500, 1000, 2000];

  @override
  void initState() {
    super.initState();
    phoneController = TextEditingController(text: widget.receiverPhone ?? '');
    _loadContacts();
    _checkController = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
    _scaleController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    _checkAnimation =
        CurvedAnimation(parent: _checkController, curve: Curves.easeOutBack);
    _scaleAnimation =
        CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack);
  }

  Future<void> _loadContacts() async {
    final data = await ApiService.getBeneficiaries(widget.userId);
    if (mounted) setState(() => _contacts = data);
  }

  @override
  void dispose() {
    _checkController.dispose();
    _scaleController.dispose();
    phoneController.dispose();
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  String? _validateSend() {
    final phone = phoneController.text.trim();
    final amountText = amountController.text.trim();
    if (phone.isEmpty) return 'Receiver phone required';
    if (!RegExp(r'^\d{10}$').hasMatch(phone)) return 'Phone must be exactly 10 digits';
    if (amountText.isEmpty) return 'Amount required';
    final amount = double.tryParse(amountText);
    if (amount == null || amount < 1) return 'Minimum transfer amount is ₹1';
    if (amount > 100000) return 'Maximum transfer amount is ₹1,00,000';
    return null;
  }

  Future<void> sendMoney() async {
    final error = _validateSend();
    if (error != null) {
      setState(() => errorMessage = error);
      return;
    }
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final result = await ApiService.sendMoney(
        senderUserId: widget.userId,
        receiverPhone: phoneController.text,
        amount: double.parse(amountController.text),
        description: noteController.text,
      );
      if (result['payment_id'] != null) {
        setState(() {
          isSuccess = true;
          paymentId = result['payment_id'];
          isLoading = false;
        });
        HapticFeedback.heavyImpact();
        _scaleController.forward();
        await Future.delayed(const Duration(milliseconds: 200));
        _checkController.forward();
      } else {
        setState(() {
          errorMessage = result['error'] ?? 'Payment failed';
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
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: isSuccess
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text('Send Money',
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.history_rounded, color: Color(0xFF6C63FF)),
                  onPressed: () {},
                ),
              ],
            ),
      body: isSuccess ? _buildSuccess() : _buildForm(),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // UPI Banner
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A56DB), Color(0xFF6C63FF)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withOpacity(0.4),
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
                      Text('Secure. Fast. Reliable.',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12)),
                      const SizedBox(height: 4),
                      const Text('UPI Payments',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.verified_rounded,
                      color: Colors.white, size: 32),
                ),
                const SizedBox(width: 8),
                // UPI Logo
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('UPI',
                      style: TextStyle(
                          color: Color(0xFF6C63FF),
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                ),
              ],
            ),
          ),

          // Form
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick contacts row
                if (_contacts.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Quick Send',
                          style: TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 72,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _contacts.length,
                      itemBuilder: (_, i) {
                        final c = _contacts[i];
                        final name = (c['nickname'] ?? c['name'] ?? '') as String;
                        final phone = (c['phone'] ?? '') as String;
                        final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
                        const colors = [
                          Color(0xFF6C63FF), Color(0xFF43C6AC), Color(0xFFFF6584),
                          Color(0xFFFFA630), Color(0xFF4FC3F7),
                        ];
                        final color = colors[name.codeUnitAt(0) % colors.length];
                        return GestureDetector(
                          onTap: () => setState(() => phoneController.text = phone),
                          child: Container(
                            width: 60,
                            margin: const EdgeInsets.only(right: 12),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  backgroundColor: color,
                                  radius: 22,
                                  child: Text(initial,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  name.length > 7 ? '${name.substring(0, 7)}…' : name,
                                  style: const TextStyle(fontSize: 10, color: Color(0xFF718096)),
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Receiver input
                const Text('Enter Receiver Details',
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.text,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Enter Mobile Number or UPI ID',
                      hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
                      suffixIcon: const Icon(Icons.person_search_rounded,
                          color: Color(0xFF6C63FF)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Amount
                const Text('Enter Amount',
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('₹',
                        style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A202C))),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A202C)),
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
                    GestureDetector(
                      onTap: () => _showAddNote(),
                      child: const Text('Add Note',
                          style: TextStyle(
                              color: Color(0xFF6C63FF),
                              fontSize: 13,
                              fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),

                Divider(color: Colors.grey.shade200),
                const SizedBox(height: 10),

                // Quick amounts
                Row(
                  children: quickAmounts.map((amt) {
                    final isSelected = amountController.text == amt.toString();
                    return Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => amountController.text = amt.toString()),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF6C63FF)
                                : const Color(0xFFF0F0FF),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF6C63FF)
                                  : Colors.grey.shade200,
                            ),
                          ),
                          child: Text(
                            '₹$amt',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF6C63FF),
                                fontSize: 13,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                if (errorMessage != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded,
                            color: Colors.red, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(errorMessage!,
                              style: TextStyle(
                                  color: Colors.red.shade700, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // Send button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : sendMoney,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            amountController.text.isEmpty
                                ? 'Send Money'
                                : 'Send ₹${amountController.text}',
                            style: const TextStyle(
                                fontSize: 17,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                  ),
                ),

                const SizedBox(height: 14),

                // Powered by UPI
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Powered by ',
                        style: TextStyle(color: Colors.black38, fontSize: 12)),
                    Text('UPI',
                        style: TextStyle(
                            color: Color(0xFF6C63FF),
                            fontSize: 13,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  void _showAddNote() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Add Note',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              decoration: InputDecoration(
                hintText: 'e.g. Rent, Food, etc.',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF6C63FF), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Done',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
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
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 120, height: 120,
                      decoration: const BoxDecoration(
                          color: Color(0xFF00C853), shape: BoxShape.circle),
                      child: ScaleTransition(
                        scale: _checkAnimation,
                        child: const Icon(Icons.check_rounded,
                            color: Colors.white, size: 64),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Text('₹ ${amountController.text}',
                        style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A202C),
                            letterSpacing: -1)),
                  ),
                  const SizedBox(height: 8),
                  Text('Paid to ${phoneController.text}',
                      style: const TextStyle(
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
                          _receiptRow('Transaction ID',
                              paymentId?.substring(0, 8).toUpperCase() ?? 'N/A',
                              icon: Icons.receipt_rounded),
                          _divider(),
                          _receiptRow(
                              'Date & Time',
                              '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}  ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                              icon: Icons.calendar_today_rounded),
                          _divider(),
                          _receiptRow('Payment Method', 'OB Wallet',
                              icon: Icons.account_balance_wallet_rounded),
                          _divider(),
                          _receiptRow('Status', 'Success',
                              icon: Icons.check_circle_rounded,
                              valueColor: const Color(0xFF00C853)),
                          if (noteController.text.isNotEmpty) ...[
                            _divider(),
                            _receiptRow('Note', noteController.text,
                                icon: Icons.note_rounded),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: OutlinedButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Receipt shared!'),
                              backgroundColor: Color(0xFF00C853)),
                        );
                      },
                      icon: const Icon(Icons.share_rounded,
                          color: Color(0xFF6C63FF)),
                      label: const Text('Share Receipt',
                          style: TextStyle(color: Color(0xFF6C63FF))),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        side: const BorderSide(color: Color(0xFF6C63FF)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
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
                    backgroundColor: const Color(0xFF6C63FF),
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

  Widget _receiptRow(String label, String value,
      {IconData? icon, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: Colors.black38),
            const SizedBox(width: 8),
          ],
          Text(label,
              style: const TextStyle(color: Colors.black45, fontSize: 13)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  color: valueColor ?? Colors.black87,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _divider() =>
      Divider(height: 1, color: Colors.grey.shade200);
}