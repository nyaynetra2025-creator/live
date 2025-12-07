import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'widgets/animated_widgets.dart';
import 'utils/animation_utils.dart';
import 'services/language_service.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Clean color palette
    final backgroundColor = isDarkMode ? const Color(0xFF121212) : const Color(0xFFF5F5F5);
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textPrimary = isDarkMode ? Colors.white : const Color(0xFF1A1A1A);
    final textSecondary = isDarkMode ? Colors.white70 : const Color(0xFF666666);
    final accentColor = const Color(0xFFE67E22); // Warm orange accent

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            children: [
              const SizedBox(height: 32),

              // Header with logo and app name
              FadeInWidget(
                delay: const Duration(milliseconds: 100),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Hero(
                      tag: HeroTags.logo,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/nyaynetra_logo.png',
                          height: 32,
                          width: 32,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Nyaynetra',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Center illustration
              Expanded(
                child: Center(
                  child: FadeInWidget(
                    delay: const Duration(milliseconds: 300),
                    child: ScaleInWidget(
                      delay: const Duration(milliseconds: 300),
                      curve: Curves.easeOutBack,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 280, maxHeight: 280),
                        child: Lottie.network(
                          'https://lottie.host/5e0c3a89-3f0f-4b0e-9e22-c83e5db67f78/JKlBYpLzPT.json',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.balance_rounded,
                              size: 150,
                              color: isDarkMode ? accentColor : textPrimary,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom section
              Column(
                children: [
                  // Welcome text
                  FadeInWidget(
                    delay: const Duration(milliseconds: 500),
                    child: SlideInWidget(
                      delay: const Duration(milliseconds: 500),
                      direction: AxisDirection.up,
                      offset: 30,
                      child: Text(
                        LanguageService.instance.tr('welcome'),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Subtitle
                  FadeInWidget(
                    delay: const Duration(milliseconds: 600),
                    child: Text(
                      LanguageService.instance.tr('welcome_subtitle'),
                      style: TextStyle(
                        fontSize: 16,
                        color: textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Advocate Button
                  FadeInWidget(
                    delay: const Duration(milliseconds: 700),
                    child: SlideInWidget(
                      delay: const Duration(milliseconds: 700),
                      direction: AxisDirection.up,
                      offset: 20,
                      child: BouncyButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/lawyer_signin');
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: isDarkMode ? accentColor : textPrimary,
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: (isDarkMode ? accentColor : textPrimary).withOpacity(0.25),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            LanguageService.instance.tr('i_am_advocate'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode ? Colors.white : Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Client Button
                  FadeInWidget(
                    delay: const Duration(milliseconds: 800),
                    child: SlideInWidget(
                      delay: const Duration(milliseconds: 800),
                      direction: AxisDirection.up,
                      offset: 20,
                      child: BouncyButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/signin');
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: isDarkMode 
                                  ? Colors.white.withOpacity(0.3) 
                                  : textPrimary.withOpacity(0.2),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            LanguageService.instance.tr('i_am_client'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: textPrimary,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}