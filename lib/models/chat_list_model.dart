class ChatListItem {
  final String userId;
  final String userName;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final bool isLastMessageFromMe;
  final int unreadCount;
  final bool isTyping;

  ChatListItem({
    required this.userId,
    required this.userName,
    this.lastMessage,
    this.lastMessageTime,
    this.isLastMessageFromMe = false,
    this.unreadCount = 0,
    this.isTyping = false,
  });

  factory ChatListItem.fromMap(Map<String, dynamic> map, String currentUserId) {
    return ChatListItem(
      userId: map['id'] as String,
      userName: map['full_name'] as String? ?? 'Unknown',
      lastMessage: map['last_message'] as String?,
      lastMessageTime: map['last_message_time'] != null
          ? DateTime.parse(map['last_message_time'] as String)
          : null,
      isLastMessageFromMe: map['last_message_sender_id'] == currentUserId,
      unreadCount: map['unread_count'] as int? ?? 0,
      isTyping: map['is_typing'] as bool? ?? false,
    );
  }

  ChatListItem copyWith({
    String? userId,
    String? userName,
    String? lastMessage,
    DateTime? lastMessageTime,
    bool? isLastMessageFromMe,
    int? unreadCount,
    bool? isTyping,
  }) {
    return ChatListItem(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      isLastMessageFromMe: isLastMessageFromMe ?? this.isLastMessageFromMe,
      unreadCount: unreadCount ?? this.unreadCount,
      isTyping: isTyping ?? this.isTyping,
    );
  }

  String getFormattedTime() {
    if (lastMessageTime == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(lastMessageTime!);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      final hour = lastMessageTime!.hour;
      final minute = lastMessageTime!.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[lastMessageTime!.weekday - 1];
    } else {
      return '${lastMessageTime!.day}/${lastMessageTime!.month}/${lastMessageTime!.year}';
    }
  }
}
