import 'package:flutter/material.dart';

class MerchantSettingsScreen extends StatefulWidget {
  final String userId;

  const MerchantSettingsScreen({super.key, required this.userId});

  @override
  State<MerchantSettingsScreen> createState() =>
      _MerchantSettingsScreenState();
}

class _MerchantSettingsScreenState extends State<MerchantSettingsScreen> {
  static const Color bgPage = Color(0xFFF5F5F5);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color blue = Color(0xFF3D5AF1);
  static const Color textDark = Color(0xFF1A202C);
  static const Color textLight = Color(0xFF718096);

  bool notificationsEnabled = true;
  bool biometricEnabled = true;
  bool autoSettlement = true;
  bool transactionAlerts = true;
  bool settlementAlerts = true;

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
        title: const Text('Settings',
            style: TextStyle(color: Color(0xFF1A202C), fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Account'),
            _settingsCard([
              _navTile(icon: Icons.person_rounded, color: const Color(0xFF6C63FF), bg: const Color(0xFFEEEDFE), title: 'Business Profile', subtitle: 'Edit your business information', onTap: () {}),
              _divider(),
              _navTile(icon: Icons.account_balance_rounded, color: const Color(0xFF3D5AF1), bg: const Color(0xFFEEEDFE), title: 'Bank Account', subtitle: 'Manage bank accounts', onTap: () {}),
              _divider(),
              _navTile(icon: Icons.verified_user_rounded, color: const Color(0xFF48BB78), bg: const Color(0xFFE8F5E9), title: 'KYC Verification', subtitle: 'Business verification status', onTap: () {}),
              _divider(),
              _navTile(icon: Icons.lock_rounded, color: const Color(0xFFED8936), bg: const Color(0xFFFFF3E0), title: 'Change PIN', subtitle: 'Update your security PIN', onTap: () {}),
            ]),
            const SizedBox(height: 16),
            _sectionTitle('Notifications'),
            _settingsCard([
              _switchTile(icon: Icons.notifications_rounded, color: const Color(0xFF6C63FF), bg: const Color(0xFFEEEDFE), title: 'Push Notifications', subtitle: 'Enable all notifications', value: notificationsEnabled, onChanged: (val) => setState(() => notificationsEnabled = val)),
              _divider(),
              _switchTile(icon: Icons.payment_rounded, color: const Color(0xFF48BB78), bg: const Color(0xFFE8F5E9), title: 'Transaction Alerts', subtitle: 'Get notified for payments', value: transactionAlerts, onChanged: (val) => setState(() => transactionAlerts = val)),
              _divider(),
              _switchTile(icon: Icons.account_balance_rounded, color: const Color(0xFF3D5AF1), bg: const Color(0xFFEEEDFE), title: 'Settlement Alerts', subtitle: 'Get notified for settlements', value: settlementAlerts, onChanged: (val) => setState(() => settlementAlerts = val)),
            ]),
            const SizedBox(height: 16),
            _sectionTitle('Security'),
            _settingsCard([
              _switchTile(icon: Icons.fingerprint_rounded, color: const Color(0xFF9F7AEA), bg: const Color(0xFFF3E5F5), title: 'Biometric Login', subtitle: 'Use fingerprint or face ID', value: biometricEnabled, onChanged: (val) => setState(() => biometricEnabled = val)),
              _divider(),
              _switchTile(icon: Icons.account_balance_wallet_rounded, color: const Color(0xFF48BB78), bg: const Color(0xFFE8F5E9), title: 'Auto Settlement', subtitle: 'Auto settle daily at midnight', value: autoSettlement, onChanged: (val) => setState(() => autoSettlement = val)),
            ]),
            const SizedBox(height: 16),
            _sectionTitle('Appearance'),
            _settingsCard([
              _navTile(icon: Icons.language_rounded, color: const Color(0xFF00B5D8), bg: const Color(0xFFE0F7FA), title: 'Language', subtitle: 'English', onTap: () {}),
            ]),
            const SizedBox(height: 16),
            _sectionTitle('About'),
            _settingsCard([
              _navTile(icon: Icons.info_rounded, color: const Color(0xFF3D5AF1), bg: const Color(0xFFEEEDFE), title: 'App Version', subtitle: 'OB Pay Business v1.0.0', onTap: () {}),
              _divider(),
              _navTile(icon: Icons.privacy_tip_rounded, color: const Color(0xFF48BB78), bg: const Color(0xFFE8F5E9), title: 'Privacy Policy', subtitle: 'Read our privacy policy', onTap: () {}),
              _divider(),
              _navTile(icon: Icons.description_rounded, color: const Color(0xFFED8936), bg: const Color(0xFFFFF3E0), title: 'Terms of Service', subtitle: 'Read terms and conditions', onTap: () {}),
            ]),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false),
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
                label: const Text('Logout', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title, style: const TextStyle(color: textDark, fontSize: 15, fontWeight: FontWeight.bold)),
    );
  }

  Widget _settingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(children: children),
    );
  }

  Widget _navTile({required IconData icon, required Color color, required Color bg, required String title, required String subtitle, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: textDark, fontSize: 14, fontWeight: FontWeight.w500)),
                  Text(subtitle, style: const TextStyle(color: textLight, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.shade300, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _switchTile({required IconData icon, required Color color, required Color bg, required String title, required String subtitle, required bool value, required ValueChanged<bool> onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: textDark, fontSize: 14, fontWeight: FontWeight.w500)),
                Text(subtitle, style: const TextStyle(color: textLight, fontSize: 12)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: blue),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(height: 1, indent: 66, color: Colors.grey.withOpacity(0.1));
  }
}