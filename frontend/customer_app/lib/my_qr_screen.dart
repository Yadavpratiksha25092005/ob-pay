import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:gal/gal.dart';
import 'api_service.dart';

class MyQRScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const MyQRScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<MyQRScreen> createState() => _MyQRScreenState();
}

class _MyQRScreenState extends State<MyQRScreen> {
  static const Color purple = Color(0xFF6C63FF);

  final GlobalKey _qrKey = GlobalKey();
  bool _saving = false;
  String _phone = '';
  String _email = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final data = await ApiService.getUser(widget.userId);
    if (data.isNotEmpty && mounted) {
      setState(() {
        _phone = data['phone'] as String? ?? '';
        _email = data['email'] as String? ?? '';
      });
    }
  }

  String get _qrData {
    final upi = _phone.isNotEmpty ? '$_phone@obpay' : '${widget.userId}@obpay';
    return 'upi://pay?pa=$upi&pn=${Uri.encodeComponent(widget.userName)}&cu=INR';
  }

  String get _upiId =>
      _phone.isNotEmpty ? '$_phone@obpay' : '${widget.userId}@obpay';

  Future<void> _saveToGallery() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final boundary =
          _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw Exception('Encoding failed');
      await Gal.putImageBytes(
          byteData.buffer.asUint8List(),
          name: 'obpay_qr_${widget.userName.replaceAll(' ', '_')}.png');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('QR Code saved to gallery!'),
            backgroundColor: Color(0xFF48BB78),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1A202C)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('My QR Code',
            style: TextStyle(
                color: Color(0xFF1A202C),
                fontSize: 18,
                fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // QR Card
            RepaintBoundary(
              key: _qrKey,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Color(0xFF6C63FF), Color(0xFF3D5AF1)]),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('Scan to Pay Me',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 20),

                    // QR
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: purple.withValues(alpha: 0.15), width: 1.5),
                      ),
                      child: QrImageView(
                        data: _qrData,
                        version: QrVersions.auto,
                        size: 200,
                        backgroundColor: Colors.white,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: Color(0xFF6C63FF),
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: Color(0xFF1A202C),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Name
                    Text(widget.userName,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A202C))),
                    if (_email.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(_email,
                          style: const TextStyle(
                              color: Color(0xFF718096), fontSize: 12)),
                    ],
                    const SizedBox(height: 10),

                    // UPI ID chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEEDFE),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.alternate_email_rounded,
                              color: purple, size: 14),
                          const SizedBox(width: 6),
                          Text(_upiId,
                              style: const TextStyle(
                                  color: purple,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // OB Pay branding
                    Text('OB Pay',
                        style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.5)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // How it works
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10)
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('How to receive money:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 12),
                  _step('1', 'Share this QR with the sender'),
                  _step('2', 'They scan it with any UPI app'),
                  _step('3', 'They enter amount and pay'),
                  _step('4', 'Money lands in your OB wallet instantly'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _saveToGallery,
                icon: _saving
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.download_rounded, color: Colors.white),
                label: Text(
                  _saving ? 'Saving...' : 'Save QR to Gallery',
                  style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: purple,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _step(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 13,
            backgroundColor: const Color(0xFFEEEDFE),
            child: Text(number,
                style: const TextStyle(
                    color: purple,
                    fontSize: 11,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}
