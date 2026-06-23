import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BillsScreen extends StatefulWidget {
  final String userId;

  const BillsScreen({super.key, required this.userId});

  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  String? selectedCategory;

  final List<Map<String, dynamic>> categories = [
    {'name': 'Mobile Recharge', 'icon': Icons.phone_android_rounded, 'color': const Color(0xFF6C63FF), 'bg': const Color(0xFFEEEDFE)},
    {'name': 'Electricity', 'icon': Icons.electric_bolt_rounded, 'color': const Color(0xFFFF9800), 'bg': const Color(0xFFFFF3E0)},
    {'name': 'Water', 'icon': Icons.water_drop_rounded, 'color': const Color(0xFF2196F3), 'bg': const Color(0xFFE3F2FD)},
    {'name': 'DTH / Cable', 'icon': Icons.tv_rounded, 'color': const Color(0xFFE91E63), 'bg': const Color(0xFFFCE4EC)},
    {'name': 'Gas', 'icon': Icons.local_fire_department_rounded, 'color': const Color(0xFFFF5722), 'bg': const Color(0xFFFBE9E7)},
    {'name': 'Broadband', 'icon': Icons.wifi_rounded, 'color': const Color(0xFF009688), 'bg': const Color(0xFFE0F2F1)},
    {'name': 'Insurance', 'icon': Icons.security_rounded, 'color': const Color(0xFF4CAF50), 'bg': const Color(0xFFE8F5E9)},
    {'name': 'FASTag', 'icon': Icons.directions_car_rounded, 'color': const Color(0xFF795548), 'bg': const Color(0xFFEFEBE9)},
  ];

  final List<Map<String, dynamic>> recentBills = [
    {'name': 'Jio Recharge', 'amount': '₹299', 'date': 'Yesterday', 'icon': Icons.phone_android_rounded, 'color': const Color(0xFF6C63FF), 'bg': const Color(0xFFEEEDFE)},
    {'name': 'MSEDCL Electricity', 'amount': '₹1,240', 'date': '3 days ago', 'icon': Icons.electric_bolt_rounded, 'color': const Color(0xFFFF9800), 'bg': const Color(0xFFFFF3E0)},
    {'name': 'Tata Sky DTH', 'amount': '₹349', 'date': '1 week ago', 'icon': Icons.tv_rounded, 'color': const Color(0xFFE91E63), 'bg': const Color(0xFFFCE4EC)},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C63FF),
        title: Text(selectedCategory ?? 'Bill Payments',
            style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        leading: selectedCategory != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => setState(() => selectedCategory = null),
              )
            : null,
      ),
      body: selectedCategory == null
          ? _buildHome()
          : selectedCategory == 'Mobile Recharge'
              ? _MobileRechargeScreen(userId: widget.userId)
              : _BillForm(
                  category: selectedCategory!,
                  userId: widget.userId,
                  onBack: () => setState(() => selectedCategory = null),
                ),
    );
  }

  Widget _buildHome() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recharge & stay connected Banner
          Container(
            width: double.infinity,
            height: 130,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF6C63FF), Color(0xFF3D5AF1)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -20, top: -20,
                  child: Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.07),
                    ),
                  ),
                ),
                Positioned(
                  right: 20, bottom: -30,
                  child: Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.05),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Recharge & stay connected',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(
                              'Get exciting cashback and\nbest offers on every recharge',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 70, height: 70,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          const Icon(Icons.phone_android_rounded,
                              color: Colors.white, size: 36),
                          Positioned(
                            top: 4, right: 4,
                            child: Container(
                              width: 24, height: 24,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFD700),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.percent_rounded,
                                  color: Colors.white, size: 14),
                            ),
                          ),
                          Positioned(
                            bottom: 4, right: 4,
                            child: Container(
                              width: 24, height: 24,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.flash_on_rounded,
                                  color: Color(0xFF6C63FF), size: 14),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          const Text('Pay Bills',
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04), blurRadius: 10)
              ],
            ),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              childAspectRatio: 0.85,
              mainAxisSpacing: 12,
              crossAxisSpacing: 8,
              children: categories.map((cat) {
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() => selectedCategory = cat['name']);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 52, height: 52,
                        decoration: BoxDecoration(
                          color: cat['bg'] as Color,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(cat['icon'] as IconData,
                            color: cat['color'] as Color, size: 24),
                      ),
                      const SizedBox(height: 6),
                      Text(cat['name'] as String,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: const TextStyle(
                              fontSize: 10,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Bills',
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              const Text('View all',
                  style: TextStyle(
                      color: Color(0xFF6C63FF),
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04), blurRadius: 10)
              ],
            ),
            child: Column(
              children: recentBills.asMap().entries.map((entry) {
                final i = entry.key;
                final bill = entry.value;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 46, height: 46,
                            decoration: BoxDecoration(
                              color: bill['bg'] as Color,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(bill['icon'] as IconData,
                                color: bill['color'] as Color, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(bill['name'] as String,
                                    style: const TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14)),
                                Text(bill['date'] as String,
                                    style: const TextStyle(
                                        color: Colors.black38,
                                        fontSize: 12)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(bill['amount'] as String,
                                  style: const TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15)),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEAF3DE),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text('Paid',
                                    style: TextStyle(
                                        color: Color(0xFF3B6D11),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (i < recentBills.length - 1)
                      Divider(
                          height: 1,
                          color: Colors.grey.withOpacity(0.1),
                          indent: 74),
                  ],
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 20),

          const Text('Bill Offers',
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _OfferCard(
                    title: '10% off',
                    subtitle: 'On Jio recharge',
                    color: const Color(0xFF6C63FF),
                    icon: Icons.phone_android_rounded),
                _OfferCard(
                    title: '₹50 cashback',
                    subtitle: 'On electricity bill',
                    color: const Color(0xFFFF9800),
                    icon: Icons.electric_bolt_rounded),
                _OfferCard(
                    title: 'Free DTH',
                    subtitle: '3 months free',
                    color: const Color(0xFFE91E63),
                    icon: Icons.tv_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// MOBILE RECHARGE — PhonePe style
// ─────────────────────────────────────────
class _MobileRechargeScreen extends StatefulWidget {
  final String userId;
  const _MobileRechargeScreen({required this.userId});

  @override
  State<_MobileRechargeScreen> createState() => _MobileRechargeScreenState();
}

class _MobileRechargeScreenState extends State<_MobileRechargeScreen> {
  String? selectedOperator;
  String selectedTab = 'Unlimited';
  String selectedRechargeType = 'Prepaid';
  int? selectedAmount;
  bool isPaid = false;
  Map<String, dynamic>? selectedPlan;
  final phoneController = TextEditingController();
  late PageController _pageController;
  int _bannerIndex = 0;

  final List<String> rechargeTypes = [
    'Prepaid', 'Postpaid', 'Data Add-on', 'International'
  ];
  final List<int> quickAmounts = [199, 249, 299, 399];

  final List<Map<String, dynamic>> operators = [
    {'name': 'Airtel', 'color': const Color(0xFFE40000), 'icon': Icons.signal_cellular_alt_rounded},
    {'name': 'Jio', 'color': const Color(0xFF0070C0), 'icon': Icons.network_cell_rounded},
    {'name': 'Vi', 'color': const Color(0xFF6B2D8B), 'icon': Icons.signal_cellular_4_bar_rounded},
    {'name': 'BSNL', 'color': const Color(0xFF009933), 'icon': Icons.cell_tower_rounded},
    {'name': 'MTNL', 'color': const Color(0xFF003087), 'icon': Icons.signal_cellular_alt_2_bar_rounded},
  ];

  final List<String> tabs = ['Unlimited', 'Data', 'Top Up', 'Others'];

  final Map<String, Map<String, List<Map<String, dynamic>>>> plans = {
    'Jio': {
      'Unlimited': [
        {'price': 149, 'data': '2 GB/day', 'validity': '28 days', 'calls': 'Unlimited', 'sms': '100/day', 'extra': ''},
        {'price': 209, 'data': '1.5 GB/day', 'validity': '28 days', 'calls': 'Unlimited', 'sms': '100/day', 'extra': 'JioCinema'},
        {'price': 239, 'data': '1.5 GB/day', 'validity': '28 days', 'calls': 'Unlimited', 'sms': '100/day', 'extra': 'Disney+Hotstar'},
        {'price': 299, 'data': '2 GB/day', 'validity': '28 days', 'calls': 'Unlimited', 'sms': '100/day', 'extra': 'JioCinema + OTT'},
        {'price': 349, 'data': '2 GB/day', 'validity': '28 days', 'calls': 'Unlimited', 'sms': '100/day', 'extra': 'Disney+Hotstar'},
        {'price': 479, 'data': '2.5 GB/day', 'validity': '56 days', 'calls': 'Unlimited', 'sms': '100/day', 'extra': ''},
        {'price': 533, 'data': '2 GB/day', 'validity': '84 days', 'calls': 'Unlimited', 'sms': '100/day', 'extra': 'JioCinema'},
        {'price': 599, 'data': '2 GB/day', 'validity': '84 days', 'calls': 'Unlimited', 'sms': '100/day', 'extra': 'Disney+Hotstar'},
        {'price': 666, 'data': '2 GB/day', 'validity': '84 days', 'calls': 'Unlimited', 'sms': '100/day', 'extra': 'JioCinema + Netflix'},
        {'price': 999, 'data': '2 GB/day', 'validity': '84 days', 'calls': 'Unlimited', 'sms': '100/day', 'extra': 'All OTT Apps'},
        {'price': 1299, 'data': '2.5 GB/day', 'validity': '84 days', 'calls': 'Unlimited', 'sms': '100/day', 'extra': 'JioCinema Premium'},
        {'price': 2999, 'data': '2 GB/day', 'validity': '365 days', 'calls': 'Unlimited', 'sms': '100/day', 'extra': 'JioCinema'},
        {'price': 3599, 'data': '2 GB/day', 'validity': '365 days', 'calls': 'Unlimited', 'sms': '100/day', 'extra': 'JioCinema + OTT'},
      ],
      'Data': [
        {'price': 11, 'data': '1 GB', 'validity': '1 day', 'calls': 'NA', 'sms': 'NA', 'extra': ''},
        {'price': 21, 'data': '2 GB', 'validity': '1 day', 'calls': 'NA', 'sms': 'NA', 'extra': ''},
        {'price': 51, 'data': '6 GB', 'validity': '7 days', 'calls': 'NA', 'sms': 'NA', 'extra': ''},
        {'price': 101, 'data': '12 GB', 'validity': '30 days', 'calls': 'NA', 'sms': 'NA', 'extra': ''},
        {'price': 151, 'data': '24 GB', 'validity': '30 days', 'calls': 'NA', 'sms': 'NA', 'extra': ''},
        {'price': 251, 'data': '50 GB', 'validity': '30 days', 'calls': 'NA', 'sms': 'NA', 'extra': ''},
      ],
      'Top Up': [
        {'price': 10, 'data': 'NA', 'validity': '60 days', 'calls': 'NA', 'sms': 'NA', 'extra': 'Talktime ₹7.47'},
        {'price': 50, 'data': 'NA', 'validity': '60 days', 'calls': 'NA', 'sms': 'NA', 'extra': 'Talktime ₹37.35'},
        {'price': 100, 'data': 'NA', 'validity': '60 days', 'calls': 'NA', 'sms': 'NA', 'extra': 'Talktime ₹74.70'},
        {'price': 200, 'data': 'NA', 'validity': '60 days', 'calls': 'NA', 'sms': 'NA', 'extra': 'Talktime ₹149.40'},
        {'price': 500, 'data': 'NA', 'validity': '60 days', 'calls': 'NA', 'sms': 'NA', 'extra': 'Talktime ₹373.50'},
      ],
      'Others': [
        {'price': 19, 'data': 'NA', 'validity': '28 days', 'calls': 'Unlimited Local', 'sms': '100/day', 'extra': 'Voice Only'},
        {'price': 29, 'data': 'NA', 'validity': '28 days', 'calls': 'Unlimited', 'sms': '100/day', 'extra': 'Voice Only'},
        {'price': 91, 'data': 'NA', 'validity': '28 days', 'calls': 'Unlimited', 'sms': '100/day', 'extra': 'ISD Pack'},
      ],
    },
    'Airtel': {
      'Unlimited': [
        {'price': 155, 'data': '1 GB/day', 'validity': '24 days', 'calls': 'Unlimited', 'sms': '100/day', 'extra': ''},
        {'price': 179, 'data': '1.5 GB/day', 'validity': '28 days', 'calls': 'Unlimited', 'sms': '100/day', 'extra': ''},
        {'price': 265, 'data': '1.5 GB/day', 'validity': '28 days', 'calls': 'Unlimited', 'sms': '100/day', 'extra': 'Apollo 24|7'},
        {'price': 299, 'data': '2 GB/day', 'validity': '28 days', 'calls': 'Unlimited', 'sms': '100/day', 'extra': 'Wynk + Apollo'},
        {'price': 359, 'data': '2 GB/day', 'validity': '28 days', 'calls': 'Unlimited', 'sms': '100/day', 'extra': 'Disney+Hotstar'},
        {'price': 449, 'data': '2.5 GB/day', 'validity': '28 days', 'calls': 'Unlimited', 'sms': '100/day', 'extra': 'Amazon Prime'},
        {'price': 599, 'data': '2 GB/day', 'validity': '56 days', 'calls': 'Unlimited', 'sms': '100/day', 'extra': ''},
        {'price': 839, 'data': '2 GB/day', 'validity': '84 days', 'calls': 'Unlimited', 'sms': '100/day', 'extra': ''},
        {'price': 979, 'data': '2 GB/day', 'validity': '84 days', 'calls': 'Unlimited', 'sms': '100/day', 'extra': 'Disney+Hotstar'},
        {'price': 1199, 'data': '2.5 GB/day', 'validity': '84 days', 'calls': 'Unlimited', 'sms': '100/day', 'extra': 'Amazon Prime'},
        {'price': 3599, 'data': '2 GB/day', 'validity': '365 days', 'calls': 'Unlimited', 'sms': '100/day', 'extra': ''},
        {'price': 3999, 'data': '2.5 GB/day', 'validity': '365 days', 'calls': 'Unlimited', 'sms': '100/day', 'extra': 'Disney+Hotstar'},
      ],
      'Data': [
        {'price': 19, 'data': '1 GB', 'validity': '1 day', 'calls': 'NA', 'sms': 'NA', 'extra': ''},
        {'price': 49, 'data': '6 GB', 'validity': '7 days', 'calls': 'NA', 'sms': 'NA', 'extra': ''},
        {'price': 99, 'data': '12 GB', 'validity': '30 days', 'calls': 'NA', 'sms': 'NA', 'extra': ''},
        {'price': 149, 'data': '25 GB', 'validity': '30 days', 'calls': 'NA', 'sms': 'NA', 'extra': ''},
        {'price': 249, 'data': '50 GB', 'validity': '30 days', 'calls': 'NA', 'sms': 'NA', 'extra': ''},
      ],
      'Top Up': [
        {'price': 10, 'data': 'NA', 'validity': '28 days', 'calls': 'NA', 'sms': 'NA', 'extra': 'Talktime ₹7.47'},
        {'price': 100, 'data': 'NA', 'validity': '28 days', 'calls': 'NA', 'sms': 'NA', 'extra': 'Talktime ₹74.70'},
        {'price': 500, 'data': 'NA', 'validity': '28 days', 'calls': 'NA', 'sms': 'NA', 'extra': 'Talktime ₹373.50'},
      ],
      'Others': [
        {'price': 99, 'data': 'NA', 'validity': '28 days', 'calls': 'Unlimited', 'sms': '100/day', 'extra': 'Voice Only'},
        {'price': 199, 'data': 'NA', 'validity': '28 days', 'calls': 'Unlimited', 'sms': '100/day', 'extra': 'ISD Pack'},
      ],
    },
    'Vi': {
      'Unlimited': [
        {'price': 155, 'data': '1 GB/day', 'validity': '24 days', 'calls': 'Unlimited', 'sms': '100/day', 'extra': ''},
        {'price': 199, 'data': '1.5 GB/day', 'validity': '28 days', 'calls': 'Unlimited', 'sms': '100/day', 'extra': 'Vi Movies & TV'},
        {'price': 269, 'data': '1.5 GB/day', 'validity': '28 days', 'calls': 'Unlimited', 'sms': '100/day', 'extra': 'Weekend Data'},
        {'price': 299, 'data': '2 GB/day', 'validity': '28 days', 'calls': 'Unlimited', 'sms': '100/day', 'extra': 'Vi Movies & TV'},
        {'price': 449, 'data': '2.5 GB/day', 'validity': '28 days', 'calls': 'Unlimited', 'sms': '100/day', 'extra': 'Weekend Data Rollover'},
        {'price': 719, 'data': '2 GB/day', 'validity': '56 days', 'calls': 'Unlimited', 'sms': '100/day', 'extra': ''},
        {'price': 799, 'data': '1.5 GB/day', 'validity': '84 days', 'calls': 'Unlimited', 'sms': '100/day', 'extra': ''},
        {'price': 999, 'data': '2 GB/day', 'validity': '84 days', 'calls': 'Unlimited', 'sms': '100/day', 'extra': 'Vi Movies & TV'},
        {'price': 2899, 'data': '1.5 GB/day', 'validity': '365 days', 'calls': 'Unlimited', 'sms': '100/day', 'extra': ''},
      ],
      'Data': [
        {'price': 16, 'data': '1 GB', 'validity': '1 day', 'calls': 'NA', 'sms': 'NA', 'extra': ''},
        {'price': 46, 'data': '6 GB', 'validity': '7 days', 'calls': 'NA', 'sms': 'NA', 'extra': ''},
        {'price': 96, 'data': '12 GB', 'validity': '30 days', 'calls': 'NA', 'sms': 'NA', 'extra': ''},
      ],
      'Top Up': [
        {'price': 10, 'data': 'NA', 'validity': '28 days', 'calls': 'NA', 'sms': 'NA', 'extra': 'Talktime ₹7.47'},
        {'price': 100, 'data': 'NA', 'validity': '28 days', 'calls': 'NA', 'sms': 'NA', 'extra': 'Talktime ₹74.70'},
      ],
      'Others': [
        {'price': 98, 'data': 'NA', 'validity': '28 days', 'calls': 'Unlimited', 'sms': '100/day', 'extra': 'Voice Only'},
      ],
    },
    'BSNL': {
      'Unlimited': [
        {'price': 107, 'data': '1 GB/day', 'validity': '26 days', 'calls': 'Unlimited', 'sms': '100/day', 'extra': ''},
        {'price': 187, 'data': '2 GB/day', 'validity': '28 days', 'calls': 'Unlimited', 'sms': '100/day', 'extra': 'Eros Now'},
        {'price': 247, 'data': '2 GB/day', 'validity': '28 days', 'calls': 'Unlimited', 'sms': '100/day', 'extra': 'Eros Now'},
        {'price': 397, 'data': '3 GB/day', 'validity': '80 days', 'calls': 'Unlimited', 'sms': '100/day', 'extra': 'Eros Now'},
        {'price': 997, 'data': '2 GB/day', 'validity': '160 days', 'calls': 'Unlimited', 'sms': '100/day', 'extra': 'Eros Now'},
        {'price': 1999, 'data': '2 GB/day', 'validity': '365 days', 'calls': 'Unlimited', 'sms': '100/day', 'extra': 'Eros Now'},
      ],
      'Data': [
        {'price': 99, 'data': '10 GB', 'validity': '30 days', 'calls': 'NA', 'sms': 'NA', 'extra': ''},
        {'price': 199, 'data': '25 GB', 'validity': '30 days', 'calls': 'NA', 'sms': 'NA', 'extra': ''},
      ],
      'Top Up': [
        {'price': 36, 'data': 'NA', 'validity': '90 days', 'calls': 'NA', 'sms': 'NA', 'extra': 'Talktime ₹36'},
        {'price': 186, 'data': 'NA', 'validity': '90 days', 'calls': 'NA', 'sms': 'NA', 'extra': 'Talktime ₹186'},
      ],
      'Others': [
        {'price': 99, 'data': 'NA', 'validity': '26 days', 'calls': 'Unlimited', 'sms': 'NA', 'extra': 'Voice Only'},
      ],
    },
    'MTNL': {
      'Unlimited': [
        {'price': 99, 'data': '1 GB/day', 'validity': '28 days', 'calls': 'Unlimited', 'sms': '100/day', 'extra': ''},
        {'price': 199, 'data': '2 GB/day', 'validity': '28 days', 'calls': 'Unlimited', 'sms': '100/day', 'extra': ''},
        {'price': 399, 'data': '3 GB/day', 'validity': '56 days', 'calls': 'Unlimited', 'sms': '100/day', 'extra': ''},
      ],
      'Data': [
        {'price': 49, 'data': '5 GB', 'validity': '30 days', 'calls': 'NA', 'sms': 'NA', 'extra': ''},
      ],
      'Top Up': [
        {'price': 50, 'data': 'NA', 'validity': '60 days', 'calls': 'NA', 'sms': 'NA', 'extra': 'Talktime ₹50'},
      ],
      'Others': [
        {'price': 75, 'data': 'NA', 'validity': '28 days', 'calls': 'Unlimited', 'sms': 'NA', 'extra': 'Voice Only'},
      ],
    },
  };

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startBannerTimer();
  }

  void _startBannerTimer() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _pageController.hasClients) {
        final next = (_bannerIndex + 1) % 3;
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
        _startBannerTimer();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isPaid && selectedPlan != null) return _buildSuccess();
    if (selectedOperator != null) return _buildPlans();
    return _buildOperatorSelect();
  }

  Widget _buildOperatorSelect() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Carousel
          SizedBox(
            height: 130,
            child: PageView(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _bannerIndex = i),
              children: [
                _bannerCard(
                  'Recharge & stay connected',
                  'Get exciting cashback and\nbest offers on every recharge',
                  const Color(0xFF6C63FF),
                  Icons.phone_android_rounded,
                ),
                _bannerCard(
                  'Flat ₹10 Cashback',
                  'On every recharge using\nOneBharat Pay Wallet',
                  const Color(0xFF3D5AF1),
                  Icons.account_balance_wallet_rounded,
                ),
                _bannerCard(
                  'Special Offer',
                  'Get 28 days extra on\nselect plans',
                  const Color(0xFF00897B),
                  Icons.card_giftcard_rounded,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: i == _bannerIndex ? 16 : 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: i == _bannerIndex
                      ? const Color(0xFF6C63FF)
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Phone number
          const Text('Enter Mobile Number',
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04), blurRadius: 10)
              ],
            ),
            child: TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: 'Enter mobile number',
                hintStyle: const TextStyle(color: Colors.black38),
                prefixIcon: Container(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🇮🇳',
                          style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 6),
                      const Text('+91',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500)),
                      Container(
                          width: 1,
                          height: 20,
                          color: Colors.grey.shade300,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8)),
                    ],
                  ),
                ),
                suffixIcon: const Icon(Icons.contacts_rounded,
                    color: Color(0xFF6C63FF)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 16),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Select Operator
          const Text('Select Operator',
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: operators.map((op) {
                final isSelected = selectedOperator == op['name'];
                final color = op['color'] as Color;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(
                        () => selectedOperator = op['name'] as String);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withOpacity(0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? color
                            : Colors.grey.shade200,
                        width: isSelected ? 1.5 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 6)
                      ],
                    ),
                    child: Row(
                      children: [
                        if (isSelected)
                          Container(
                            width: 18,
                            height: 18,
                            margin: const EdgeInsets.only(right: 6),
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check_rounded,
                                color: Colors.white, size: 12),
                          ),
                        Icon(op['icon'] as IconData,
                            color: color, size: 20),
                        const SizedBox(width: 6),
                        Text(op['name'] as String,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? color
                                    : Colors.black54)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 20),

          // Recharge Type
          const Text('Recharge Type',
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: rechargeTypes.map((type) {
                final isSelected = selectedRechargeType == type;
                return GestureDetector(
                  onTap: () =>
                      setState(() => selectedRechargeType = type),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF6C63FF)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF6C63FF)
                            : Colors.grey.shade200,
                      ),
                    ),
                    child: Text(type,
                        style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Colors.black54,
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal)),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 20),

          // Select Amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Select Amount',
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
              GestureDetector(
                onTap: () {
                  if (selectedOperator != null) {
                    // go to plans
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Please select operator first')),
                    );
                  }
                },
                child: const Text('Browse Plans',
                    style: TextStyle(
                        color: Color(0xFF6C63FF),
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ...quickAmounts.map((amt) {
                final isSelected = selectedAmount == amt;
                return Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => selectedAmount = amt),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding:
                          const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF6C63FF)
                                .withOpacity(0.1)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF6C63FF)
                              : Colors.grey.shade200,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text('₹$amt',
                              style: TextStyle(
                                  color: isSelected
                                      ? const Color(0xFF6C63FF)
                                      : Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14)),
                          if (amt == 199) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6C63FF),
                                borderRadius:
                                    BorderRadius.circular(4),
                              ),
                              child: const Text('Popular',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 8)),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
              Expanded(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: Colors.grey.shade200),
                    ),
                    child: const Column(
                      children: [
                        Text('Other',
                            style: TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                        Text('Enter amount',
                            style: TextStyle(
                                color: Colors.black38,
                                fontSize: 9)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          if (selectedAmount != null) ...[
            const SizedBox(height: 16),

            // Plan detail card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEEEDFE),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: const Color(0xFF6C63FF).withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: Color(0xFF6C63FF), size: 18),
                      const SizedBox(width: 8),
                      Text('₹$selectedAmount Plan',
                          style: const TextStyle(
                              color: Color(0xFF6C63FF),
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceAround,
                    children: [
                      _planDetail(Icons.call_rounded,
                          'Unlimited', 'Calls'),
                      _planDetail(
                          Icons.signal_cellular_alt_rounded,
                          '2 GB/Day',
                          'Data'),
                      _planDetail(Icons.calendar_today_rounded,
                          '28 Days', 'Validity'),
                      _planDetail(Icons.celebration_rounded,
                          '1 Extra', 'Validity'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Cashback offer
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded,
                        color: Colors.green, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Best Offer Applied',
                            style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                        Text(
                            'Flat ₹10 cashback using OneBharat Pay Wallet',
                            style: TextStyle(
                                color: Colors.black45,
                                fontSize: 11)),
                      ],
                    ),
                  ),
                  const Text('- ₹10',
                      style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  const SizedBox(width: 6),
                  const Icon(Icons.check_circle_rounded,
                      color: Colors.green, size: 18),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Total payable + Proceed
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Payable',
                        style: TextStyle(
                            color: Colors.black54, fontSize: 12)),
                    Row(
                      children: [
                        Text('₹${selectedAmount! - 10}',
                            style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 24,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Text('₹$selectedAmount',
                            style: const TextStyle(
                                color: Colors.black38,
                                fontSize: 14,
                                decoration:
                                    TextDecoration.lineThrough)),
                        const SizedBox(width: 4),
                        const Icon(Icons.info_outline_rounded,
                            size: 14, color: Colors.black38),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      if (selectedOperator == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Please select operator first')),
                        );
                        return;
                      }
                      setState(() {
                        selectedPlan = {
                          'price': selectedAmount,
                          'data': '2 GB/day',
                          'validity': '28 days',
                          'calls': 'Unlimited',
                          'sms': '100/day',
                          'extra': '',
                        };
                        isPaid = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20),
                    ),
                    child: const Row(
                      children: [
                        Text('Proceed to Pay',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward_rounded,
                            color: Colors.white, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _bannerCard(
      String title, String subtitle, Color color, IconData icon) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 6))
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10, top: -10,
            child: Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(subtitle,
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _planDetail(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF6C63FF), size: 20),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Color(0xFF1A202C),
                fontSize: 12,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(
                color: Color(0xFF718096), fontSize: 10)),
      ],
    );
  }

  Widget _buildPlans() {
    final operatorPlans = plans[selectedOperator] ?? {};
    final currentPlans = operatorPlans[selectedTab] ?? [];
    final op =
        operators.firstWhere((o) => o['name'] == selectedOperator);
    final opColor = op['color'] as Color;

    return Column(
      children: [
        // Operator header
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              GestureDetector(
                onTap: () =>
                    setState(() => selectedOperator = null),
                child: const Icon(Icons.arrow_back_rounded,
                    color: Colors.black87),
              ),
              const SizedBox(width: 12),
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: opColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(op['icon'] as IconData,
                    color: opColor, size: 22),
              ),
              const SizedBox(width: 10),
              Text('$selectedOperator Prepaid',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
            ],
          ),
        ),

        // Search
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Search for a plan or enter amount',
                hintStyle:
                    TextStyle(color: Colors.black38, fontSize: 14),
                prefixIcon:
                    Icon(Icons.search_rounded, color: Colors.black38),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ),

        // Tabs
        Container(
          color: Colors.white,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: tabs.map((tab) {
                final isSelected = selectedTab == tab;
                return GestureDetector(
                  onTap: () => setState(() => selectedTab = tab),
                  child: Container(
                    margin: const EdgeInsets.only(right: 24),
                    padding:
                        const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isSelected
                              ? const Color(0xFF6C63FF)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(tab,
                        style: TextStyle(
                            color: isSelected
                                ? const Color(0xFF6C63FF)
                                : Colors.black54,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 14)),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        const Divider(height: 1, color: Color(0xFFE0E0E0)),

        // Plans list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: currentPlans.length,
            itemBuilder: (context, index) {
              final plan = currentPlans[index];
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _showPlanConfirm(plan);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8)
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('₹${plan['price']}',
                                    style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87)),
                                const SizedBox(width: 8),
                                if (plan['extra'] != '')
                                  Container(
                                    padding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2),
                                    decoration: BoxDecoration(
                                      color:
                                          const Color(0xFFEEEDFE),
                                      borderRadius:
                                          BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                        plan['extra'] as String,
                                        style: const TextStyle(
                                            color:
                                                Color(0xFF6C63FF),
                                            fontSize: 10,
                                            fontWeight:
                                                FontWeight.w500)),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                if (plan['data'] != 'NA') ...[
                                  _planTag(
                                      Icons
                                          .signal_cellular_alt_rounded,
                                      plan['data'] as String,
                                      Colors.blue),
                                  const SizedBox(width: 8),
                                ],
                                _planTag(
                                    Icons.calendar_today_rounded,
                                    plan['validity'] as String,
                                    Colors.green),
                                const SizedBox(width: 8),
                                if (plan['calls'] != 'NA')
                                  _planTag(
                                      Icons.call_rounded,
                                      plan['calls'] as String,
                                      Colors.orange),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6C63FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 18),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _planTag(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(text,
            style: const TextStyle(fontSize: 11, color: Colors.black54)),
      ],
    );
  }

  void _showPlanConfirm(Map<String, dynamic> plan) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Confirm Recharge',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _confirmRow('Operator', selectedOperator ?? ''),
            _confirmRow(
                'Mobile',
                phoneController.text.isEmpty
                    ? 'XXXXXXXXXX'
                    : phoneController.text),
            _confirmRow('Plan', '₹${plan['price']}'),
            _confirmRow('Data', plan['data'] as String),
            _confirmRow('Validity', plan['validity'] as String),
            _confirmRow('Calls', plan['calls'] as String),
            if (plan['extra'] != '')
              _confirmRow('Extra', plan['extra'] as String),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    selectedPlan = plan;
                    isPaid = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: Text('Pay ₹${plan['price']}',
                    style: const TextStyle(
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

  Widget _confirmRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.black45, fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
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
                  color: Color(0xFF00C853), shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded,
                  size: 54, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text('₹${selectedPlan!['price']}',
                style: const TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            const SizedBox(height: 8),
            Text('Recharge successful — $selectedOperator',
                style: const TextStyle(
                    fontSize: 16, color: Colors.black54)),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _confirmRow(
                      'Mobile',
                      phoneController.text.isEmpty
                          ? 'XXXXXXXXXX'
                          : phoneController.text),
                  _confirmRow('Operator', selectedOperator ?? ''),
                  _confirmRow(
                      'Data', selectedPlan!['data'] as String),
                  _confirmRow(
                      'Validity', selectedPlan!['validity'] as String),
                  _confirmRow(
                      'Calls', selectedPlan!['calls'] as String),
                  _confirmRow('Status', '✅ Success'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => setState(() {
                  isPaid = false;
                  selectedPlan = null;
                  selectedOperator = null;
                  selectedAmount = null;
                }),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
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
}

// ─────────────────────────────────────────
// OTHER BILLS FORM
// ─────────────────────────────────────────
class _BillForm extends StatefulWidget {
  final String category;
  final String userId;
  final VoidCallback onBack;

  const _BillForm(
      {required this.category,
      required this.userId,
      required this.onBack});

  @override
  State<_BillForm> createState() => _BillFormState();
}

class _BillFormState extends State<_BillForm> {
  final numberController = TextEditingController();
  final amountController = TextEditingController();
  String? selectedOperator;
  bool isLoading = false;
  bool isPaid = false;

  final Map<String, List<Map<String, dynamic>>> operators = {
    'Electricity': [
      {'name': 'MSEDCL', 'color': const Color(0xFFFF9800)},
      {'name': 'BSES', 'color': const Color(0xFF2196F3)},
      {'name': 'TATA Power', 'color': const Color(0xFF003087)},
      {'name': 'Adani', 'color': const Color(0xFF00A3E0)},
    ],
    'DTH / Cable': [
      {'name': 'Tata Play', 'color': const Color(0xFF003087)},
      {'name': 'Dish TV', 'color': const Color(0xFFE31837)},
      {'name': 'Sun Direct', 'color': const Color(0xFFFF6B00)},
      {'name': 'Airtel DTH', 'color': const Color(0xFFE40000)},
    ],
    'Broadband': [
      {'name': 'Jio Fiber', 'color': const Color(0xFF0070C0)},
      {'name': 'Airtel Xstream', 'color': const Color(0xFFE40000)},
      {'name': 'BSNL', 'color': const Color(0xFF009933)},
      {'name': 'ACT Fibernet', 'color': const Color(0xFF6B2D8B)},
    ],
  };

  final Map<String, List<int>> quickAmounts = {
    'Electricity': [500, 1000, 2000, 5000],
    'Water': [200, 500, 1000, 2000],
    'DTH / Cable': [149, 249, 349, 499],
    'Gas': [500, 800, 1000, 1500],
    'Broadband': [699, 999, 1299, 1499],
    'Insurance': [1000, 2500, 5000, 10000],
    'Loan EMI': [1000, 5000, 10000, 25000],
    'Education': [500, 1000, 5000, 10000],
    'FASTag': [100, 200, 500, 1000],
    'Municipality': [500, 1000, 2000, 5000],
    'Credit Card': [1000, 5000, 10000, 25000],
  };

  Future<void> payBill() async {
    if (numberController.text.isEmpty ||
        amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }
    setState(() => isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      isLoading = false;
      isPaid = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ops = operators[widget.category] ?? [];
    final amounts =
        quickAmounts[widget.category] ?? [100, 500, 1000, 2000];

    return isPaid
        ? _buildSuccess()
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (ops.isNotEmpty) ...[
                  const Text('Select Provider',
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                          fontSize: 12)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ops.map((op) {
                      final isSelected =
                          selectedOperator == op['name'];
                      return GestureDetector(
                        onTap: () => setState(() =>
                            selectedOperator =
                                op['name'] as String),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (op['color'] as Color)
                                    .withOpacity(0.1)
                                : Colors.white,
                            borderRadius:
                                BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? op['color'] as Color
                                  : Colors.grey.shade200,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Text(op['name'] as String,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? op['color'] as Color
                                      : Colors.black54)),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                ],
                const Text('Account / Consumer Number',
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                        fontSize: 12)),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10)
                    ],
                  ),
                  child: TextField(
                    controller: numberController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Enter account/consumer number',
                      hintStyle: TextStyle(
                          color: Colors.black38, fontSize: 14),
                      prefixIcon: Icon(Icons.numbers_rounded,
                          color: Colors.black38),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Amount (₹)',
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                        fontSize: 12)),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10)
                    ],
                  ),
                  child: TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: '0',
                      hintStyle: TextStyle(
                          color: Colors.black38,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                      prefixIcon: Icon(
                          Icons.currency_rupee_rounded,
                          color: Colors.black38),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: amounts.map((amt) {
                    final isSelected =
                        amountController.text == amt.toString();
                    return GestureDetector(
                      onTap: () => setState(
                          () => amountController.text =
                              amt.toString()),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF6C63FF)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF6C63FF)
                                  : Colors.grey.shade200),
                        ),
                        child: Text('₹$amt',
                            style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF6C63FF),
                                fontSize: 13,
                                fontWeight: FontWeight.w500)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : payBill,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white)
                        : Text(
                            amountController.text.isEmpty
                                ? 'Pay Bill'
                                : 'Pay ₹${amountController.text}',
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
                    Icon(Icons.lock_rounded,
                        size: 14, color: Colors.black38),
                    SizedBox(width: 4),
                    Text('100% Secure Payment',
                        style: TextStyle(
                            color: Colors.black38, fontSize: 12)),
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
              decoration: const BoxDecoration(
                  color: Color(0xFF00C853), shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded,
                  size: 54, color: Colors.white),
            ),
            const SizedBox(height: 24),
            const Text('Payment Successful!',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            const SizedBox(height: 8),
            Text(
                '₹${amountController.text} paid for ${widget.category}',
                style: const TextStyle(
                    color: Colors.black45, fontSize: 15)),
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
                  _receiptRow('Bill Type', widget.category),
                  _receiptRow(
                      'Amount', '₹${amountController.text}'),
                  _receiptRow('Account', numberController.text),
                  _receiptRow('Status', '✅ Success'),
                  _receiptRow(
                      'Date',
                      DateTime.now()
                          .toString()
                          .substring(0, 10)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: widget.onBack,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text('Done',
                    style: TextStyle(
                        fontSize: 18,
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
              style: const TextStyle(
                  color: Colors.black45, fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;

  const _OfferCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient:
            LinearGradient(colors: [color, color.withOpacity(0.7)]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const Spacer(),
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
          Text(subtitle,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }
}