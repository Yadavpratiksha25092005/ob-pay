import 'package:flutter/material.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  void _showSnackBar(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label coming soon'),
        backgroundColor: const Color(0xFF2563EB),
      ),
    );
  }

  Widget _buildTile(BuildContext context, IconData icon, String label, Color color) {
    return GestureDetector(
      onTap: () => _showSnackBar(context, label),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _section(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                blurRadius: 12,
                color: Colors.black.withValues(alpha: 0.04),
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: content,
        ),
      ],
    );
  }

  Widget _moneyTransferRow(BuildContext context) {
    final items = [
      (Icons.account_balance_rounded, 'To Bank', const Color(0xFF2563EB)),
      (Icons.qr_code_rounded, 'To UPI ID', const Color(0xFF7C3AED)),
      (Icons.swap_horiz_rounded, 'Self Transfer', const Color(0xFF0891B2)),
      (Icons.account_balance_wallet_rounded, 'Check Balance', const Color(0xFF059669)),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: items
          .map((item) => _buildTile(context, item.$1, item.$2, item.$3))
          .toList(),
    );
  }

  Widget _billsGrid(BuildContext context) {
    final items = [
      (Icons.phone_android_rounded, 'Mobile', const Color(0xFF2563EB)),
      (Icons.tv_rounded, 'DTH', const Color(0xFF7C3AED)),
      (Icons.electric_bolt_rounded, 'Electricity', const Color(0xFFD97706)),
      (Icons.local_fire_department_rounded, 'Gas', const Color(0xFFDC2626)),
      (Icons.water_drop_rounded, 'Water', const Color(0xFF0891B2)),
      (Icons.wifi_rounded, 'Broadband', const Color(0xFF059669)),
      (Icons.directions_car_rounded, 'FASTag', const Color(0xFF0369A1)),
      (Icons.more_horiz_rounded, 'More', const Color(0xFF6B7280)),
    ];

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 0.85,
      children: items
          .map((item) => _buildTile(context, item.$1, item.$2, item.$3))
          .toList(),
    );
  }

  Widget _financialRow(BuildContext context) {
    final items = [
      (Icons.security_rounded, 'Insurance', const Color(0xFF7C3AED)),
      (Icons.account_balance_rounded, 'Loan', const Color(0xFF2563EB)),
      (Icons.star_rounded, 'Gold', const Color(0xFFD97706)),
      (Icons.credit_score_rounded, 'Credit Score', const Color(0xFF059669)),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: items
          .map((item) => _buildTile(context, item.$1, item.$2, item.$3))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF111827)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Services',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Color(0xFF111827)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Coming soon'),
                  backgroundColor: Color(0xFF2563EB),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _section('Money Transfer', _moneyTransferRow(context)),
            const SizedBox(height: 20),
            _section('Recharges & Bills', _billsGrid(context)),
            const SizedBox(height: 20),
            _section('Financial Services', _financialRow(context)),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
