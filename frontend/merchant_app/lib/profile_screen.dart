import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'auth_screen.dart';
import 'api_service.dart';

class MerchantProfileScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String phone;

  const MerchantProfileScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.phone,
  });

  @override
  State<MerchantProfileScreen> createState() => _MerchantProfileScreenState();
}

class _MerchantProfileScreenState extends State<MerchantProfileScreen> {
  static const Color bgPage = Color(0xFFF5F5F5);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color blue = Color(0xFF3D5AF1);
  static const Color textDark = Color(0xFF1A202C);
  static const Color textLight = Color(0xFF718096);

  String _email = 'merchant@obpay.com';
  String _phone = '';
  String _kycStatus = 'pending';
  bool _notifPush = true;
  bool _notifSettlement = true;
  bool _notifPayment = true;

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadKycStatus();
  }

  Future<void> _loadUserProfile() async {
    final data = await ApiService.getUser(widget.userId);
    if (data.isNotEmpty && mounted) {
      setState(() {
        _email = (data['email'] as String? ?? _email);
        _phone = (data['phone'] as String? ?? widget.phone);
      });
    }
  }

  Future<void> _loadKycStatus() async {
    final status = await ApiService.getKycStatus(widget.userId);
    if (mounted) setState(() => _kycStatus = status);
  }

  Widget _kycBadge() {
    Color bgColor;
    Color textColor;
    String label;
    IconData icon;

    switch (_kycStatus) {
      case 'approved':
      case 'verified':
        bgColor = Colors.green.withValues(alpha: 0.1);
        textColor = Colors.green;
        label = 'Verified';
        icon = Icons.verified_rounded;
        break;
      case 'rejected':
        bgColor = Colors.red.withValues(alpha: 0.1);
        textColor = Colors.red;
        label = 'Rejected';
        icon = Icons.cancel_rounded;
        break;
      default:
        bgColor = Colors.orange.withValues(alpha: 0.1);
        textColor = Colors.orange;
        label = 'Pending';
        icon = Icons.hourglass_empty_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: 12),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: textColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

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
        title: const Text('Profile',
            style: TextStyle(
                color: Color(0xFF1A202C),
                fontSize: 18,
                fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2D3748), Color(0xFF4A5568)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 60, height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.4), width: 2),
                        ),
                        child: _profileImage != null
                            ? ClipOval(
                                child: Image.file(
                                  _profileImage!,
                                  width: 60, height: 60,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Center(
                                child: Text(
                                  widget.userName.isNotEmpty
                                      ? widget.userName[0].toUpperCase()
                                      : 'M',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                      ),
                      Positioned(
                        bottom: 0, right: 0,
                        child: GestureDetector(
                          onTap: _showPhotoOptions,
                          child: Container(
                            width: 22, height: 22,
                            decoration: BoxDecoration(
                              color: blue,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                            child: const Icon(Icons.camera_alt_rounded,
                                color: Colors.white, size: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(widget.userName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(_email,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
                  const SizedBox(height: 2),
                  Text('+91 ${_phone.isNotEmpty ? _phone : widget.phone}',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_rounded,
                            color: Colors.greenAccent, size: 12),
                        SizedBox(width: 4),
                        Text('Verified Merchant',
                            style: TextStyle(
                                color: Colors.greenAccent,
                                fontSize: 11,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Account Overview
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bgCard,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _overviewStat('₹68,750', 'Revenue', Icons.trending_up_rounded),
                  _vDivider(),
                  _overviewStat('128', 'Transactions', Icons.receipt_long_rounded),
                  _vDivider(),
                  _overviewStat('4.8★', 'Rating', Icons.star_rounded),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _sectionTitle('Business Information'),
            _settingsCard([
              _navTile(
                icon: Icons.store_rounded,
                color: blue,
                bg: const Color(0xFFEEEDFE),
                title: 'Profile & Business Information',
                subtitle: 'Update your business details',
                onTap: _showEditProfile,
              ),
              _divider(),
              _navTile(
                icon: Icons.account_balance_rounded,
                color: const Color(0xFF48BB78),
                bg: const Color(0xFFE8F5E9),
                title: 'Bank Accounts & UPI',
                subtitle: 'Manage your linked accounts',
                onTap: _showBankUPI,
              ),
              _divider(),
              _navTile(
                icon: Icons.security_rounded,
                color: const Color(0xFF3D5AF1),
                bg: const Color(0xFFEEEDFE),
                title: 'Security & Privacy',
                subtitle: 'Password, PIN, Biometrics',
                onTap: _showChangePIN,
              ),
              _divider(),
              _navTile(
                icon: Icons.notifications_rounded,
                color: const Color(0xFFED8936),
                bg: const Color(0xFFFFF3E0),
                title: 'Notification Settings',
                subtitle: 'Manage your alerts & updates',
                onTap: _showNotificationSettings,
              ),
              _divider(),
              _navTile(
                icon: Icons.verified_user_rounded,
                color: const Color(0xFF00B5D8),
                bg: const Color(0xFFE0F7FA),
                title: 'KYC & Verification',
                subtitle: 'View your KYC status',
                trailing: _kycBadge(),
                onTap: () {},
              ),
            ]),

            const SizedBox(height: 16),

            _sectionTitle('Support & About'),
            _settingsCard([
              _navTile(
                icon: Icons.help_rounded,
                color: blue,
                bg: const Color(0xFFEEEDFE),
                title: 'Help & Support',
                subtitle: 'Get help and contact us',
                onTap: _showSupport,
              ),
              _divider(),
              _navTile(
                icon: Icons.info_rounded,
                color: const Color(0xFF3D5AF1),
                bg: const Color(0xFFEEEDFE),
                title: 'About OB Pay Business',
                subtitle: 'App version 1.0.0',
                onTap: () {},
              ),
              _divider(),
              _navTile(
                icon: Icons.star_rounded,
                color: const Color(0xFFFFD700),
                bg: const Color(0xFFFFFDE7),
                title: 'Rate Us',
                subtitle: 'Share your experience',
                onTap: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final url = Uri.parse(
                      'https://play.google.com/store/apps/details?id=com.obpay.merchant');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Could not open Play Store')),
                    );
                  }
                },
              ),
            ]),

            const SizedBox(height: 16),

            _settingsCard([
              _navTile(
                icon: Icons.logout_rounded,
                color: Colors.red,
                bg: const Color(0xFFFCE4EC),
                title: 'Logout',
                subtitle: 'Securely logout from app',
                titleColor: Colors.red,
                onTap: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const AuthScreen()),
                  (route) => false,
                ),
              ),
            ]),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _showBankUPI() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bank Accounts & UPI',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            // UPI ID
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEEEDFE),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: blue.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.alternate_email_rounded,
                        color: blue, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('UPI ID',
                            style: TextStyle(
                                color: textLight, fontSize: 11)),
                        Text(
                          '${_phone.isNotEmpty ? _phone : widget.phone}@obpay',
                          style: const TextStyle(
                              color: textDark,
                              fontWeight: FontWeight.bold,
                              fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.copy_rounded, color: textLight, size: 18),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Linked Bank Accounts',
                style: TextStyle(
                    color: textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.account_balance_rounded,
                      color: textLight, size: 20),
                  SizedBox(width: 12),
                  Text('No bank account linked yet',
                      style: TextStyle(color: textLight, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showLinkBankAccount();
                },
                icon: const Icon(Icons.add_rounded, color: Colors.white),
                label: const Text('Link Bank Account',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLinkBankAccount() {
    final accountController = TextEditingController();
    final confirmController = TextEditingController();
    final ifscController = TextEditingController();
    String selectedBank = 'State Bank of India';
    String selectedType = 'Savings';
    bool linked = false;
    bool obscureAccount = true;

    const banks = [
      'State Bank of India',
      'HDFC Bank',
      'ICICI Bank',
      'Axis Bank',
      'Kotak Mahindra Bank',
      'Punjab National Bank',
      'Bank of Baroda',
      'Canara Bank',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
              left: 24, right: 24, top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: linked
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: Color(0xFF48BB78), size: 60),
                      const SizedBox(height: 12),
                      const Text('Bank Account Linked!',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(selectedBank,
                          style: const TextStyle(
                              color: textLight, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(
                        '****${accountController.text.length > 4 ? accountController.text.substring(accountController.text.length - 4) : accountController.text}',
                        style: const TextStyle(
                            color: textDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF48BB78),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          child: const Text('Done',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Link Bank Account',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      // Bank dropdown
                      DropdownButtonFormField<String>(
                        initialValue: selectedBank,
                        decoration: InputDecoration(
                          labelText: 'Select Bank',
                          prefixIcon: const Icon(
                              Icons.account_balance_rounded,
                              color: blue),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: blue, width: 2),
                          ),
                        ),
                        items: banks
                            .map((b) => DropdownMenuItem(
                                value: b, child: Text(b, overflow: TextOverflow.ellipsis)))
                            .toList(),
                        onChanged: (v) =>
                            setModalState(() => selectedBank = v!),
                      ),
                      const SizedBox(height: 12),
                      // Account number
                      TextField(
                        controller: accountController,
                        keyboardType: TextInputType.number,
                        obscureText: obscureAccount,
                        decoration: InputDecoration(
                          labelText: 'Account Number',
                          prefixIcon: const Icon(
                              Icons.credit_card_rounded,
                              color: blue),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureAccount
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              color: textLight,
                            ),
                            onPressed: () => setModalState(
                                () => obscureAccount = !obscureAccount),
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: blue, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Confirm account number
                      TextField(
                        controller: confirmController,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Confirm Account Number',
                          prefixIcon:
                              const Icon(Icons.credit_card_rounded, color: blue),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: blue, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // IFSC
                      TextField(
                        controller: ifscController,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.characters,
                        onChanged: (v) {
                          final upper = v.toUpperCase();
                          if (upper != v) {
                            ifscController.value = ifscController.value.copyWith(
                              text: upper,
                              selection: TextSelection.collapsed(
                                  offset: upper.length),
                            );
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'IFSC Code',
                          prefixIcon:
                              const Icon(Icons.code_rounded, color: blue),
                          hintText: 'e.g. SBIN0001234',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: blue, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Account type
                      Row(
                        children: ['Savings', 'Current'].map((type) {
                          final selected = selectedType == type;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setModalState(() => selectedType = type),
                              child: Container(
                                margin: EdgeInsets.only(
                                    right: type == 'Savings' ? 8 : 0),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? blue.withValues(alpha: 0.1)
                                      : const Color(0xFFF8F9FA),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: selected
                                        ? blue
                                        : Colors.grey.shade300,
                                  ),
                                ),
                                child: Text(type,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: selected ? blue : textLight,
                                        fontWeight: selected
                                            ? FontWeight.bold
                                            : FontWeight.normal)),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Colors.amber.withValues(alpha: 0.4)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline_rounded,
                                color: Colors.amber, size: 16),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'A ₹1 penny drop will be done to verify your account.',
                                style: TextStyle(
                                    color: Colors.amber,
                                    fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            final ifscRegex =
                                RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');
                            if (accountController.text.isEmpty ||
                                confirmController.text.isEmpty ||
                                ifscController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Please fill all fields')),
                              );
                              return;
                            }
                            if (accountController.text !=
                                confirmController.text) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Account numbers do not match')),
                              );
                              return;
                            }
                            if (!ifscRegex
                                .hasMatch(ifscController.text)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Invalid IFSC code')),
                              );
                              return;
                            }
                            setModalState(() => linked = true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: blue,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          child: const Text('Link Account',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  void _showNotificationSettings() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (_, setModalState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Notification Settings',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _notifTile(
                icon: Icons.notifications_active_rounded,
                color: blue,
                title: 'Push Notifications',
                subtitle: 'Receive app notifications',
                value: _notifPush,
                onChanged: (v) {
                  setModalState(() => _notifPush = v);
                  setState(() => _notifPush = v);
                },
              ),
              const Divider(height: 1),
              _notifTile(
                icon: Icons.account_balance_rounded,
                color: const Color(0xFF48BB78),
                title: 'Settlement Alerts',
                subtitle: 'Get notified on settlements',
                value: _notifSettlement,
                onChanged: (v) {
                  setModalState(() => _notifSettlement = v);
                  setState(() => _notifSettlement = v);
                },
              ),
              const Divider(height: 1),
              _notifTile(
                icon: Icons.payment_rounded,
                color: const Color(0xFFED8936),
                title: 'Payment Alerts',
                subtitle: 'Get notified on payments received',
                value: _notifPayment,
                onChanged: (v) {
                  setModalState(() => _notifPayment = v);
                  setState(() => _notifPayment = v);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _notifTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
                Text(subtitle,
                    style: const TextStyle(color: textLight, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: blue,
            activeTrackColor: blue.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }

  void _showSupport() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Help & Support',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _supportTile(
              Icons.email_rounded,
              const Color(0xFFED8936),
              'Email Support',
              'support@obpay.com',
              onTap: () async {
                final url = Uri.parse('mailto:support@obpay.com?subject=Merchant%20Support');
                if (await canLaunchUrl(url)) await launchUrl(url);
              },
            ),
            _supportTile(
              Icons.phone_rounded,
              const Color(0xFF00897B),
              'Call Support',
              '+91 1800-XXX-XXXX',
              onTap: () async {
                final url = Uri.parse('tel:+911800000000');
                if (await canLaunchUrl(url)) await launchUrl(url);
              },
            ),
            _supportTile(
              Icons.help_center_rounded,
              const Color(0xFF9F7AEA),
              'Help Center',
              'Browse help articles',
              onTap: () async {
                final url = Uri.parse('https://obpay.com/help');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _supportTile(
      IconData icon, Color color, String title, String subtitle,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: textDark,
                          fontWeight: FontWeight.w500,
                          fontSize: 14)),
                  Text(subtitle,
                      style: const TextStyle(color: textLight, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.grey, size: 14),
          ],
        ),
      ),
    );
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Update Profile Photo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _photoOption(Icons.camera_alt_rounded, 'Take Photo', () async {
              Navigator.pop(context);
              final XFile? image = await _picker.pickImage(
                  source: ImageSource.camera, imageQuality: 80);
              if (image != null) {
                setState(() => _profileImage = File(image.path));
              }
            }),
            _photoOption(Icons.photo_library_rounded, 'Choose from Gallery',
                () async {
              Navigator.pop(context);
              final XFile? image = await _picker.pickImage(
                  source: ImageSource.gallery, imageQuality: 80);
              if (image != null) {
                setState(() => _profileImage = File(image.path));
              }
            }),
            if (_profileImage != null)
              _photoOption(Icons.delete_rounded, 'Remove Photo', () {
                setState(() => _profileImage = null);
                Navigator.pop(context);
              }, color: Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _photoOption(IconData icon, String label, VoidCallback onTap,
      {Color color = const Color(0xFF3D5AF1)}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Text(label,
                style: TextStyle(
                    color: color, fontSize: 15, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  void _showEditProfile() {
    final nameController = TextEditingController(text: widget.userName);
    final emailController = TextEditingController(text: _email);
    final phoneController = TextEditingController(
        text: _phone.isNotEmpty ? _phone : widget.phone);
    final businessController = TextEditingController(text: 'My Business');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Edit Business Profile',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _editField('Owner Name', nameController, Icons.person_rounded),
              const SizedBox(height: 12),
              _editField('Business Name', businessController, Icons.store_rounded),
              const SizedBox(height: 12),
              _editField('Email', emailController, Icons.email_rounded,
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 12),
              _editField('Phone', phoneController, Icons.phone_rounded,
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() => _email = emailController.text);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile updated successfully!'),
                        backgroundColor: Color(0xFF48BB78),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text('Save Changes',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                ),
              ),
            ],
          ),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Change PIN',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _editField('Current PIN', currentPinController, Icons.lock_rounded,
                obscure: true, keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            _editField('New PIN', newPinController, Icons.lock_open_rounded,
                obscure: true, keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            _editField('Confirm PIN', confirmPinController,
                Icons.lock_outline_rounded,
                obscure: true, keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('PIN changed successfully!'),
                      backgroundColor: Color(0xFF48BB78),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text('Change PIN',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _overviewStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: blue, size: 20),
        const SizedBox(height: 6),
        Text(value,
            style: const TextStyle(
                color: textDark, fontSize: 14, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: textLight, fontSize: 10)),
      ],
    );
  }

  Widget _vDivider() {
    return Container(
        height: 40, width: 1, color: Colors.grey.withValues(alpha: 0.2));
  }

  Widget _editField(String label, TextEditingController controller, IconData icon,
      {bool obscure = false, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: blue),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3D5AF1), width: 2),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title,
            style: const TextStyle(
                color: textDark, fontSize: 15, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _settingsCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _navTile({
    required IconData icon,
    required Color color,
    required Color bg,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
    Color? titleColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                  color: bg, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: titleColor ?? textDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                  Text(subtitle,
                      style: const TextStyle(color: textLight, fontSize: 12)),
                ],
              ),
            ),
            trailing ??
                Icon(Icons.arrow_forward_ios_rounded,
                    color: Colors.grey.shade300, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Divider(
        height: 1, indent: 66, color: Colors.grey.withValues(alpha: 0.1));
  }
}
