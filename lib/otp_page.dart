import 'package:flutter/material.dart';


class OtpPage extends StatelessWidget {
Widget _otpField() => Container(
width: 48,
height: 56,
alignment: Alignment.center,
decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
child: TextField(
textAlign: TextAlign.center,
keyboardType: TextInputType.number,
maxLength: 1,
decoration: InputDecoration(counterText: '', border: InputBorder.none),
),
);


@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: IconThemeData(color: Colors.black)),
body: SafeArea(
child: Padding(
padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
child: Column(
children: [
SizedBox(height: 12),
Text('Verify Your Number', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
SizedBox(height: 8),
Text('Enter the 6-digit code sent to +91 ******XXXX', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[700])),
SizedBox(height: 30),
Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(6, (_) => Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: _otpField()))),
SizedBox(height: 20),
Text("Didn't receive code? Resend in 30s", style: TextStyle(color: Colors.grey[600])),
Spacer(),
SizedBox(
width: double.infinity,
child: ElevatedButton(
onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
child: Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Text('Verify')),
),
),
],
),
),
),
);
}
}