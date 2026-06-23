import 'package:flutter/material.dart';

class MerchantKYCScreen extends StatefulWidget {
  final String userId;

  const MerchantKYCScreen({super.key, required this.userId});

  @override
  State<MerchantKYCScreen> createState() => _MerchantKYCScreenState();
}

class _MerchantKYCScreenState extends State<MerchantKYCScreen> {
  static const Color bgPage = Color(0xFFF5F5F5);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color blue = Color(0xFF3D5AF1);
  static const Color textDark = Color(0xFF1A202C);
  static const Color textLight = Color(0xFF718096);

  int currentStep = 0;
  bool isSubmitted = false;

  // Step 1 — Owner Details
  final ownerNameController = TextEditingController();
  final ownerDOBController = TextEditingController();
  final ownerAddressController = TextEditingController();
  final ownerAadhaarController = TextEditingController();
  final ownerPANController = TextEditingController();

  // Step 2 — Business Details
  final businessNameController = TextEditingController();
  final gstController = TextEditingController();
  final businessAddressController = TextEditingController();
  String selectedBusinessType = 'Proprietorship';

  // Step 3 — Bank Details
  final bankAccountController = TextEditingController();
  final ifscController = TextEditingController();
  final bankNameController = TextEditingController();
  String selectedBank = 'HDFC Bank';

  final List<String> businessTypes = [
    'Proprietorship',
    'Partnership',
    'Private Limited',
    'LLP',
    'Others',
  ];

  final List<String> banks = [
    'HDFC Bank', 'SBI', 'ICICI Bank', 'Axis Bank',
    'Kotak Bank', 'PNB', 'Bank of Baroda',
  ];

  final List<Map<String, dynamic>> steps = [
    {'title': 'Owner Details', 'icon': Icons.person_rounded},
    {'title': 'Business Info', 'icon': Icons.store_rounded},
    {'title': 'Bank Details', 'icon': Icons.account_balance_rounded},
    {'title': 'Review', 'icon': Icons.check_circle_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgPage,
      appBar: AppBar(
        backgroundColor: bgCard,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1A202C)),
onPressed: () => Navigator.pop(context, true),        ),
        title: const Text('Business KYC',
            style: TextStyle(
                color: Color(0xFF1A202C),
                fontSize: 18,
                fontWeight: FontWeight.bold)),
      ),
      body: isSubmitted ? _buildSuccess() : _buildKYCForm(),
    );
  }

  Widget _buildKYCForm() {
    return Column(
      children: [
        // Progress steps
        Container(
          color: bgCard,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: steps.asMap().entries.map((entry) {
              final i = entry.key;
              final step = entry.value;
              final isCompleted = i < currentStep;
              final isActive = i == currentStep;
              return Expanded(
                child: Row(
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? const Color(0xFF48BB78)
                                : isActive
                                    ? blue
                                    : Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isCompleted
                                ? Icons.check_rounded
                                : step['icon'] as IconData,
                            color: isCompleted || isActive
                                ? Colors.white
                                : Colors.grey,
                            size: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          step['title'] as String,
                          style: TextStyle(
                              fontSize: 9,
                              color: isActive ? blue : Colors.grey,
                              fontWeight: isActive
                                  ? FontWeight.w600
                                  : FontWeight.normal),
                        ),
                      ],
                    ),
                    if (i < steps.length - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          margin: const EdgeInsets.only(bottom: 20),
                          color: i < currentStep
                              ? const Color(0xFF48BB78)
                              : Colors.grey.shade200,
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),

        // Form content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (currentStep == 0) _buildOwnerDetails(),
                if (currentStep == 1) _buildBusinessDetails(),
                if (currentStep == 2) _buildBankDetails(),
                if (currentStep == 3) _buildReview(),
                const SizedBox(height: 20),
                Row(
                  children: [
                    if (currentStep > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              setState(() => currentStep--),
                          style: OutlinedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Back',
                              style: TextStyle(
                                  color: Color(0xFF718096),
                                  fontWeight: FontWeight.w500)),
                        ),
                      ),
                    if (currentStep > 0) const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          if (currentStep < steps.length - 1) {
                            setState(() => currentStep++);
                          } else {
                            setState(() => isSubmitted = true);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: blue,
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          currentStep == steps.length - 1
                              ? 'Submit KYC'
                              : 'Continue',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOwnerDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Owner Information', Icons.person_rounded, blue),
        const SizedBox(height: 16),
        _inputField('Full Name', ownerNameController,
            hint: 'Enter owner full name', icon: Icons.person_outlined),
        _inputField('Date of Birth', ownerDOBController,
            hint: 'DD/MM/YYYY', icon: Icons.calendar_today_rounded),
        _inputField('Address', ownerAddressController,
            hint: 'Enter full address',
            icon: Icons.location_on_outlined,
            maxLines: 3),
        _inputField('Aadhaar Number', ownerAadhaarController,
            hint: 'XXXX XXXX XXXX',
            icon: Icons.badge_outlined,
            keyboardType: TextInputType.number),
        _inputField('PAN Number', ownerPANController,
            hint: 'ABCDE1234F', icon: Icons.credit_card_outlined),
      ],
    );
  }

  Widget _buildBusinessDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Business Information', Icons.store_rounded, blue),
        const SizedBox(height: 16),
        _inputField('Business Name', businessNameController,
            hint: 'Enter business name', icon: Icons.store_outlined),
        const Text('Business Type',
            style: TextStyle(
                color: textLight,
                fontSize: 12,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: bgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.04), blurRadius: 8)
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedBusinessType,
              isExpanded: true,
              items: businessTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (val) =>
                  setState(() => selectedBusinessType = val!),
            ),
          ),
        ),
        const SizedBox(height: 14),
        _inputField('GST Number', gstController,
            hint: '22AAAAA0000A1Z5', icon: Icons.receipt_outlined),
        _inputField('Business Address', businessAddressController,
            hint: 'Enter business address',
            icon: Icons.location_on_outlined,
            maxLines: 3),
      ],
    );
  }

  Widget _buildBankDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Bank Account Details', Icons.account_balance_rounded, blue),
        const SizedBox(height: 16),
        const Text('Select Bank',
            style: TextStyle(
                color: textLight,
                fontSize: 12,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: bgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.04), blurRadius: 8)
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedBank,
              isExpanded: true,
              items: banks.map((bank) {
                return DropdownMenuItem(value: bank, child: Text(bank));
              }).toList(),
              onChanged: (val) => setState(() => selectedBank = val!),
            ),
          ),
        ),
        const SizedBox(height: 14),
        _inputField('Account Number', bankAccountController,
            hint: 'Enter account number',
            icon: Icons.numbers_rounded,
            keyboardType: TextInputType.number),
        _inputField('IFSC Code', ifscController,
            hint: 'HDFC0001234', icon: Icons.code_rounded),
        _inputField('Account Holder Name', bankNameController,
            hint: 'Enter account holder name',
            icon: Icons.person_outlined),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFE8EAF6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: blue.withOpacity(0.2)),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_rounded, color: Color(0xFF3D5AF1), size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'A penny drop of ₹1 will be sent to verify your bank account.',
                  style: TextStyle(color: Color(0xFF3D5AF1), fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Review & Submit', Icons.check_circle_rounded, const Color(0xFF48BB78)),
        const SizedBox(height: 16),

        // Owner info review
        _reviewCard('Owner Details', [
          _reviewRow('Name', ownerNameController.text.isEmpty ? 'Not filled' : ownerNameController.text),
          _reviewRow('DOB', ownerDOBController.text.isEmpty ? 'Not filled' : ownerDOBController.text),
          _reviewRow('Aadhaar', ownerAadhaarController.text.isEmpty ? 'Not filled' : 'XXXX XXXX ${ownerAadhaarController.text.length > 4 ? ownerAadhaarController.text.substring(ownerAadhaarController.text.length - 4) : "****"}'),
          _reviewRow('PAN', ownerPANController.text.isEmpty ? 'Not filled' : ownerPANController.text),
        ]),
        const SizedBox(height: 12),

        // Business info review
        _reviewCard('Business Details', [
          _reviewRow('Business Name', businessNameController.text.isEmpty ? 'Not filled' : businessNameController.text),
          _reviewRow('Business Type', selectedBusinessType),
          _reviewRow('GST Number', gstController.text.isEmpty ? 'Not filled' : gstController.text),
        ]),
        const SizedBox(height: 12),

        // Bank info review
        _reviewCard('Bank Details', [
          _reviewRow('Bank', selectedBank),
          _reviewRow('Account', bankAccountController.text.isEmpty ? 'Not filled' : '•••• ${bankAccountController.text.length > 4 ? bankAccountController.text.substring(bankAccountController.text.length - 4) : "****"}'),
          _reviewRow('IFSC', ifscController.text.isEmpty ? 'Not filled' : ifscController.text),
        ]),
        const SizedBox(height: 16),

        // Declaration
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'By submitting, you confirm that all information provided is accurate and complete.',
                  style: TextStyle(color: Colors.orange, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
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
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: Color(0xFFEAF3DE),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded,
                  size: 54, color: Color(0xFF3B6D11)),
            ),
            const SizedBox(height: 24),
            const Text('KYC Submitted!',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textDark)),
            const SizedBox(height: 8),
            const Text(
              'Your business KYC has been submitted successfully. Verification takes 2-3 business days.',
              textAlign: TextAlign.center,
              style: TextStyle(color: textLight, fontSize: 14),
            ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: bgCard,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10)
                ],
              ),
              child: Column(
                children: [
                  _reviewRow('Status', 'Under Review'),
                  _reviewRow('Submitted', DateTime.now().toString().substring(0, 10)),
                  _reviewRow('Expected', '2-3 Business Days'),
                  _reviewRow('Reference', 'KYC${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text('Back to Dashboard',
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

  Widget _sectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(title,
            style: const TextStyle(
                color: textDark,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _inputField(
    String label,
    TextEditingController controller, {
    String? hint,
    IconData? icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: textLight,
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04), blurRadius: 8)
              ],
            ),
            child: TextField(
              controller: controller,
              maxLines: maxLines,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle:
                    const TextStyle(color: Color(0xFFCBD5E0), fontSize: 14),
                prefixIcon: icon != null
                    ? Icon(icon, color: Colors.grey.shade400, size: 20)
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _reviewCard(String title, List<Widget> rows) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...rows,
        ],
      ),
    );
  }

  Widget _reviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: textLight, fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  color: textDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}