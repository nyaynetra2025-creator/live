-- ============================================
-- NYAYNETRA APP - COMPLETE DATABASE SETUP
-- ============================================
-- For fresh Supabase project
-- Run this entire script in Supabase SQL Editor

-- ============================================
-- 1. PROFILES TABLE
-- ============================================
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

-- ============================================
-- 2. MESSAGES TABLE (for chat)
-- ============================================
CREATE TABLE public.messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  sender_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  receiver_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  content text NOT NULL,
  status text DEFAULT 'sent' CHECK (status IN ('sent', 'delivered', 'read')),
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- ============================================
-- 3. TYPING STATUS TABLE
-- ============================================
CREATE TABLE public.typing_status (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  chat_with_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  is_typing boolean DEFAULT false,
  updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
  UNIQUE(user_id, chat_with_id)
);

-- ============================================
-- 4. LAWS TABLE
-- ============================================
CREATE TABLE public.laws (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text,
  category text,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- ============================================
-- 5. CREATE INDEXES
-- ============================================
-- Indexes for profiles
CREATE INDEX idx_profiles_role ON public.profiles(role);
CREATE INDEX idx_profiles_email ON public.profiles(email);

-- Indexes for messages
CREATE INDEX idx_messages_sender ON public.messages(sender_id);
CREATE INDEX idx_messages_receiver ON public.messages(receiver_id);
CREATE INDEX idx_messages_created_at ON public.messages(created_at DESC);
CREATE INDEX idx_messages_status ON public.messages(status);
CREATE INDEX idx_messages_conversation ON public.messages(sender_id, receiver_id);

-- Indexes for typing_status
CREATE INDEX idx_typing_status_user ON public.typing_status(user_id);
CREATE INDEX idx_typing_status_chat_with ON public.typing_status(chat_with_id);

-- Indexes for laws
CREATE INDEX idx_laws_category ON public.laws(category);
CREATE INDEX idx_laws_title ON public.laws(title);

-- ============================================
-- 6. ENABLE ROW LEVEL SECURITY
-- ============================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.typing_status ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.laws ENABLE ROW LEVEL SECURITY;

-- ============================================
-- 7. RLS POLICIES - PROFILES
-- ============================================
CREATE POLICY "Profiles are viewable by everyone" 
  ON public.profiles FOR SELECT 
  USING (true);

CREATE POLICY "Users can insert their own profile" 
  ON public.profiles FOR INSERT 
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update their own profile" 
  ON public.profiles FOR UPDATE 
  USING (auth.uid() = id);

-- ============================================
-- 8. RLS POLICIES - MESSAGES
-- ============================================
CREATE POLICY "Users can view their own messages" 
  ON public.messages FOR SELECT 
  USING (auth.uid() = sender_id OR auth.uid() = receiver_id);

CREATE POLICY "Users can insert messages they send" 
  ON public.messages FOR INSERT 
  WITH CHECK (auth.uid() = sender_id);

CREATE POLICY "Receivers can update message status" 
  ON public.messages FOR UPDATE 
  USING (auth.uid() = receiver_id);

-- ============================================
-- 9. RLS POLICIES - TYPING STATUS
-- ============================================
CREATE POLICY "Users can view typing status in their chats" 
  ON public.typing_status FOR SELECT 
  USING (auth.uid() = user_id OR auth.uid() = chat_with_id);

CREATE POLICY "Users can manage their typing status" 
  ON public.typing_status FOR ALL 
  USING (auth.uid() = user_id);

-- ============================================
-- 10. RLS POLICIES - LAWS
-- ============================================
CREATE POLICY "Laws are viewable by everyone" 
  ON public.laws FOR SELECT 
  USING (true);

-- ============================================
-- 11. AUTO-UPDATE TIMESTAMP FUNCTION
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = timezone('utc'::text, now());
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 12. TRIGGERS FOR AUTO-UPDATE
-- ============================================
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

-- ============================================
-- 13. ENABLE REALTIME
-- ============================================
ALTER PUBLICATION supabase_realtime ADD TABLE public.messages;
ALTER PUBLICATION supabase_realtime ADD TABLE public.typing_status;

-- ============================================
-- 14. INSERT SAMPLE LAWS
-- ============================================
INSERT INTO public.laws (title, description, category) VALUES
  ('Constitution of India', 'The supreme law of India.', 'Constitutional'),
  ('Indian Penal Code (IPC)', 'The official criminal code of India.', 'Criminal'),
  ('Code of Civil Procedure', 'Procedural law for civil cases in India.', 'Civil'),
  ('Information Technology Act', 'Laws governing cyber crimes and electronic commerce.', 'Cyber Law'),
  ('Consumer Protection Act', 'Protects the rights of consumers in India.', 'Consumer Law'),
  ('Right to Information Act', 'Empowers citizens to seek information from public authorities.', 'Transparency'),
  ('Hindu Marriage Act', 'Governs marriage and divorce among Hindus.', 'Family Law'),
  ('Dowry Prohibition Act', 'Prohibits the giving or taking of dowry.', 'Social Welfare'),
  ('Sexual Harassment of Women at Workplace Act', 'Protects women from harassment at workplace.', 'Women Rights'),
  ('Juvenile Justice Act', 'Protects the rights of children in conflict with law.', 'Child Rights');

-- ============================================
-- 15. SUCCESS MESSAGE
-- ============================================
DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '╔════════════════════════════════════════╗';
  RAISE NOTICE '║   ✅ NYAYNETRA DATABASE SETUP COMPLETE  ║';
  RAISE NOTICE '╚════════════════════════════════════════╝';
  RAISE NOTICE '';
  RAISE NOTICE '✅ Tables Created:';
  RAISE NOTICE '   📋 profiles - User accounts (client/advocate)';
  RAISE NOTICE '   💬 messages - Chat messages with status';
  RAISE NOTICE '   ⌨️  typing_status - Typing indicators';
  RAISE NOTICE '   ⚖️  laws - Legal database';
  RAISE NOTICE '';
  RAISE NOTICE '✅ Security:';
  RAISE NOTICE '   🔒 Row Level Security enabled';
  RAISE NOTICE '   🛡️  Access policies configured';
  RAISE NOTICE '';
  RAISE NOTICE '✅ Performance:';
  RAISE NOTICE '   ⚡ Indexes on key columns';
  RAISE NOTICE '   🔄 Auto-updating timestamps';
  RAISE NOTICE '';
  RAISE NOTICE '✅ Realtime:';
  RAISE NOTICE '   💬 Messages - instant delivery';
  RAISE NOTICE '   ⌨️  Typing indicators - live updates';
  RAISE NOTICE '';
  RAISE NOTICE '✅ Sample Data:';
  RAISE NOTICE '   📚 10 Indian laws pre-loaded';
  RAISE NOTICE '';
  RAISE NOTICE '🚀 Next Steps:';
  RAISE NOTICE '   1. Update Flutter app with Supabase URL & API key';
  RAISE NOTICE '   2. Register test accounts (client & advocate)';
  RAISE NOTICE '   3. Test chat functionality';
  RAISE NOTICE '';
  RAISE NOTICE '════════════════════════════════════════';
END $$;
