import 'package:flutter/material.dart';
import 'api_service.dart';

class RewardsScreen extends StatefulWidget {
  final String userId;

  const RewardsScreen({super.key, required this.userId});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  static const Color purple = Color(0xFF6C63FF);
  static const Color bgPage = Color(0xFFF2F4F7);

  Map<String, dynamic>? rewardsData;
  List<dynamic> offers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final rewards = await ApiService.getRewards(widget.userId);
      final offersData = await ApiService.getOffers();
      setState(() {
        rewardsData = rewards;
        offers = offersData['offers'] ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  int get points => rewardsData?['points'] ?? 0;
  double get cashValue => rewardsData?['cash_value'] ?? 0.0;

  final List<Map<String, dynamic>> cashbackCards = const [
    {'title': '₹50 Cashback', 'points': 500, 'color': Color(0xFF6C63FF), 'icon': Icons.local_offer_rounded},
    {'title': '₹100 Cashback', 'points': 900, 'color': Color(0xFF00B5D8), 'icon': Icons.card_giftcard_rounded},
    {'title': '₹150 Cashback', 'points': 1300, 'color': Color(0xFF48BB78), 'icon': Icons.monetization_on_rounded},
    {'title': '₹200 Cashback', 'points': 1800, 'color': Color(0xFFED8936), 'icon': Icons.redeem_rounded},
    {'title': '₹500 Cashback', 'points': 4000, 'color': Color(0xFFE91E63), 'icon': Icons.stars_rounded},
  ];

  IconData _getOfferIcon(String? category) {
    switch (category) {
      case 'electricity': return Icons.electric_bolt_rounded;
      case 'recharge': return Icons.phone_android_rounded;
      case 'dth': return Icons.tv_rounded;
      case 'bills': return Icons.receipt_rounded;
      case 'transfer': return Icons.send_rounded;
      case 'upi': return Icons.account_balance_wallet_rounded;
      default: return Icons.local_offer_rounded;
    }
  }

  Color _getOfferColor(String? category) {
    switch (category) {
      case 'electricity': return const Color(0xFFFF9800);
      case 'recharge': return const Color(0xFF6C63FF);
      case 'dth': return const Color(0xFFE91E63);
      case 'bills': return const Color(0xFF48BB78);
      case 'transfer': return const Color(0xFF00B5D8);
      case 'upi': return const Color(0xFF9C27B0);
      default: return purple;
    }
  }

  Color _getOfferBg(String? category) {
    switch (category) {
      case 'electricity': return const Color(0xFFFFF3E0);
      case 'recharge': return const Color(0xFFEEEDFE);
      case 'dth': return const Color(0xFFFCE4EC);
      case 'bills': return const Color(0xFFE8F5E9);
      case 'transfer': return const Color(0xFFE0F7FA);
      case 'upi': return const Color(0xFFF3E5F5);
      default: return const Color(0xFFEEEDFE);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgPage,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Rewards',
            style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF6C63FF)),
            onPressed: loadData,
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
                  // Points Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF1A56DB), Color(0xFF6C63FF)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: purple.withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Available Points',
                            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              width: 36, height: 36,
                              decoration: const BoxDecoration(color: Color(0xFFFFD700), shape: BoxShape.circle),
                              child: const Icon(Icons.star_rounded, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Text('$points',
                                style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => _showRedeem(),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text('Redeem',
                                    style: TextStyle(color: purple, fontWeight: FontWeight.bold, fontSize: 14)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _pointsStat('₹${cashValue.toStringAsFixed(2)}', 'Cash Value'),
                            const SizedBox(width: 24),
                            _pointsStat('${rewardsData?['total_earned'] ?? 0}', 'Total Earned'),
                            const SizedBox(width: 24),
                            _pointsStat('${rewardsData?['total_redeemed'] ?? 0}', 'Redeemed'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Claim Rewards
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Claim Your Rewards!',
                          style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('View All', style: TextStyle(color: purple, fontSize: 13, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    height: 140,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: cashbackCards.length,
                      itemBuilder: (context, index) {
                        final card = cashbackCards[index];
                        final color = card['color'] as Color;
                        final requiredPoints = card['points'] as int;
                        final canRedeem = points >= requiredPoints;
                        return GestureDetector(
                          onTap: () => _showRedeemCard(card),
                          child: Container(
                            width: 130,
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: canRedeem
                                    ? [color, color.withOpacity(0.7)]
                                    : [Colors.grey.shade400, Colors.grey.shade300],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: (canRedeem ? color : Colors.grey).withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(card['icon'] as IconData, color: Colors.white70, size: 24),
                                const Spacer(),
                                Text(card['title'] as String,
                                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 13),
                                    const SizedBox(width: 3),
                                    Text('$requiredPoints pts',
                                        style: const TextStyle(color: Colors.white70, fontSize: 11)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Offers from API
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Exclusive Offers',
                          style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('View All >',
                          style: TextStyle(color: purple, fontSize: 13, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Featured offer
                  if (offers.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEEDFE),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: purple.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(offers[0]['title'] ?? '',
                                    style: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(offers[0]['subtitle'] ?? '',
                                    style: const TextStyle(color: Colors.black54, fontSize: 13)),
                                const SizedBox(height: 8),
                                if (offers[0]['code'] != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text('Use Code: ${offers[0]['code']}',
                                        style: const TextStyle(color: purple, fontSize: 12, fontWeight: FontWeight.w600)),
                                  ),
                                const SizedBox(height: 12),
                                GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: purple,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text('Pay Now →',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 70, height: 70,
                            decoration: BoxDecoration(
                              color: purple.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(_getOfferIcon(offers[0]['category']),
                                color: purple, size: 36),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 12),

                  // Remaining offers
                  ...offers.skip(1).map((offer) {
                    final color = _getOfferColor(offer['category']);
                    final bg = _getOfferBg(offer['category']);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
                            child: Icon(_getOfferIcon(offer['category']), color: color, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(offer['title'] ?? '',
                                    style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 14)),
                                Text(offer['subtitle'] ?? '',
                                    style: const TextStyle(color: Colors.black45, fontSize: 12)),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: purple,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('Claim',
                                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _pointsStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        Text(label,
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10)),
      ],
    );
  }

  void _showRedeem() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Redeem Points',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('$points points = ₹${cashValue.toStringAsFixed(2)} cashback',
                style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    await ApiService.redeemPoints(
                      userId: widget.userId,
                      points: points,
                    );
                    await loadData();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('₹${cashValue.toStringAsFixed(2)} cashback added!'),
                          backgroundColor: const Color(0xFF48BB78),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: purple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Redeem Now',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRedeemCard(Map<String, dynamic> card) {
    final requiredPoints = card['points'] as int;
    final canRedeem = points >= requiredPoints;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(card['icon'] as IconData, color: card['color'] as Color, size: 40),
            const SizedBox(height: 12),
            Text(card['title'] as String,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Required: $requiredPoints points',
                style: const TextStyle(color: Colors.black54)),
            Text('Your Points: $points',
                style: TextStyle(
                    color: canRedeem ? const Color(0xFF48BB78) : Colors.red,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: canRedeem
                    ? () async {
                        Navigator.pop(context);
                        try {
                          await ApiService.redeemPoints(
                            userId: widget.userId,
                            points: requiredPoints,
                          );
                          await loadData();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${card['title']} redeemed!'),
                                backgroundColor: const Color(0xFF48BB78),
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: purple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(canRedeem ? 'Redeem' : 'Insufficient Points',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}