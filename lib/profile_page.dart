import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final supabase = Supabase.instance.client;
  String userName = '';
  String userEmail = '';
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadThemePreference();
  }

  Future<void> _loadUserData() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      setState(() {
        userEmail = user.email ?? '';
        userName = user.userMetadata?['name'] ?? userEmail.split('@').first;
      });
    }
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('darkMode') ?? false;
    });
  }

  Future<void> _toggleDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
    setState(() => _isDarkMode = value);
    
    // This would require rebuilding the entire app with new theme
    // For now, show a message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isDarkMode ? 'Dark mode enabled' : 'Light mode enabled'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF14171E) : const Color(0xFFF6F7F8),
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF14171E) : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : const Color(0xFF121317),
        elevation: 0,
        title: const Text('Profile'),
      ),
      body: ListView(
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(24),
            color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: isDarkMode ? const Color(0xFF253D79) : const Color(0xFF253D79),
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  userName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : const Color(0xFF121317),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userEmail,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.grey : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Settings Section
          _buildSection(
            'Settings',
            [
              _buildSwitchTile(
                icon: Icons.dark_mode,
                title: 'Dark Mode',
                value: _isDarkMode,
                onChanged: _toggleDarkMode,
                isDarkMode: isDarkMode,
              ),
              _buildTile(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'Manage notification preferences',
                onTap: () {},
                isDarkMode: isDarkMode,
              ),
              _buildTile(
                icon: Icons.language,
                title: 'Language',
                subtitle: 'English',
                onTap: () {},
                isDarkMode: isDarkMode,
              ),
            ],
            isDarkMode,
          ),
          
          const SizedBox(height: 8),
          
          // Saved Items
          _buildSection(
            'Saved',
            [
              _buildTile(
                icon: Icons.bookmark_outline,
                title: 'Bookmarks',
                subtitle: 'Saved articles and resources',
                onTap: () => Navigator.pushNamed(context, '/bookmarks'),
                isDarkMode: isDarkMode,
              ),
              _buildTile(
                icon: Icons.download_outlined,
                title: 'Downloads',
                subtitle: 'Downloaded documents',
                onTap: () {},
                isDarkMode: isDarkMode,
              ),
            ],
            isDarkMode,
          ),
          
          const SizedBox(height: 8),
          
          // About Section
          _buildSection(
            'About',
            [
              _buildTile(
                icon: Icons.info_outline,
                title: 'About Nyaynetra',
                subtitle: 'Version 1.0.0',
                onTap: () {},
                isDarkMode: isDarkMode,
              ),
              _buildTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                onTap: () {},
                isDarkMode: isDarkMode,
              ),
              _buildTile(
                icon: Icons.description_outlined,
                title: 'Terms of Service',
                onTap: () {},
                isDarkMode: isDarkMode,
              ),
              _buildTile(
                icon: Icons.help_outline,
                title: 'Help & Support',
                onTap: () {},
                isDarkMode: isDarkMode,
              ),
            ],
            isDarkMode,
          ),
          
          const SizedBox(height: 24),
          
          // Logout Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () async {
                await supabase.auth.signOut();
                if (mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.grey : Colors.grey[600],
            ),
          ),
        ),
        Container(
          color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return ListTile(
      leading: Icon(icon, color: isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79)),
      title: Text(
        title,
        style: TextStyle(
          color: isDarkMode ? Colors.white : const Color(0xFF121317),
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: isDarkMode ? Colors.grey : Colors.grey[600],
              ),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right,
        color: isDarkMode ? Colors.grey : Colors.grey[400],
      ),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required Function(bool) onChanged,
    required bool isDarkMode,
  }) {
    return ListTile(
      leading: Icon(icon, color: isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79)),
      title: Text(
        title,
        style: TextStyle(
          color: isDarkMode ? Colors.white : const Color(0xFF121317),
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF253D79),
      ),
    );
  }
}
