import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> with SingleTickerProviderStateMixin {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleSignUp() async {
    // Validate input fields
    if (_fullNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your full name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final password = _passwordController.text;
    if (password.isEmpty || password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;

      // Create account with email + password
      await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': _fullNameController.text.trim(), 'role': 'client'},
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign up successful! Please verify your email.')),
        );

        // Navigate to OTP Verification Page
        Navigator.pushNamed(
          context, 
          '/otp', 
          arguments: {'email': email, 'isSignup': true}
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign up failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF14171E)
          : const Color(0xFFF6F7F8),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 448),
                  child: Column(
                    children: [
                      // Header
                      Column(
                        children: [
                          Hero(
                            tag: 'app_logo',
                            child: Container(
                              height: 48,
                              width: 48,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF6B21D), // Accent color
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.gavel,
                                color: Color(0xFF253D79), // Primary color
                                size: 28,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nyaynetra',
                            style: TextStyle(
                              fontSize: isTablet ? 32 : 28,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode
                                  ? Colors.white
                                  : const Color(0xFF253D79),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Create Your Account',
                            style: TextStyle(
                              fontSize: isTablet ? 26 : 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                              color: isDarkMode
                                  ? const Color(0xFFE5E7EB)
                                  : const Color(0xFF121317),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please enter your details to sign up.',
                            style: TextStyle(
                              fontSize: isTablet ? 18 : 16,
                              color: isDarkMode
                                  ? const Color(0xFF9CA3AF)
                                  : const Color(0xFF687082),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Sign Up Form
                      // Full Name Field
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _fullNameController,
                          style: TextStyle(
                            fontSize: isTablet ? 18 : 16,
                            color: isDarkMode
                                ? const Color(0xFFE5E7EB)
                                : const Color(0xFF121317),
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: isDarkMode ? const Color(0xFF14171E) : Colors.white,
                            hintText: 'Full Name',
                            hintStyle: TextStyle(
                              color: isDarkMode
                                  ? const Color(0xFF9CA3AF)
                                  : const Color(0xFF687082),
                            ),
                            prefixIcon: Icon(
                              Icons.person_outline,
                              color: isDarkMode
                                  ? const Color(0xFF9CA3AF)
                                  : const Color(0xFF687082),
                            ),
                            contentPadding: EdgeInsets.all(isTablet ? 18 : 15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isDarkMode
                                    ? const Color(0xFF374151)
                                    : const Color(0xFFDDDFE4),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isDarkMode
                                    ? const Color(0xFF374151)
                                    : const Color(0xFFDDDFE4),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isDarkMode
                                    ? const Color(0xFFF6B21D)
                                    : const Color(0xFF253D79),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Email Field
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(
                            fontSize: isTablet ? 18 : 16,
                            color: isDarkMode
                                ? const Color(0xFFE5E7EB)
                                : const Color(0xFF121317),
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: isDarkMode ? const Color(0xFF14171E) : Colors.white,
                            hintText: 'Email Address',
                            hintStyle: TextStyle(
                              color: isDarkMode
                                  ? const Color(0xFF9CA3AF)
                                  : const Color(0xFF687082),
                            ),
                            prefixIcon: Icon(
                              Icons.mail_outline,
                              color: isDarkMode
                                  ? const Color(0xFF9CA3AF)
                                  : const Color(0xFF687082),
                            ),
                            contentPadding: EdgeInsets.all(isTablet ? 18 : 15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isDarkMode
                                    ? const Color(0xFF374151)
                                    : const Color(0xFFDDDFE4),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isDarkMode
                                    ? const Color(0xFF374151)
                                    : const Color(0xFFDDDFE4),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isDarkMode
                                    ? const Color(0xFFF6B21D)
                                    : const Color(0xFF253D79),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Password Field
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _passwordController,
                          obscureText: true,
                          style: TextStyle(
                            fontSize: isTablet ? 18 : 16,
                            color: isDarkMode
                                ? const Color(0xFFE5E7EB)
                                : const Color(0xFF121317),
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: isDarkMode ? const Color(0xFF14171E) : Colors.white,
                            hintText: 'New Password',
                            hintStyle: TextStyle(
                              color: isDarkMode
                                  ? const Color(0xFF9CA3AF)
                                  : const Color(0xFF687082),
                            ),
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: isDarkMode
                                  ? const Color(0xFF9CA3AF)
                                  : const Color(0xFF687082),
                            ),
                            contentPadding: EdgeInsets.all(isTablet ? 18 : 15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isDarkMode
                                    ? const Color(0xFF374151)
                                    : const Color(0xFFDDDFE4),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isDarkMode
                                    ? const Color(0xFF374151)
                                    : const Color(0xFFDDDFE4),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isDarkMode
                                    ? const Color(0xFFF6B21D)
                                    : const Color(0xFF253D79),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Sign Up Button
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleSignUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF253D79),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                vertical: isTablet ? 20 : 16,
                                horizontal: 24,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'Sign Up',
                                    style: TextStyle(
                                      fontSize: isTablet ? 18 : 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Log In Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: TextStyle(
                              fontSize: isTablet ? 16 : 14,
                              color: isDarkMode
                                  ? const Color(0xFF9CA3AF)
                                  : const Color(0xFF687082),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // Navigate to login page
                              Navigator.pushReplacementNamed(context, '/signin');
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Log In',
                              style: TextStyle(
                                fontSize: isTablet ? 16 : 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFF6B21D),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

