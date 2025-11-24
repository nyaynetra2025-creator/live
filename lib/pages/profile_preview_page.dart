import 'dart:io';



import 'package:flutter/material.dart';
import '../utils/registration_manager.dart';
import '../services/supabase_service.dart';

class ProfilePreviewPage extends StatelessWidget {

  const ProfilePreviewPage({Key? key}) : super(key: key);

  // Local uploaded asset (auto-used if exists)

  static const String _localImagePath =

      '/mnt/data/848e5419-acc1-4443-ba1f-77d25cd7f6c8.png';

  // Network fallback (from HTML)

  static const String _networkImage =

      "https://lh3.googleusercontent.com/aida-public/AB6AXuBOMDzFXYqJGwDD8Mvy6HWngh1dREurQYD9AEw5nvzHn-vkkOOUHEm9jU4n-PiknGtwRJIajKOJA6Zw9ku3UmkyI6hcB6ZfRRKVCgRILXWpD8j-Ea7FqBXs7hLTL-ViqV5aqlcF89sB6ObYSLKvCIJUnozoymbP68ehLtyNsvsWmy-WW5EIaTeR4M_ry_lPFVsoncrDqstlYapF8t23Xexw34Yx23GCtMztQ1W4Luh0jMK1-5Y0qyrSPAULG_zEz-yZ3GoAFlK5v_o";

  Color get _primary => const Color(0xFF253D7A);

  Color get _accent => const Color(0xFFF6B21D);

  @override

  Widget build(BuildContext context) {

    final bool hasLocal = File(_localImagePath).existsSync();

    final bool dark = Theme.of(context).brightness == Brightness.dark;

    final Color cardColor = dark ? const Color(0xFF2D303B) : Colors.white;

    final Color subtleText = dark ? const Color(0xFFA1A1AA) : const Color(0xFF8A7D60);
    final manager = RegistrationManager();

    return Scaffold(

      backgroundColor: dark ? const Color(0xFF1A1C23) : const Color(0xFFF8F7F5),

      // Top Bar

      appBar: AppBar(

        backgroundColor: cardColor.withOpacity(0.85),

        centerTitle: true,

        elevation: 0,

        leading: IconButton(

          icon: Icon(Icons.arrow_back, color: dark ? Colors.white : Colors.black),

          onPressed: () => Navigator.pop(context),

        ),

        title: Text(

          "Profile Preview",

          style: TextStyle(

            fontWeight: FontWeight.bold,

            color: dark ? Colors.white : Colors.black,

          ),

        ),

      ),

      // Body

      body: SingleChildScrollView(

        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),

        child: Column(

          children: [

            const SizedBox(height: 10),

            // Progress Dots

            Row(

              mainAxisAlignment: MainAxisAlignment.center,

              children: [

                dot(color: _primary.withOpacity(0.3)),

                const SizedBox(width: 8),

                dot(color: _primary.withOpacity(0.3)),

                const SizedBox(width: 8),

                dot(color: _primary),

              ],

            ),

            const SizedBox(height: 12),

            Text(

              "This is how clients will see your profile.",

              textAlign: TextAlign.center,

              style: TextStyle(fontSize: 14, color: subtleText),

            ),

            const SizedBox(height: 16),

            // Profile Card

            Container(

              width: double.infinity,

              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(

                color: cardColor,

                borderRadius: BorderRadius.circular(18),

                boxShadow: [

                  BoxShadow(

                    color: _primary.withOpacity(0.07),

                    blurRadius: 12,

                    offset: const Offset(0, 6),

                  )

                ],

              ),

              child: Column(

                crossAxisAlignment: CrossAxisAlignment.center,

                children: [

                  // Avatar

                  Container(

                    width: 120,

                    height: 120,

                    decoration: BoxDecoration(

                      shape: BoxShape.circle,

                      border: Border.all(

                        color: _primary.withOpacity(0.1),

                        width: 4,

                      ),

                      image: DecorationImage(

                        fit: BoxFit.cover,

                        image: hasLocal

                            ? FileImage(File(_localImagePath))

                            : NetworkImage(_networkImage) as ImageProvider,

                      ),

                    ),

                  ),

                  const SizedBox(height: 14),

                  // Name

                  Text(
                    manager.name.isNotEmpty ? manager.name : "Aarav Sharma",

                    style: TextStyle(

                      fontSize: 22,

                      fontWeight: FontWeight.bold,

                      color: dark ? _accent : _primary,

                    ),

                  ),

                  const SizedBox(height: 6),

                  Text(

                    "Criminal Defense Advocate",

                    style: TextStyle(fontSize: 14, color: subtleText),

                  ),

                  const SizedBox(height: 14),

                  // Languages

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: manager.languages.isNotEmpty 
                        ? manager.languages.map((l) => langChip(l)).toList()
                        : [
                            langChip("English"),
                            langChip("Hindi"),
                            langChip("Marathi"),
                          ],
                  ),
                  
                  const SizedBox(height: 20),

                  divider(dark),

                  const SizedBox(height: 16),

                  // Available Hours

                  infoTile(

                    icon: Icons.schedule,

                    title: "Available Hours",

                    value: "${manager.availableDays.join(', ')}, ${manager.availableTimeStart} - ${manager.availableTimeEnd}",

                    subtle: subtleText,

                  ),

                  const SizedBox(height: 16),

                  // Location

                  infoTile(

                    icon: Icons.location_on,

                    title: "Location",

                    value: manager.location.isNotEmpty ? manager.location : "Mumbai, Maharashtra",

                    subtle: subtleText,

                  ),

                  const SizedBox(height: 20),

                  divider(dark),

                  const SizedBox(height: 16),

                  // About

                  Align(

                    alignment: Alignment.centerLeft,

                    child: Text(

                      "About",

                      style: TextStyle(

                        fontSize: 18,

                        color: dark ? _accent : _primary,

                        fontWeight: FontWeight.bold,

                      ),

                    ),

                  ),

                  const SizedBox(height: 8),

                  const Text(

                    "With over 10 years of experience, I specialize in criminal law and am dedicated to providing robust legal representation. My focus is on ensuring justice for my clients through meticulous case preparation and a compassionate approach.",

                    style: TextStyle(height: 1.6, fontSize: 14),

                  ),

                ],

              ),

            ),

          ],

        ),

      ),

      // Bottom Buttons

      bottomNavigationBar: Container(

        padding: const EdgeInsets.all(16),

        height: 100,

        decoration: BoxDecoration(

          color: cardColor.withOpacity(0.85),

          border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.3))),

        ),

        child: Row(

          children: [

            Expanded(

              child: OutlinedButton(

                style: OutlinedButton.styleFrom(

                  padding: const EdgeInsets.symmetric(vertical: 16),

                  side: BorderSide(color: _primary),

                  shape: RoundedRectangleBorder(

                      borderRadius: BorderRadius.circular(14)),

                ),

                onPressed: () => Navigator.pop(context),

                child: Text(

                  "Edit",

                  style: TextStyle(

                      fontWeight: FontWeight.bold, color: _primary),

                ),

              ),

            ),

            const SizedBox(width: 12),

            Expanded(

              child: ElevatedButton(

                style: ElevatedButton.styleFrom(

                  backgroundColor: _accent,

                  padding: const EdgeInsets.symmetric(vertical: 16),

                  shape: RoundedRectangleBorder(

                      borderRadius: BorderRadius.circular(14)),

                ),

                onPressed: () async {
                  try {
                    await SupabaseService().saveAdvocateProfile(
                      name: manager.name,
                      email: manager.email,
                      gender: manager.gender,
                      languages: manager.languages,
                      location: manager.location,
                      fee: manager.fee,
                      availableDays: manager.availableDays,
                      availableTimeStart: manager.availableTimeStart,
                      availableTimeEnd: manager.availableTimeEnd,
                      onlineConsult: manager.onlineConsult,
                      inPersonConsult: manager.inPersonConsult,
                    );
                    
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/lawyer_dashboard',
                        (route) => false,
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error saving profile: $e')),
                      );
                    }
                  }
                },

                child: Text(

                  "Finish Setup",

                  style: TextStyle(

                    fontWeight: FontWeight.bold,

                    color: Colors.black87,

                  ),

                ),

              ),

            ),

          ],

        ),

      ),

    );

  }

  // --- Reusable Widgets ---

  Widget dot({required Color color}) {

    return Container(

      width: 10,

      height: 10,

      decoration: BoxDecoration(color: color, shape: BoxShape.circle),

    );

  }

  Widget langChip(String text) {

    return Container(

      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),

      decoration: BoxDecoration(

        color: _primary.withOpacity(0.1),

        borderRadius: BorderRadius.circular(50),

      ),

      child: Text(

        text,

        style: TextStyle(

          color: _primary,

          fontWeight: FontWeight.w600,

        ),

      ),

    );

  }

  Widget infoTile({

    required IconData icon,

    required String title,

    required String value,

    required Color subtle,

  }) {

    return Row(

      children: [

        Container(

          width: 44,

          height: 44,

          decoration: BoxDecoration(

            color: _primary.withOpacity(0.1),

            borderRadius: BorderRadius.circular(12),

          ),

          child: Icon(icon, color: _primary),

        ),

        const SizedBox(width: 12),

        Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Text(title, style: TextStyle(color: subtle, fontSize: 13)),

            const SizedBox(height: 4),

            Text(value,

                style:

                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),

          ],

        ),

      ],

    );

  }

  Widget divider(bool dark) {

    return Container(

      height: 1,

      color: dark ? Colors.grey.shade700 : Colors.grey.shade300,

    );

  }

}

