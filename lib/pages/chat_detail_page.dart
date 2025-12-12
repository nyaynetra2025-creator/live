import 'package:flutter/material.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import '../services/supabase_service.dart';
import '../services/zego_call_service.dart';

class ChatDetailPage extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;

  const ChatDetailPage({
    Key? key,
    required this.otherUserId,
    required this.otherUserName,
  }) : super(key: key);

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _controller = TextEditingController();
  final SupabaseService _supabaseService = SupabaseService();
  final ScrollController _scrollController = ScrollController();
  Timer? _typingTimer;
  bool _isTyping = false;
  String? _otherUserPhone;

  @override
  void initState() {
    super.initState();
    _markMessagesAsRead();
    _fetchOtherUserPhone();
    _controller.addListener(_onTextChanged);
    print('ChatDetailPage opened with user: ${widget.otherUserId}');
    print('Current user: ${_supabaseService.currentUser?.id}');
  }
  
  Future<void> _fetchOtherUserPhone() async {
    try {
      final profile = await SupabaseService.client
          .from('profiles')
          .select('phone')
          .eq('id', widget.otherUserId)
          .maybeSingle();
      
      if (profile != null && mounted) {
        setState(() {
          _otherUserPhone = profile['phone'];
        });
      }
    } catch (e) {
      print('Error fetching phone: $e');
    }
  }
  
  Future<void> _makePhoneCall() async {
    if (_otherUserPhone == null || _otherUserPhone!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone number not available'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    final Uri phoneUri = Uri(scheme: 'tel', path: _otherUserPhone);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not launch phone dialer'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _startVoiceCall() {
    final currentUserId = _supabaseService.currentUser?.id;
    final currentUserName = _supabaseService.currentUser?.userMetadata?['full_name'] ?? 'User';
    
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to make calls'), backgroundColor: Colors.red),
      );
      return;
    }
    
    ZegoCallService.startVoiceCall(
      context: context,
      callerUserId: currentUserId,
      callerUserName: currentUserName,
      calleeUserId: widget.otherUserId,
      calleeUserName: widget.otherUserName,
    );
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _scrollController.dispose();
    _supabaseService.setTypingStatus(widget.otherUserId, false);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    
    if (hasText && !_isTyping) {
      _isTyping = true;
      _supabaseService.setTypingStatus(widget.otherUserId, true);
    }
    
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      if (_isTyping) {
        _isTyping = false;
        _supabaseService.setTypingStatus(widget.otherUserId, false);
      }
    });
  }

  void _markMessagesAsRead() async {
    await _supabaseService.markMessagesAsRead(widget.otherUserId);
  }

  void _sendMessage() async {
    final content = _controller.text.trim();
    if (content.isEmpty) return;

    print('Sending message to: ${widget.otherUserId}');
    print('Message content: $content');

    _controller.clear();
    _typingTimer?.cancel();
    _isTyping = false;
    _supabaseService.setTypingStatus(widget.otherUserId, false);
    
    await _supabaseService.sendMessage(widget.otherUserId, content);
    
    if (_scrollController.hasClients) {
        _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
        );
    }
  }

  String _formatMessageTime(String? timestamp) {
    return SupabaseService.formatMessageTime(timestamp);
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: dark ? const Color(0xFF1A1A2E) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: dark ? const Color(0xFF16213E) : Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: dark ? Colors.white : const Color(0xFF2C3E50)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Hero(
              tag: 'avatar_${widget.otherUserId}',
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF667EEA),
                      const Color(0xFF764BA2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Text(
                    widget.otherUserName.isNotEmpty ? widget.otherUserName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.otherUserName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: dark ? Colors.white : const Color(0xFF2C3E50),
                    ),
                  ),
                  StreamBuilder<bool>(
                    stream: _supabaseService.getTypingStatus(widget.otherUserId),
                    builder: (context, snapshot) {
                      final isTyping = snapshot.data ?? false;
                      return Text(
                        isTyping ? 'typing...' : 'Active now',
                        style: TextStyle(
                          fontSize: 12,
                          color: isTyping 
                              ? const Color(0xFF667EEA)
                              : (dark ? Colors.grey.shade400 : Colors.grey.shade600),
                          fontStyle: isTyping ? FontStyle.italic : FontStyle.normal,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.call_rounded, color: dark ? Colors.white70 : const Color(0xFF667EEA)),
            onPressed: _startVoiceCall,
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: dark ? Colors.white70 : Colors.grey.shade600),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _supabaseService.getMessages(widget.otherUserId),
              builder: (context, snapshot) {
                print('Stream state: ${snapshot.connectionState}');
                print('Has data: ${snapshot.hasData}');
                print('Has error: ${snapshot.hasError}');
                
                if (snapshot.hasError) {
                  print('Stream error: ${snapshot.error}');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}'),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!;
                print('Messages count: ${messages.length}');
                
                // Messages are already ordered by created_at DESC from SupabaseService
                // So index 0 is the newest message.
                // We want to display them starting from the bottom, so reverse: true in ListView is correct.
                // But we don't need to reverse the list itself if the ListView is reversed.

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _markMessagesAsRead();
                });

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF667EEA).withOpacity(0.2),
                                const Color(0xFF764BA2).withOpacity(0.2),
                              ],
                            ),
                          ),
                          child: Icon(
                            Icons.chat_bubble_outline_rounded, 
                            size: 50, 
                            color: dark ? const Color(0xFF667EEA) : const Color(0xFF764BA2),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No messages yet',
                          style: TextStyle(
                            color: dark ? Colors.grey.shade400 : Colors.grey.shade700,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Send a message to start the conversation',
                          style: TextStyle(
                            color: dark ? Colors.grey.shade600 : Colors.grey.shade500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg['sender_id'] == _supabaseService.currentUser?.id;
                    final status = msg['status'] ?? 'sent';
                    
                    print('Message $index: isMe=$isMe, sender=${msg['sender_id']}, content=${msg['content']}');

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (!isMe) ...[
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF667EEA),
                                    const Color(0xFF764BA2),
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  widget.otherUserName[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.7,
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                gradient: isMe
                                    ? LinearGradient(
                                        colors: [
                                          const Color(0xFF667EEA),
                                          const Color(0xFF764BA2),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : null,
                                color: isMe ? null : (dark ? const Color(0xFF2C3E50) : Colors.white),
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(20),
                                  topRight: const Radius.circular(20),
                                  bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(4),
                                  bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(20),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    msg['content'] ?? '',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: isMe ? Colors.white : (dark ? Colors.white : const Color(0xFF2C3E50)),
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _formatMessageTime(msg['created_at']),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isMe 
                                              ? Colors.white.withOpacity(0.8)
                                              : (dark ? Colors.grey.shade500 : Colors.grey.shade600),
                                        ),
                                      ),
                                      if (isMe) ...[ 
                                        const SizedBox(width: 6),
                                        Icon(
                                          status == 'read' ? Icons.done_all_rounded :
                                          status == 'delivered' ? Icons.done_all_rounded : Icons.done_rounded,
                                          size: 16,
                                          color: status == 'read' 
                                              ? const Color(0xFF4FACFE)
                                              : Colors.white.withOpacity(0.7),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (isMe) const SizedBox(width: 8),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          
          // Input Area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: dark ? const Color(0xFF16213E) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: dark ? const Color(0xFF2C3E50) : const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        controller: _controller,
                        style: TextStyle(
                          color: dark ? Colors.white : const Color(0xFF2C3E50),
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(
                            color: dark ? Colors.grey.shade500 : Colors.grey.shade500,
                          ),
                          border: InputBorder.none,
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.attach_file_rounded, 
                                    color: dark ? Colors.grey.shade500 : Colors.grey.shade600,
                                    size: 22),
                                onPressed: () {},
                              ),
                              IconButton(
                                icon: Icon(Icons.camera_alt_rounded, 
                                    color: dark ? Colors.grey.shade500 : Colors.grey.shade600,
                                    size: 22),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                        maxLines: null,
                        textInputAction: TextInputAction.newline,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 48,
                    height: 48,
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
                          color: const Color(0xFF667EEA).withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _sendMessage,
                        borderRadius: BorderRadius.circular(24),
                        child: const Center(
                          child: Icon(Icons.send_rounded, color: Colors.white, size: 22),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
