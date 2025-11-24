import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'chat_detail_page.dart';

class LawyerChatsPage extends StatefulWidget {
  const LawyerChatsPage({Key? key}) : super(key: key);

  @override
  State<LawyerChatsPage> createState() => _LawyerChatsPageState();
}

class _LawyerChatsPageState extends State<LawyerChatsPage> {
  final Color _primary = const Color(0xFF253D7A);
  final Color _bgLight = const Color(0xFFF6F7F8);
  final Color _bgDark = const Color(0xFF14141E);

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: dark ? const Color(0xFF1A1A2E) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: dark ? const Color(0xFF16213E) : Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: dark ? Colors.white : _primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Messages',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: dark ? Colors.white : _primary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search_rounded, color: dark ? Colors.white70 : _primary),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: dark ? Colors.white70 : _primary),
            onPressed: () {},
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: SupabaseService().getChatListStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final users = snapshot.data ?? [];

          if (users.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No chats yet', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text(
                    'Start a conversation with a lawyer',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            );
          }

          // Sort users by last message time
          users.sort((a, b) {
            final aTime = a['last_message_time'] as String?;
            final bTime = b['last_message_time'] as String?;
            if (aTime == null && bTime == null) return 0;
            if (aTime == null) return 1;
            if (bTime == null) return -1;
            return DateTime.parse(bTime).compareTo(DateTime.parse(aTime));
          });

          return ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final unreadCount = user['unread_count'] as int? ?? 0;
              final isTyping = user['is_typing'] as bool? ?? false;
              
              String lastMessageText;
              if (isTyping) {
                lastMessageText = 'typing...';
              } else if (user['last_message'] != null) {
                final isMe = user['last_message_sender_id'] == SupabaseService().currentUser?.id;
                lastMessageText = isMe 
                    ? 'You: ${user['last_message']}' 
                    : user['last_message'];
              } else {
                lastMessageText = 'Tap to chat';
              }

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatDetailPage(
                        otherUserId: user['id'],
                        otherUserName: user['full_name'] ?? 'Unknown',
                      ),
                    ),
                  );
                },
                child: _chatItem(
                  name: user['full_name'] ?? 'Unknown',
                  lastMessage: lastMessageText,
                  time: SupabaseService.formatMessageTime(user['last_message_time']),
                  unread: unreadCount > 0,
                  unreadCount: unreadCount,
                  isTyping: isTyping,
                  dark: dark,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _chatItem({
    required String name,
    required String lastMessage,
    required String time,
    required bool unread,
    required int unreadCount,
    required bool isTyping,
    required bool dark,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF16213E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Hero(
            tag: 'avatar_chat_$name',
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF667EEA),
                    Color(0xFF764BA2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF667EEA).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: dark ? Colors.white : const Color(0xFF2C3E50),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (time.isNotEmpty)
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 12,
                          color: unread 
                              ? const Color(0xFF667EEA)
                              : (dark ? Colors.grey.shade500 : Colors.grey.shade500),
                          fontWeight: unread ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        lastMessage,
                        style: TextStyle(
                          fontSize: 14,
                          color: isTyping 
                              ? const Color(0xFF667EEA)
                              : (unread 
                                  ? (dark ? Colors.white : const Color(0xFF2C3E50))
                                  : (dark ? Colors.grey.shade500 : Colors.grey.shade600)),
                          fontWeight: unread ? FontWeight.w500 : FontWeight.normal,
                          fontStyle: isTyping ? FontStyle.italic : FontStyle.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (unreadCount > 0)
                      Container(
                        margin: const EdgeInsets.only(left: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF667EEA),
                              Color(0xFF764BA2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 24,
                          minHeight: 24,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          unreadCount > 99 ? '99+' : unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
