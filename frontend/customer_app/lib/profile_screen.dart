import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'auth_screen.dart';
import 'kyc_screen.dart';

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

  String email = 'user@obpay.com';
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

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
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Color(0xFF6C63FF)),
            onPressed: () {},
          ),
        ],
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
                  Text(email,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.7), fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(widget.phone.isEmpty ? 'No phone' : '+91 ${widget.phone}',
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
                onTap: () {},
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
                onTap: () {},
              ),
              _divider(),
              _navTile(
                icon: Icons.verified_user_rounded,
                color: const Color(0xFF00B5D8),
                bg: const Color(0xFFE0F7FA),
                title: 'KYC & Verification',
                subtitle: 'View your KYC status',
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Pending',
                      style: TextStyle(
                          color: Colors.orange,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => KYCScreen(userId: widget.userId))),
              ),
              _divider(),
              _navTile(
                icon: Icons.payment_rounded,
                color: const Color(0xFF9F7AEA),
                bg: const Color(0xFFF3E5F5),
                title: 'Payment Limits',
                subtitle: 'View and manage your limits',
                onTap: () {},
              ),
              _divider(),
              _navTile(
                icon: Icons.people_rounded,
                color: const Color(0xFFE91E63),
                bg: const Color(0xFFFCE4EC),
                title: 'Refer & Earn',
                subtitle: 'Invite friends and earn rewards',
                onTap: () {},
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
                icon: Icons.quiz_rounded,
                color: const Color(0xFF00897B),
                bg: const Color(0xFFE0F2F1),
                title: 'FAQs',
                subtitle: 'Find answers to common questions',
                onTap: () {},
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
                subtitle: 'Share your experience',
                onTap: () {},
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
            _supportTile(Icons.email_rounded, const Color(0xFFED8936),
                'Email Support', 'support@obpay.com'),
            _supportTile(Icons.phone_rounded, const Color(0xFF00897B),
                'Call Support', 'Coming Soon'),
            _supportTile(Icons.chat_rounded, const Color(0xFF3D5AF1),
                'Live Chat', 'Coming Soon'),
            _supportTile(Icons.help_center_rounded, const Color(0xFF9F7AEA),
                'FAQs', 'Browse frequently asked questions'),
          ],
        ),
      ),
    );
  }

  Widget _supportTile(IconData icon, Color color, String title, String subtitle) {
    return Container(
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
              color: color.withOpacity(0.1),
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