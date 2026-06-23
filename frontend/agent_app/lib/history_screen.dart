import 'package:flutter/material.dart';
import 'api_service.dart';

class HistoryScreen extends StatefulWidget {
  final String userId;

  const HistoryScreen({super.key, required this.userId});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> payments = [];
  bool isLoading = true;
  double totalCashIn = 0;
  double totalCashOut = 0;

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    try {
      final data = await ApiService.getPaymentHistory(widget.userId);
      final list = data['payments'] ?? [];

      double cashIn = 0;
      double cashOut = 0;

      for (var p in list) {
        if (p['receiver_user_id'] == widget.userId) {
          cashIn += p['amount'];
        } else {
          cashOut += p['amount'];
        }
      }

      setState(() {
        payments = list;
        totalCashIn = cashIn;
        totalCashOut = cashOut;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF004D40),
        title: const Text('Transaction History',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: loadHistory,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Summary Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: const Color(0xFF004D40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text('Cash In',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                          Text(
                            '₹ ${totalCashIn.toStringAsFixed(0)}',
                            style: const TextStyle(
                                color: Colors.greenAccent,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('Cash Out',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                          Text(
                            '₹ ${totalCashOut.toStringAsFixed(0)}',
                            style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('Commission',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                          Text(
                            '₹ ${(payments.length * 2.5).toStringAsFixed(0)}',
                            style: const TextStyle(
                                color: Colors.orangeAccent,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Transactions List
                Expanded(
                  child: payments.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.receipt_long,
                                  size: 80, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('No transactions yet',
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
                            final isCashIn =
                                payment['receiver_user_id'] ==
                                    widget.userId;
                            final amount = payment['amount'];

                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isCashIn
                                      ? Colors.green.shade50
                                      : Colors.red.shade50,
                                  child: Icon(
                                    isCashIn
                                        ? Icons.add_circle
                                        : Icons.remove_circle,
                                    color: isCashIn
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                                title: Text(
                                  isCashIn ? 'Cash In' : 'Cash Out',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500),
                                ),
                                subtitle: Text(
                                  payment['description'] ?? 'Agent Transaction',
                                  style: const TextStyle(
                                      color: Colors.grey),
                                ),
                                trailing: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${isCashIn ? '+' : '-'}₹$amount',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isCashIn
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                    const Text('₹2.5 commission',
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.orange)),
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