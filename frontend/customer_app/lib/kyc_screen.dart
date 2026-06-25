import 'package:flutter/material.dart';
import 'theme_toggle.dart';

class KYCScreen extends StatefulWidget {
  final String userId;

  const KYCScreen({super.key, required this.userId});

  @override
  State<KYCScreen> createState() => _KYCScreenState();
}

class _KYCScreenState extends State<KYCScreen> {
  int currentStep = 0;
  bool isLoading = false;

  // Step 1 - Personal Details
  final nameController = TextEditingController();
  final dobController = TextEditingController();
  final addressController = TextEditingController();
  String selectedGender = 'Male';

  // Step 2 - Document selection
  String _selectedDocType = 'Aadhaar';

  // Step 3 - Aadhaar
  final aadhaarController = TextEditingController();
  final aadhaarOTPController = TextEditingController();
  bool otpSent = false;
  bool aadhaarVerified = false;
  bool _consentChecked = false;

  // Step 3 - PAN
  final panController = TextEditingController();
  bool panVerified = false;

  // Step 4 - Selfie
  bool selfieUploaded = false;

  // Design tokens
  static const Color _blue = Color(0xFF2563EB);
  static const Color _bgColor = Color(0xFFF8FAFF);

  static const Color _textPrimary = Color(0xFF111827);
  static const Color _textSecondary = Color(0xFF6B7280);
  static const Color _green = Color(0xFF16A34A);
  static const Color _border = Color(0xFFE5E7EB);

  InputDecoration _fieldDecoration({
    required String label,
    required IconData prefixIcon,
    String? hintText,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hintText,
      labelStyle: const TextStyle(color: _textSecondary, fontSize: 14),
      hintStyle: const TextStyle(color: _textSecondary),
      prefixIcon: Icon(prefixIcon, color: _blue, size: 20),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _blue, width: 1.5),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _border),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  Future<void> sendAadhaarOTP() async {
    if (aadhaarController.text.length != 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid 12 digit Aadhaar number')),
      );
      return;
    }
    setState(() => isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      isLoading = false;
      otpSent = true;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP sent to Aadhaar linked mobile!')),
      );
    }
  }

  Future<void> verifyAadhaarOTP() async {
    if (aadhaarOTPController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid 6 digit OTP')),
      );
      return;
    }
    setState(() => isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      isLoading = false;
      aadhaarVerified = true;
    });
  }

  Future<void> verifyPAN() async {
    final pan = panController.text.trim().toUpperCase();
    if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$').hasMatch(pan)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid PAN (e.g. ABCDE1234F)')),
      );
      return;
    }
    setState(() => isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        isLoading = false;
        panVerified = true;
      });
    }
  }

  Future<void> uploadSelfie() async {
    setState(() => isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      isLoading = false;
      selfieUploaded = true;
    });
  }

  void nextStep() {
    if (currentStep < 3) {
      setState(() => currentStep++);
    }
  }

  void prevStep() {
    if (currentStep > 0) {
      setState(() => currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: _textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'KYC Verification',
          style: TextStyle(
            color: _textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _border),
        ),
      ),
=======
     appBar: AppBar(
  backgroundColor: const Color(0xFF6C63FF),
  title: const Text('KYC Verification',
      style: TextStyle(color: Colors.white)),
  iconTheme: const IconThemeData(color: Colors.white),
  actions: const [
    ThemeToggleButton(),
    SizedBox(width: 8),
  ],
),
>>>>>>> 1599325dc4419b4965a88810dc274c34cfc0e110
      body: Column(
        children: [
          // Shield trust bar
          Container(
            color: Colors.white,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: const Row(
              children: [
                Icon(Icons.shield_rounded, color: _blue, size: 16),
                SizedBox(width: 6),
                Text(
                  'Your identity is 100% secure with us',
                  style: TextStyle(
                    color: _blue,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Step progress indicator
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Step ${currentStep + 1} of 4',
                  style: const TextStyle(
                    color: _blue,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(4, (i) {
                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                        height: 4,
                        decoration: BoxDecoration(
                          color: i <= currentStep ? _blue : _border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          // Step Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildCurrentStep(),
            ),
          ),

          // Bottom navigation buttons
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (currentStep) {
      case 0:
        return _buildStep1Personal();
      case 1:
        return _buildStep2SelectDocument();
      case 2:
        return _buildStep3DocumentVerification();
      case 3:
        return _buildStep4Selfie();
      default:
        return _buildStep1Personal();
    }
  }

  // ─── Step 1: Personal Information ───────────────────────────────────────────

  Widget _buildStep1Personal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Personal Information',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Please enter your details as per Aadhaar',
          style: TextStyle(color: _textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 24),

        // Full Name
        TextField(
          controller: nameController,
          style: const TextStyle(color: _textPrimary, fontSize: 15),
          decoration: _fieldDecoration(
            label: 'Full Name',
            prefixIcon: Icons.person_outline,
          ),
        ),
        const SizedBox(height: 16),

        // Date of Birth
        TextField(
          controller: dobController,
          keyboardType: TextInputType.datetime,
          style: const TextStyle(color: _textPrimary, fontSize: 15),
          decoration: _fieldDecoration(
            label: 'Date of Birth',
            prefixIcon: Icons.calendar_today_outlined,
            hintText: 'DD/MM/YYYY',
          ),
        ),
        const SizedBox(height: 16),

        // Gender
        const Text(
          'Gender',
          style: TextStyle(
            color: _textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: ['Male', 'Female', 'Other'].map((g) {
            final selected = selectedGender == g;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => selectedGender = g),
                child: Container(
                  margin: EdgeInsets.only(
                      right: g != 'Other' ? 10 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: selected ? _blue : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected ? _blue : _border,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      g,
                      style: TextStyle(
                        color: selected ? Colors.white : _textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // Address
        TextField(
          controller: addressController,
          maxLines: 2,
          style: const TextStyle(color: _textPrimary, fontSize: 15),
          decoration: _fieldDecoration(
            label: 'Address',
            prefixIcon: Icons.location_on_outlined,
          ),
        ),
        const SizedBox(height: 24),

        // Trust note
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _blue.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _blue.withValues(alpha: 0.15)),
          ),
          child: const Row(
            children: [
              Icon(Icons.lock_outline_rounded, color: _blue, size: 18),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Your information is encrypted and secure',
                  style: TextStyle(
                    color: _blue,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Secured by footer
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.shield_rounded,
                  color: _textSecondary, size: 14),
              const SizedBox(width: 4),
              const Text(
                'Secured by OneBharat Pay',
                style: TextStyle(
                  color: _textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // ─── Step 2: Select Document ─────────────────────────────────────────────────

  Widget _buildStep2SelectDocument() {
    final docs = [
      {
        'label': 'Aadhaar Card',
        'subtitle': 'Unique Identification',
        'icon': Icons.credit_card_rounded,
      },
      {
        'label': 'PAN Card',
        'subtitle': 'Permanent Account Number',
        'icon': Icons.credit_card_outlined,
      },
      {
        'label': 'Passport',
        'subtitle': 'Government Issued',
        'icon': Icons.book_rounded,
      },
      {
        'label': 'Driving License',
        'subtitle': 'Transport Department',
        'icon': Icons.drive_eta_rounded,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Document',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Choose any one document for verification',
          style: TextStyle(color: _textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 24),

        ...docs.map((doc) {
          final label = doc['label'] as String;
          final subtitle = doc['subtitle'] as String;
          final icon = doc['icon'] as IconData;
          final selected = _selectedDocType == label;

          return GestureDetector(
            onTap: () => setState(() => _selectedDocType = label),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border(
                  left: BorderSide(
                    color: selected ? _blue : Colors.transparent,
                    width: 4,
                  ),
                  top: BorderSide(color: selected ? _blue.withValues(alpha: 0.3) : _border),
                  right: BorderSide(color: selected ? _blue.withValues(alpha: 0.3) : _border),
                  bottom: BorderSide(color: selected ? _blue.withValues(alpha: 0.3) : _border),
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: _blue.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : [],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: selected
                            ? _blue.withValues(alpha: 0.1)
                            : _bgColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon,
                          color: selected ? _blue : _textSecondary,
                          size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: TextStyle(
                              color: selected ? _blue : _textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              color: _textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: selected ? _blue : _textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),

        const SizedBox(height: 16),

        // Trust note
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _green.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _green.withValues(alpha: 0.2)),
          ),
          child: const Row(
            children: [
              Icon(Icons.security_rounded, color: _green, size: 18),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'We do not store your documents. Your data is safe with us.',
                  style: TextStyle(
                    color: _green,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Step 3: Document Verification ──────────────────────────────────────────

  Widget _buildStep3DocumentVerification() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aadhaar Verification',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Enter your 12 digit Aadhaar number',
          style: TextStyle(color: _textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 24),

        if (aadhaarVerified)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _green.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _green.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.verified_rounded, color: _green, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Aadhaar Verified!',
                        style: TextStyle(
                          color: _green,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Your Aadhaar has been verified successfully.',
                        style: TextStyle(color: _green, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else ...[
          // Aadhaar Number label
          const Text(
            'Aadhaar Number',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          TextField(
            controller: aadhaarController,
            keyboardType: TextInputType.number,
            maxLength: 12,
            style: const TextStyle(
              color: _textPrimary,
              fontSize: 16,
              letterSpacing: 2,
            ),
            decoration: InputDecoration(
              hintText: '1234 5678 9012',
              hintStyle: const TextStyle(
                  color: _textSecondary, letterSpacing: 2),
              counterText: '',
              prefixIcon: const Icon(Icons.rotate_right_rounded,
                  color: _blue, size: 20),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _blue, width: 1.5),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 12),

          // Secure govt API note
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _blue.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.verified_user_rounded, color: _blue, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'We use secure government API to verify your identity',
                    style: TextStyle(color: _blue, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Consent checkbox
          GestureDetector(
            onTap: () =>
                setState(() => _consentChecked = !_consentChecked),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: _consentChecked ? _blue : Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                        color: _consentChecked ? _blue : _border,
                        width: 1.5),
                  ),
                  child: _consentChecked
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 14)
                      : null,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'I consent to validate my Aadhaar details for KYC verification',
                    style: TextStyle(
                        color: _textSecondary, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Send OTP button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : sendAadhaarOTP,
              style: ElevatedButton.styleFrom(
                backgroundColor: _blue,
                disabledBackgroundColor: _blue.withValues(alpha: 0.6),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5),
                    )
                  : const Text(
                      'Send OTP',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),

          // OTP section
          if (otpSent) ...[
            const SizedBox(height: 28),
            const Text(
              'Enter OTP',
              style: TextStyle(
                color: _textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            // 6 individual digit boxes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (i) {
                return Container(
                  width: 44,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _border),
                  ),
                  child: Center(
                    child: Text(
                      aadhaarOTPController.text.length > i
                          ? aadhaarOTPController.text[i]
                          : '',
                      style: const TextStyle(
                        color: _textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),

            // Hidden OTP input
            Opacity(
              opacity: 0,
              child: SizedBox(
                height: 0,
                child: TextField(
                  controller: aadhaarOTPController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ),

            // Resend timer
            const Text(
              'Resend OTP in 00:25',
              style: TextStyle(color: _textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),

            // Verify OTP
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : verifyAadhaarOTP,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  disabledBackgroundColor: _green.withValues(alpha: 0.6),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Verify OTP',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ],
    );
  }

  // ─── Step 4: Selfie + Completion ─────────────────────────────────────────────

  Widget _buildStep4Selfie() {
    if (selfieUploaded) {
      return _buildKycCompleted();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Take a Selfie',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Please align your face in the circle',
          style: TextStyle(color: _textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 36),

        // Selfie circle
        Center(
          child: GestureDetector(
            onTap: uploadSelfie,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(200, 200),
                  painter: _DashedCirclePainter(
                    color: selfieUploaded ? _green : _blue,
                  ),
                ),
                Container(
                  width: 184,
                  height: 184,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selfieUploaded
                        ? _green.withValues(alpha: 0.08)
                        : _blue.withValues(alpha: 0.06),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        selfieUploaded
                            ? Icons.check_circle_rounded
                            : Icons.person_outline_rounded,
                        size: 72,
                        color: selfieUploaded ? _green : _textSecondary,
                      ),
                      if (!selfieUploaded) ...[
                        const SizedBox(height: 8),
                        const Text(
                          'Tap to take selfie',
                          style: TextStyle(
                              color: _textSecondary, fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 32),

        // Status indicators
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _border),
          ),
          child: Column(
            children: [
              _statusRow('Good Lighting', _green),
              const SizedBox(height: 10),
              _statusRow('Face Centered', _green),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Privacy note
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _border),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  color: _textSecondary, size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Your selfie is used only for verification and not stored.',
                  style: TextStyle(color: _textSecondary, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statusRow(String label, Color dotColor) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration:
              BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            color: _textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ─── KYC Completed screen ────────────────────────────────────────────────────

  Widget _buildKycCompleted() {
    return Column(
      children: [
        const SizedBox(height: 20),
        // Green checkmark circle
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: _green.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle_rounded,
              color: _green, size: 50),
        ),
        const SizedBox(height: 20),
        const Text(
          'KYC Completed!',
          style: TextStyle(
            color: _textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Your identity has been verified successfully',
          textAlign: TextAlign.center,
          style: TextStyle(color: _textSecondary, fontSize: 15),
        ),
        const SizedBox(height: 32),

        // Stats card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _statRow('Account Status', 'Verified', valueColor: _green),
              _divider(),
              _statRow('Daily Limit', '₹1,00,000'),
              _divider(),
              _statRow('Wallet Status', 'Activated', valueColor: _green),
              _divider(),
              _statRow('Bank Transfer', 'Enabled', valueColor: _green),
              _divider(),
              _statRow('UPI Payments', 'Enabled', valueColor: _green),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Go to Dashboard button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () =>
                Navigator.of(context).popUntil((r) => r.isFirst),
            style: ElevatedButton.styleFrom(
              backgroundColor: _blue,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Go to Dashboard',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _statRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: _textSecondary, fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? _textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(height: 1, color: _border);
  }

  // ─── Bottom buttons ──────────────────────────────────────────────────────────

  Widget _buildBottomButtons() {
    // On completed screen, no buttons needed
    if (currentStep == 3 && selfieUploaded) {
      return const SizedBox.shrink();
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Back button (steps 2-4)
              if (currentStep > 0) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: prevStep,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: _blue),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Back',
                      style: TextStyle(
                        color: _blue,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],

              // Continue / Take Selfie button
              if (!(currentStep == 3 && selfieUploaded))
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : (currentStep == 3 ? uploadSelfie : nextStep),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _blue,
                      disabledBackgroundColor: _blue.withValues(alpha: 0.6),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5),
                          )
                        : Text(
                            currentStep == 3
                                ? 'Take Selfie'
                                : currentStep == 0
                                    ? 'Continue →'
                                    : 'Continue →',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Dashed circle painter ───────────────────────────────────────────────────

class _DashedCirclePainter extends CustomPainter {
  final Color color;

  const _DashedCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;
    const dashCount = 24;
    const gapRatio = 0.4;
    const totalAngle = 6.2832; // 2*pi
    final dashAngle = totalAngle / dashCount * (1 - gapRatio);
    final gapAngle = totalAngle / dashCount * gapRatio;

    double startAngle = 0;
    for (int i = 0; i < dashCount; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        dashAngle,
        false,
        paint,
      );
      startAngle += dashAngle + gapAngle;
    }
  }

  @override
  bool shouldRepaint(_DashedCirclePainter oldDelegate) =>
      oldDelegate.color != color;
}
