
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseClient client = Supabase.instance.client;

  // --- Auth ---
  Future<AuthResponse> signUp(String email, String password, {Map<String, dynamic>? data}) async {
    return await client.auth.signUp(email: email, password: password, data: data);
  }

  Future<AuthResponse> signIn(String email, String password) async {
    return await client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  Future<void> signInWithOtp(String email) async {
    await client.auth.signInWithOtp(
      email: email,
      shouldCreateUser: false, // For login, user must exist
    );
  }

  Future<void> signUpWithOtp(String email, {Map<String, dynamic>? data}) async {
    await client.auth.signInWithOtp(
      email: email,
      shouldCreateUser: true,
      data: data,
    );
  }

  Future<AuthResponse> verifyOTP(String email, String token, OtpType type) async {
    return await client.auth.verifyOTP(
      email: email,
      token: token,
      type: type,
    );
  }

  User? get currentUser => client.auth.currentUser;

  // --- Profiles ---
  Future<void> saveAdvocateProfile({
    required String name,
    required String email,
    required String gender,
    required List<String> languages,
    required String location,
    required String fee,
    required List<String> availableDays,
    required String availableTimeStart,
    required String availableTimeEnd,
    required bool onlineConsult,
    required bool inPersonConsult,
  }) async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    await client.from('profiles').upsert({
      'id': user.id,
      'role': 'advocate',
      'full_name': name,
      'email': email,
      'gender': gender,
      'languages': languages,
      'location': location,
      'fee': fee,
      'available_days': availableDays,
      'available_time_start': availableTimeStart,
      'available_time_end': availableTimeEnd,
      'consultation_methods': {
        'online': onlineConsult,
        'in_person': inPersonConsult,
      },
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<Map<String, dynamic>?> getProfile(String userId) async {
    final response = await client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    return response;
  }

  Future<List<Map<String, dynamic>>> getAdvocates() async {
    final response = await client
        .from('profiles')
        .select()
        .eq('role', 'advocate');
    return List<Map<String, dynamic>>.from(response);
  }

  // --- Chat ---
  
  // Get realtime stream of messages between two users
  Stream<List<Map<String, dynamic>>> getMessages(String otherUserId) {
    final myId = client.auth.currentUser?.id;
    if (myId == null) return const Stream.empty();

    return client
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map((maps) => maps.where((msg) {
              return (msg['sender_id'] == myId && msg['receiver_id'] == otherUserId) ||
                     (msg['sender_id'] == otherUserId && msg['receiver_id'] == myId);
            }).toList());
  }
  
  // Send a new message
  Future<void> sendMessage(String receiverId, String content) async {
    final myId = client.auth.currentUser?.id;
    if (myId == null) return;

    await client.from('messages').insert({
      'sender_id': myId,
      'receiver_id': receiverId,
      'content': content,
      'status': 'sent',
    });
  }
  
  // Update message status (delivered or read)
  Future<void> updateMessageStatus(String messageId, String status) async {
    await client.from('messages').update({
      'status': status,
    }).eq('id', messageId);
  }
  
  // Mark all messages from a user as read
  Future<void> markMessagesAsRead(String senderId) async {
    final myId = client.auth.currentUser?.id;
    if (myId == null) return;

    await client
        .from('messages')
        .update({'status': 'read'})
        .eq('sender_id', senderId)
        .eq('receiver_id', myId)
        .neq('status', 'read');
  }
  
  // Mark messages as delivered when they arrive
  Future<void> markMessagesAsDelivered(String senderId) async {
    final myId = client.auth.currentUser?.id;
    if (myId == null) return;

    await client
        .from('messages')
        .update({'status': 'delivered'})
        .eq('sender_id', senderId)
        .eq('receiver_id', myId)
        .eq('status', 'sent');
  }
  
  // Get unread message count for a specific user
  Future<int> getUnreadCount(String otherUserId) async {
    final myId = client.auth.currentUser?.id;
    if (myId == null) return 0;

    try {
      final response = await client
          .from('messages')
          .select()
          .eq('sender_id', otherUserId)
          .eq('receiver_id', myId)
          .neq('status', 'read');
      
      return response.length;
    } catch (e) {
      print('getUnreadCount error: $e');
      return 0;
    }
  }
  
  // Set typing status
  Future<void> setTypingStatus(String chatWithId, bool isTyping) async {
    final myId = client.auth.currentUser?.id;
    if (myId == null) return;

    try {
      await client.from('typing_status').upsert({
        'user_id': myId,
        'chat_with_id': chatWithId,
        'is_typing': isTyping,
      });
    } catch (e) {
      print('setTypingStatus error: $e');
    }
  }
  
  // Get typing status stream
  Stream<bool> getTypingStatus(String otherUserId) {
    final myId = client.auth.currentUser?.id;
    if (myId == null) return Stream.value(false);

    return client
        .from('typing_status')
        .stream(primaryKey: ['id'])
        .map((list) {
          final status = list.firstWhere(
            (item) =>
                item['user_id'] == otherUserId &&
                item['chat_with_id'] == myId,
            orElse: () => {'is_typing': false},
          );
          return status['is_typing'] as bool? ?? false;
        });
  }
  
  // Get realtime chat list with latest messages
  Stream<List<Map<String, dynamic>>> getChatListStream() {
    final myId = client.auth.currentUser?.id;
    if (myId == null) return const Stream.empty();

    return client
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .asyncMap((messages) async {
          // Get unique users from messages
          final Set<String> userIds = {};
          final Map<String, Map<String, dynamic>> latestMessages = {};
          final Map<String, int> unreadCounts = {};

          for (var msg in messages) {
            final senderId = msg['sender_id'];
            final receiverId = msg['receiver_id'];
            
            String? otherUserId;
            if (senderId == myId) {
              otherUserId = receiverId;
            } else if (receiverId == myId) {
              otherUserId = senderId;
              // Count unread messages
              if (msg['status'] != 'read' && otherUserId != null) {
                unreadCounts[otherUserId] = (unreadCounts[otherUserId] ?? 0) + 1;
              }
            }

            if (otherUserId != null) {
              userIds.add(otherUserId);
              
              // Store latest message for each user
              if (!latestMessages.containsKey(otherUserId)) {
                latestMessages[otherUserId] = {
                  'content': msg['content'],
                  'created_at': msg['created_at'],
                  'sender_id': senderId,
                };
              }
            }
          }

          if (userIds.isEmpty) return [];

          // Fetch user profiles
          final users = await client
              .from('profiles')
              .select()
              .inFilter('id', userIds.toList());

          // Get typing status for all users
          final typingStatuses = await client
              .from('typing_status')
              .select()
              .eq('chat_with_id', myId)
              .inFilter('user_id', userIds.toList());

          final typingMap = <String, bool>{};
          for (var status in typingStatuses) {
            typingMap[status['user_id']] = status['is_typing'] ?? false;
          }

          // Combine user info with latest message and unread count
          return users.map((user) {
            final userId = user['id'];
            final latestMsg = latestMessages[userId];
            return {
              ...user,
              'last_message': latestMsg?['content'],
              'last_message_time': latestMsg?['created_at'],
              'last_message_sender_id': latestMsg?['sender_id'],
              'unread_count': unreadCounts[userId] ?? 0,
              'is_typing': typingMap[userId] ?? false,
            };
          }).toList();
        });
  }
  
  // Get list of users I have chatted with (legacy method, use getChatListStream instead)
  Future<List<Map<String, dynamic>>> getChatUsers() async {
    try {
      final myId = client.auth.currentUser?.id;
      if (myId == null) {
        print('getChatUsers: No current user');
        return [];
      }

      print('getChatUsers: Fetching messages for user $myId');
      
      // Fetch all messages involving the current user
      final response = await client
          .from('messages')
          .select()
          .or('sender_id.eq.$myId,receiver_id.eq.$myId')
          .order('created_at', ascending: false);
      
      print('getChatUsers: Found ${response.length} messages');
      
      final Set<String> userIds = {};
      final Map<String, Map<String, dynamic>> latestMessages = {};
      final Map<String, int> unreadCounts = {};
      
      for (var msg in response) {
        String? otherUserId;
        if (msg['sender_id'] == myId) {
          otherUserId = msg['receiver_id'];
        } else if (msg['receiver_id'] == myId) {
          otherUserId = msg['sender_id'];
          // Count unread messages
          if (msg['status'] != 'read' && otherUserId != null) {
            unreadCounts[otherUserId] = (unreadCounts[otherUserId] ?? 0) + 1;
          }
        }
        
        if (otherUserId != null) {
          userIds.add(otherUserId);
          // Store latest message for each user
          if (!latestMessages.containsKey(otherUserId)) {
            latestMessages[otherUserId] = {
              'content': msg['content'],
              'created_at': msg['created_at'],
              'sender_id': msg['sender_id'],
            };
          }
        }
      }
      
      print('getChatUsers: Found ${userIds.length} unique users');

      if (userIds.isEmpty) return [];

      // Fetch user profiles
      final users = await client
          .from('profiles')
          .select()
          .inFilter('id', userIds.toList());
      
      print('getChatUsers: Fetched ${users.length} user profiles');
      
      // Combine user info with latest message and unread count
      return users.map((user) {
        final userId = user['id'];
        final latestMsg = latestMessages[userId];
        return {
          ...user,
          'last_message': latestMsg?['content'],
          'last_message_time': latestMsg?['created_at'],
          'last_message_sender_id': latestMsg?['sender_id'],
          'unread_count': unreadCounts[userId] ?? 0,
        };
      }).toList();
    } catch (e) {
      print('getChatUsers error: $e');
      return [];
    }
  }
  
  // Helper to format message timestamp
  static String formatMessageTime(String? timestamp) {
    if (timestamp == null) return '';
    
    try {
      final messageTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(messageTime);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes}m';
      } else if (difference.inDays < 1) {
        final hour = messageTime.hour;
        final minute = messageTime.minute.toString().padLeft(2, '0');
        final period = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        return '$displayHour:$minute $period';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        return days[messageTime.weekday - 1];
      } else {
        return '${messageTime.day}/${messageTime.month}/${messageTime.year}';
      }
    } catch (e) {
      return '';
    }
  }

  // --- Laws ---
  Future<List<Map<String, dynamic>>> searchLaws(String query) async {
    if (query.isEmpty) {
      return await client.from('laws').select().limit(50);
    }
    return await client
        .from('laws')
        .select()
        .ilike('title', '%$query%'); // Simple search
  }

  // --- Legal News ---
  
  /// Fetch legal news articles from Supabase
  /// Returns a list of news articles ordered by published_at (newest first)
  /// Optionally filter by category or featured status
  Future<List<Map<String, dynamic>>> getLegalNews({
    String? category,
    bool? isFeatured,
    int limit = 50,
  }) async {
    try {
      var query = client
          .from('legal_news')
          .select()
          .order('published_at', ascending: false)
          .limit(limit);

      if (category != null) {
        query = query.eq('category', category);
      }

      if (isFeatured != null) {
        query = query.eq('is_featured', isFeatured);
      }

      return List<Map<String, dynamic>>.from(await query);
    } catch (e) {
      print('getLegalNews error: $e');
      return [];
    }
  }

  /// Get real-time stream of legal news articles
  /// This will automatically update when new articles are added or existing ones are modified
  Stream<List<Map<String, dynamic>>> getLegalNewsStream({
    String? category,
    int limit = 50,
  }) {
    try {
      var query = client
          .from('legal_news')
          .stream(primaryKey: ['id'])
          .order('published_at', ascending: false)
          .limit(limit);

      if (category != null) {
        return query.map((list) => 
          list.where((item) => item['category'] == category).toList()
        );
      }

      return query;
    } catch (e) {
      print('getLegalNewsStream error: $e');
      return const Stream.empty();
    }
  }

  /// Get a single news article by ID
  Future<Map<String, dynamic>?> getNewsArticle(String id) async {
    try {
      final response = await client
          .from('legal_news')
          .select()
          .eq('id', id)
          .maybeSingle();
      return response;
    } catch (e) {
      print('getNewsArticle error: $e');
      return null;
    }
  }

  /// Add a new news article (for admin use)
  Future<bool> addNewsArticle({
    required String title,
    String? subtitle,
    String? content,
    String? imageUrl,
    String? link,
    String category = 'general',
    bool isFeatured = false,
  }) async {
    try {
      await client.from('legal_news').insert({
        'title': title,
        'subtitle': subtitle,
        'content': content,
        'image_url': imageUrl,
        'link': link,
        'category': category,
        'is_featured': isFeatured,
      });
      return true;
    } catch (e) {
      print('addNewsArticle error: $e');
      return false;
    }
  }

  /// Update an existing news article (for admin use)
  Future<bool> updateNewsArticle(String id, Map<String, dynamic> updates) async {
    try {
      await client
          .from('legal_news')
          .update(updates)
          .eq('id', id);
      return true;
    } catch (e) {
      print('updateNewsArticle error: $e');
      return false;
    }
  }

  /// Delete a news article (for admin use)
  Future<bool> deleteNewsArticle(String id) async {
    try {
      await client
          .from('legal_news')
          .delete()
          .eq('id', id);
      return true;
    } catch (e) {
      print('deleteNewsArticle error: $e');
      return false;
    }
  }
}
