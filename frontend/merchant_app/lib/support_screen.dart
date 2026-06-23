import 'package:flutter/material.dart';

class MerchantSupportScreen extends StatefulWidget {
  final String userId;

  const MerchantSupportScreen({super.key, required this.userId});

  @override
  State<MerchantSupportScreen> createState() =>
      _MerchantSupportScreenState();
}

class _MerchantSupportScreenState
    extends State<MerchantSupportScreen> {
  static const Color bgPage = Color(0xFFF0F4FF);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color blue = Color(0xFF3D5AF1);
  static const Color textDark = Color(0xFF1A202C);
  static const Color textLight = Color(0xFF718096);

  final messageController = TextEditingController();
  bool isSubmitted = false;
  int? selectedFAQ;

  final List<Map<String, dynamic>> faqs = [
    {'q': 'How do I request a settlement?', 'a': 'Go to Settlement screen → Fill bank details → Click "Request Settlement". Amount will be credited within T+1 business day.'},
    {'q': 'What is the settlement fee?', 'a': 'OB Pay charges 1% of the transaction amount as platform fee. Minimum fee is ₹1.'},
    {'q': 'How do I generate my QR code?', 'a': 'Tap "My QR" in Quick Actions. Your unique QR code will be displayed. Share or print it for customers to scan.'},
    {'q': 'How long does KYC verification take?', 'a': 'Business KYC verification takes 2-3 business days. You will receive a notification once approved.'},
    {'q': 'What payment methods are supported?', 'a': 'OB Pay supports UPI, QR Code, Debit Card, Credit Card, and Net Banking payments from customers.'},
    {'q': 'How do I issue a refund?', 'a': 'Go to Refunds section → Select transaction → Enter amount → Click "Issue Refund". Refund will be processed within 24 hours.'},
  ];

  final List<Map<String, dynamic>> contactOptions = [
    {'icon': Icons.chat_rounded, 'title': 'Live Chat', 'subtitle': 'Chat with us now', 'color': const Color(0xFF6C63FF), 'bg': const Color(0xFFEEEDFE)},
    {'icon': Icons.phone_rounded, 'title': 'Call Us', 'subtitle': '1800-XXX-XXXX (Free)', 'color': const Color(0xFF48BB78), 'bg': const Color(0xFFE8F5E9)},
    {'icon': Icons.email_rounded, 'title': 'Email Support', 'subtitle': 'support@obpay.com', 'color': const Color(0xFF3D5AF1), 'bg': const Color(0xFFEEEDFE)},
    {'icon': Icons.help_center_rounded, 'title': 'Help Center', 'subtitle': 'Browse articles', 'color': const Color(0xFFED8936), 'bg': const Color(0xFFFFF3E0)},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgPage,
      appBar: AppBar(
        backgroundColor: bgCard,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: Color(0xFF1A202C)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Support',
            style: TextStyle(
                color: Color(0xFF1A202C),
                fontSize: 18,
                fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A56DB), Color(0xFF3D5AF1)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('How can we help?',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('We\'re here 24/7 for you',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 13)),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('Avg response: 2 mins',
                              style: TextStyle(
                                  color: Color(0xFF3D5AF1),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.support_agent_rounded,
                      color: Colors.white70, size: 60),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Contact options
            const Text('Contact Us',
                style: TextStyle(
                    color: textDark,
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 2.2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: contactOptions.map((opt) {
                final color = opt['color'] as Color;
                final bg = opt['bg'] as Color;
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: bgCard,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(opt['icon'] as IconData,
                            color: color, size: 20),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Text(opt['title'] as String,
                                style: const TextStyle(
                                    color: textDark,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                            Text(opt['subtitle'] as String,
                                style: const TextStyle(
                                    color: textLight,
                                    fontSize: 10),
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // FAQs
            const Text('Frequently Asked Questions',
                style: TextStyle(
                    color: textDark,
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: bgCard,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: faqs.asMap().entries.map((entry) {
                  final i = entry.key;
                  final faq = entry.value;
                  final isOpen = selectedFAQ == i;
                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () => setState(
                            () => selectedFAQ = isOpen ? null : i),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(faq['q'] as String,
                                    style: TextStyle(
                                        color: textDark,
                                        fontSize: 13,
                                        fontWeight: isOpen
                                            ? FontWeight.w600
                                            : FontWeight.w500)),
                              ),
                              Icon(
                                isOpen
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons
                                        .keyboard_arrow_down_rounded,
                                color: textLight,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (isOpen)
                        Container(
                          padding: const EdgeInsets.fromLTRB(
                              16, 0, 16, 16),
                          child: Text(faq['a'] as String,
                              style: const TextStyle(
                                  color: textLight, fontSize: 13)),
                        ),
                      if (i < faqs.length - 1)
                        Divider(
                            height: 1,
                            color: Colors.grey.withOpacity(0.1)),
                    ],
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // Send message
            const Text('Send us a Message',
                style: TextStyle(
                    color: textDark,
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            isSubmitted
                ? Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF3DE),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle_rounded,
                            color: Color(0xFF3B6D11), size: 24),
                        SizedBox(width: 12),
                        Text('Message sent! We\'ll respond within 2 hours.',
                            style: TextStyle(
                                color: Color(0xFF3B6D11),
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: bgCard,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: messageController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText:
                                'Describe your issue...',
                            hintStyle: TextStyle(
                                color: textLight, fontSize: 14),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: Colors.grey.shade200),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: Colors.grey.shade200),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: blue),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              if (messageController.text.isNotEmpty) {
                                setState(() => isSubmitted = true);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: blue,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text('Send Message',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}