// lib/pages/personal_details.dart



// Copy–paste this file into your Flutter project (save as lib/pages/personal_details.dart).

// This uses a local image present in the conversation: /mnt/data/848e5419-acc1-4443-ba1f-77d25cd7f6c8.png

// If that file isn't available at runtime the widget will silently fall back to a placeholder icon.

import 'dart:io';

import 'package:flutter/material.dart';
import '../utils/registration_manager.dart';

class PersonalDetailsPage extends StatefulWidget {

  const PersonalDetailsPage({Key? key}) : super(key: key);

  @override

  State<PersonalDetailsPage> createState() => _PersonalDetailsPageState();

}

class _PersonalDetailsPageState extends State<PersonalDetailsPage> {

  final TextEditingController _nameCtrl = TextEditingController();

  final TextEditingController _emailCtrl =

      TextEditingController(text: 'lawyer.name@example.com');

  String _gender = 'Select';

  final List<String> _languages = [

    'English',

    'Hindi',

    'Tamil',

    'Marathi',

    'Bengali'

  ];

  final Set<String> _selectedLangs = {'English'};

  // Local image path (from your uploaded file)

  static const String _localImagePath =

      '/mnt/data/848e5419-acc1-4443-ba1f-77d25cd7f6c8.png';

  Color get _primary => const Color(0xFF253D7A);

  Color get _cta => const Color(0xFFF6B21D);

  Color get _accent => const Color(0xFF4263EB);

  Color get _borderLight => const Color(0xFFE5E7EB);

  @override

  void dispose() {

    _nameCtrl.dispose();

    _emailCtrl.dispose();

    super.dispose();

  }

  void _toggleLanguage(String lang) {

    setState(() {

      if (_selectedLangs.contains(lang)) {

        _selectedLangs.remove(lang);

      } else {

        _selectedLangs.add(lang);

      }

    });

  }

  @override

  Widget build(BuildContext context) {

    final bool localImageExists = File(_localImagePath).existsSync();

    return Scaffold(

      backgroundColor: const Color(0xFFF6F7F8), // background-light

      body: SafeArea(

        child: Column(

          children: [

            // Top app bar area

            Container(

              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

              color: Colors.transparent,

              child: Row(

                children: [

                  IconButton(

                      onPressed: () => Navigator.of(context).maybePop(),

                      icon: Icon(Icons.arrow_back, color: const Color(0xFF1F2937))),

                  const Expanded(

                    child: Center(

                      child: Text(

                        'Personal Details',

                        style: TextStyle(

                            fontSize: 17,

                            fontWeight: FontWeight.w600,

                            color: Color(0xFF1F2937)),

                      ),

                    ),

                  ),

                  const SizedBox(width: 48), // placeholder for symmetry

                ],

              ),

            ),

            // Progress bars row

            Padding(

              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),

              child: Row(

                children: [

                  Expanded(

                      child: Container(

                    height: 8,

                    decoration: BoxDecoration(

                        color: _primary, borderRadius: BorderRadius.circular(8)),

                  )),

                  const SizedBox(width: 8),

                  Expanded(

                      child: Container(

                    height: 8,

                    decoration: BoxDecoration(

                        color: _borderLight, borderRadius: BorderRadius.circular(8)),

                  )),

                  const SizedBox(width: 8),

                  Expanded(

                      child: Container(

                    height: 8,

                    decoration: BoxDecoration(

                        color: _borderLight, borderRadius: BorderRadius.circular(8)),

                  )),

                  const SizedBox(width: 8),

                  Expanded(

                      child: Container(

                    height: 8,

                    decoration: BoxDecoration(

                        color: _borderLight, borderRadius: BorderRadius.circular(8)),

                  )),

                ],

              ),

            ),

            // Content

            Expanded(

              child: SingleChildScrollView(

                padding:

                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    const SizedBox(height: 6),

                    const Text(

                      "Let's start with the basics.",

                      style: TextStyle(

                        fontSize: 28,

                        fontWeight: FontWeight.bold,

                        // color set below with default primary if needed

                      ),

                    ),

                    const SizedBox(height: 18),

                    // Full Name

                    const Text(

                      'Full Name',

                      style: TextStyle(

                        fontWeight: FontWeight.w600,

                        color: Color(0xFF1F2937),

                      ),

                    ),

                    const SizedBox(height: 8),

                    Container(

                      decoration: BoxDecoration(

                        color: Colors.white,

                        borderRadius: BorderRadius.circular(12),

                        border: Border.all(color: _borderLight),

                      ),

                      child: Row(

                        children: [

                          Padding(

                            padding: const EdgeInsets.symmetric(horizontal: 12),

                            child: Icon(Icons.person, color: _accent),

                          ),

                          Expanded(

                            child: TextField(

                              controller: _nameCtrl,

                              decoration: const InputDecoration(

                                border: InputBorder.none,

                                hintText: 'Enter your full name',

                                isDense: true,

                                contentPadding: EdgeInsets.symmetric(vertical: 16),

                              ),

                            ),

                          ),

                        ],

                      ),

                    ),

                    const SizedBox(height: 16),

                    // Email readonly

                    const Text(

                      'Email',

                      style: TextStyle(

                        fontWeight: FontWeight.w600,

                        color: Color(0xFF1F2937),

                      ),

                    ),

                    const SizedBox(height: 8),

                    Container(

                      decoration: BoxDecoration(

                        color: const Color(0xFFF6F7F8),

                        borderRadius: BorderRadius.circular(12),

                        border: Border.all(color: _borderLight),

                      ),

                      child: Row(

                        children: [

                          Padding(

                            padding: const EdgeInsets.symmetric(horizontal: 12),

                            child: Icon(Icons.mail, color: _accent),

                          ),

                          Expanded(

                            child: TextField(

                              controller: _emailCtrl,

                              readOnly: true,

                              decoration: const InputDecoration(

                                border: InputBorder.none,

                                isDense: true,

                                contentPadding: EdgeInsets.symmetric(vertical: 16),

                              ),

                              style: const TextStyle(color: Color(0xFF6B7280)),

                            ),

                          ),

                        ],

                      ),

                    ),

                    const SizedBox(height: 16),

                    // Gender select

                    const Text(

                      'Gender (Optional)',

                      style: TextStyle(

                        fontWeight: FontWeight.w600,

                        color: Color(0xFF1F2937),

                      ),

                    ),

                    const SizedBox(height: 8),

                    Container(

                      decoration: BoxDecoration(

                        color: Colors.white,

                        borderRadius: BorderRadius.circular(12),

                        border: Border.all(color: _borderLight),

                      ),

                      child: Row(

                        children: [

                          Padding(

                            padding: const EdgeInsets.symmetric(horizontal: 12),

                            child: Icon(Icons.wc, color: _accent),

                          ),

                          Expanded(

                            child: DropdownButtonHideUnderline(

                              child: DropdownButton<String>(

                                value: _gender,

                                items: <String>[

                                  'Select',

                                  'Male',

                                  'Female',

                                  'Prefer not to say'

                                ].map((s) {

                                  return DropdownMenuItem(

                                    value: s,

                                    child: Text(s,

                                        style: const TextStyle(

                                            color: Color(0xFF1F2937))),

                                  );

                                }).toList(),

                                onChanged: (v) {

                                  if (v == null) return;

                                  setState(() {

                                    _gender = v;

                                  });

                                },

                                isExpanded: true,

                                icon: const Padding(

                                  padding: EdgeInsets.only(right: 12),

                                  child: Icon(Icons.expand_more,

                                      color: Color(0xFF6B7280)),

                                ),

                                style: const TextStyle(

                                    fontSize: 16, color: Color(0xFF1F2937)),

                              ),

                            ),

                          ),

                        ],

                      ),

                    ),

                    const SizedBox(height: 16),

                    // Languages

                    const Text(

                      'Languages Spoken',

                      style: TextStyle(

                        fontWeight: FontWeight.w600,

                        color: Color(0xFF1F2937),

                      ),

                    ),

                    const SizedBox(height: 10),

                    Wrap(

                      spacing: 8,

                      runSpacing: 8,

                      children: _languages.map((lang) {

                        final bool selected = _selectedLangs.contains(lang);

                        return ChoiceChip(

                          label: Text(

                            lang,

                            style: TextStyle(

                                color: selected ? Colors.white : const Color(0xFF6B7280)),

                          ),

                          selected: selected,

                          onSelected: (_) => _toggleLanguage(lang),

                          selectedColor: _primary,

                          backgroundColor: Colors.white,

                          shape: RoundedRectangleBorder(

                              side: BorderSide(

                                  color: selected ? _primary : _borderLight),

                              borderRadius: BorderRadius.circular(999)),

                          labelPadding: const EdgeInsets.symmetric(horizontal: 12),

                        );

                      }).toList(),

                    ),

                    const SizedBox(height: 24),

                    // Local image preview from uploaded file (shown below form)

                    if (localImageExists) ...[

                      const SizedBox(height: 8),

                      Text('Preview (uploaded image):',

                          style: TextStyle(

                              color: _primary, fontWeight: FontWeight.w600)),

                      const SizedBox(height: 8),

                      ClipRRect(

                        borderRadius: BorderRadius.circular(12),

                        child: Image.file(File(_localImagePath),

                            width: double.infinity, height: 180, fit: BoxFit.cover),

                      ),

                    ],

                    const SizedBox(height: 24),

                  ],

                ),

              ),

            ),

            // Sticky Next button

            Container(

              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

              color: const Color(0xFFF6F7F8),

              child: SizedBox(

                width: double.infinity,

                height: 56,

                child: ElevatedButton(

                  style: ElevatedButton.styleFrom(

                    backgroundColor: _cta,

                    foregroundColor: _primary,

                    shape: RoundedRectangleBorder(

                      borderRadius: BorderRadius.circular(12),

                    ),

                  ),

                  onPressed: () {

                    // Validate and navigate to next onboarding step

                    if (_nameCtrl.text.trim().isEmpty) {

                      ScaffoldMessenger.of(context).showSnackBar(

                        const SnackBar(content: Text('Please enter your full name')),

                      );

                      return;

                    }

                    // Save to manager
                    final manager = RegistrationManager();
                    manager.name = _nameCtrl.text.trim();
                    manager.email = _emailCtrl.text.trim();
                    manager.gender = _gender;
                    manager.languages = _selectedLangs.toList();

                    // Navigate to practice information page (step 2)
                    Navigator.of(context).pushNamed('/practice_information');

                  },

                  child: const Text('Next',

                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),

                ),

              ),

            ),

          ],

        ),

      ),

    );

  }

}

