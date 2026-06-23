import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final String userId;

  const SettingsScreen({super.key, required this.userId});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const Color bgPage = Color(0xFFF2F4F7);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color purple = Color(0xFF6C63FF);
  static const Color textDark = Color(0xFF1A202C);
  static const Color textLight = Color(0xFF718096);

  bool paymentAlerts = true;
  bool billReminders = true;
  bool biometricLogin = true;
  bool appLock = false;
  bool promotionalAlerts = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgPage,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
              _navTile(icon: Icons.person_rounded, color: purple, bg: const Color(0xFFEEEDFE), title: 'Edit Profile', subtitle: 'Update your personal info', onTap: _showEditProfile),
              _divider(),
              _navTile(icon: Icons.lock_rounded, color: const Color(0xFFED8936), bg: const Color(0xFFFFF3E0), title: 'Change PIN', subtitle: 'Update your security PIN', onTap: _showChangePIN),
              _divider(),
              _navTile(icon: Icons.account_balance_rounded, color: const Color(0xFF48BB78), bg: const Color(0xFFE8F5E9), title: 'Linked Bank Accounts', subtitle: 'Manage your bank accounts', onTap: _showBankAccounts),
              _divider(),
              _navTile(icon: Icons.credit_card_rounded, color: const Color(0xFF00B5D8), bg: const Color(0xFFE0F7FA), title: 'Saved Cards', subtitle: 'Manage debit/credit cards', onTap: () {}),
            ]),
            const SizedBox(height: 16),
            _sectionTitle('Notifications'),
            _settingsCard([
              _switchTile(icon: Icons.payment_rounded, color: purple, bg: const Color(0xFFEEEDFE), title: 'Payment Alerts', subtitle: 'Get notified for payments', value: paymentAlerts, onChanged: (val) => setState(() => paymentAlerts = val)),
              _divider(),
              _switchTile(icon: Icons.receipt_rounded, color: const Color(0xFFED8936), bg: const Color(0xFFFFF3E0), title: 'Bill Reminders', subtitle: 'Reminders for due bills', value: billReminders, onChanged: (val) => setState(() => billReminders = val)),
              _divider(),
              _switchTile(icon: Icons.local_offer_rounded, color: const Color(0xFF48BB78), bg: const Color(0xFFE8F5E9), title: 'Promotional Alerts', subtitle: 'Offers and rewards', value: promotionalAlerts, onChanged: (val) => setState(() => promotionalAlerts = val)),
            ]),
            const SizedBox(height: 16),
            _sectionTitle('Security'),
            _settingsCard([
              _switchTile(icon: Icons.fingerprint_rounded, color: const Color(0xFF9F7AEA), bg: const Color(0xFFF3E5F5), title: 'Biometric Login', subtitle: 'Use fingerprint to login', value: biometricLogin, onChanged: (val) => setState(() => biometricLogin = val)),
              _divider(),
              _switchTile(icon: Icons.screen_lock_portrait_rounded, color: const Color(0xFFFC8181), bg: const Color(0xFFFCEBEB), title: 'App Lock', subtitle: 'Lock app when minimized', value: appLock, onChanged: (val) => setState(() => appLock = val)),
            ]),
            const SizedBox(height: 16),
            _sectionTitle('Payment'),
            _settingsCard([
              _navTile(icon: Icons.alternate_email_rounded, color: purple, bg: const Color(0xFFEEEDFE), title: 'UPI ID', subtitle: 'Manage your UPI address', onTap: _showUPIId),
              _divider(),
              _navTile(icon: Icons.autorenew_rounded, color: const Color(0xFF00B5D8), bg: const Color(0xFFE0F7FA), title: 'Auto Pay', subtitle: 'Set up automatic payments', onTap: _showAutoPay),
            ]),
            const SizedBox(height: 16),
            _sectionTitle('General'),
            _settingsCard([
              _navTile(icon: Icons.language_rounded, color: const Color(0xFFED8936), bg: const Color(0xFFFFF3E0), title: 'Language', subtitle: 'English', onTap: _showLanguage),
              _divider(),
              _navTile(icon: Icons.privacy_tip_rounded, color: const Color(0xFF48BB78), bg: const Color(0xFFE8F5E9), title: 'Privacy Policy', subtitle: 'Read our privacy policy', onTap: () {}),
              _divider(),
              _navTile(icon: Icons.description_rounded, color: const Color(0xFF9F7AEA), bg: const Color(0xFFF3E5F5), title: 'Terms of Service', subtitle: 'Read terms and conditions', onTap: () {}),
              _divider(),
              _navTile(icon: Icons.info_rounded, color: const Color(0xFF00B5D8), bg: const Color(0xFFE0F7FA), title: 'App Version', subtitle: 'OB Pay v1.0.0', onTap: () {}),
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

  void _showEditProfile() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Edit Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _editField('Full Name', nameController, Icons.person_rounded),
            const SizedBox(height: 12),
            _editField('Email', emailController, Icons.email_rounded, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 12),
            _editField('Phone', phoneController, Icons.phone_rounded, keyboardType: TextInputType.phone),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated!'), backgroundColor: Color(0xFF48BB78)));
                },
                style: ElevatedButton.styleFrom(backgroundColor: purple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
                child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePIN() {
    final currentPinController = TextEditingController();
    final newPinController = TextEditingController();
    final confirmPinController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Change PIN', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _editField('Current PIN', currentPinController, Icons.lock_rounded, obscure: true, keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            _editField('New PIN', newPinController, Icons.lock_open_rounded, obscure: true, keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            _editField('Confirm PIN', confirmPinController, Icons.lock_outline_rounded, obscure: true, keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN changed successfully!'), backgroundColor: Color(0xFF48BB78)));
                },
                style: ElevatedButton.styleFrom(backgroundColor: purple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
                child: const Text('Change PIN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBankAccounts() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Linked Bank Accounts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _bankTile('HDFC Bank', '•••• 1234', 'Primary'),
            _bankTile('SBI', '•••• 5678', ''),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add_rounded, color: Color(0xFF6C63FF)),
              label: const Text('Add Bank Account', style: TextStyle(color: Color(0xFF6C63FF))),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                side: const BorderSide(color: Color(0xFF6C63FF)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bankTile(String bank, String account, String tag) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFFEEEDFE), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.account_balance_rounded, color: Color(0xFF6C63FF), size: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(bank, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
              Text(account, style: const TextStyle(color: Colors.black45, fontSize: 12)),
            ]),
          ),
          if (tag.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(8)),
              child: Text(tag, style: const TextStyle(color: Color(0xFF48BB78), fontSize: 10, fontWeight: FontWeight.w500)),
            ),
        ],
      ),
    );
  }

  void _showUPIId() {
    final upiController = TextEditingController(text: 'user@obpay');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('UPI ID', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('Your UPI ID is used to receive payments', style: TextStyle(color: Colors.black45, fontSize: 13)),
            const SizedBox(height: 20),
            TextField(
              controller: upiController,
              decoration: InputDecoration(
                labelText: 'UPI ID',
                prefixIcon: const Icon(Icons.alternate_email_rounded, color: Color(0xFF6C63FF)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.copy_rounded, color: Colors.black45),
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('UPI ID copied!'))),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('UPI ID updated!'), backgroundColor: Color(0xFF48BB78)));
                },
                style: ElevatedButton.styleFrom(backgroundColor: purple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
                child: const Text('Save UPI ID', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAutoPay() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Auto Pay', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('Automatically pay your bills on due date', style: TextStyle(color: Colors.black45, fontSize: 13)),
            const SizedBox(height: 16),
            _autoPayTile('Jio Recharge', '₹299 • 28th every month', true),
            _autoPayTile('Electricity Bill', '₹1,000 • 5th every month', false),
            _autoPayTile('Broadband', '₹999 • 1st every month', true),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add_rounded, color: Color(0xFF6C63FF)),
              label: const Text('Add Auto Pay', style: TextStyle(color: Color(0xFF6C63FF))),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                side: const BorderSide(color: Color(0xFF6C63FF)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _autoPayTile(String name, String detail, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
              Text(detail, style: const TextStyle(color: Colors.black45, fontSize: 12)),
            ]),
          ),
          Switch(value: isActive, onChanged: (_) {}, activeColor: purple),
        ],
      ),
    );
  }

  void _showLanguage() {
    final languages = ['English', 'Hindi', 'Marathi', 'Tamil', 'Telugu', 'Bengali', 'Gujarati'];
    String selected = 'English';
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Language', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ...languages.map((lang) => GestureDetector(
                onTap: () => setModal(() => selected = lang),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: selected == lang ? const Color(0xFFEEEDFE) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: selected == lang ? purple : Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: Text(lang, style: TextStyle(color: selected == lang ? purple : Colors.black87, fontWeight: selected == lang ? FontWeight.w600 : FontWeight.normal))),
                      if (selected == lang) const Icon(Icons.check_rounded, color: Color(0xFF6C63FF), size: 18),
                    ],
                  ),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _editField(String label, TextEditingController controller, IconData icon, {bool obscure = false, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: purple),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2)),
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
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(color: textDark, fontSize: 14, fontWeight: FontWeight.w500)),
                Text(subtitle, style: const TextStyle(color: textLight, fontSize: 12)),
              ]),
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
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(color: textDark, fontSize: 14, fontWeight: FontWeight.w500)),
              Text(subtitle, style: const TextStyle(color: textLight, fontSize: 12)),
            ]),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: purple),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(height: 1, indent: 66, color: Colors.grey.withOpacity(0.1));
  }
}