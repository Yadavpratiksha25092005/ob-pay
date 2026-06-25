import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'auth_screen.dart';
import 'kyc_screen.dart';
import 'api_service.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String phone;

  const ProfileScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.phone,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color bgPage = Color(0xFFF2F4F7);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color purple = Color(0xFF6C63FF);
  static const Color textDark = Color(0xFF1A202C);
  static const Color textLight = Color(0xFF718096);

  String email = 'Loading...';
  String _phone = '';
  String _kycStatus = 'pending';
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  // Notification toggles
  bool _notifPayments = true;
  bool _notifOffers = true;
  bool _notifSecurity = true;
  bool _notifUpdates = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadKycStatus();
  }

  Future<void> _loadUserProfile() async {
    final user = await ApiService.getUser(widget.userId);
    if (mounted && user.isNotEmpty) {
      setState(() {
        email = (user['email'] as String? ?? '').isNotEmpty
            ? user['email'] as String
            : 'user@obpay.com';
        _phone = (user['phone'] as String? ?? widget.phone).isNotEmpty
            ? (user['phone'] as String? ?? widget.phone)
            : widget.phone;
      });
    }
  }

  Future<void> _loadKycStatus() async {
    final status = await ApiService.getKycStatus(widget.userId);
    if (mounted) setState(() => _kycStatus = status);
  }

  Widget _kycBadge() {
    final Color color;
    final String label;
    switch (_kycStatus) {
      case 'approved':
        color = Colors.green;
        label = 'Approved';
        break;
      case 'rejected':
        color = Colors.red;
        label = 'Rejected';
        break;
      default:
        color = Colors.orange;
        label = 'Pending';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AuthScreen()),
      (route) => false,
    );
  }

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
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Photo with camera button
                  Stack(
                    children: [
                      Container(
                        width: 60, height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withOpacity(0.4), width: 2),
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
                                      : 'U',
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
                          onTap: () => _showPhotoOptions(),
                          child: Container(
                            width: 22, height: 22,
                            decoration: BoxDecoration(
                              color: purple,
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
                  Text(
                      email.isEmpty ? 'user@obpay.com' : email,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.7), fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(
                      _phone.isEmpty
                          ? (widget.phone.isEmpty ? 'No phone' : '+91 ${widget.phone}')
                          : '+91 $_phone',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.7), fontSize: 12)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green.withOpacity(0.4)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_rounded,
                            color: Colors.greenAccent, size: 12),
                        SizedBox(width: 4),
                        Text('Verified User',
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
                      color: Colors.black.withOpacity(0.04), blurRadius: 10)
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _overviewStat('₹ 0.00', 'Wallet Balance',
                      Icons.account_balance_wallet_rounded),
                  _vDivider(),
                  _overviewStat('0', 'Bank Accounts',
                      Icons.account_balance_rounded),
                  _vDivider(),
                  _overviewStat('0', 'UPI IDs', Icons.qr_code_rounded),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _sectionTitle('Personal Information'),
            _settingsCard([
              _navTile(
                icon: Icons.person_rounded,
                color: purple,
                bg: const Color(0xFFEEEDFE),
                title: 'Profile & Personal Information',
                subtitle: 'Update your personal details',
                onTap: () => _showEditProfile(),
              ),
              _divider(),
              _navTile(
                icon: Icons.account_balance_rounded,
                color: const Color(0xFF48BB78),
                bg: const Color(0xFFE8F5E9),
                title: 'Bank Accounts & UPI',
                subtitle: 'Manage your linked accounts',
                onTap: () => _showBankUPI(),
              ),
              _divider(),
              _navTile(
                icon: Icons.security_rounded,
                color: const Color(0xFF3D5AF1),
                bg: const Color(0xFFEEEDFE),
                title: 'Security & Privacy',
                subtitle: 'Password, PIN, Biometrics',
                onTap: () => _showChangePIN(),
              ),
              _divider(),
              _navTile(
                icon: Icons.notifications_rounded,
                color: const Color(0xFFED8936),
                bg: const Color(0xFFFFF3E0),
                title: 'Notification Settings',
                subtitle: 'Manage your alerts & updates',
                onTap: () => _showNotificationSettings(),
              ),
              _divider(),
              _navTile(
                icon: Icons.verified_user_rounded,
                color: const Color(0xFF00B5D8),
                bg: const Color(0xFFE0F7FA),
                title: 'KYC & Verification',
                subtitle: 'View your KYC status',
                trailing: _kycBadge(),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => KYCScreen(userId: widget.userId))),
              ),
            ]),

            const SizedBox(height: 16),

            _sectionTitle('Support & About'),
            _settingsCard([
              _navTile(
                icon: Icons.help_rounded,
                color: purple,
                bg: const Color(0xFFEEEDFE),
                title: 'Help & Support',
                subtitle: 'Get help, chat with us',
                onTap: () => _showSupport(),
              ),
              _divider(),
              _navTile(
                icon: Icons.info_rounded,
                color: const Color(0xFF3D5AF1),
                bg: const Color(0xFFEEEDFE),
                title: 'About OB Pay',
                subtitle: 'App version 1.0.0',
                onTap: () {},
              ),
              _divider(),
              _navTile(
                icon: Icons.star_rounded,
                color: const Color(0xFFFFD700),
                bg: const Color(0xFFFFFDE7),
                title: 'Rate Us',
                subtitle: 'Share your experience on Play Store',
                onTap: () async {
                  const playStoreUrl =
                      'https://play.google.com/store/apps/details?id=com.obpay.app';
                  final uri = Uri.parse(playStoreUrl);
                  final messenger = ScaffoldMessenger.of(context);
                  final launched = await canLaunchUrl(uri);
                  if (launched) {
                    await launchUrl(uri,
                        mode: LaunchMode.externalApplication);
                  } else {
                    messenger.showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Could not open Play Store. Please search for OB Pay manually.')),
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
                onTap: logout,
              ),
            ]),

            const SizedBox(height: 30),
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
      {Color color = const Color(0xFF6C63FF)}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
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
    final emailController = TextEditingController(text: email);
    final phoneController = TextEditingController(text: widget.phone);

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Edit Profile',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _editField('Full Name', nameController, Icons.person_rounded),
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
                  setState(() => email = emailController.text);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile updated successfully!'),
                      backgroundColor: Color(0xFF48BB78),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: purple,
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
            _editField('Confirm New PIN', confirmPinController,
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
                  backgroundColor: purple,
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

void _showLinkBankAccount() {
    final accountNameCtrl = TextEditingController();
    final accountNumberCtrl = TextEditingController();
    final confirmAccountCtrl = TextEditingController();
    final ifscCtrl = TextEditingController();
    String selectedAccountType = 'Savings';
    bool isVerifying = false;
    bool isLinked = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: isLinked
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 16),
                      Container(
                        width: 72, height: 72,
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.green, width: 2),
                        ),
                        child: const Icon(Icons.check_rounded,
                            color: Colors.green, size: 38),
                      ),
                      const SizedBox(height: 16),
                      const Text('Bank Account Linked!',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                        '${accountNameCtrl.text}\nA/C ending ••••${accountNumberCtrl.text.length > 4 ? accountNumberCtrl.text.substring(accountNumberCtrl.text.length - 4) : accountNumberCtrl.text}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Color(0xFF718096), fontSize: 14),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C63FF),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: const Text('Done',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Link Bank Account',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      const Text(
                          'Enter your bank details to link your account',
                          style: TextStyle(
                              color: Color(0xFF718096), fontSize: 13)),
                      const SizedBox(height: 20),

                      // Account Holder Name
                      _editField('Account Holder Name', accountNameCtrl,
                          Icons.person_rounded),
                      const SizedBox(height: 12),

                      // Bank Name
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: const Text('Select Bank'),
                            items: [
                              'State Bank of India',
                              'HDFC Bank',
                              'ICICI Bank',
                              'Axis Bank',
                              'Kotak Mahindra Bank',
                              'Punjab National Bank',
                              'Bank of Baroda',
                              'Canara Bank',
                              'Union Bank of India',
                              'Other',
                            ].map((b) => DropdownMenuItem(
                                  value: b,
                                  child: Text(b,
                                      style: const TextStyle(fontSize: 14)),
                                )).toList(),
                            onChanged: (_) {},
                            value: null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Account Number
                      TextField(
                        controller: accountNumberCtrl,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Account Number',
                          prefixIcon:
                              const Icon(Icons.account_balance_rounded),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Confirm Account Number
                      TextField(
                        controller: confirmAccountCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Confirm Account Number',
                          prefixIcon: const Icon(Icons.account_balance_rounded),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // IFSC Code
                      TextField(
                        controller: ifscCtrl,
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          labelText: 'IFSC Code',
                          prefixIcon: const Icon(Icons.code_rounded),
                          helperText: 'e.g. SBIN0001234',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onChanged: (v) {
                          ifscCtrl.value = ifscCtrl.value.copyWith(
                            text: v.toUpperCase(),
                            selection:
                                TextSelection.collapsed(offset: v.length),
                          );
                        },
                      ),
                      const SizedBox(height: 12),

                      // Account Type
                      const Text('Account Type',
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 13)),
                      const SizedBox(height: 8),
                      Row(
                        children: ['Savings', 'Current'].map((type) {
                          final selected = selectedAccountType == type;
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: ChoiceChip(
                              label: Text(type),
                              selected: selected,
                              selectedColor: const Color(0xFF6C63FF),
                              labelStyle: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : Colors.black87,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                              onSelected: (_) => setSheet(
                                  () => selectedAccountType = type),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      // Info note
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline_rounded,
                                color: Color(0xFF388E3C), size: 18),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'A penny drop of ₹1 will be sent to verify your account. It will be refunded within 24 hours.',
                                style: TextStyle(
                                    color: Color(0xFF2E7D32), fontSize: 12),
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
                          onPressed: isVerifying
                              ? null
                              : () async {
                                  if (accountNameCtrl.text.trim().isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Enter account holder name')),
                                    );
                                    return;
                                  }
                                  if (accountNumberCtrl.text.trim().length < 9) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Enter a valid account number')),
                                    );
                                    return;
                                  }
                                  if (accountNumberCtrl.text !=
                                      confirmAccountCtrl.text) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Account numbers do not match')),
                                    );
                                    return;
                                  }
                                  if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$')
                                      .hasMatch(ifscCtrl.text.trim())) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Enter a valid IFSC code')),
                                    );
                                    return;
                                  }
                                  setSheet(() => isVerifying = true);
                                  await Future.delayed(
                                      const Duration(seconds: 2));
                                  setSheet(() {
                                    isVerifying = false;
                                    isLinked = true;
                                  });
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C63FF),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          child: isVerifying
                              ? const SizedBox(
                                  width: 22, height: 22,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : const Text('Verify & Link Account',
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
            const SizedBox(height: 4),
            const Text('Manage your linked bank accounts and UPI IDs',
                style: TextStyle(color: Color(0xFF718096), fontSize: 13)),
            const SizedBox(height: 20),
            // UPI ID section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.qr_code_rounded,
                            color: Color(0xFF6C63FF), size: 18),
                      ),
                      const SizedBox(width: 10),
                      const Text('UPI ID',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF6C63FF).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${_phone.isNotEmpty ? _phone : widget.phone}@obpay',
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ),
                        const Icon(Icons.copy_rounded,
                            color: Color(0xFF6C63FF), size: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Bank Account section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFF48BB78).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.account_balance_rounded,
                            color: Color(0xFF48BB78), size: 18),
                      ),
                      const SizedBox(width: 10),
                      const Text('Linked Bank Accounts',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.account_balance_outlined,
                            size: 40, color: Colors.grey.shade300),
                        const SizedBox(height: 8),
                        const Text('No bank account linked',
                            style: TextStyle(
                                color: Color(0xFF718096), fontSize: 13)),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _showLinkBankAccount();
                          },
                          icon: const Icon(Icons.add_rounded,
                              size: 18, color: Colors.white),
                          label: const Text('Link Bank Account',
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C63FF),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showNotificationSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Notification Settings',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Choose which notifications you want to receive',
                  style: TextStyle(color: Color(0xFF718096), fontSize: 13)),
              const SizedBox(height: 20),
              _notifTile(
                ctx, setModalState,
                icon: Icons.payment_rounded,
                color: const Color(0xFF6C63FF),
                title: 'Payment Alerts',
                subtitle: 'Get notified for every payment sent or received',
                value: _notifPayments,
                onChanged: (v) {
                  setModalState(() => _notifPayments = v);
                  setState(() => _notifPayments = v);
                },
              ),
              _notifTile(
                ctx, setModalState,
                icon: Icons.local_offer_rounded,
                color: const Color(0xFFED8936),
                title: 'Offers & Cashback',
                subtitle: 'Promotional offers and cashback alerts',
                value: _notifOffers,
                onChanged: (v) {
                  setModalState(() => _notifOffers = v);
                  setState(() => _notifOffers = v);
                },
              ),
              _notifTile(
                ctx, setModalState,
                icon: Icons.security_rounded,
                color: const Color(0xFF3D5AF1),
                title: 'Security Alerts',
                subtitle: 'Login attempts and security updates',
                value: _notifSecurity,
                onChanged: (v) {
                  setModalState(() => _notifSecurity = v);
                  setState(() => _notifSecurity = v);
                },
              ),
              _notifTile(
                ctx, setModalState,
                icon: Icons.system_update_rounded,
                color: const Color(0xFF00897B),
                title: 'App Updates',
                subtitle: 'New features and app announcements',
                value: _notifUpdates,
                onChanged: (v) {
                  setModalState(() => _notifUpdates = v);
                  setState(() => _notifUpdates = v);
                },
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Notification preferences saved!'),
                          backgroundColor: Color(0xFF48BB78)),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Save Preferences',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _notifTile(
    BuildContext ctx,
    StateSetter setModalState, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
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
                        fontWeight: FontWeight.w500, fontSize: 14)),
                Text(subtitle,
                    style: const TextStyle(
                        color: Color(0xFF718096), fontSize: 11)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF6C63FF),
            activeTrackColor: const Color(0xFF6C63FF).withValues(alpha: 0.4),
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
              Icons.help_center_rounded,
              const Color(0xFF6C63FF),
              'Help Center',
              'Browse guides and tutorials',
              onTap: () async {
                final uri = Uri.parse('https://obpay.in/help');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
            _supportTile(
              Icons.email_rounded,
              const Color(0xFFED8936),
              'Contact Support',
              'support@obpay.com',
              onTap: () async {
                final uri = Uri.parse('mailto:support@obpay.com?subject=OB Pay Support');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
            ),
            _supportTile(
              Icons.phone_rounded,
              const Color(0xFF00897B),
              'Call Support',
              '+91 1800-XXX-XXXX (Toll Free)',
              onTap: () async {
                final uri = Uri.parse('tel:+911800000000');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
            ),
            _supportTile(
              Icons.quiz_rounded,
              const Color(0xFF009688),
              'FAQs',
              'Frequently asked questions',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _supportTile(IconData icon, Color color, String title, String subtitle,
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
        ],
      ),
    ),
    );
  }

  Widget _overviewStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: purple, size: 20),
        const SizedBox(height: 6),
        Text(value,
            style: const TextStyle(
                color: textDark, fontSize: 14, fontWeight: FontWeight.bold)),
        Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: textLight, fontSize: 10)),
      ],
    );
  }

  Widget _vDivider() {
    return Container(
        height: 40, width: 1, color: Colors.grey.withOpacity(0.2));
  }

  Widget _editField(String label, TextEditingController controller, IconData icon,
      {bool obscure = false, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: purple),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
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
              color: Colors.black.withOpacity(0.04),
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
        height: 1, indent: 66, color: Colors.grey.withOpacity(0.1));
  }
}