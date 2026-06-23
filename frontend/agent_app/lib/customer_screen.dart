import 'package:flutter/material.dart';

class CustomerScreen extends StatefulWidget {
  final String agentId;

  const CustomerScreen({super.key, required this.agentId});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen>
    with SingleTickerProviderStateMixin {
  static const Color green = Color(0xFF00897B);
  static const Color bgPage = Color(0xFFF5F5F5);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1A202C);
  static const Color textLight = Color(0xFF718096);

  late TabController _tabController;
  bool isLoading = false;
  bool isRegistered = false;
  bool isMerchantRegistered = false;
  String registeredType = '';

  // Customer fields
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final aadhaarController = TextEditingController();
  final addressController = TextEditingController();

  // Merchant fields
  final shopNameController = TextEditingController();
  final merchantPhoneController = TextEditingController();
  final merchantEmailController = TextEditingController();
  final gstController = TextEditingController();
  final panController = TextEditingController();
  final shopAddressController = TextEditingController();
  String selectedBusinessType = 'Retail Shop';

  final List<String> businessTypes = [
    'Retail Shop', 'Medical Store', 'Restaurant', 'Grocery',
    'Electronics', 'Clothing', 'Hardware', 'Other'
  ];

  final List<Map<String, dynamic>> customers = [
    {'name': 'Rahul Kumar', 'phone': '9876543210', 'kyc': 'Verified', 'type': 'Customer', 'joined': '15 Jun 2026', 'transactions': 12},
    {'name': 'Priya Sharma', 'phone': '8765432109', 'kyc': 'Pending', 'type': 'Customer', 'joined': '16 Jun 2026', 'transactions': 5},
    {'name': 'Amit Medical', 'phone': '7654321098', 'kyc': 'Verified', 'type': 'Merchant', 'joined': '17 Jun 2026', 'transactions': 8},
    {'name': 'Sunita Devi', 'phone': '6543210987', 'kyc': 'Verified', 'type': 'Customer', 'joined': '18 Jun 2026', 'transactions': 3},
    {'name': 'Mohan Kirana', 'phone': '5432109876', 'kyc': 'Pending', 'type': 'Merchant', 'joined': '19 Jun 2026', 'transactions': 1},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        title: const Text('Customers & Merchants',
            style: TextStyle(
                color: Color(0xFF1A202C),
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Color(0xFF1A202C)),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: green,
          unselectedLabelColor: textLight,
          indicatorColor: green,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Register Customer'),
            Tab(text: 'Register Merchant'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCustomerList(),
          _buildCustomerForm(),
          _buildMerchantForm(),
        ],
      ),
    );
  }

  Widget _buildCustomerList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Stats
        Row(
          children: [
            Expanded(child: _statCard('${customers.length}', 'Total',
                Icons.people_rounded, green)),
            const SizedBox(width: 10),
            Expanded(child: _statCard(
                '${customers.where((c) => c['type'] == 'Customer').length}',
                'Customers', Icons.person_rounded, const Color(0xFF3D5AF1))),
            const SizedBox(width: 10),
            Expanded(child: _statCard(
                '${customers.where((c) => c['type'] == 'Merchant').length}',
                'Merchants', Icons.store_rounded, const Color(0xFFED8936))),
          ],
        ),
        const SizedBox(height: 16),

        ...customers.map((c) {
          final isVerified = c['kyc'] == 'Verified';
          final isMerchant = c['type'] == 'Merchant';
          final color = isMerchant ? const Color(0xFFED8936) : green;
          final bg = isMerchant
              ? const Color(0xFFFFF3E0)
              : const Color(0xFFE0F2F1);

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: bgCard,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04), blurRadius: 8)
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 46, height: 46,
                  decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                  child: Center(
                    child: Icon(
                      isMerchant ? Icons.store_rounded : Icons.person_rounded,
                      color: color, size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c['name'] as String,
                          style: const TextStyle(
                              color: textDark,
                              fontWeight: FontWeight.w600,
                              fontSize: 14)),
                      Row(
                        children: [
                          Text(c['phone'] as String,
                              style: const TextStyle(
                                  color: textLight, fontSize: 12)),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(c['type'] as String,
                                style: TextStyle(
                                    color: color,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isVerified
                            ? const Color(0xFFEAF3DE)
                            : const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(c['kyc'] as String,
                          style: TextStyle(
                              color: isVerified
                                  ? const Color(0xFF3B6D11)
                                  : const Color(0xFF854F0B),
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 4),
                    Text('${c['transactions']} txns',
                        style: const TextStyle(
                            color: textLight, fontSize: 11)),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCustomerForm() {
    if (isRegistered) {
      return _buildSuccessScreen(
        'Customer Registered! 🎉',
        '${nameController.text} has been registered successfully.\nYou earned ₹10 bonus!',
        () => setState(() {
          isRegistered = false;
          nameController.clear();
          phoneController.clear();
          aadhaarController.clear();
          addressController.clear();
        }),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoBanner('Register new customers to earn ₹10 per customer bonus!', green),
          const SizedBox(height: 20),
          _inputField('Full Name', nameController, Icons.person_rounded),
          const SizedBox(height: 14),
          _inputField('Phone Number', phoneController, Icons.phone_rounded,
              keyboardType: TextInputType.phone),
          const SizedBox(height: 14),
          _inputField('Aadhaar Number', aadhaarController, Icons.badge_rounded,
              keyboardType: TextInputType.number),
          const SizedBox(height: 14),
          _inputField('Address', addressController, Icons.location_on_rounded,
              maxLines: 3),
          const SizedBox(height: 24),
          _submitButton('Register Customer', isLoading, () async {
            if (nameController.text.isEmpty || phoneController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please fill all fields')),
              );
              return;
            }
            setState(() => isLoading = true);
            await Future.delayed(const Duration(seconds: 2));
            setState(() {
              isLoading = false;
              isRegistered = true;
            });
          }),
        ],
      ),
    );
  }

  Widget _buildMerchantForm() {
    if (isMerchantRegistered) {
      return _buildSuccessScreen(
        'Merchant Registered! 🏪',
        '${shopNameController.text} has been registered successfully.\nYou earned ₹50 bonus!',
        () => setState(() {
          isMerchantRegistered = false;
          shopNameController.clear();
          merchantPhoneController.clear();
          merchantEmailController.clear();
          gstController.clear();
          panController.clear();
          shopAddressController.clear();
        }),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoBanner('Register merchants to earn ₹50 per merchant bonus! 🏪', const Color(0xFFED8936)),
          const SizedBox(height: 20),

          // Business Type
          const Text('Business Type',
              style: TextStyle(color: textLight, fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: bgCard,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedBusinessType,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down_rounded, color: Color(0xFFED8936)),
                items: businessTypes.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (val) => setState(() => selectedBusinessType = val!),
              ),
            ),
          ),

          const SizedBox(height: 14),
          _inputField('Shop / Business Name', shopNameController,
              Icons.store_rounded, color: const Color(0xFFED8936)),
          const SizedBox(height: 14),
          _inputField('Owner Phone Number', merchantPhoneController,
              Icons.phone_rounded,
              keyboardType: TextInputType.phone,
              color: const Color(0xFFED8936)),
          const SizedBox(height: 14),
          _inputField('Email Address', merchantEmailController,
              Icons.email_rounded,
              keyboardType: TextInputType.emailAddress,
              color: const Color(0xFFED8936)),
          const SizedBox(height: 14),
          _inputField('GST Number (Optional)', gstController,
              Icons.receipt_rounded, color: const Color(0xFFED8936)),
          const SizedBox(height: 14),
          _inputField('PAN Number', panController,
              Icons.badge_rounded, color: const Color(0xFFED8936)),
          const SizedBox(height: 14),
          _inputField('Shop Address', shopAddressController,
              Icons.location_on_rounded,
              maxLines: 3, color: const Color(0xFFED8936)),

          const SizedBox(height: 16),

          // KYC Documents info
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFED8936).withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.document_scanner_rounded,
                        color: Color(0xFFED8936), size: 18),
                    SizedBox(width: 8),
                    Text('Documents Required',
                        style: TextStyle(
                            color: Color(0xFF854F0B),
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 8),
                _docRow('Shop Photo'),
                _docRow('Owner Aadhaar Card'),
                _docRow('PAN Card'),
                _docRow('GST Certificate (if applicable)'),
                _docRow('Bank Passbook / Cancelled Cheque'),
              ],
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (shopNameController.text.isEmpty ||
                          merchantPhoneController.text.isEmpty ||
                          panController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please fill all required fields')),
                        );
                        return;
                      }
                      setState(() => isLoading = true);
                      await Future.delayed(const Duration(seconds: 2));
                      setState(() {
                        isLoading = false;
                        isMerchantRegistered = true;
                      });
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFED8936),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Register Merchant',
                      style: TextStyle(
                          fontSize: 17,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSuccessScreen(String title, String message, VoidCallback onReset) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100, height: 100,
              decoration: const BoxDecoration(
                  color: Color(0xFFEAF3DE), shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded,
                  size: 54, color: Color(0xFF3B6D11)),
            ),
            const SizedBox(height: 24),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textDark)),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: textLight, fontSize: 13)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onReset,
              style: ElevatedButton.styleFrom(
                backgroundColor: green,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('Register Another',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoBanner(String text, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_rounded, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: TextStyle(color: color, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _docRow(String doc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded,
              color: Color(0xFFED8936), size: 14),
          const SizedBox(width: 6),
          Text(doc,
              style: const TextStyle(
                  color: Color(0xFF854F0B), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _submitButton(String label, bool isLoading, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: green,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(label,
                style: const TextStyle(
                    fontSize: 17,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _statCard(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label,
              style: const TextStyle(color: textLight, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _inputField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    Color color = green,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: textLight, fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: bgCard,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: color, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}