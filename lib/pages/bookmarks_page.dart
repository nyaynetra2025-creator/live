import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import '../chatbot_page.dart';

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({super.key});

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  final ChatService _chatService = ChatService();
  List<Map<String, dynamic>> _savedChats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedChats();
  }

  Future<void> _loadSavedChats() async {
    final chats = await _chatService.getSavedChats();
    if (mounted) {
      setState(() {
        _savedChats = chats;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteChat(String id) async {
    await _chatService.deleteChat(id);
    _loadSavedChats();
  }

  void _openChat(Map<String, dynamic> chat) {
    final List<dynamic> rawMessages = chat['messages'];
    final List<Map<String, String>> messages = rawMessages.map((m) {
      return Map<String, String>.from(m);
    }).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatBotPage(
          initialMessages: messages,
          chatId: chat['id'],
        ),
      ),
    );
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
        title: const Text('Saved Chats'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _savedChats.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bookmarks_outlined,
                        size: 80,
                        color: isDarkMode ? Colors.grey : Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No saved chats yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: isDarkMode ? Colors.grey : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Save chats from the AI Assistant to view them here',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? Colors.grey : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _savedChats.length,
                  itemBuilder: (context, index) {
                    final chat = _savedChats[index];
                    final date = DateTime.parse(chat['date']);
                    
                    return Dismissible(
                      key: Key(chat['id']),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.red,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) => _deleteChat(chat['id']),
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isDarkMode 
                                  ? const Color(0xFF253D79).withOpacity(0.3)
                                  : const Color(0xFF253D79).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.chat_bubble_outline,
                              color: isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79),
                            ),
                          ),
                          title: Text(
                            chat['title'] ?? 'Untitled Chat',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          subtitle: Text(
                            '${date.day}/${date.month}/${date.year} • ${chat['messages'].length} messages',
                            style: TextStyle(
                              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                          onTap: () => _openChat(chat),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
