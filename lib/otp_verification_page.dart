import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

class OtpVerificationPage extends StatefulWidget {
  final String? email; // prefer email-based OTP
  final String phoneNumber;

  const OtpVerificationPage({
    super.key,
    this.email,
    this.phoneNumber = '+91 ******XXXX',
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());
  int _resendTimer = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _otpFocusNodes) {
      node.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendTimer > 0) {
          _resendTimer--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  void _resendOtp() async {
    // Get email from widget or route arguments
    String? email = widget.email;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (email == null && args is Map && args['email'] is String) {
      email = args['email'] as String;
    }
    if (email == null || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Missing email to resend OTP'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_resendTimer > 0) return;

    try {
      await Supabase.instance.client.auth.signInWithOtp(email: email);
      _startResendTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP resent'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to resend OTP: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _verifyOtp() async {
    // Get the OTP entered
    String otp = _otpControllers.map((controller) => controller.text).join();

    // Get email from widget or route arguments
    String? email = widget.email;
    bool isSignup = false;
    
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      if (email == null && args['email'] is String) {
        email = args['email'] as String;
      }
      if (args['isSignup'] == true) {
        isSignup = true;
      }
    }

    // Check if all 6 digits are entered
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter all 6 digits'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (email == null || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Missing email for verification'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final supabase = Supabase.instance.client;

      // Verify the 6-digit OTP
      // If it's a signup verification, use OtpType.signup
      // Otherwise (login), use OtpType.email
      await supabase.auth.verifyOTP(
        type: isSignup ? OtpType.signup : OtpType.magiclink,
        token: otp,
        email: email,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification successful! Please log in.'),
            backgroundColor: Colors.green,
          ),
        );
        // On success, navigate to Sign In
        // On success, navigate based on role and action
        if (args is Map && args['isLawyer'] == true) {
          if (isSignup) {
             Navigator.pushReplacementNamed(context, '/advocate_step1');
          } else {
             Navigator.pushReplacementNamed(context, '/lawyer_dashboard');
          }
        } else {
          Navigator.pushReplacementNamed(context, '/signin');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid or expired OTP: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF101622)
          : const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: isDarkMode
            ? const Color(0xFF101622)
            : const Color(0xFFF7F8FA),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode
                ? const Color(0xFFF7F8FA)
                : const Color(0xFF333333),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'OTP Verification',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.015,
            color: isDarkMode
                ? const Color(0xFFF7F8FA)
                : const Color(0xFF333333),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 48),

                    // Headline Text
                    Text(
                      'Verify Your Email',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                        color: isDarkMode
                            ? const Color(0xFFF7F8FA)
                            : const Color(0xFF333333),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    // Body Text
                    Text(
                      'Enter the 6-digit code sent to',
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: isDarkMode
                            ? const Color(0xFFF7F8FA)
                            : const Color(0xFF333333),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.email ?? 'your email',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode
                            ? const Color(0xFFF7F8FA)
                            : const Color(0xFF333333),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 24),

                    // OTP Input Fields
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(6, (index) {
                        return Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: MediaQuery.of(context).size.width > 400
                                ? 8
                                : 6,
                          ),
                          child: SizedBox(
                            width: 48,
                            height: 56,
                            child: TextField(
                              controller: _otpControllers[index],
                              focusNode: _otpFocusNodes[index],
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode
                                    ? const Color(0xFFF7F8FA)
                                    : const Color(0xFF333333),
                              ),
                              decoration: InputDecoration(
                                counterText: '',
                                filled: false,
                                fillColor: Colors.transparent,
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: isDarkMode
                                        ? const Color(0xFF4A5568)
                                        : const Color(0xFFDBDFE6),
                                    width: 2,
                                  ),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFF1A237E),
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onChanged: (value) {
                                if (value.length == 1) {
                                  if (index < 5) {
                                    _otpFocusNodes[index + 1].requestFocus();
                                  } else {
                                    _otpFocusNodes[index].unfocus();
                                  }
                                }
                              },
                              onTap: () {
                                _otpControllers[index]
                                    .selection = TextSelection.fromPosition(
                                  TextPosition(
                                    offset: _otpControllers[index].text.length,
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 16),

                    // Resend Text
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Didn\'t receive code? ',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF616F89),
                          ),
                        ),
                        GestureDetector(
                          onTap: _resendOtp,
                          child: Text(
                            _resendTimer > 0
                                ? 'Resend in ${_resendTimer}s'
                                : 'Resend',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _resendTimer > 0
                                  ? const Color(
                                      0xFF1A237E,
                                    ).withOpacity(0.5)
                                  : const Color(0xFF1A237E),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Verify Button
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A237E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 24,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 1,
                    ),
                    child: const Text(
                      'Verify',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
