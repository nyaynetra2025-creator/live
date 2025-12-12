import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/supabase_service.dart';

class BareActDetailPage extends StatefulWidget {
  const BareActDetailPage({super.key});

  @override
  State<BareActDetailPage> createState() => _BareActDetailPageState();
}

class _BareActDetailPageState extends State<BareActDetailPage> {
  final SupabaseService _supabaseService = SupabaseService();
  bool _isLoading = true;
  Map<String, dynamic>? _act;
  List<Map<String, dynamic>> _sections = [];
  bool _isBookmarked = false;
  String? _actId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_actId == null) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      _actId = args['actId'];
      _loadActDetails();
    }
  }

  Future<void> _loadActDetails() async {
    if (_actId == null) return;
    
    setState(() => _isLoading = true);
    try {
      final act = await _supabaseService.getBareActById(_actId!);
      final sections = await _supabaseService.getBareActSections(_actId!);
      final isBookmarked = await _supabaseService.isActBookmarked(_actId!);

      if (mounted) {
        setState(() {
          _act = act;
          _sections = sections;
          _isBookmarked = isBookmarked;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading details: $e')),
        );
      }
    }
  }

  Future<void> _toggleBookmark() async {
    if (_actId == null) return;

    try {
      if (_isBookmarked) {
        await _supabaseService.removeBookmark(_actId!);
      } else {
        await _supabaseService.bookmarkBareAct(_actId!);
      }
      
      setState(() {
        _isBookmarked = !_isBookmarked;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isBookmarked ? 'Added to favorites' : 'Removed from favorites'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating bookmark: $e')),
      );
    }
  }

  Future<void> _shareAct() async {
    if (_act == null) return;
    
    final title = _act!['title'];
    final url = _act!['official_url'];
    final text = 'Check out $title on NyayNetra:\n$url';
    
    await Share.share(text);
  }

  Future<void> _launchURL() async {
    if (_act == null) return;
    final urlString = _act!['official_url'];
    if (urlString == null || urlString.isEmpty) return;
    
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch official URL')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDarkMode ? const Color(0xFF14171E) : const Color(0xFFF6F7F8),
        appBar: AppBar(
          backgroundColor: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
          elevation: 0,
          leading: const BackButton(),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_act == null) {
      return Scaffold(
        backgroundColor: isDarkMode ? const Color(0xFF14171E) : const Color(0xFFF6F7F8),
        appBar: AppBar(leading: const BackButton()),
        body: const Center(child: Text('Act not found')),
      );
    }

    final title = _act!['title'] ?? 'Untitled Act';
    final actNumber = _act!['act_number'];
    final year = _act!['year_enacted'];
    final description = _act!['description'];
    final jurisdiction = _act!['jurisdiction'];
    final category = _act!['category'];
    final state = _act!['state'];

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF14171E) : const Color(0xFFF6F7F8),
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? const Color(0xFFF5F5F7) : const Color(0xFF121317),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isBookmarked ? IconlyBold.bookmark : IconlyLight.bookmark,
              color: _isBookmarked ? const Color(0xFFF6B21D) : (isDarkMode ? const Color(0xFFF5F5F7) : const Color(0xFF121317)),
            ),
            onPressed: _toggleBookmark,
          ),
          IconButton(
            icon: Icon(
              IconlyLight.send,
              color: isDarkMode ? const Color(0xFFF5F5F7) : const Color(0xFF121317),
            ),
            onPressed: _shareAct,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF253D79).withOpacity(0.3) : const Color(0xFF253D79).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      category.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      jurisdiction.toUpperCase() + (state != null ? ' - $state' : ''),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? const Color(0xFFA0AEC0) : const Color(0xFF687082),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Title
              Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                  color: isDarkMode ? const Color(0xFFF5F5F7) : const Color(0xFF121317),
                ),
              ),
              const SizedBox(height: 8),
              
              // Subtitle info
              Text(
                'Act No. $actNumber of $year',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? const Color(0xFFA0AEC0) : const Color(0xFF687082),
                ),
              ),
              const SizedBox(height: 24),
              
              // Description
              if (description != null && description.isNotEmpty) ...[
                Text(
                  'About this Act',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? const Color(0xFFF5F5F7) : const Color(0xFF121317),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: isDarkMode ? const Color(0xFFD1D5DB) : const Color(0xFF4B5563),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              
              // Sections List
              if (_sections.isNotEmpty) ...[
                Text(
                  'Full Text',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? const Color(0xFFF5F5F7) : const Color(0xFF121317),
                  ),
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _sections.length,
                  itemBuilder: (context, index) {
                    final section = _sections[index];
                    return Card(
                      color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ExpansionTile(
                        title: Text(
                          'Section ${section['section_number']}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? const Color(0xFFF5F5F7) : const Color(0xFF121317),
                          ),
                        ),
                        subtitle: Text(
                          section['title'] ?? '',
                          style: TextStyle(
                            color: isDarkMode ? const Color(0xFFA0AEC0) : const Color(0xFF687082),
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              section['content'] ?? 'Content not available',
                              style: TextStyle(
                                height: 1.5,
                                color: isDarkMode ? const Color(0xFFD1D5DB) : const Color(0xFF4B5563),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ] else ...[
                // Fallback if no sections available
                Container(
                  padding: const EdgeInsets.all(24),
                  width: double.infinity,
                  child: Column(
                    children: [
                      Icon(
                        IconlyLight.document,
                        size: 48,
                        color: isDarkMode ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Full text content is being digitized.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDarkMode ? const Color(0xFFA0AEC0) : const Color(0xFF687082),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
