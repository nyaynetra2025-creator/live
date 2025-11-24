-- ============================================
-- COMPLETE FRESH SETUP FOR REALTIME CHAT
-- ============================================
-- Run this script in Supabase SQL Editor after deleting old tables
-- This creates everything from scratch

-- Step 1: Drop existing tables if they exist (cleanup)
DROP TABLE IF EXISTS public.typing_status CASCADE;
DROP TABLE IF EXISTS public.messages CASCADE;
DROP TABLE IF EXISTS public.profiles CASCADE;

-- Step 2: Create profiles table
CREATE TABLE public.profiles (
  id uuid REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  role text DEFAULT 'client' CHECK (role IN ('client', 'advocate')),
  full_name text,
  email text,
  gender text,
  languages text[],
  location text,
  fee text,
  available_days text[],
  available_time_start text,
  available_time_end text,
  consultation_methods jsonb,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Step 3: Create messages table
CREATE TABLE public.messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  sender_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  receiver_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  content text NOT NULL,
  status text DEFAULT 'sent' CHECK (status IN ('sent', 'delivered', 'read')),
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Step 4: Create typing_status table
CREATE TABLE public.typing_status (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  chat_with_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  is_typing boolean DEFAULT false,
  updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
  UNIQUE(user_id, chat_with_id)
);

-- Step 5: Create indexes for performance
CREATE INDEX idx_messages_sender ON public.messages(sender_id);
CREATE INDEX idx_messages_receiver ON public.messages(receiver_id);
CREATE INDEX idx_messages_created_at ON public.messages(created_at DESC);
CREATE INDEX idx_messages_conversation ON public.messages(sender_id, receiver_id);
CREATE INDEX idx_typing_status_user ON public.typing_status(user_id);
CREATE INDEX idx_typing_status_chat_with ON public.typing_status(chat_with_id);

-- Step 6: Enable Row Level Security
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.typing_status ENABLE ROW LEVEL SECURITY;

-- Step 7: Create RLS policies for profiles
CREATE POLICY "Profiles are viewable by everyone" 
  ON public.profiles FOR SELECT 
  USING (true);

CREATE POLICY "Users can insert their own profile" 
  ON public.profiles FOR INSERT 
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update their own profile" 
  ON public.profiles FOR UPDATE 
  USING (auth.uid() = id);

-- Step 8: Create RLS policies for messages
CREATE POLICY "Users can view their own messages" 
  ON public.messages FOR SELECT 
  USING (auth.uid() = sender_id OR auth.uid() = receiver_id);

CREATE POLICY "Users can insert messages they send" 
  ON public.messages FOR INSERT 
  WITH CHECK (auth.uid() = sender_id);

CREATE POLICY "Receivers can update message status" 
  ON public.messages FOR UPDATE 
  USING (auth.uid() = receiver_id);

-- Step 9: Create RLS policies for typing_status
CREATE POLICY "Users can view typing status in their chats" 
  ON public.typing_status FOR SELECT 
  USING (auth.uid() = user_id OR auth.uid() = chat_with_id);

CREATE POLICY "Users can manage their typing status" 
  ON public.typing_status FOR ALL 
  USING (auth.uid() = user_id);

-- Step 10: Create function to auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = timezone('utc'::text, now());
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Step 11: Add triggers for auto-updating timestamps
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_messages_updated_at
  BEFORE UPDATE ON public.messages
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_typing_status_updated_at
  BEFORE UPDATE ON public.typing_status
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Step 12: Enable Realtime
ALTER PUBLICATION supabase_realtime ADD TABLE public.messages;
ALTER PUBLICATION supabase_realtime ADD TABLE public.typing_status;

-- Step 13: Success message
DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '========================================';
  RAISE NOTICE '✅ REALTIME CHAT SETUP COMPLETE!';
  RAISE NOTICE '========================================';
  RAISE NOTICE '';
  RAISE NOTICE '✅ Tables created:';
  RAISE NOTICE '   - profiles (user accounts)';
  RAISE NOTICE '   - messages (chat messages)';
  RAISE NOTICE '   - typing_status (typing indicators)';
  RAISE NOTICE '';
  RAISE NOTICE '✅ Security enabled:';
  RAISE NOTICE '   - Row Level Security (RLS) on all tables';
  RAISE NOTICE '   - Proper access policies configured';
  RAISE NOTICE '';
  RAISE NOTICE '✅ Performance optimized:';
  RAISE NOTICE '   - Indexes created on key columns';
  RAISE NOTICE '   - Auto-updating timestamps';
  RAISE NOTICE '';
  RAISE NOTICE '✅ Realtime enabled:';
  RAISE NOTICE '   - Messages update instantly';
  RAISE NOTICE '   - Typing indicators work in realtime';
  RAISE NOTICE '';
  RAISE NOTICE '🚀 Your chat is ready to use!';
  RAISE NOTICE '========================================';
  RAISE NOTICE '';
END $$;
