# Realtime Chat Database Migration

This guide explains how to run the database migration to enable realtime chat functionality.

## 📋 Prerequisites

- Access to your Supabase project dashboard
- Administrative access to run SQL queries

## 🚀 Migration Steps

### Step 1: Access Supabase SQL Editor

1. Go to your [Supabase Dashboard](https://app.supabase.com)
2. Select your project
3. Navigate to **SQL Editor** from the left sidebar
4. Click on **New query** button

### Step 2: Run the Migration Script

1. Open the file `chat_migration.sql` from your project root
2. Copy the entire contents of the file
3. Paste it into the Supabase SQL Editor
4. Click **Run** button at the bottom right

### Step 3: Verify Migration

After running the migration, you should see a success message. The migration will:

✅ Rename the existing `messages` table to `ai_messages` (preserves old data)  
✅ Create a new `messages` table for peer-to-peer chat  
✅ Create a `typing_status` table for typing indicators  
✅ Set up proper indexes for performance  
✅ Configure Row Level Security (RLS) policies  
✅ Enable Realtime subscriptions

### Step 4: Verify Tables

To verify the migration was successful, run this query in the SQL Editor:

```sql
-- Check that tables were created
SELECT tablename 
FROM pg_tables 
WHERE schemaname = 'public' 
  AND tablename IN ('messages', 'typing_status', 'ai_messages');

-- Check realtime is enabled
SELECT tablename 
FROM pg_publication_tables 
WHERE pubname = 'supabase_realtime'
  AND tablename IN ('messages', 'typing_status');
```

You should see all three tables listed, and both `messages` and `typing_status` should be in the realtime publication.

## 📱 Flutter App Updates

The Flutter app has been updated with the following realtime features:

### Chat Detail Page (`chat_detail_page.dart`)
- ✅ Real message timestamps (no more "12:00 PM" placeholder)
- ✅ Message status indicators (sent ✓, delivered ✓✓, read ✓✓ blue)
- ✅ Typing indicators (shows when other user is typing)
- ✅ Auto-mark messages as read when viewing
- ✅ Empty state when no messages exist

### Chat List Page (`lawyer_chats_page.dart`)
- ✅ Realtime updates (no manual refresh needed)
- ✅ Shows latest message preview
- ✅ Displays accurate timestamps
- ✅ Unread message count badges
- ✅ Typing indicator in chat list
- ✅ Sorted by most recent message

### Supabase Service (`supabase_service.dart`)
- ✅ Realtime message streaming
- ✅ Message status updates (sent/delivered/read)
- ✅ Typing status management
- ✅ Unread count calculation
- ✅ Chat list streaming with all metadata
- ✅ Timestamp formatting helper

## 🧪 Testing the Features

### Test Realtime Messaging
1. Open the app on two devices with different accounts
2. Send a message from Device A
3. Message should appear instantly on Device B

### Test Message Status
1. Send message while recipient is offline → Shows ✓ (sent)
2. Recipient comes online → Changes to ✓✓ (delivered)
3. Recipient opens chat → Changes to ✓✓ blue (read)

### Test Typing Indicators
1. Start typing on Device A
2. Device B shows "typing..." indicator
3. Stop typing → Indicator disappears after 2 seconds

### Test Chat List
1. Send message from Device A
2. Chat list on both devices updates automatically
3. Unread badge appears on Device B
4. Opening chat clears the badge

## 🆘 Troubleshooting

### Messages not appearing in realtime
- Verify Realtime is enabled: Check that `messages` table is in `supabase_realtime` publication
- Check RLS policies: Ensure the user has proper permissions

### Typing indicators not working
- Verify `typing_status` table was created
- Check that it's in the realtime publication
- Ensure RLS policies allow read/write access

### Old messages table issues
- The old `messages` table is now renamed to `ai_messages`
- If you need to access old AI chat data, query the `ai_messages` table
- The new peer-to-peer chat uses the `messages` table

## 📝 Database Schema

### Messages Table
```sql
messages (
  id uuid PRIMARY KEY,
  sender_id uuid REFERENCES profiles(id),
  receiver_id uuid REFERENCES profiles(id),
  content text,
  status text ('sent' | 'delivered' | 'read'),
  created_at timestamp,
  updated_at timestamp
)
```

### Typing Status Table
```sql
typing_status (
  id uuid PRIMARY KEY,
  user_id uuid REFERENCES profiles(id),
  chat_with_id uuid REFERENCES profiles(id),
  is_typing boolean,
  updated_at timestamp
)
```

## 🔒 Security

All tables have Row Level Security (RLS) enabled:
- Users can only see messages they sent or received
- Users can only see typing status in their active chats
- Message status can only be updated by the receiver

## ✨ Next Steps

After successful migration, you can:
1. Test the chat functionality on your device
2. Add more features like file uploads
3. Implement push notifications
4. Add message reactions
5. Create group chats

For any issues, check the Supabase logs in the dashboard under **Logs** > **Realtime**.
