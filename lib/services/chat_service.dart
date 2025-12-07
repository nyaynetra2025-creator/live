import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChatService {
  static const String _storageKey = 'saved_chats';

  // Save a chat session
  Future<void> saveChat(String title, List<Map<String, String>> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final savedChatsStr = prefs.getString(_storageKey);
    List<dynamic> savedChats = [];

    if (savedChatsStr != null) {
      savedChats = jsonDecode(savedChatsStr);
    }

    final newChat = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'date': DateTime.now().toIso8601String(),
      'messages': messages,
    };

    savedChats.insert(0, newChat); // Add to top
    await prefs.setString(_storageKey, jsonEncode(savedChats));
  }

  // Get all saved chats
  Future<List<Map<String, dynamic>>> getSavedChats() async {
    final prefs = await SharedPreferences.getInstance();
    final savedChatsStr = prefs.getString(_storageKey);

    if (savedChatsStr == null) return [];

    final List<dynamic> decoded = jsonDecode(savedChatsStr);
    return decoded.cast<Map<String, dynamic>>();
  }

  // Delete a saved chat
  Future<void> deleteChat(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final savedChatsStr = prefs.getString(_storageKey);

    if (savedChatsStr != null) {
      List<dynamic> savedChats = jsonDecode(savedChatsStr);
      savedChats.removeWhere((chat) => chat['id'] == id);
      await prefs.setString(_storageKey, jsonEncode(savedChats));
    }
  }
}
