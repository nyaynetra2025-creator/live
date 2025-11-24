import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'widgets/animated_widgets.dart';
import 'utils/animation_utils.dart';
import 'utils/custom_page_transitions.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: AnimatedGradientContainer(
        colors: isDarkMode
            ? [
                const Color(0xFF191919),
                const Color(0xFF2D2D2D),
                const Color(0xFF191919),
              ]
            : [
                const Color(0xFFF7F7F7),
                const Color(0xFFE8E8E8),
                const Color(0xFFF7F7F7),
              ],
        duration: const Duration(seconds: 5),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                // Logo and Title with fade-in animation
                FadeInWidget(
                  delay: const Duration(milliseconds: 200),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Hero(
                          tag: HeroTags.logo,
                          child: Image.asset(
                            'assets/images/nyaynetra_logo.png',
                            height: 36,
                            width: 36,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Nyaynetra',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode
                                ? Colors.white
                                : const Color(0xFF1A1A1A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Center Animation with scale and float
                Expanded(
                  child: Center(
                    child: ScaleInWidget(
                      delay: const Duration(milliseconds: 400),
                      duration: AnimationDurations.slow,
                      curve: AnimationCurves.bouncy,
                      child: FloatingWidget(
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 320),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Lottie.network(
                              'https://lottie.host/5e0c3a89-3f0f-4b0e-9e22-c83e5db67f78/JKlBYpLzPT.json',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return PulsingWidget(
                                  child: Icon(
                                    Icons.smart_toy_outlined,
                                    size: 200,
                                    color: isDarkMode
                                        ? const Color(0xFFF39C12)
                                        : const Color(0xFF1A1A1A),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom Section with staggered animations
                Column(
                  children: [
                    SlideInWidget(
                      delay: const Duration(milliseconds: 600),
                      direction: AxisDirection.up,
                      child: FadeInWidget(
                        delay: const Duration(milliseconds: 600),
                        child: Text(
                          'Welcome to Nyaynetra',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode
                                ? const Color(0xFFF5F5F5)
                                : const Color(0xFF333333),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SlideInWidget(
                      delay: const Duration(milliseconds: 750),
                      direction: AxisDirection.up,
                      child: FadeInWidget(
                        delay: const Duration(milliseconds: 750),
                        child: Text(
                          'Your Legal Companion.',
                          style: TextStyle(
                            fontSize: 16,
                            color: isDarkMode
                                ? const Color(0xFFF5F5F5).withOpacity(0.8)
                                : const Color(0xFF333333).withOpacity(0.8),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Buttons with staggered animations
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        children: [
                          SlideInWidget(
                            delay: const Duration(milliseconds: 900),
                            direction: AxisDirection.up,
                            child: FadeInWidget(
                              delay: const Duration(milliseconds: 900),
                              child: SizedBox(
                                width: double.infinity,
                                child: BouncyButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/lawyer_signin');
                                  },
                                  child: ElevatedButton(
                                    onPressed: null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isDarkMode
                                          ? const Color(0xFFF39C12)
                                          : const Color(0xFF1A1A1A),
                                      foregroundColor: isDarkMode
                                          ? const Color(0xFF1A1A1A)
                                          : Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                        horizontal: 24,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(9999),
                                      ),
                                      elevation: 2,
                                    ),
                                    child: const Text(
                                      'Advocate',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SlideInWidget(
                            delay: const Duration(milliseconds: 1050),
                            direction: AxisDirection.up,
                            child: FadeInWidget(
                              delay: const Duration(milliseconds: 1050),
                              child: SizedBox(
                                width: double.infinity,
                                child: BouncyButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/signin');
                                  },
                                  child: OutlinedButton(
                                    onPressed: null,
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: isDarkMode
                                          ? const Color(0xFFF39C12)
                                          : const Color(0xFF1A1A1A),
                                      side: BorderSide(
                                        color: isDarkMode
                                            ? const Color(0xFFF39C12).withOpacity(0.5)
                                            : const Color(0xFF1A1A1A).withOpacity(0.5),
                                        width: 2,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                        horizontal: 24,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(9999),
                                      ),
                                      backgroundColor: Colors.transparent,
                                    ),
                                    child: const Text(
                                      'Client',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
