import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'api_service.dart';

class AnalyticsScreen extends StatefulWidget {
  final String userId;

  const AnalyticsScreen({super.key, required this.userId});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  static const Color bgPage = Color(0xFFF5F5F5);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color blue = Color(0xFF3D5AF1);
  static const Color textDark = Color(0xFF1A202C);
  static const Color textLight = Color(0xFF718096);

  String selectedPeriod = 'This Month';
  Map<String, dynamic>? analyticsData;
  bool isLoading = true;

  final Map<String, String> periodMap = {
    'This Week': 'week',
    'This Month': 'month',
    'Last Month': 'last_month',
  };

  @override
  void initState() {
    super.initState();
    loadAnalytics();
  }

  Future<void> loadAnalytics() async {
    setState(() => isLoading = true);
    try {
      final period = periodMap[selectedPeriod] ?? 'month';
      final data = await ApiService.getAnalytics(widget.userId, period: period);
      setState(() {
        analyticsData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  double get totalRevenue => (analyticsData?['total_revenue'] ?? 0).toDouble();
  int get totalTx => analyticsData?['transactions'] ?? 0;
  double get avgPerDay => (analyticsData?['avg_per_day'] ?? 0).toDouble();
  String get bestDay => (analyticsData?['best_day'] ?? 'N/A').toString().trim();

  List<Map<String, dynamic>> get chartData {
    final raw = analyticsData?['chart_data'];
    if (raw == null) return [];
    return List<Map<String, dynamic>>.from(raw);
  }

  List<Map<String, dynamic>> get topTx {
    final raw = analyticsData?['top_transactions'];
    if (raw == null) return [];
    return List<Map<String, dynamic>>.from(raw);
  }

  Map<String, dynamic> get paymentMethods =>
      analyticsData?['payment_methods'] ?? {};

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
        title: const Text('Analytics',
            style: TextStyle(
                color: Color(0xFF1A202C),
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF3D5AF1)),
            onPressed: loadAnalytics,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Period selector
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: bgCard,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8),
                      ],
                    ),
                    child: Row(
                      children: ['This Week', 'This Month', 'Last Month']
                          .map((p) {
                        final isSelected = selectedPeriod == p;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() => selectedPeriod = p);
                              loadAnalytics();
                            },
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? blue : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(p,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : textLight,
                                      fontSize: 12,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Summary Cards
                  Row(
                    children: [
                      Expanded(
                        child: _summaryCard(
                          title: 'Revenue',
                          value: '₹ ${totalRevenue.toStringAsFixed(2)}',
                          growth: '+16.7%',
                          isUp: true,
                          icon: Icons.trending_up_rounded,
                          color: const Color(0xFF48BB78),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _summaryCard(
                          title: 'Transactions',
                          value: '$totalTx',
                          growth: '+14.3%',
                          isUp: true,
                          icon: Icons.receipt_long_rounded,
                          color: blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _summaryCard(
                          title: 'Avg per Day',
                          value: '₹ ${avgPerDay.toStringAsFixed(0)}',
                          growth: '',
                          isUp: true,
                          icon: Icons.bar_chart_rounded,
                          color: const Color(0xFFED8936),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _summaryCard(
                          title: 'Best Day',
                          value: bestDay,
                          growth: '',
                          isUp: true,
                          icon: Icons.star_rounded,
                          color: const Color(0xFF9F7AEA),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Revenue Trend Chart
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: bgCard,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Revenue Trend',
                                style: TextStyle(
                                    color: textDark,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                            Text('₹ ${totalRevenue.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    color: textDark,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 20),

                        chartData.isEmpty
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Text('No data available',
                                      style:
                                          TextStyle(color: Colors.black38)),
                                ),
                              )
                            : SizedBox(
                                height: 180,
                                child: () {
                                  final maxAmt = chartData
                                      .map((e) =>
                                          (e['amount'] as num).toDouble())
                                      .reduce((a, b) => a > b ? a : b);
                                  return Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: chartData.map((d) {
                                      final amount =
                                          (d['amount'] as num).toDouble();
                                      final height = maxAmt > 0
                                          ? (amount / maxAmt) * 140
                                          : 20.0;
                                      final isMax = amount == maxAmt;
                                      return Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            amount >= 1000
                                                ? '₹${(amount / 1000).toStringAsFixed(1)}k'
                                                : '₹${amount.toStringAsFixed(0)}',
                                            style: TextStyle(
                                                fontSize: 9,
                                                color: isMax
                                                    ? blue
                                                    : Colors.black38,
                                                fontWeight: isMax
                                                    ? FontWeight.bold
                                                    : FontWeight.normal),
                                          ),
                                          const SizedBox(height: 4),
                                          Container(
                                            width: 36,
                                            height: height,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin:
                                                    Alignment.bottomCenter,
                                                end: Alignment.topCenter,
                                                colors: isMax
                                                    ? [
                                                        blue,
                                                        const Color(
                                                            0xFF00B5D8)
                                                      ]
                                                    : [
                                                        blue.withOpacity(
                                                            0.4),
                                                        blue.withOpacity(
                                                            0.2)
                                                      ],
                                              ),
                                              borderRadius:
                                                  const BorderRadius
                                                      .vertical(
                                                      top:
                                                          Radius.circular(
                                                              8)),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                              d['day']
                                                  .toString()
                                                  .substring(0, 
                                                    d['day'].toString().length > 6 ? 6 : d['day'].toString().length),
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: isMax
                                                      ? blue
                                                      : textLight,
                                                  fontWeight: isMax
                                                      ? FontWeight.bold
                                                      : FontWeight
                                                          .normal)),
                                        ],
                                      );
                                    }).toList(),
                                  );
                                }(),
                              ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Payment Methods
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: bgCard,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Top Payment Methods',
                            style: TextStyle(
                                color: textDark,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            SizedBox(
                              width: 100, height: 100,
                              child: PieChart(
                                PieChartData(
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 30,
                                  sections: [
                                    PieChartSectionData(
                                        value: 65,
                                        color: blue,
                                        radius: 20,
                                        showTitle: false),
                                    PieChartSectionData(
                                        value: 25,
                                        color: const Color(0xFF48BB78),
                                        radius: 20,
                                        showTitle: false),
                                    PieChartSectionData(
                                        value: 7,
                                        color: const Color(0xFFED8936),
                                        radius: 20,
                                        showTitle: false),
                                    PieChartSectionData(
                                        value: 3,
                                        color: const Color(0xFF9F7AEA),
                                        radius: 20,
                                        showTitle: false),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                children: [
                                  _methodRow(
                                      'UPI',
                                      paymentMethods['upi']?['percent'] ?? 65,
                                      '₹ ${((paymentMethods['upi']?['amount'] ?? 0) as num).toStringAsFixed(0)}',
                                      blue),
                                  _methodRow(
                                      'QR Code',
                                      paymentMethods['qr']?['percent'] ?? 25,
                                      '₹ ${((paymentMethods['qr']?['amount'] ?? 0) as num).toStringAsFixed(0)}',
                                      const Color(0xFF48BB78)),
                                  _methodRow(
                                      'Wallet',
                                      paymentMethods['wallet']?['percent'] ?? 7,
                                      '₹ ${((paymentMethods['wallet']?['amount'] ?? 0) as num).toStringAsFixed(0)}',
                                      const Color(0xFFED8936)),
                                  _methodRow(
                                      'Others',
                                      paymentMethods['others']?['percent'] ?? 3,
                                      '₹ ${((paymentMethods['others']?['amount'] ?? 0) as num).toStringAsFixed(0)}',
                                      const Color(0xFF9F7AEA)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Top Transactions
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: bgCard,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Top Transactions',
                            style: TextStyle(
                                color: textDark,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        topTx.isEmpty
                            ? const Center(
                                child: Text('No transactions yet',
                                    style:
                                        TextStyle(color: Colors.black38)))
                            : Column(
                                children: topTx
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  final i = entry.key;
                                  final tx = entry.value;
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 14),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 36, height: 36,
                                          decoration: BoxDecoration(
                                            color:
                                                blue.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text('${i + 1}',
                                                style: const TextStyle(
                                                    color: blue,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    fontSize: 14)),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                            children: [
                                              Text(
                                                  tx['name'] ??
                                                      'Customer',
                                                  style: const TextStyle(
                                                      color: textDark,
                                                      fontWeight:
                                                          FontWeight
                                                              .w500,
                                                      fontSize: 14)),
                                              Text(
                                                  tx['time'] ??
                                                      'Recently',
                                                  style: const TextStyle(
                                                      color: textLight,
                                                      fontSize: 12)),
                                            ],
                                          ),
                                        ),
                                        Text(
                                            '₹ ${(tx['amount'] as num).toStringAsFixed(0)}',
                                            style: const TextStyle(
                                                color:
                                                    Color(0xFF48BB78),
                                                fontWeight:
                                                    FontWeight.bold,
                                                fontSize: 15)),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required String growth,
    required bool isUp,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 10),
          Text(value,
              style: const TextStyle(
                  color: textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(title,
                    style:
                        const TextStyle(color: textLight, fontSize: 11)),
              ),
              if (growth.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isUp
                        ? const Color(0xFFEAF3DE)
                        : const Color(0xFFFCEBEB),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isUp
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                        color: isUp
                            ? const Color(0xFF3B6D11)
                            : Colors.red,
                        size: 10,
                      ),
                      Text(
                          growth
                              .replaceAll('+', '')
                              .replaceAll('-', ''),
                          style: TextStyle(
                              color: isUp
                                  ? const Color(0xFF3B6D11)
                                  : Colors.red,
                              fontSize: 9,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _methodRow(
      String method, dynamic percent, String amount, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 10, height: 10,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(method,
                style: const TextStyle(
                    color: textDark,
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
          ),
          Text('$percent%',
              style:
                  const TextStyle(color: textLight, fontSize: 12)),
          const SizedBox(width: 8),
          Text(amount,
              style: const TextStyle(
                  color: textDark,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}