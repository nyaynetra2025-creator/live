// lib/pages/client_requests.dart



// Flutter conversion of the "Client Requests" Tailwind HTML screen you provided.

// Save as: lib/pages/client_requests.dart

//

// Note: this file references a local uploaded image available in the conversation:

// local image path: /mnt/data/848e5419-acc1-4443-ba1f-77d25cd7f6c8.png

// The code will attempt to use that file for the profile avatar if it exists.

import 'dart:io';

import 'package:flutter/material.dart';

class ClientRequestsPage extends StatefulWidget {

  const ClientRequestsPage({Key? key}) : super(key: key);

  @override

  State<ClientRequestsPage> createState() => _ClientRequestsPageState();

}

class _ClientRequestsPageState extends State<ClientRequestsPage> {

  // Local uploaded image path from conversation history

  static const String _localImagePath =

      '/mnt/data/848e5419-acc1-4443-ba1f-77d25cd7f6c8.png';

  // Colors mapped from the Tailwind config in the HTML

  final Color _primary = const Color(0xFF253D7A); // deep indigo

  final Color _secondary = const Color(0xFFF6B21D); // warm amber

  final Color _bgLight = const Color(0xFFF6F6F8);

  final Color _bgDark = const Color(0xFF14141E);

  final Color _textLight = const Color(0xFF121217);

  final Color _subtextLight = const Color(0xFF686882);

  bool get _hasLocalImage => File(_localImagePath).existsSync();

  @override

  Widget build(BuildContext context) {

    final bool dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(

      backgroundColor: dark ? _bgDark : _bgLight,

      body: SafeArea(

        child: Column(

          children: [

            // Top App Bar (sticky)

            Container(

              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),

              decoration: BoxDecoration(

                color: dark ? _bgDark.withOpacity(0.95) : _bgLight.withOpacity(0.95),

                border: Border(

                  bottom: BorderSide(color: Colors.grey.withOpacity(0.08)),

                ),

              ),

              child: Row(

                children: [

                  IconButton(

                    icon: Icon(Icons.arrow_back, color: dark ? Colors.white : _primary),

                    onPressed: () => Navigator.pop(context),

                  ),

                  Expanded(

                    child: Center(

                      child: Text(

                        'Client Requests',

                        style: TextStyle(

                          fontSize: 20,

                          fontWeight: FontWeight.bold,

                          color: dark ? Colors.white : _primary,

                        ),

                      ),

                    ),

                  ),

                  // Right: notifications button replaced by profile avatar (uses uploaded file if available)

                  Padding(

                    padding: const EdgeInsets.only(right: 4.0),

                    child: _hasLocalImage

                        ? CircleAvatar(

                            radius: 18,

                            backgroundImage: FileImage(File(_localImagePath)),

                          )

                        : Container(

                            width: 36,

                            height: 36,

                            decoration: BoxDecoration(

                              color: Colors.transparent,

                              shape: BoxShape.circle,

                            ),

                            child: IconButton(

                              icon: Icon(Icons.notifications, color: dark ? Colors.white : _textLight),

                              onPressed: () {

                                // handle notifications

                              },

                            ),

                          ),

                  ),

                ],

              ),

            ),

            // Main content

            Expanded(

              child: SingleChildScrollView(

                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),

                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.stretch,

                  children: [

                    const SizedBox(height: 18),

                    // Empty state box

                    Container(

                      margin: const EdgeInsets.only(top: 8),

                      padding: const EdgeInsets.all(20),

                      decoration: BoxDecoration(

                        color: dark ? Colors.grey.shade900 : Colors.white,

                        borderRadius: BorderRadius.circular(14),

                        border: Border.all(

                          color: dark ? Colors.grey.shade700 : Colors.grey.shade300,

                          style: BorderStyle.solid,

                          width: 1,

                        ),

                        // dashed border effect isn't built-in; using solid border to match look

                      ),

                      child: Column(

                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [

                          Container(

                            width: 64,

                            height: 64,

                            decoration: BoxDecoration(

                              color: dark ? _primary.withOpacity(0.2) : _primary.withOpacity(0.1),

                              shape: BoxShape.circle,

                            ),

                            child: Icon(Icons.inbox, size: 36, color: _primary),

                          ),

                          const SizedBox(height: 12),

                          Text(

                            'No New Requests',

                            style: TextStyle(

                              fontSize: 16,

                              fontWeight: FontWeight.w600,

                              color: dark ? Colors.white : _textLight,

                            ),

                          ),

                          const SizedBox(height: 6),

                          Text(

                            "You'll be notified when new client requests arrive.",

                            textAlign: TextAlign.center,

                            style: TextStyle(

                              fontSize: 13,

                              color: dark ? Colors.grey.shade400 : _subtextLight,

                            ),

                          ),

                        ],

                      ),

                    ),

                    const SizedBox(height: 48),

                  ],

                ),

              ),

            ),

            // Bottom Navigation Bar (sticky)

            Container(

              decoration: BoxDecoration(

                color: dark ? Colors.grey.shade900.withOpacity(0.95) : Colors.white.withOpacity(0.95),

                border: Border(

                  top: BorderSide(color: Colors.grey.withOpacity(0.08)),

                ),

              ),

              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),

              child: Row(

                mainAxisAlignment: MainAxisAlignment.spaceAround,

                children: [

                  _bottomNavItem(icon: Icons.home, label: 'Home', active: true, dark: dark, primary: _primary),

                  _bottomNavItem(icon: Icons.folder, label: 'Cases', active: false, dark: dark, primary: _primary),

                  _bottomNavItem(icon: Icons.chat, label: 'Messages', active: false, dark: dark, primary: _primary),

                  _bottomNavItem(icon: Icons.person, label: 'Profile', active: false, dark: dark, primary: _primary),

                ],

              ),

            ),

          ],

        ),

      ),

    );

  }

  Widget _requestCard({

    required String title,

    required String time,

    required String body,

    required IconData icon,

    required bool dark,

  }) {

    return Container(

      decoration: BoxDecoration(

        color: dark ? Colors.grey.shade900 : Colors.white,

        borderRadius: BorderRadius.circular(14),

        boxShadow: const [BoxShadow(color: Color(0x10000000), blurRadius: 8, offset: Offset(0, 4))],

      ),

      child: Column(

        children: [

          Padding(

            padding: const EdgeInsets.all(12),

            child: Row(

              children: [

                Container(

                  height: 48,

                  width: 48,

                  decoration: BoxDecoration(

                    color: _primary.withOpacity(0.10),

                    borderRadius: BorderRadius.circular(10),

                  ),

                  child: Icon(icon, color: _primary, size: 26),

                ),

                const SizedBox(width: 12),

                Expanded(

                  child: Column(

                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [

                      Text(title,

                          style: TextStyle(

                              fontSize: 16,

                              fontWeight: FontWeight.w700,

                              color: dark ? Colors.white : _textLight)),

                      const SizedBox(height: 4),

                      Text(time, style: TextStyle(fontSize: 12, color: _subtextLight)),

                      const SizedBox(height: 8),

                      Text(body, style: TextStyle(fontSize: 13, color: _subtextLight)),

                    ],

                  ),

                ),

              ],

            ),

          ),

          Container(

            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

            decoration: BoxDecoration(

              color: dark ? Colors.grey.shade900 : Colors.white,

              border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.12))),

            ),

            child: Row(

              children: [

                Expanded(

                  child: ElevatedButton(

                    style: ElevatedButton.styleFrom(

                      backgroundColor: _secondary,

                      foregroundColor: _primary,

                      padding: const EdgeInsets.symmetric(vertical: 12),

                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),

                    ),

                    onPressed: () {

                      // Accept action

                    },

                    child: const Text('Accept', style: TextStyle(fontWeight: FontWeight.bold)),

                  ),

                ),

                const SizedBox(width: 8),

                Expanded(

                  child: OutlinedButton(

                    style: OutlinedButton.styleFrom(

                      backgroundColor: dark ? Colors.grey.shade800 : Colors.grey.shade100,

                      foregroundColor: dark ? Colors.white : _textLight,

                      padding: const EdgeInsets.symmetric(vertical: 12),

                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),

                      side: BorderSide(color: Colors.grey.shade300),

                    ),

                    onPressed: () {

                      // Reject action

                    },

                    child: const Text('Reject', style: TextStyle(fontWeight: FontWeight.bold)),

                  ),

                ),

                const SizedBox(width: 8),

                Expanded(

                  child: TextButton(

                    style: TextButton.styleFrom(

                      foregroundColor: _primary,

                      padding: const EdgeInsets.symmetric(vertical: 12),

                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),

                    ),

                    onPressed: () {

                      // Chat action

                    },

                    child: const Text('Chat', style: TextStyle(fontWeight: FontWeight.bold)),

                  ),

                ),

              ],

            ),

          ),

        ],

      ),

    );

  }

  Widget _bottomNavItem({

    required IconData icon,

    required String label,

    required bool active,

    required bool dark,

    required Color primary,

  }) {

    final color = active ? primary : (dark ? Colors.white60 : _subtextLight);

    return GestureDetector(

      onTap: () {

        // Handle navigation

      },

      child: Column(

        mainAxisSize: MainAxisSize.min,

        children: [

          Icon(icon, size: 26, color: color),

          const SizedBox(height: 4),

          Text(

            label,

            style: TextStyle(fontSize: 11, fontWeight: active ? FontWeight.w700 : FontWeight.w500, color: color),

          ),

        ],

      ),

    );

  }

}

