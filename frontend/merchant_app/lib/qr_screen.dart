import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRScreen extends StatelessWidget {
  final String userId;
  final String userName;
  final String phone;

  const QRScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    final qrData = 'obpay://pay?phone=$phone&name=$userName&id=$userId';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        title: const Text('My QR Code',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // QR Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text('Scan to Pay',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A237E))),
                    const SizedBox(height: 20),

                    // QR Code
                    QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      size: 220,
                      backgroundColor: Colors.white,
                    ),

                    const SizedBox(height: 20),

                    // Merchant Info
                    Text(userName,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(phone,
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 16),

                    // OB Pay branding
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A237E),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('OB Pay Business',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Instructions
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('How to receive payment:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    const SizedBox(height: 12),
                    _InstructionTile(
                      number: '1',
                      text: 'Show this QR code to customer',
                    ),
                    _InstructionTile(
                      number: '2',
                      text: 'Customer scans with OB Pay app',
                    ),
                    _InstructionTile(
                      number: '3',
                      text: 'Customer enters amount and pays',
                    ),
                    _InstructionTile(
                      number: '4',
                      text: 'You receive instant notification',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Download Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('QR Code saved to gallery!')),
                  );
                },
                icon: const Icon(Icons.download, color: Colors.white),
                label: const Text('Download QR Code',
                    style: TextStyle(
                        fontSize: 16, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InstructionTile extends StatelessWidget {
  final String number;
  final String text;

  const _InstructionTile({
    required this.number,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: const Color(0xFF1A237E),
            child: Text(number,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}