import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'wallet_screen.dart';

class QRScannerScreen extends StatefulWidget {
  final String userId;

  const QRScannerScreen({super.key, required this.userId});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool isScanned = false;
  bool isTorchOn = false;
  final upiController = TextEditingController();

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void onDetect(BarcodeCapture capture) {
    if (isScanned) return;
    final barcode = capture.barcodes.first;
    if (barcode.rawValue != null) {
      setState(() => isScanned = true);
      HapticFeedback.heavyImpact();
      final value = barcode.rawValue!;
      // Extract phone number from UPI QR
      String phone = value;
      if (value.contains('pa=')) {
        phone = value.split('pa=')[1].split('&')[0];
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => WalletScreen(
            userId: widget.userId,
            receiverPhone: phone,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Scan & Pay',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        actions: [
          // Torch
          IconButton(
            icon: Icon(
              isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
              color: isTorchOn ? Colors.yellow : Colors.white,
            ),
            onPressed: () {
              cameraController.toggleTorch();
              setState(() => isTorchOn = !isTorchOn);
            },
          ),
          // Gallery
          IconButton(
            icon: const Icon(Icons.image_rounded, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera
          MobileScanner(
            controller: cameraController,
            onDetect: onDetect,
          ),

          // Dark overlay with hole
          CustomPaint(
            size: Size.infinite,
            painter: _ScannerOverlayPainter(),
          ),

          // Corner brackets
          Center(
            child: SizedBox(
              width: 260,
              height: 260,
              child: Stack(
                children: [
                  // Top left
                  Positioned(
                    top: 0, left: 0,
                    child: _corner(topLeft: true),
                  ),
                  // Top right
                  Positioned(
                    top: 0, right: 0,
                    child: _corner(topRight: true),
                  ),
                  // Bottom left
                  Positioned(
                    bottom: 0, left: 0,
                    child: _corner(bottomLeft: true),
                  ),
                  // Bottom right
                  Positioned(
                    bottom: 0, right: 0,
                    child: _corner(bottomRight: true),
                  ),
                ],
              ),
            ),
          ),

          // Scan text
          Positioned(
            bottom: 200,
            left: 0, right: 0,
            child: const Text(
              'Scan any QR code to pay',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500),
            ),
          ),

          // Bottom sheet — OR ENTER UPI ID
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('OR ENTER UPI ID',
                            style: TextStyle(
                                color: Colors.black45,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5)),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () => _showEnterUPI(),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F0FF),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.3)),
                      ),
                      child: const Text(
                        'Enter UPI ID / Mobile Number',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color(0xFF6C63FF),
                            fontSize: 15,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _corner({
    bool topLeft = false,
    bool topRight = false,
    bool bottomLeft = false,
    bool bottomRight = false,
  }) {
    return SizedBox(
      width: 30,
      height: 30,
      child: CustomPaint(
        painter: _CornerPainter(
          topLeft: topLeft,
          topRight: topRight,
          bottomLeft: bottomLeft,
          bottomRight: bottomRight,
        ),
      ),
    );
  }

  void _showEnterUPI() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter UPI ID / Mobile Number',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: upiController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: 'e.g. 9876543210 or name@obpay',
                prefixIcon: const Icon(Icons.alternate_email_rounded,
                    color: Color(0xFF6C63FF)),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF6C63FF), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (upiController.text.isNotEmpty) {
                    Navigator.pop(ctx);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WalletScreen(
                          userId: widget.userId,
                          receiverPhone: upiController.text,
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text('Proceed',
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
}

// Dark overlay with transparent center
class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.6);
    const scanSize = 260.0;
    final left = (size.width - scanSize) / 2;
    final top = (size.height - scanSize) / 2 - 60;

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, scanSize, scanSize),
          const Radius.circular(16)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Blue corner brackets
class _CornerPainter extends CustomPainter {
  final bool topLeft, topRight, bottomLeft, bottomRight;

  const _CornerPainter({
    this.topLeft = false,
    this.topRight = false,
    this.bottomLeft = false,
    this.bottomRight = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF6C63FF)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const len = 28.0;

    if (topLeft) {
      canvas.drawLine(Offset.zero, Offset(len, 0), paint);
      canvas.drawLine(Offset.zero, Offset(0, len), paint);
    }
    if (topRight) {
      canvas.drawLine(Offset(size.width, 0), Offset(size.width - len, 0), paint);
      canvas.drawLine(Offset(size.width, 0), Offset(size.width, len), paint);
    }
    if (bottomLeft) {
      canvas.drawLine(Offset(0, size.height), Offset(len, size.height), paint);
      canvas.drawLine(Offset(0, size.height), Offset(0, size.height - len), paint);
    }
    if (bottomRight) {
      canvas.drawLine(Offset(size.width, size.height), Offset(size.width - len, size.height), paint);
      canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - len), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}