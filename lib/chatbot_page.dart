import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:iconly/iconly.dart';
import 'dart:convert';
import 'services/ai_service.dart';
import 'services/chat_service.dart';
import 'services/language_service.dart';

enum ChatMode { text, voice }

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

  // Mode toggle
  ChatMode _currentMode = ChatMode.text;

  // Voice - Speech to Text
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _textFromSpeech = '';
  late AnimationController _pulseController;

  // Voice - Text to Speech
  late FlutterTts _flutterTts;
  bool _isSpeaking = false;
  bool _autoSpeak = true; // Auto-speak AI responses in voice mode

  @override
  void initState() {
    super.initState();
    if (widget.initialMessages != null) {
      _messages.addAll(widget.initialMessages!);
    }
    // No automatic welcome message - start with empty chat
    
    _speech = stt.SpeechToText();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    
    _initTts();
  }

  Future<void> _initTts() async {
    _flutterTts = FlutterTts();
    
    // Set language based on current app language
    final langCode = LanguageService.instance.currentLanguageCode;
    await _setTtsLanguage(langCode);
    
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    
    _flutterTts.setStartHandler(() {
      setState(() => _isSpeaking = true);
    });
    
    _flutterTts.setCompletionHandler(() {
      setState(() => _isSpeaking = false);
    });
    
    _flutterTts.setErrorHandler((msg) {
      setState(() => _isSpeaking = false);
    });
  }

  Future<void> _setTtsLanguage(String langCode) async {
    // Map app language codes to TTS language codes
    final Map<String, String> languageMap = {
      'en': 'en-IN', // English India
      'hi': 'hi-IN', // Hindi
      'bn': 'bn-IN', // Bengali
      'te': 'te-IN', // Telugu
      'mr': 'mr-IN', // Marathi
      'ta': 'ta-IN', // Tamil
      'gu': 'gu-IN', // Gujarati
      'kn': 'kn-IN', // Kannada
      'ml': 'ml-IN', // Malayalam
      'pa': 'pa-IN', // Punjabi
      'ur': 'ur-IN', // Urdu
      'or': 'or-IN', // Odia
    };
    
    final ttsLang = languageMap[langCode] ?? 'en-IN';
    await _flutterTts.setLanguage(ttsLang);
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    if (text.isEmpty) return;
    
    // Clean text - remove recommendations JSON and markdown
    String cleanText = text;
    if (cleanText.contains('<<<RECOMMENDATIONS>>>')) {
      cleanText = cleanText.split('<<<RECOMMENDATIONS>>>')[0].trim();
    }
    // Remove markdown-style formatting
    cleanText = cleanText.replaceAll(RegExp(r'\*+'), '');
    cleanText = cleanText.replaceAll(RegExp(r'#+\s*'), '');
    cleanText = cleanText.replaceAll(RegExp(r'\[.*?\]\(.*?\)'), '');
    
    await _flutterTts.speak(cleanText);
  }

  Future<void> _stopSpeaking() async {
    await _flutterTts.stop();
    setState(() => _isSpeaking = false);
  }

  Future<void> _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            if (_textFromSpeech.isNotEmpty && mounted) {
              _sendMessage(_textFromSpeech);
            }
            if (mounted) {
              setState(() => _isListening = false);
            }
          }
        },
      );
      if (available) {
        setState(() => _isListening = true);
        
        // Get speech recognition locale based on app language
        final langCode = LanguageService.instance.currentLanguageCode;
        final localeId = _getSpeechLocale(langCode);
        
        _speech.listen(
          onResult: (result) {
            setState(() {
              _textFromSpeech = result.recognizedWords;
              _controller.text = _textFromSpeech;
            });
          },
          localeId: localeId,
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 3),
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

  String _getSpeechLocale(String langCode) {
    final Map<String, String> localeMap = {
      'en': 'en_IN',
      'hi': 'hi_IN',
      'bn': 'bn_IN',
      'te': 'te_IN',
      'mr': 'mr_IN',
      'ta': 'ta_IN',
      'gu': 'gu_IN',
      'kn': 'kn_IN',
      'ml': 'ml_IN',
      'pa': 'pa_IN',
    };
    return localeMap[langCode] ?? 'en_IN';
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
      final response = await _aiService.getChatbotAnswer(text, _messages);
      
      setState(() {
        _isLoading = false;
        _messages.add({'role': 'assistant', 'content': '', 'fullContent': response});
      });
      
      // Auto-speak in voice mode
      if (_currentMode == ChatMode.voice && _autoSpeak) {
        await _speak(response);
      }
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
          // Mode Toggle
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildModeButton(
                  icon: Icons.chat_bubble_outline,
                  mode: ChatMode.text,
                  label: 'Chat',
                  isDarkMode: isDarkMode,
                ),
                _buildModeButton(
                  icon: Icons.mic,
                  mode: ChatMode.voice,
                  label: 'Voice',
                  isDarkMode: isDarkMode,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(IconlyLight.bookmark),
            tooltip: 'Save Chat',
            onPressed: _saveChat,
          ),
          IconButton(
            icon: const Icon(IconlyLight.delete),
            tooltip: 'Clear Chat',
            onPressed: () {
              _stopSpeaking();
              setState(() => _messages.clear());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Voice Mode Banner
          if (_currentMode == ChatMode.voice)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: isDarkMode 
                  ? const Color(0xFF253D79).withValues(alpha: 0.3)
                  : const Color(0xFF253D79).withValues(alpha: 0.1),
              child: Row(
                children: [
                  Icon(
                    Icons.volume_up,
                    size: 18,
                    color: isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Voice Mode: Tap the mic to speak, AI will respond with voice',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.white70 : const Color(0xFF253D79),
                      ),
                    ),
                  ),
                  // Toggle auto-speak
                  TextButton.icon(
                    onPressed: () => setState(() => _autoSpeak = !_autoSpeak),
                    icon: Icon(
                      _autoSpeak ? Icons.volume_up : Icons.volume_off,
                      size: 16,
                    ),
                    label: Text(
                      _autoSpeak ? 'Auto' : 'Muted',
                      style: const TextStyle(fontSize: 12),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ],
              ),
            ),
          
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState(isDarkMode)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isUser = message['role'] == 'user';
                      
                      final isLatestAssistant = !isUser && 
                          index == _messages.length - 1 && 
                          message.containsKey('fullContent');

                      if (isLatestAssistant) {
                        return _TypewriterText(
                          text: message['fullContent']!,
                          isDarkMode: isDarkMode,
                          onComplete: (completedText) {
                            if (mounted) {
                              setState(() {
                                _messages[index]['content'] = completedText;
                                _messages[index].remove('fullContent');
                              });
                            }
                          },
                          onRecommendationSelected: _sendMessage,
                          onSpeak: _speak,
                          isSpeaking: _isSpeaking,
                          onStopSpeaking: _stopSpeaking,
                          showSpeakButton: _currentMode == ChatMode.voice,
                        );
                      }

                      return _buildMessage(
                        message['content']!,
                        isUser,
                        isDarkMode,
                        index,
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

          // Input area - different for voice vs text mode
          _currentMode == ChatMode.voice
              ? _buildVoiceInputArea(isDarkMode)
              : _buildTextInputArea(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildModeButton({
    required IconData icon,
    required ChatMode mode,
    required String label,
    required bool isDarkMode,
  }) {
    final isSelected = _currentMode == mode;
    return GestureDetector(
      onTap: () {
        _stopSpeaking();
        setState(() => _currentMode = mode);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDarkMode ? const Color(0xFF253D79) : const Color(0xFF253D79))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? Colors.white
                  : (isDarkMode ? Colors.grey : Colors.grey[600]),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? Colors.white
                    : (isDarkMode ? Colors.grey : Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    final starterQuestions = [
      'What are my fundamental rights?',
      'How do I file an FIR?',
      'What is Section 420 IPC?',
      'How can I get legal aid?',
      'What is the process for divorce?',
      'How do I file a consumer complaint?',
    ];

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _currentMode == ChatMode.voice ? IconlyBold.voice : IconlyLight.chat,
              size: 80,
              color: isDarkMode
                  ? const Color(0xFFF6B21D)
                  : const Color(0xFF253D79),
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome to Nyaynetra AI',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDarkMode
                    ? Colors.white
                    : const Color(0xFF121317),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your AI Legal Assistant for Indian Law',
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.grey : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Text(
              'Try asking:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white70 : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),
            // Starter question chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: starterQuestions.map((question) {
                return GestureDetector(
                  onTap: () => _sendMessage(question),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          isDarkMode
                              ? const Color(0xFF253D79)
                              : const Color(0xFF253D79),
                          isDarkMode
                              ? const Color(0xFF1a2d5a)
                              : const Color(0xFF1c3366),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: (isDarkMode
                                  ? const Color(0xFF253D79)
                                  : const Color(0xFF253D79))
                              .withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      question,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text(
              _currentMode == ChatMode.voice
                  ? 'Or tap the mic to ask anything'
                  : 'Or type your question below',
              style: TextStyle(
                fontSize: 13,
                color: isDarkMode ? Colors.grey : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceInputArea(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Voice visualization or status
          if (_isListening)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _textFromSpeech.isEmpty ? 'Listening...' : _textFromSpeech,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black87,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          
          // Large mic button
          GestureDetector(
            onTap: _listen,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: _isListening
                          ? [Colors.red, Colors.red.shade700]
                          : [
                              const Color(0xFF253D79),
                              const Color(0xFF1a2d5a),
                            ],
                    ),
                    boxShadow: _isListening
                        ? [
                            BoxShadow(
                              color: Colors.red.withValues(
                                alpha: 0.4 * _pulseController.value,
                              ),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: const Color(0xFF253D79).withValues(alpha: 0.3),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                  ),
                  child: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: Colors.white,
                    size: 40,
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            _isListening ? 'Tap to stop' : 'Tap to speak',
            style: TextStyle(
              color: isDarkMode ? Colors.grey : Colors.grey[600],
              fontSize: 14,
            ),
          ),
          
          // Speaking indicator
          if (_isSpeaking)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: GestureDetector(
                onTap: _stopSpeaking,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6B21D).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.volume_up, color: Color(0xFFF6B21D), size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Speaking... Tap to stop',
                        style: TextStyle(color: Color(0xFFF6B21D)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextInputArea(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Voice button (quick access)
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: _isListening
                      ? [
                          BoxShadow(
                            color: Colors.red.withValues(
                              alpha: 0.3 * _pulseController.value,
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
              IconlyBold.send,
              color: isDarkMode
                  ? const Color(0xFFF6B21D)
                  : const Color(0xFF253D79),
            ),
            onPressed: () => _sendMessage(),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(String text, bool isUser, bool isDarkMode, int index) {
    String mainText = text;
    List<String> recommendations = [];

    // Only parse suggestions for the welcome message (index 0, assistant)
    final isWelcomeMessage = index == 0 && !isUser;
    
    if (isWelcomeMessage) {
      // Parse new format: ---SUGGESTIONS---
      if (text.contains('---SUGGESTIONS---')) {
        final parts = text.split('---SUGGESTIONS---');
        mainText = parts[0].trim();
        
        if (parts.length > 1) {
          // Extract numbered suggestions (1. Question, 2. Question, etc.)
          final suggestionsText = parts[1].trim();
          final lines = suggestionsText.split('\n');
          
          for (final line in lines) {
            final trimmed = line.trim();
            // Match lines starting with numbers like "1.", "2.", "3."
            final match = RegExp(r'^\d+\.\s*(.+)$').firstMatch(trimmed);
            if (match != null) {
              recommendations.add(match.group(1)!.trim());
            }
          }
        }
      }
      // Legacy format support
      else if (text.contains('<<<RECOMMENDATIONS>>>')) {
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
    } else {
      // For non-welcome messages, just use the text as-is
      mainText = text;
    }

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 8),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mainText,
                  style: TextStyle(
                    color: isUser
                        ? Colors.white
                        : (isDarkMode ? Colors.white : const Color(0xFF121317)),
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
                // Speak button for AI messages in voice mode
                if (!isUser && _currentMode == ChatMode.voice && mainText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: GestureDetector(
                      onTap: () => _isSpeaking ? _stopSpeaking() : _speak(text),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: (isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79)).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isSpeaking ? Icons.stop : Icons.volume_up,
                              size: 14,
                              color: isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _isSpeaking ? 'Stop' : 'Listen',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (!isUser && recommendations.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12, top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                    child: Text(
                      'You might also ask:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: recommendations.map((rec) {
                      return GestureDetector(
                        onTap: () => _sendMessage(rec),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                isDarkMode
                                    ? const Color(0xFF253D79)
                                    : const Color(0xFF253D79),
                                isDarkMode
                                    ? const Color(0xFF1a2d5a)
                                    : const Color(0xFF1c3366),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: (isDarkMode
                                        ? const Color(0xFF253D79)
                                        : const Color(0xFF253D79))
                                    .withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.lightbulb_outline,
                                size: 14,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  rec,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
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
  final Function(String) onSpeak;
  final VoidCallback onStopSpeaking;
  final bool isSpeaking;
  final bool showSpeakButton;

  const _TypewriterText({
    required this.text,
    required this.isDarkMode,
    required this.onComplete,
    required this.onRecommendationSelected,
    required this.onSpeak,
    required this.onStopSpeaking,
    required this.isSpeaking,
    required this.showSpeakButton,
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
      widget.onComplete(widget.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 8),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _displayedText,
                  style: TextStyle(
                    color: widget.isDarkMode ? Colors.white : const Color(0xFF121317),
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
                // Speak button in voice mode
                if (widget.showSpeakButton && _displayedText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: GestureDetector(
                      onTap: () => widget.isSpeaking 
                          ? widget.onStopSpeaking() 
                          : widget.onSpeak(widget.text),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: (widget.isDarkMode 
                              ? const Color(0xFFF6B21D) 
                              : const Color(0xFF253D79)).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              widget.isSpeaking ? Icons.stop : Icons.volume_up,
                              size: 14,
                              color: widget.isDarkMode 
                                  ? const Color(0xFFF6B21D) 
                                  : const Color(0xFF253D79),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.isSpeaking ? 'Stop' : 'Listen',
                              style: TextStyle(
                                fontSize: 12,
                                color: widget.isDarkMode 
                                    ? const Color(0xFFF6B21D) 
                                    : const Color(0xFF253D79),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
