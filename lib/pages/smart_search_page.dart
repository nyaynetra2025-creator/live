import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../services/ai_service.dart';
import '../widgets/animated_widgets.dart';
import '../utils/animation_utils.dart';

class SmartSearchPage extends StatefulWidget {
  final String initialQuery;

  const SmartSearchPage({super.key, required this.initialQuery});

  @override
  State<SmartSearchPage> createState() => _SmartSearchPageState();
}

class _SmartSearchPageState extends State<SmartSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final AiService _aiService = AiService();
  String _answer = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialQuery;
    if (widget.initialQuery.isNotEmpty) {
      _performSearch(widget.initialQuery);
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _answer = '';
    });

    final result = await _aiService.getLegalAnswer(query);

    if (mounted) {
      setState(() {
        _answer = result;
        _isLoading = false;
      });
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
        title: TextField(
          controller: _searchController,
          style: TextStyle(
            color: isDarkMode ? Colors.white : const Color(0xFF121317),
          ),
          decoration: InputDecoration(
            hintText: 'Ask a legal question...',
            border: InputBorder.none,
            hintStyle: TextStyle(
              color: isDarkMode ? const Color(0xFFA0AEC0) : const Color(0xFF687082),
            ),
          ),
          onSubmitted: _performSearch,
        ),
        actions: [
          BouncyButton(
            onPressed: () => _performSearch(_searchController.text),
            child: IconButton(
              icon: const Icon(Icons.search),
              onPressed: null,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated loading indicator
                  PulsingWidget(
                    child: Icon(
                      Icons.psychology_outlined,
                      size: 80,
                      color: isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Shimmer.fromColors(
                    baseColor: isDarkMode ? const Color(0xFF9CA3AF) : const Color(0xFF687082),
                    highlightColor: isDarkMode ? Colors.white : const Color(0xFF1F2937),
                    child: const Text(
                      'Analyzing your query...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 200,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        backgroundColor: isDarkMode
                            ? const Color(0xFF374151)
                            : const Color(0xFFE5E7EB),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_answer.isNotEmpty) ...[
                    // Animated header
                    SlideInWidget(
                      delay: const Duration(milliseconds: 100),
                      direction: AxisDirection.left,
                      child: FadeInWidget(
                        delay: const Duration(milliseconds: 100),
                        child: Row(
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 20,
                              color: isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'AI Generated Answer',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Animated answer container
                    FadeInWidget(
                      delay: const Duration(milliseconds: 300),
                      child: ScaleInWidget(
                        delay: const Duration(milliseconds: 300),
                        beginScale: 0.95,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            _answer,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.6,
                              color: isDarkMode ? const Color(0xFFF5F5F7) : const Color(0xFF121317),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Animated "Related Visuals" header
                    SlideInWidget(
                      delay: const Duration(milliseconds: 500),
                      direction: AxisDirection.left,
                      child: FadeInWidget(
                        delay: const Duration(milliseconds: 500),
                        child: Row(
                          children: [
                            Icon(
                              Icons.image_outlined,
                              size: 20,
                              color: isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Related Visuals',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Animated image list
                    SizedBox(
                      height: 200,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          SlideInWidget(
                            delay: const Duration(milliseconds: 700),
                            direction: AxisDirection.left,
                            child: _buildRelatedImage('https://source.unsplash.com/400x300/?law,court'),
                          ),
                          const SizedBox(width: 12),
                          SlideInWidget(
                            delay: const Duration(milliseconds: 850),
                            direction: AxisDirection.left,
                            child: _buildRelatedImage('https://source.unsplash.com/400x300/?judge,gavel'),
                          ),
                          const SizedBox(width: 12),
                          SlideInWidget(
                            delay: const Duration(milliseconds: 1000),
                            direction: AxisDirection.left,
                            child: _buildRelatedImage('https://source.unsplash.com/400x300/?lawyer,books'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildRelatedImage(String url) {
    return FadeInWidget(
      delay: const Duration(milliseconds: 200),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          url,
          width: 280,
          height: 200,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 280,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
            );
          },
        ),
      ),
    );
  }
}
