import 'package:flutter/material.dart';

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

  // Step 2 - Aadhaar
  final aadhaarController = TextEditingController();
  final aadhaarOTPController = TextEditingController();
  bool otpSent = false;
  bool aadhaarVerified = false;

  // Step 3 - Selfie
  bool selfieUploaded = false;

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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OTP sent to Aadhaar linked mobile!')),
    );
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

  Future<void> uploadSelfie() async {
    setState(() => isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      isLoading = false;
      selfieUploaded = true;
    });
  }

  void nextStep() {
    if (currentStep < 2) {
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C63FF),
        title: const Text('KYC Verification',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Progress Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF6C63FF).withValues(alpha: 0.05),
            child: Row(
              children: List.generate(3, (index) {
                return Expanded(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: index <= currentStep
                            ? const Color(0xFF6C63FF)
                            : Colors.grey.shade300,
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: index <= currentStep
                                ? Colors.white
                                : Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (index < 2)
                        Expanded(
                          child: Container(
                            height: 2,
                            color: index < currentStep
                                ? const Color(0xFF6C63FF)
                                : Colors.grey.shade300,
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
          ),

          // Step Labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StepLabel('Personal', currentStep >= 0),
                _StepLabel('Aadhaar', currentStep >= 1),
                _StepLabel('Selfie', currentStep >= 2),
              ],
            ),
          ),

          // Step Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: [
                _buildPersonalStep(),
                _buildAadhaarStep(),
                _buildSelfieStep(),
              ][currentStep],
            ),
          ),

          // Navigation Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: prevStep,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF6C63FF)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Back',
                          style: TextStyle(color: Color(0xFF6C63FF))),
                    ),
                  ),
                if (currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: currentStep == 2
                        ? () {
                            if (selfieUploaded) {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('KYC Submitted!'),
                                  content: const Text(
                                      'Your KYC is under review. It will be verified within 24 hours.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          }
                        : nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      currentStep == 2 ? 'Submit KYC' : 'Next',
                      style: const TextStyle(
                          fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Personal Details',
            style:
                TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'Full Name (as per Aadhaar)',
            prefixIcon: const Icon(Icons.person),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: dobController,
          decoration: InputDecoration(
            labelText: 'Date of Birth (DD/MM/YYYY)',
            prefixIcon: const Icon(Icons.calendar_today),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Gender',
            style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Row(
          children: ['Male', 'Female', 'Other'].map((g) {
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ChoiceChip(
                label: Text(g),
                selected: selectedGender == g,
                selectedColor: const Color(0xFF6C63FF),
                labelStyle: TextStyle(
                  color: selectedGender == g
                      ? Colors.white
                      : Colors.black,
                ),
                onSelected: (_) =>
                    setState(() => selectedGender = g),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: addressController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Address',
            prefixIcon: const Icon(Icons.location_on),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAadhaarStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Aadhaar Verification',
            style:
                TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Your Aadhaar is linked to UIDAI for verification',
            style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 20),

        if (aadhaarVerified)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green),
            ),
            child: const Row(
              children: [
                Icon(Icons.verified, color: Colors.green),
                SizedBox(width: 8),
                Text('Aadhaar Verified Successfully!',
                    style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          )
        else ...[
          TextField(
            controller: aadhaarController,
            keyboardType: TextInputType.number,
            maxLength: 12,
            decoration: InputDecoration(
              labelText: 'Aadhaar Number',
              prefixIcon: const Icon(Icons.credit_card),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : sendAadhaarOTP,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Send OTP',
                      style: TextStyle(color: Colors.white)),
            ),
          ),
          if (otpSent) ...[
            const SizedBox(height: 16),
            TextField(
              controller: aadhaarOTPController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                labelText: 'Enter OTP',
                prefixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : verifyAadhaarOTP,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Verify OTP',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildSelfieStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Selfie Verification',
            style:
                TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Take a clear selfie for face verification',
            style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 24),

        Center(
          child: GestureDetector(
            onTap: uploadSelfie,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: selfieUploaded
                    ? Colors.green.shade50
                    : const Color(0xFF6C63FF).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(90),
                border: Border.all(
                  color: selfieUploaded
                      ? Colors.green
                      : const Color(0xFF6C63FF),
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    selfieUploaded
                        ? Icons.check_circle
                        : Icons.camera_alt,
                    size: 60,
                    color: selfieUploaded
                        ? Colors.green
                        : const Color(0xFF6C63FF),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    selfieUploaded
                        ? 'Selfie Uploaded!'
                        : 'Tap to take selfie',
                    style: TextStyle(
                      color: selfieUploaded
                          ? Colors.green
                          : const Color(0xFF6C63FF),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        const Text('Instructions:',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _Instruction('Make sure your face is clearly visible'),
        _Instruction('Good lighting is required'),
        _Instruction('Remove glasses if any'),
        _Instruction('Look straight into the camera'),
      ],
    );
  }
}

class _StepLabel extends StatelessWidget {
  final String label;
  final bool isActive;

  const _StepLabel(this.label, this.isActive);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        color: isActive ? const Color(0xFF6C63FF) : Colors.grey,
        fontWeight:
            isActive ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}

class _Instruction extends StatelessWidget {
  final String text;

  const _Instruction(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline,
              color: Color(0xFF6C63FF), size: 18),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}
