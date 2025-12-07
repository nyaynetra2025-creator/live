import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';

class DocumentScannerPage extends StatefulWidget {
  const DocumentScannerPage({super.key});

  @override
  State<DocumentScannerPage> createState() => _DocumentScannerPageState();
}

class _DocumentScannerPageState extends State<DocumentScannerPage> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _searchController = TextEditingController();
  
  List<Map<String, dynamic>> _savedDocuments = [];
  List<Map<String, dynamic>> _filteredDocuments = [];
  bool _isLoadingDocuments = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedDocuments();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredDocuments = List.from(_savedDocuments);
      } else {
        _filteredDocuments = _savedDocuments.where((doc) {
          final title = (doc['document_title'] as String? ?? '').toLowerCase();
          return title.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _loadSavedDocuments() async {
    setState(() => _isLoadingDocuments = true);
    
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final response = await Supabase.instance.client
          .from('scanned_documents')
          .select()
          .eq('user_id', user.id)
          .order('scanned_at', ascending: false);

      setState(() {
        _savedDocuments = List<Map<String, dynamic>>.from(response);
        _filteredDocuments = List.from(_savedDocuments);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading documents: $e')),
        );
      }
    } finally {
      setState(() => _isLoadingDocuments = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) return;

      // Show dialog to get document title
      final title = await _showTitleDialog();
      if (title == null || title.isEmpty) return;

      await _uploadDocument(File(image.path), title);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<String?> _showTitleDialog() async {
    final controller = TextEditingController();
    
    return showDialog<String>(
      context: context,
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Document Title',
            style: TextStyle(
              color: isDarkMode ? const Color(0xFFF5F5F7) : const Color(0xFF121317),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: TextStyle(
              color: isDarkMode ? const Color(0xFFF5F5F7) : const Color(0xFF121317),
            ),
            decoration: InputDecoration(
              hintText: 'e.g., Aadhaar Card, PAN Card',
              hintStyle: TextStyle(
                color: isDarkMode ? const Color(0xFFA0AEC0) : const Color(0xFF687082),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDarkMode ? const Color(0xFFA0AEC0) : const Color(0xFF687082),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _uploadDocument(File imageFile, String title) async {
    setState(() => _isUploading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Upload image to Supabase Storage
      final fileName = '${user.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final bytes = await imageFile.readAsBytes();
      
      await Supabase.instance.client.storage
          .from('documents')
          .uploadBinary(fileName, bytes);

      // Get public URL
      final imageUrl = Supabase.instance.client.storage
          .from('documents')
          .getPublicUrl(fileName);

      // Save to database
      await Supabase.instance.client.from('scanned_documents').insert({
        'user_id': user.id,
        'document_type': 'Document',
        'document_title': title,
        'ai_analysis': '', // Empty since no AI
        'image_url': imageUrl,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Document uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Reload saved documents
      await _loadSavedDocuments();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF14171E) : const Color(0xFFF6F7F8),
      appBar: AppBar(
        title: const Text('My Documents'),
        backgroundColor: isDarkMode ? const Color(0xFF14171E) : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : const Color(0xFF121317),
        elevation: 0,
      ),
      body: _isUploading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Uploading document...',
                    style: TextStyle(
                      color: isDarkMode ? const Color(0xFFA0AEC0) : const Color(0xFF687082),
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Upload Options
                  _buildUploadSection(isDarkMode),

                  const SizedBox(height: 24),

                  // Search Bar
                  if (_savedDocuments.isNotEmpty)
                    _buildSearchBar(isDarkMode),

                  const SizedBox(height: 16),

                  // Saved Documents List
                  if (_savedDocuments.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.folder_outlined,
                          size: 20,
                          color: isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'My Documents (${_filteredDocuments.length})',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? const Color(0xFFF5F5F7) : const Color(0xFF121317),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_filteredDocuments.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Text(
                            'No documents found',
                            style: TextStyle(
                                color: isDarkMode ? const Color(0xFFA0AEC0) : const Color(0xFF687082)
                            ),
                          ),
                        ),
                      )
                    else
                      ..._filteredDocuments.map((doc) => _buildDocumentCard(doc, isDarkMode)),
                  ],

                  if (_savedDocuments.isEmpty && !_isLoadingDocuments)
                    _buildEmptyState(isDarkMode),
                ],
              ),
            ),
    );
  }

  Widget _buildUploadSection(bool isDarkMode) {
    return Row(
      children: [
        Expanded(
          child: _buildUploadOption(
            icon: Icons.camera_alt_outlined,
            title: 'Camera',
            isDarkMode: isDarkMode,
            onTap: () => _pickImage(ImageSource.camera),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildUploadOption(
            icon: Icons.photo_library_outlined,
            title: 'Gallery',
            isDarkMode: isDarkMode,
            onTap: () => _pickImage(ImageSource.gallery),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadOption({
    required IconData icon,
    required String title,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDarkMode ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? const Color(0xFFF6B21D).withOpacity(0.1)
                    : const Color(0xFF253D79).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 28,
                color: isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? const Color(0xFFF5F5F7) : const Color(0xFF121317),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
        ),
      ),
      child: TextField(
        controller: _searchController,
        style: TextStyle(
          color: isDarkMode ? const Color(0xFFF5F5F7) : const Color(0xFF121317),
        ),
        decoration: InputDecoration(
          hintText: 'Search documents...',
          hintStyle: TextStyle(
            color: isDarkMode ? const Color(0xFFA0AEC0) : const Color(0xFF687082),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: isDarkMode ? const Color(0xFFA0AEC0) : const Color(0xFF687082),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildDocumentCard(Map<String, dynamic> doc, bool isDarkMode) {
    return InkWell(
      onTap: () => _viewDocument(doc, isDarkMode),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDarkMode ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Preview thumbnail with Caching
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: doc['image_url'] != null
                  ? CachedNetworkImage(
                      imageUrl: doc['image_url'],
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: isDarkMode ? const Color(0xFF374151) : const Color(0xFFE0E0E0),
                        highlightColor: isDarkMode ? const Color(0xFF4B5563) : const Color(0xFFF5F5F5),
                        child: Container(
                          width: 60,
                          height: 60,
                          color: Colors.white,
                        ),
                      ),
                      errorWidget: (context, url, error) => _buildErrorThumbnail(isDarkMode),
                    )
                  : _buildErrorThumbnail(isDarkMode),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc['document_title'] ?? 'Untitled',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? const Color(0xFFF5F5F7) : const Color(0xFF121317),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(doc['scanned_at']),
                    style: TextStyle(
                      fontSize: 13,
                      color: isDarkMode ? const Color(0xFFA0AEC0) : const Color(0xFF687082),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.share_outlined,
                color: isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79),
              ),
              onPressed: () => _shareDocument(doc),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorThumbnail(bool isDarkMode) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.image_outlined,
        color: isDarkMode ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(
          children: [
            Icon(
              Icons.folder_open_outlined,
              size: 80,
              color: isDarkMode ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
            ),
            const SizedBox(height: 16),
            Text(
              'No documents yet',
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? const Color(0xFFA0AEC0) : const Color(0xFF687082),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload your first document above',
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _viewDocument(Map<String, dynamic> doc, bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            // Document image
            Flexible(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: doc['image_url'] != null
                      ? InteractiveViewer(
                          minScale: 0.1,
                          maxScale: 4.0,
                          child: CachedNetworkImage(
                            imageUrl: doc['image_url'],
                            fit: BoxFit.contain,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        )
                      : const Center(child: Text('No image available', style: TextStyle(color: Colors.white))),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                   _buildActionButton(
                    icon: Icons.share,
                    label: 'Share',
                    color: Colors.blue,
                    onTap: () => _shareDocument(doc),
                  ),
                  _buildActionButton(
                    icon: Icons.delete_outline,
                    label: 'Delete',
                    color: Colors.red,
                    onTap: () {
                      Navigator.pop(context);
                      _deleteDocument(doc['id'], isDarkMode);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Future<void> _shareDocument(Map<String, dynamic> doc) async {
    final url = doc['image_url'] as String?;
    final title = doc['document_title'] as String? ?? 'Document';
    
    if (url != null) {
      await Share.share('Check out this document: $title\n$url');
    }
  }

  Future<void> _deleteDocument(String docId, bool isDarkMode) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Document?'),
        content: const Text(
          'This will permanently delete this document. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    try {
      final doc = _savedDocuments.firstWhere((d) => d['id'] == docId);
      
      await Supabase.instance.client
          .from('scanned_documents')
          .delete()
          .eq('id', docId);

      if (doc['image_url'] != null && (doc['image_url'] as String).isNotEmpty) {
        final url = doc['image_url'] as String;
        final fileName = url.split('/documents/').last;
        await Supabase.instance.client.storage
            .from('documents')
            .remove([fileName]);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document deleted'), backgroundColor: Colors.green),
        );
      }

      await _loadSavedDocuments();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) return 'Today';
      if (difference.inDays == 1) return 'Yesterday';
      if (difference.inDays < 7) return '${difference.inDays} days ago';
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return '';
    }
  }
}
