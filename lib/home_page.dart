import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:iconly/iconly.dart';
import 'pages/news_detail_page.dart';
import 'services/supabase_service.dart';
import 'services/language_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _userName = 'User';
  final _supabaseService = SupabaseService();

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final fullName = user.userMetadata?['full_name'];
      if (fullName != null && fullName.isNotEmpty) {
        setState(() {
          _userName = fullName;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF14171E)
          : const Color(0xFFF6F7F8),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top App Bar
            _buildAppBar(context, isDarkMode),

            // Scrollable Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  // Supabase stream automatically updates, 
                  // just add a small delay for visual feedback
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quick Actions Grid
                      _buildQuickActions(context, isDarkMode),

                      // Trending Topics Section
                      _buildTrendingTopics(isDarkMode),

                      // Bottom spacer for nav bar
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(isDarkMode),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      color: isDarkMode ? const Color(0xFF14171E) : const Color(0xFFF6F7F8),
      child: Row(
        children: [
          // Profile Picture
          GestureDetector(
            onTap: () {
              // Navigate to profile page
              Navigator.pushNamed(context, '/profile');
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuDkaCYmwcwTAWpZnEH1zl_wDb0fkIefcKbPm433Yo3xVW74vlJttIVxETF4LB3MrlDJfrzUnHkhynVrh8M4CW5rgAz5e1WO4cn_EWkZN6uxlWuQYn9tQzc8PTF655OS6xF0T2lzQFbf4xtZk8S-YRahqzux8ebDZB_-5YzmVHdQEXZnt2k1U2djXoh2mRfRIcLgaK3xImkqzpHioelYI8niN7tj3gaOsWl55ELKA7VmtSwDHy33lOD_7-ftWI6dBJtSrIOImuPoEyc',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Greeting Text
          Expanded(
            child: Text(
              'Hello, $_userName',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.015,
                color: isDarkMode
                    ? const Color(0xFFF5F5F7)
                    : const Color(0xFF121317),
              ),
            ),
          ),
          // Notification Icon
          IconButton(
            icon: Icon(
              IconlyLight.notification,
              color: isDarkMode
                  ? const Color(0xFFA0AEC0)
                  : const Color(0xFF687082),
              size: 24,
            ),
            onPressed: () {
              // Handle notifications
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.2,
        children: [
          _buildQuickActionCard(
            context: context,
            icon: IconlyLight.scan,
            label: LanguageService.instance.tr('document_scanner'),
            title: LanguageService.instance.tr('document_scanner'),
            subtitle: 'Scan & analyze docs',
            isDarkMode: isDarkMode,
            isHighlighted: false,
            onTap: () => Navigator.pushNamed(context, '/document-scanner'),
          ),
          _buildQuickActionCard(
            context: context,
            icon: IconlyLight.shield_done,
            label: LanguageService.instance.tr('legal_rights'),
            title: LanguageService.instance.tr('legal_rights'),
            subtitle: LanguageService.instance.tr('know_rights'),
            isDarkMode: isDarkMode,
            isHighlighted: false,
            onTap: () => Navigator.pushNamed(context, '/legal-rights'),
          ),
          _buildQuickActionCard(
            context: context,
            icon: Icons.directions_car,
            label: 'Cycle/Car',
            title: 'Vehicle Laws',
            subtitle: 'RTO, Fines & Signs',
            isDarkMode: isDarkMode,
            isHighlighted: false,
            onTap: () => Navigator.pushNamed(context, '/rto-laws'),
          ),
          _buildQuickActionCard(
            context: context,
            icon: IconlyBold.paper,
            label: 'Bare Acts',
            title: 'Bare Acts',
            subtitle: 'Central & State Laws',
            isDarkMode: isDarkMode,
            isHighlighted: false,
            onTap: () => Navigator.pushNamed(context, '/bare-acts'),
          ),
          _buildQuickActionCard(
            context: context,
            icon: Icons.gavel,
            label: 'IPC Cases',
            title: 'IPC Case Search',
            subtitle: 'Search by Section',
            isDarkMode: isDarkMode,
            isHighlighted: false,
            onTap: () => Navigator.pushNamed(context, '/ipc-case-search'),
          ),
          _buildQuickActionCard(
            context: context,
            icon: IconlyLight.chat,
            label: 'AI',
            title: LanguageService.instance.tr('ai_chatbot'),
            subtitle: 'Get instant answers',
            isDarkMode: isDarkMode,
            isHighlighted: true,
            onTap: () => Navigator.pushNamed(context, '/chatbot'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String title,
    required String subtitle,
    required bool isDarkMode,
    required bool isHighlighted,
    required VoidCallback onTap,
  }) {
    return _QuickActionCard(
      context: context,
      icon: icon,
      label: label,
      title: title,
      subtitle: subtitle,
      isDarkMode: isDarkMode,
      isHighlighted: isHighlighted,
      onTap: onTap,
    );
  }

  // No more caching needed - Supabase handles this efficiently

  Widget _buildTrendingTopics(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                LanguageService.instance.tr('legal_news'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode
                      ? const Color(0xFFF5F5F7)
                      : const Color(0xFF121317),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.circle, color: Colors.white, size: 8),
                    SizedBox(width: 4),
                    Text(
                      'LIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _supabaseService.getLegalNewsStream(
              limit: 50,
              language: LanguageService.instance.currentLanguageCode,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Icon(
                          IconlyLight.info_circle,
                          size: 48,
                          color: isDarkMode ? Colors.grey : Colors.grey[600],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Unable to load news',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode ? Colors.grey : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please check your connection and try again',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode ? Colors.grey : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Icon(
                          IconlyLight.paper,
                          size: 48,
                          color: isDarkMode ? Colors.grey : Colors.grey[600],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No news available',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode ? Colors.grey : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'New articles will appear here',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode ? Colors.grey : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final newsItems = snapshot.data!;
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: newsItems.length,
                itemBuilder: (context, index) {
                  final item = newsItems[index];
                  return _buildNewsListItem(
                    title: item['title'] ?? 'Legal Update',
                    subtitle: item['subtitle'] ?? 'Tap to read more',
                    link: item['link'] ?? '',
                    imageUrl: item['image_url'],
                    category: item['category'] ?? 'general',
                    isFeatured: item['is_featured'] ?? false,
                    isDarkMode: isDarkMode,
                    index: index + 1,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNewsListItem({
    required String title,
    String? subtitle,
    required String link,
    String? imageUrl,
    String? category,
    bool isFeatured = false,
    required bool isDarkMode,
    required int index,
  }) {
    return InkWell(
      onTap: () {
        if (link.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewsDetailPage(
                title: title,
                link: link,
              ),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isFeatured
                ? (isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79))
                : (isDarkMode ? const Color(0xFF374151) : const Color(0xFFE5E7EB)),
            width: isFeatured ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Number badge or image thumbnail
            imageUrl != null && imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildIndexBadge(index, isDarkMode, isFeatured);
                      },
                    ),
                  )
                : _buildIndexBadge(index, isDarkMode, isFeatured),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Featured badge
                  if (isFeatured) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? const Color(0xFFF6B21D).withOpacity(0.2)
                            : const Color(0xFFF6B21D).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.star, size: 12, color: Color(0xFFF6B21D)),
                          SizedBox(width: 4),
                          Text(
                            'FEATURED',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFF6B21D),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                  // Title
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                      color: isDarkMode
                          ? const Color(0xFFF5F5F7)
                          : const Color(0xFF121317),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Subtitle
                  if (subtitle != null && subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDarkMode
                            ? const Color(0xFFA0AEC0)
                            : const Color(0xFF687082),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  // Category and read more
                  Row(
                    children: [
                      if (category != null && category != 'general') ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? const Color(0xFF253D79).withOpacity(0.3)
                                : const Color(0xFF253D79).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            category.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode
                                  ? const Color(0xFFF6B21D)
                                  : const Color(0xFF253D79),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Icon(
                        IconlyLight.arrow_right,
                        size: 14,
                        color: isDarkMode ? Colors.grey : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Read more',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndexBadge(int index, bool isDarkMode, bool isFeatured) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: isFeatured
            ? (isDarkMode
                ? const Color(0xFFF6B21D).withOpacity(0.2)
                : const Color(0xFFF6B21D).withOpacity(0.1))
            : (isDarkMode
                ? const Color(0xFF253D79)
                : const Color(0xFF253D79).withOpacity(0.1)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          '$index',
          style: TextStyle(
            color: isFeatured
                ? const Color(0xFFF6B21D)
                : (isDarkMode ? Colors.white : const Color(0xFF253D79)),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }


  Widget _buildBottomNavBar(bool isDarkMode) {
    return SafeArea(
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: IconlyBold.home,
                label: LanguageService.instance.tr('home'),
                isActive: true,
                isDarkMode: isDarkMode,
                onTap: () {},
              ),
              _buildNavItem(
                icon: IconlyLight.user_1,
                label: LanguageService.instance.tr('lawyers'),
                isActive: false,
                isDarkMode: isDarkMode,
                onTap: () => Navigator.pushNamed(context, '/lawyers'),
              ),
              _buildNavItem(
                icon: IconlyLight.profile,
                label: LanguageService.instance.tr('profile'),
                isActive: false,
                isDarkMode: isDarkMode,
                onTap: () => Navigator.pushNamed(context, '/profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    final color = isActive
        ? (isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79))
        : (isDarkMode ? const Color(0xFFA0AEC0) : const Color(0xFF687082));

    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatefulWidget {
  final BuildContext context;
  final IconData icon;
  final String label;
  final String title;
  final String subtitle;
  final bool isDarkMode;
  final bool isHighlighted;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.context,
    required this.icon,
    required this.label,
    required this.title,
    required this.subtitle,
    required this.isDarkMode,
    required this.isHighlighted,
    required this.onTap,
  });

  @override
  State<_QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<_QuickActionCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.isHighlighted
                  ? (widget.isDarkMode
                      ? [const Color(0xFFF6B21D).withOpacity(0.25), const Color(0xFFF6B21D).withOpacity(0.15)]
                      : [const Color(0xFFFFFBEB), const Color(0xFFFEF3C7)])
                  : (widget.isDarkMode
                      ? [const Color(0xFF1F2937), const Color(0xFF111827)]
                      : [Colors.white, const Color(0xFFF8FAFC)]),
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isHighlighted
                  ? const Color(0xFFF6B21D)
                  : (widget.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white),
              width: widget.isHighlighted ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.isHighlighted
                    ? const Color(0xFFF6B21D).withOpacity(0.15)
                    : Colors.black.withOpacity(0.06),
                blurRadius: 15,
                offset: const Offset(0, 8),
                spreadRadius: -2,
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.isHighlighted
                      ? const Color(0xFFF6B21D).withOpacity(0.2)
                      : (widget.isDarkMode ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F5F9)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  widget.icon,
                  color: widget.isHighlighted
                      ? const Color(0xFFD97706)
                      : (widget.isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79)),
                  size: 24,
                ),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                    color: widget.isDarkMode ? const Color(0xFFF5F5F7) : const Color(0xFF1E293B),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  widget.subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: widget.isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
