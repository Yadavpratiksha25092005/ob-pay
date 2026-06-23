import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PerformanceScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const PerformanceScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> {
  static const Color green = Color(0xFF00897B);
  static const Color darkGreen = Color(0xFF004D40);
  static const Color bgPage = Color(0xFFF5F5F5);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1A202C);
  static const Color textLight = Color(0xFF718096);

  String selectedPeriod = 'This Month';

  final Map<String, List<double>> chartData = {
    'This Week': [1200, 2500, 800, 3200, 1800, 4500, 2100],
    'This Month': [8200, 12400, 9800, 16200, 11000, 14500, 18000],
    'Last Month': [6200, 9400, 7800, 12200, 9000, 11500, 15000],
  };

  final List<Map<String, dynamic>> badges = [
    {'title': 'Top Performer', 'icon': Icons.emoji_events_rounded, 'color': const Color(0xFFFFD700), 'earned': true},
    {'title': 'Cash King', 'icon': Icons.monetization_on_rounded, 'color': const Color(0xFF00897B), 'earned': true},
    {'title': '50 Customers', 'icon': Icons.people_rounded, 'color': const Color(0xFF3D5AF1), 'earned': false},
    {'title': 'Speed Star', 'icon': Icons.speed_rounded, 'color': const Color(0xFFE91E63), 'earned': true},
    {'title': '1 Lakh Club', 'icon': Icons.stars_rounded, 'color': const Color(0xFF9F7AEA), 'earned': false},
    {'title': 'Consistent', 'icon': Icons.verified_rounded, 'color': const Color(0xFF00B5D8), 'earned': true},
  ];

  final List<Map<String, dynamic>> leaderboard = [
    {'rank': 1, 'name': 'Suresh Kumar', 'score': 98, 'amount': '₹85,000'},
    {'rank': 2, 'name': 'Meena Devi', 'score': 95, 'amount': '₹78,000'},
    {'rank': 3, 'name': 'Raju Verma', 'score': 91, 'amount': '₹72,000'},
    {'rank': 4, 'name': 'You', 'score': 87, 'amount': '₹65,000', 'isMe': true},
    {'rank': 5, 'name': 'Anita Singh', 'score': 84, 'amount': '₹61,000'},
  ];

  @override
  Widget build(BuildContext context) {
    final data = chartData[selectedPeriod]!;
    final maxVal = data.reduce((a, b) => a > b ? a : b);

    return Scaffold(
      backgroundColor: bgPage,
      appBar: AppBar(
        backgroundColor: bgCard,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1A202C)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Performance',
            style: TextStyle(
                color: Color(0xFF1A202C),
                fontSize: 18,
                fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Score Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF004D40), Color(0xFF00897B)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                      color: darkGreen.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Performance Score',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 13)),
                          const SizedBox(height: 8),
                          const Text('87',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 56,
                                  fontWeight: FontWeight.bold)),
                          const Text('out of 100',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                      Column(
                        children: [
                          Container(
                            width: 80, height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.emoji_events_rounded,
                                color: Color(0xFFFFD700), size: 44),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD700).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text('Gold Agent 🏆',
                                style: TextStyle(
                                    color: Color(0xFFFFD700),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: 0.87,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Top 15% of all agents this month! 🚀',
                      style:
                          TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _scoreStat('28', 'Customers'),
                      const SizedBox(width: 24),
                      _scoreStat('₹14,200', 'Collections'),
                      const SizedBox(width: 24),
                      _scoreStat('4.8★', 'Rating'),
                      const SizedBox(width: 24),
                      _scoreStat('#4', 'Rank'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Period selector
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: bgCard,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8)
                ],
              ),
              child: Row(
                children: ['This Week', 'This Month', 'Last Month']
                    .map((p) {
                  final isSelected = selectedPeriod == p;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => selectedPeriod = p),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? green : Colors.transparent,
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

            // Revenue Chart
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: bgCard,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10)
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Collection Trend',
                      style: TextStyle(
                          color: textDark,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 160,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) => FlLine(
                              color: Colors.grey.withOpacity(0.1),
                              strokeWidth: 1),
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const labels = ['W1', 'W2', 'W3', 'W4', 'W5', 'W6', 'W7'];
                                final idx = value.toInt();
                                if (idx < 0 || idx >= labels.length)
                                  return const SizedBox();
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(labels[idx],
                                      style: const TextStyle(
                                          fontSize: 10,
                                          color: textLight)),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: data
                                .asMap()
                                .entries
                                .map((e) => FlSpot(
                                    e.key.toDouble(), e.value))
                                .toList(),
                            isCurved: true,
                            gradient: const LinearGradient(
                                colors: [darkGreen, green]),
                            barWidth: 3,
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  green.withOpacity(0.2),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            dotData: FlDotData(
                              show: true,
                              getDotPainter:
                                  (spot, percent, bar, index) =>
                                      FlDotCirclePainter(
                                          radius: 3,
                                          color: green,
                                          strokeWidth: 2,
                                          strokeColor: bgCard),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Badges
            const Text('Achievement Badges',
                style: TextStyle(
                    color: textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              childAspectRatio: 1.0,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: badges.map((badge) {
                final earned = badge['earned'] as bool;
                final color = badge['color'] as Color;
                return Container(
                  decoration: BoxDecoration(
                    color: earned ? bgCard : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: earned
                        ? [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8)
                          ]
                        : null,
                    border: Border.all(
                      color: earned
                          ? color.withOpacity(0.3)
                          : Colors.grey.shade200,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        badge['icon'] as IconData,
                        color: earned ? color : Colors.grey.shade400,
                        size: 32,
                      ),
                      const SizedBox(height: 6),
                      Text(badge['title'] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: earned
                                  ? textDark
                                  : Colors.grey.shade400,
                              fontSize: 10,
                              fontWeight: FontWeight.w500)),
                      if (!earned)
                        Text('Locked',
                            style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 9)),
                    ],
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Leaderboard
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: bgCard,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10)
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.leaderboard_rounded,
                          color: Color(0xFF00897B), size: 20),
                      SizedBox(width: 8),
                      Text('Leaderboard',
                          style: TextStyle(
                              color: textDark,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...leaderboard.map((entry) {
                    final isMe = entry['isMe'] == true;
                    final rank = entry['rank'] as int;
                    Color rankColor;
                    if (rank == 1) rankColor = const Color(0xFFFFD700);
                    else if (rank == 2) rankColor = const Color(0xFFC0C0C0);
                    else if (rank == 3) rankColor = const Color(0xFFCD7F32);
                    else rankColor = textLight;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isMe
                            ? green.withOpacity(0.08)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isMe
                              ? green.withOpacity(0.3)
                              : Colors.grey.shade100,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32, height: 32,
                            decoration: BoxDecoration(
                              color: rankColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text('#$rank',
                                  style: TextStyle(
                                      color: rankColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry['name'] as String,
                                  style: TextStyle(
                                      color: textDark,
                                      fontWeight: isMe
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      fontSize: 14),
                                ),
                                Text('Score: ${entry['score']}',
                                    style: const TextStyle(
                                        color: textLight,
                                        fontSize: 12)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(entry['amount'] as String,
                                  style: const TextStyle(
                                      color: textDark,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                              if (isMe)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: green.withOpacity(0.1),
                                    borderRadius:
                                        BorderRadius.circular(6),
                                  ),
                                  child: const Text('You',
                                      style: TextStyle(
                                          color: green,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold)),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Commission tracker
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: bgCard,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10)
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Commission Tracker',
                      style: TextStyle(
                          color: textDark,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _commissionRow('Cash In Commission', '₹350', '140 transactions × ₹2.5'),
                  _commissionRow('Cash Out Commission', '₹175', '70 transactions × ₹2.5'),
                  _commissionRow('New Customer Bonus', '₹280', '28 customers × ₹10'),
                  _commissionRow('Performance Bonus', '₹500', 'Gold Agent bonus'),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Commission',
                          style: TextStyle(
                              color: textDark,
                              fontSize: 15,
                              fontWeight: FontWeight.bold)),
                      Text('₹1,305',
                          style: const TextStyle(
                              color: Color(0xFF00897B),
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                    ],
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

  Widget _scoreStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: TextStyle(
                color: Colors.white.withOpacity(0.6), fontSize: 10)),
      ],
    );
  }

  Widget _commissionRow(String title, String amount, String detail) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: textDark,
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
                Text(detail,
                    style: const TextStyle(
                        color: textLight, fontSize: 11)),
              ],
            ),
          ),
          Text(amount,
              style: const TextStyle(
                  color: Color(0xFF00897B),
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}