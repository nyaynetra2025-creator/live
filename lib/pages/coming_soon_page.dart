import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../widgets/animated_widgets.dart';
import '../utils/animation_utils.dart';
import 'package:shimmer/shimmer.dart';

class ComingSoonPage extends StatelessWidget {
  final String title;

  const ComingSoonPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF14171E) : const Color(0xFFF6F7F8),
      appBar: AppBar(
        title: Text(title),
        backgroundColor: isDarkMode ? const Color(0xFF14171E) : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : const Color(0xFF121317),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated floating icon
              FloatingWidget(
                child: PulsingWidget(
                  child: ScaleInWidget(
                    delay: const Duration(milliseconds: 200),
                    curve: AnimationCurves.bouncy,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: (isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79))
                            .withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.construction,
                        size: 80,
                        color: isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              
              // Animated "Coming Soon" text
              FadeInWidget(
                delay: const Duration(milliseconds: 400),
                child: SlideInWidget(
                  delay: const Duration(milliseconds: 400),
                  direction: AxisDirection.up,
                  child: DefaultTextStyle(
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : const Color(0xFF121317),
                    ),
                    child: AnimatedTextKit(
                      animatedTexts: [
                        TypewriterAnimatedText(
                          'Coming Soon',
                          speed: const Duration(milliseconds: 150),
                        ),
                      ],
                      totalRepeatCount: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Subtitle with fade-in
              FadeInWidget(
                delay: const Duration(milliseconds: 800),
                child: SlideInWidget(
                  delay: const Duration(milliseconds: 800),
                  direction: AxisDirection.up,
                  child: Text(
                    'This feature is currently under development.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? const Color(0xFF9CA3AF) : const Color(0xFF687082),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              
              // Development progress indicator with shimmer
              FadeInWidget(
                delay: const Duration(milliseconds: 1000),
                child: Column(
                  children: [
                    Text(
                      'Development Progress',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? const Color(0xFF9CA3AF) : const Color(0xFF687082),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: 250,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: 0.65,
                          minHeight: 8,
                          backgroundColor: isDarkMode
                              ? const Color(0xFF374151)
                              : const Color(0xFFE5E7EB),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Shimmer.fromColors(
                      baseColor: isDarkMode ? const Color(0xFF9CA3AF) : const Color(0xFF687082),
                      highlightColor: isDarkMode ? Colors.white : const Color(0xFF1F2937),
                      child: const Text(
                        '65% Complete',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              
              // Animated back button
              ScaleInWidget(
                delay: const Duration(milliseconds: 1200),
                curve: AnimationCurves.bouncy,
                child: BouncyButton(
                  onPressed: () => Navigator.pop(context),
                  child: ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF253D79),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      'Go Back',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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
