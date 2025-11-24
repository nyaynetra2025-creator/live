import 'dart:io';
import 'package:flutter/material.dart';

class LawyerProfilePage extends StatelessWidget {
  const LawyerProfilePage({Key? key}) : super(key: key);

  static const String _localImagePath = '/mnt/data/848e5419-acc1-4443-ba1f-77d25cd7f6c8.png';
  final Color _primary = const Color(0xFF253D7A);
  final Color _bgLight = const Color(0xFFF6F7F8);
  final Color _bgDark = const Color(0xFF14141E);

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final bool hasLocalImage = File(_localImagePath).existsSync();

    return Scaffold(
      backgroundColor: dark ? _bgDark : _bgLight,
      appBar: AppBar(
        backgroundColor: dark ? _bgDark.withOpacity(0.95) : _bgLight.withOpacity(0.95),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: dark ? Colors.white : _primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: dark ? Colors.white : _primary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: dark ? Colors.white : _primary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: dark ? Colors.grey.shade900 : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: dark ? Colors.grey.shade700 : Colors.grey.shade200,
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: hasLocalImage
                        ? FileImage(File(_localImagePath))
                        : const NetworkImage(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuDfBqoNf-l391SxtwWgKy4nVxv3cf07-jR0OB5RA7rqFn5RREo0UyZJCrtHsGBl_3P5H2XpIgfpr7KU75S2WjpEqXd7y2_Em6aVDvqTnyvh44Enkk9Yv0bkKdKjgRlLo0LbPSuRb_FlUKmoqrWE67CwLD0BsAIaeqaQdKYesOMJT6MSNIaYRzza949cNDuqAHz2jD8VBbuU4vfDfAAKzQLnTmbucls0OmX6V8p3j2xwabF4IbdiKPFDXep-X2oSSZfIiyWnJ2nKHjg',
                          ) as ImageProvider,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Adv. Aarav Sharma',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: dark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Criminal Defense Advocate',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _statItem('Cases', '45', dark),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey.shade300,
                      ),
                      _statItem('Clients', '32', dark),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey.shade300,
                      ),
                      _statItem('Rating', '4.8', dark),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Menu Items
            _menuItem(
              icon: Icons.person_outline,
              title: 'Personal Information',
              subtitle: 'Update your personal details',
              dark: dark,
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _menuItem(
              icon: Icons.business_outlined,
              title: 'Practice Information',
              subtitle: 'Office location and hours',
              dark: dark,
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _menuItem(
              icon: Icons.calendar_today_outlined,
              title: 'Availability',
              subtitle: 'Manage your schedule',
              dark: dark,
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _menuItem(
              icon: Icons.payment_outlined,
              title: 'Payment & Billing',
              subtitle: 'Manage payment methods',
              dark: dark,
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _menuItem(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              subtitle: 'Manage notification preferences',
              dark: dark,
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _menuItem(
              icon: Icons.security_outlined,
              title: 'Privacy & Security',
              subtitle: 'Manage account security',
              dark: dark,
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _menuItem(
              icon: Icons.help_outline,
              title: 'Help & Support',
              subtitle: 'Get help and contact support',
              dark: dark,
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _menuItem(
              icon: Icons.logout,
              title: 'Logout',
              subtitle: 'Sign out of your account',
              dark: dark,
              isDestructive: true,
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String value, bool dark) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool dark,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: dark ? Colors.grey.shade900 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: dark ? Colors.grey.shade700 : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDestructive
                    ? Colors.red.withOpacity(0.1)
                    : _primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isDestructive ? Colors.red : _primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDestructive
                          ? Colors.red
                          : (dark ? Colors.white : Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}

