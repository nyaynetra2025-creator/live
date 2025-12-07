import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:convert';
import 'services/ai_service.dart';
import 'services/chat_service.dart';

class ChatBotPage extends StatefulWidget {
  final List<Map<String, String>>? initialMessages;
  final String? chatId;

  const ChatBotPage({super.key, this.initialMessages, this.chatId});

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final AiService _aiService = AiService();
  final ChatService _chatService = ChatService();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  // Voice
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _textFromSpeech = '';
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    if (widget.initialMessages != null) {
      _messages.addAll(widget.initialMessages!);
    }
    _speech = stt.SpeechToText();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            setState(() {
              _textFromSpeech = result.recognizedWords;
              _controller.text = _textFromSpeech;
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
      if (_textFromSpeech.isNotEmpty) {
        _sendMessage(_textFromSpeech);
      }
    }
  }

  Future<void> _saveChat() async {
    if (_messages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No messages to save')),
      );
      return;
    }

    String title = 'Chat ${DateTime.now().toString().substring(0, 16)}';
    if (_messages.isNotEmpty) {
      // Use first user message as title, truncated
      final firstUserMsg = _messages.firstWhere(
        (m) => m['role'] == 'user', 
        orElse: () => {'content': title}
      );
      title = firstUserMsg['content'] ?? title;
      if (title.length > 30) title = '${title.substring(0, 30)}...';
    }

    await _chatService.saveChat(title, _messages);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chat saved to Bookmarks')),
      );
    }
  }

  Future<void> _sendMessage([String? voiceText]) async {
    final text = voiceText ?? _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _isLoading = true;
    });

    _controller.clear();
    _textFromSpeech = '';

    try {
      // Pass the chat history to the AI service
      final response = await _aiService.getChatbotAnswer(text, _messages);
      
      setState(() {
        _isLoading = false;
        // Add empty message for streaming effect
        _messages.add({'role': 'assistant', 'content': '', 'fullContent': response});
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _messages.add({
          'role': 'assistant',
          'content': 'Sorry, I encountered an error. Please try again.',
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF14171E)
          : const Color(0xFFF6F7F8),
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF14171E) : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : const Color(0xFF121317),
        elevation: 0,
        title: const Text('AI Legal Assistant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_add_outlined),
            tooltip: 'Save Chat',
            onPressed: _saveChat,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear Chat',
            onPressed: () {
              setState(() => _messages.clear());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.smart_toy_outlined,
                          size: 80,
                          color: isDarkMode
                              ? const Color(0xFFF6B21D)
                              : const Color(0xFF253D79),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Ask me anything about law',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode
                                ? Colors.white
                                : const Color(0xFF121317),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap 🎤 or type your question',
                          style: TextStyle(
                            color: isDarkMode ? Colors.grey : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isUser = message['role'] == 'user';
                      
                      // Check if this is the latest assistant message that needs animation
                      final isLatestAssistant = !isUser && 
                          index == _messages.length - 1 && 
                          message.containsKey('fullContent');

                      if (isLatestAssistant) {
                        return _TypewriterText(
                          text: message['fullContent']!,
                          isDarkMode: isDarkMode,
                          onComplete: (completedText) {
                            // Once animation is done, update the message content permanently
                            // to avoid re-animating on scroll
                            if (mounted) {
                              setState(() {
                                _messages[index]['content'] = completedText;
                                _messages[index].remove('fullContent');
                              });
                            }
                          },
                          onRecommendationSelected: _sendMessage,
                        );
                      }

                      return _buildMessage(
                        message['content']!,
                        isUser,
                        isDarkMode,
                      );
                    },
                  ),
          ),

          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const CircularProgressIndicator(strokeWidth: 2),
                  const SizedBox(width: 12),
                  Text(
                    'Thinking...',
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

          // Input area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Voice button
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: _isListening
                            ? [
                                BoxShadow(
                                  color: Colors.red.withOpacity(
                                    0.3 * _pulseController.value,
                                  ),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ]
                            : null,
                      ),
                      child: IconButton(
                        icon: Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          color: _isListening
                              ? Colors.red
                              : (isDarkMode
                                    ? const Color(0xFFF6B21D)
                                    : const Color(0xFF253D79)),
                        ),
                        onPressed: _listen,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: _isListening
                          ? 'Listening...'
                          : 'Type your question...',
                      border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: isDarkMode
                          ? const Color(0xFF374151)
                          : const Color(0xFFF3F4F6),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (value) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    Icons.send,
                    color: isDarkMode
                        ? const Color(0xFFF6B21D)
                        : const Color(0xFF253D79),
                  ),
                  onPressed: () => _sendMessage(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(String text, bool isUser, bool isDarkMode) {
    // Split text and recommendations
    String mainText = text;
    List<String> recommendations = [];

    if (text.contains('<<<RECOMMENDATIONS>>>')) {
      final parts = text.split('<<<RECOMMENDATIONS>>>');
      mainText = parts[0].trim();
      try {
        final jsonStr = parts[1].trim();
        final List<dynamic> parsed = jsonDecode(jsonStr);
        recommendations = parsed.map((e) => e.toString()).toList();
      } catch (e) {
        print('Error parsing recommendations: $e');
      }
    }

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              color: isUser
                  ? (isDarkMode
                      ? const Color(0xFF253D79)
                      : const Color(0xFF253D79))
                  : (isDarkMode ? const Color(0xFF1F2937) : Colors.white),
              borderRadius: BorderRadius.circular(16),
              border: !isUser
                  ? Border.all(
                      color: isDarkMode
                          ? const Color(0xFF374151)
                          : const Color(0xFFE5E7EB),
                    )
                  : null,
            ),
            child: Text(
              mainText,
              style: TextStyle(
                color: isUser
                    ? Colors.white
                    : (isDarkMode ? Colors.white : const Color(0xFF121317)),
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
          if (!isUser && recommendations.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12, left: 4),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: recommendations.map((rec) {
                  return ActionChip(
                    label: Text(
                      rec,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    backgroundColor: isDarkMode
                        ? const Color(0xFF374151)
                        : const Color(0xFFE5E7EB),
                    onPressed: () => _sendMessage(rec),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _TypewriterText extends StatefulWidget {
  final String text;
  final bool isDarkMode;
  final Function(String) onComplete;
  final Function(String) onRecommendationSelected;

  const _TypewriterText({
    required this.text,
    required this.isDarkMode,
    required this.onComplete,
    required this.onRecommendationSelected,
  });

  @override
  State<_TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<_TypewriterText> {
  String _displayedText = '';
  late List<String> _words;
  String _mainText = '';
  
  @override
  void initState() {
    super.initState();
    _processText();
    _startTyping();
  }

  void _processText() {
    // Split text and recommendations to only animate the main text
    if (widget.text.contains('<<<RECOMMENDATIONS>>>')) {
      _mainText = widget.text.split('<<<RECOMMENDATIONS>>>')[0].trim();
    } else {
      _mainText = widget.text;
    }
    _words = _mainText.split(' ');
  }

  void _startTyping() async {
    for (int i = 0; i < _words.length; i++) {
      if (!mounted) return;
      
      await Future.delayed(const Duration(milliseconds: 50));
      setState(() {
        _displayedText += (i == 0 ? '' : ' ') + _words[i];
      });
    }
    
    if (mounted) {
      // Return the original full text so the parent can render recommendations
      widget.onComplete(widget.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: widget.isDarkMode ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.isDarkMode
                ? const Color(0xFF374151)
                : const Color(0xFFE5E7EB),
          ),
        ),
        child: Text(
          _displayedText,
          style: TextStyle(
            color: widget.isDarkMode ? Colors.white : const Color(0xFF121317),
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
