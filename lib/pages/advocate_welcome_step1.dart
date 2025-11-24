import 'dart:io';

import 'package:flutter/material.dart';

/// Advocate Welcome — Step 1 of 3

/// - Uses a local image if present at /mnt/data/848e5419-acc1-4443-ba1f-77d25cd7f6c8.png

/// - Falls back to the original network image if the local file is not available.

///

/// Save this file as: lib/pages/advocate_welcome_step1.dart

class AdvocateWelcomeStep1 extends StatelessWidget {
  const AdvocateWelcomeStep1({Key? key}) : super(key: key);

  // Local file path from the conversation history (developer-provided).

  // The runtime environment that runs this Flutter app may not have this path;

  // in that case the code will fall back to the network image.

  static const String _localImagePath =
      '/mnt/data/848e5419-acc1-4443-ba1f-77d25cd7f6c8.png';

  // Original network fallback (kept from the HTML)

  static const String _networkImage =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDmwOT8_u5Ms4ZKTSB26G5UsC8xPllw8cV0X_R9tByajFnigFx6IhQC7-BYTp5VnDUJKD7iJ4dD33-Ni5P0NvYDDMLL_wHdKw6pVU1QQvpBGOm-vBTJkoBBp7Os9nKlx87vaOle09DxoEaMVjDFmQR2AEj1LnWRcT2mQUebGWNJ05Is4gYLrEQvXgG38Eqz-CK4TP5ZU-p0gt-zJiijW25xQ9A5xZVn2Ip5OzhMuG0zeTBagRSuoK7plRWH7slOPPvN7Gm9v-Xu0HA';

  Color get _primary => const Color(0xFF253D7A); // deep indigo / secondary in HTML

  Color get _accent => const Color(0xFFF6B11E); // warm amber (primary/cta)

  @override
  Widget build(BuildContext context) {
    final bool hasLocalImage = File(_localImagePath).existsSync();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F5), // background-light from HTML

      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // Top bar: Step indicator (left aligned)
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  'Step 1 of 3',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _primary, // HTML used secondary as text color for this
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Main content (image + heading + subtitle)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Illustration (uses local file if available)
                    SizedBox(
                      width: 260,
                      height: 260,
                      child: hasLocalImage
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(_localImagePath),
                                fit: BoxFit.contain,
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                _networkImage,
                                fit: BoxFit.contain,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return Center(
                                      child: CircularProgressIndicator(
                                    value: progress.expectedTotalBytes != null
                                        ? progress.cumulativeBytesLoaded /
                                            (progress.expectedTotalBytes ?? 1)
                                        : null,
                                    color: _primary,
                                  ));
                                },
                                errorBuilder: (c, e, s) => Center(
                                  child: Icon(
                                    Icons.gavel,
                                    size: 80,
                                    color: _primary.withOpacity(0.15),
                                  ),
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 28),
                    // Title
                    Text(
                      'Welcome, Advocate!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: _primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Subtitle
                    Text(
                      'Let\'s set up your profile.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Page indicators
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 36,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _primary.withOpacity(0.22),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _primary.withOpacity(0.22),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Primary CTA button - Continue
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: _primary,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushNamed('/personal_details');
                    },
                    child: const Text(
                      'Continue',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}

