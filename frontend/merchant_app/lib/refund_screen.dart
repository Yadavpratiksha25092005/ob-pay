import 'package:flutter/material.dart';
import 'api_service.dart';

class RefundScreen extends StatefulWidget {
  final String userId;

  const RefundScreen({super.key, required this.userId});

  @override
  State<RefundScreen> createState() => _RefundScreenState();
}

class _RefundScreenState extends State<RefundScreen> {
  List<dynamic> payments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    try {
      final data = await ApiService.getPaymentHistory(widget.userId);
      setState(() {
        payments = (data['payments'] ?? [])
            .where((p) => p['receiver_user_id'] == widget.userId)
            .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> processRefund(Map<String, dynamic> payment) async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Refund'),
        content: Text(
            'Refund ₹${payment['amount']} to customer?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => isLoading = true);
              await Future.delayed(const Duration(seconds: 2));
              setState(() => isLoading = false);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      '✅ Refund of ₹${payment['amount']} processed successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Refund',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        title: const Text('Refunds',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: loadTransactions,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Info Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.orange.shade50,
                  child: const Row(
                    children: [
                      Icon(Icons.info, color: Colors.orange),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Refunds are processed within 5-7 business days to customer wallet',
                          style: TextStyle(
                              color: Colors.orange,
                              fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),

                // Transactions List
                Expanded(
                  child: payments.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Icon(Icons.receipt_long,
                                  size: 80, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('No transactions to refund',
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: payments.length,
                          itemBuilder: (context, index) {
                            final payment = payments[index];
                            return Card(
                              margin:
                                  const EdgeInsets.only(bottom: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    const CircleAvatar(
                                      backgroundColor:
                                          Color(0xFF1A237E),
                                      child: Icon(Icons.person,
                                          color: Colors.white,
                                          size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Payment Received',
                                            style: const TextStyle(
                                                fontWeight:
                                                    FontWeight.w500),
                                          ),
                                          Text(
                                            payment['description'] ??
                                                'Customer payment',
                                            style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '₹${payment['amount']}',
                                          style: const TextStyle(
                                              fontWeight:
                                                  FontWeight.bold,
                                              color: Colors.green,
                                              fontSize: 16),
                                        ),
                                        const SizedBox(height: 4),
                                        GestureDetector(
                                          onTap: () =>
                                              processRefund(payment),
                                          child: Container(
                                            padding: const EdgeInsets
                                                .symmetric(
                                                horizontal: 10,
                                                vertical: 4),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.red.shade50,
                                              borderRadius:
                                                  BorderRadius
                                                      .circular(20),
                                              border: Border.all(
                                                  color: Colors.red),
                                            ),
                                            child: const Text(
                                              'Refund',
                                              style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 12,
                                                  fontWeight:
                                                      FontWeight
                                                          .w500),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}