import 'package:flutter/material.dart';


class OtpPage extends StatelessWidget {
  const OtpPage({super.key});

  Widget _otpField() => Container(
    width: 48,
    height: 56,
    alignment: Alignment.center,
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
    child: const TextField(
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      maxLength: 1,
      decoration: InputDecoration(counterText: '', border: InputBorder.none),
    ),
  );


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 
                         MediaQuery.of(context).padding.top - 
                         MediaQuery.of(context).padding.bottom - 
                         kToolbarHeight - 24,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    const SizedBox(height: 12),
                    const Text('Verify Your Number', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Enter the 6-digit code sent to +91 ******XXXX', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[700])),
                    const SizedBox(height: 30),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(6, (_) => Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: _otpField()))),
                    const SizedBox(height: 20),
                    Text("Didn't receive code? Resend in 30s", style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                    child: const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Text('Verify')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
