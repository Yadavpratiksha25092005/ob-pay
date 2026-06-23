import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'auth_screen.dart';

class AgentProfileScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String phone;

  const AgentProfileScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.phone,
  });

  @override
  State<AgentProfileScreen> createState() => _AgentProfileScreenState();
}

class _AgentProfileScreenState extends State<AgentProfileScreen> {
  static const Color green = Color(0xFF00897B);
  static const Color darkGreen = Color(0xFF004D40);
  static const Color bgPage = Color(0xFFF5F5F5);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1A202C);
  static const Color textLight = Color(0xFF718096);

  String email = 'agent@obpay.com';
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

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
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Color(0xFF00897B)),
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
                  // Photo
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
                                      : 'A',
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
                              color: green,
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
                  Text('+91 ${widget.phone}',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.7), fontSize: 12)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.green.withOpacity(0.4)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.verified_rounded,
                                color: Colors.greenAccent, size: 12),
                            SizedBox(width: 4),
                            Text('Verified Agent',
                                style: TextStyle(
                                    color: Colors.greenAccent,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
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
                                fontSize: 11,
                                fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Overview
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
                  _overviewStat('28', 'Customers', Icons.people_rounded),
                  _vDivider(),
                  _overviewStat('140', 'Transactions', Icons.swap_horiz_rounded),
                  _vDivider(),
                  _overviewStat('₹1,305', 'Commission', Icons.monetization_on_rounded),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _sectionTitle('Agent Information'),
            _settingsCard([
              _navTile(
                icon: Icons.person_rounded,
                color: green,
                bg: const Color(0xFFE0F2F1),
                title: 'Profile & Personal Information',
                subtitle: 'Update your personal details',
                onTap: () => _showEditProfile(),
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
                onTap: () => _showNotifications(),
              ),
              _divider(),
              _navTile(
                icon: Icons.location_on_rounded,
                color: const Color(0xFFE91E63),
                bg: const Color(0xFFFCE4EC),
                title: 'Zone & Location',
                subtitle: 'Mumbai Central',
                onTap: () {},
              ),
              _divider(),
              _navTile(
                icon: Icons.star_rounded,
                color: const Color(0xFFFFD700),
                bg: const Color(0xFFFFFDE7),
                title: 'Performance & Rating',
                subtitle: 'Score: 87/100 • Rating: 4.8★',
                onTap: () {},
              ),
            ]),

            const SizedBox(height: 16),

            _sectionTitle('Support & About'),
            _settingsCard([
              _navTile(
                icon: Icons.help_rounded,
                color: green,
                bg: const Color(0xFFE0F2F1),
                title: 'Help & Support',
                subtitle: 'Get help, chat with us',
                onTap: () => _showSupport(),
              ),
              _divider(),
              _navTile(
                icon: Icons.privacy_tip_rounded,
                color: const Color(0xFF9F7AEA),
                bg: const Color(0xFFF3E5F5),
                title: 'Privacy Policy',
                subtitle: 'Read our privacy policy',
                onTap: () => _showPrivacy(),
              ),
              _divider(),
              _navTile(
                icon: Icons.info_rounded,
                color: const Color(0xFF3D5AF1),
                bg: const Color(0xFFEEEDFE),
                title: 'About OB Pay Agent',
                subtitle: 'App version 1.0.0',
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
            }, color: green),
            _photoOption(Icons.photo_library_rounded, 'Choose from Gallery',
                () async {
              Navigator.pop(context);
              final XFile? image = await _picker.pickImage(
                  source: ImageSource.gallery, imageQuality: 80);
              if (image != null) {
                setState(() => _profileImage = File(image.path));
              }
            }, color: green),
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
      {Color color = const Color(0xFF00897B)}) {
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
                      backgroundColor: Color(0xFF00897B),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkGreen,
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
    final currentPin = TextEditingController();
    final newPin = TextEditingController();
    final confirmPin = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Change PIN',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _editField('Current PIN', currentPin, Icons.lock_rounded,
                obscure: true, keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            _editField('New PIN', newPin, Icons.lock_open_rounded,
                obscure: true, keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            _editField('Confirm PIN', confirmPin, Icons.lock_outline_rounded,
                obscure: true, keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('PIN changed successfully!'),
                      backgroundColor: Color(0xFF00897B),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkGreen,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Change PIN',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotifications() {
    bool paymentAlerts = true;
    bool commissionAlerts = true;
    bool targetAlerts = true;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Notifications',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _switchRow('Payment Alerts', 'Get notified for transactions',
                  paymentAlerts, (val) => setModal(() => paymentAlerts = val)),
              _switchRow('Commission Alerts', 'Commission earned notifications',
                  commissionAlerts,
                  (val) => setModal(() => commissionAlerts = val)),
              _switchRow('Target Alerts', 'Monthly target reminders',
                  targetAlerts, (val) => setModal(() => targetAlerts = val)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notification settings saved!'),
                        backgroundColor: Color(0xFF00897B),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkGreen,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Save',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
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

  void _showPrivacy() {
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
            const Text('Privacy Policy',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text(
              'OB Pay Agent collects and uses your personal information to provide agent services. Your data is encrypted and stored securely. We do not share your information with third parties without your consent.\n\nFor full privacy policy, visit obpay.com/privacy',
              style: TextStyle(
                  color: Color(0xFF718096), fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkGreen,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Close',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _switchRow(String title, String subtitle, bool value,
      ValueChanged<bool> onChanged) {
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
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
                Text(subtitle,
                    style: const TextStyle(color: textLight, fontSize: 12)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: green),
        ],
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
        Icon(icon, color: green, size: 20),
        const SizedBox(height: 6),
        Text(value,
            style: const TextStyle(
                color: textDark, fontSize: 14, fontWeight: FontWeight.bold)),
        Text(label,
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
        prefixIcon: Icon(icon, color: green),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF00897B), width: 2),
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