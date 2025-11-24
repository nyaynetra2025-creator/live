-- ============================================
-- Realtime Chat Enhancement Script
-- ============================================
-- This script adds realtime features to your existing messages table
-- Safe to run - only adds new columns and tables

-- Step 1: Add missing columns to existing messages table
ALTER TABLE public.messages 
  ADD COLUMN IF NOT EXISTS status text DEFAULT 'sent',
  ADD COLUMN IF NOT EXISTS updated_at timestamp with time zone DEFAULT timezone('utc'::text, now());

-- Add constraint for status values
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'messages_status_check'
  ) THEN
    ALTER TABLE public.messages 
      ADD CONSTRAINT messages_status_check 
      CHECK (status IN ('sent', 'delivered', 'read'));
  END IF;
END $$;

-- Step 2: Create typing_status table for realtime typing indicators
CREATE TABLE IF NOT EXISTS public.typing_status (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  chat_with_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  is_typing boolean DEFAULT false,
  updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
  UNIQUE(user_id, chat_with_id)
);

-- Step 3: Enable Row Level Security for typing_status
ALTER TABLE public.typing_status ENABLE ROW LEVEL SECURITY;

-- Step 4: Create RLS policies for typing_status
DROP POLICY IF EXISTS "Users can view typing status" ON public.typing_status;
CREATE POLICY "Users can view typing status" ON public.typing_status
  FOR SELECT USING (
    auth.uid() = user_id OR auth.uid() = chat_with_id
  );

DROP POLICY IF EXISTS "Users can manage their typing status" ON public.typing_status;
CREATE POLICY "Users can manage their typing status" ON public.typing_status
  FOR ALL USING (
    auth.uid() = user_id
  );

-- Step 5: Update RLS policy for messages to allow status updates
DROP POLICY IF EXISTS "Receivers can update message status" ON public.messages;
CREATE POLICY "Receivers can update message status" ON public.messages
  FOR UPDATE USING (
    auth.uid() = receiver_id
  );

-- Step 6: Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_messages_sender ON public.messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_messages_receiver ON public.messages(receiver_id);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON public.messages(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_messages_status ON public.messages(status);
CREATE INDEX IF NOT EXISTS idx_typing_status_user ON public.typing_status(user_id);
CREATE INDEX IF NOT EXISTS idx_typing_status_chat_with ON public.typing_status(chat_with_id);

-- Step 7: Create function to auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = timezone('utc'::text, now());
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Step 8: Add triggers for auto-updating timestamps
DROP TRIGGER IF EXISTS update_messages_updated_at ON public.messages;
CREATE TRIGGER update_messages_updated_at
  BEFORE UPDATE ON public.messages
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_typing_status_updated_at ON public.typing_status;
CREATE TRIGGER update_typing_status_updated_at
  BEFORE UPDATE ON public.typing_status
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Step 9: Enable Realtime for the tables (only if not already added)
DO $$ 
BEGIN
  -- Add messages table to realtime publication if not already there
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables 
    WHERE pubname = 'supabase_realtime' 
    AND tablename = 'messages'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.messages;
    RAISE NOTICE 'Added messages table to realtime publication';
  ELSE
    RAISE NOTICE 'Messages table already in realtime publication';
  END IF;

  -- Add typing_status table to realtime publication if not already there
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables 
    WHERE pubname = 'supabase_realtime' 
    AND tablename = 'typing_status'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.typing_status;
    RAISE NOTICE 'Added typing_status table to realtime publication';
  ELSE
    RAISE NOTICE 'Typing_status table already in realtime publication';
  END IF;
END $$;

-- Step 10: Create view for chat list with latest message (optional helper view)
CREATE OR REPLACE VIEW public.chat_list_view AS
WITH latest_messages AS (
  SELECT DISTINCT ON (
    CASE 
      WHEN sender_id < receiver_id THEN sender_id::text || receiver_id::text
      ELSE receiver_id::text || sender_id::text
    END
  )
    id,
    sender_id,
    receiver_id,
    content,
    created_at,
    status,
    CASE 
      WHEN sender_id < receiver_id THEN sender_id::text || receiver_id::text
      ELSE receiver_id::text || sender_id::text
    END as chat_pair
  FROM public.messages
  ORDER BY chat_pair, created_at DESC
)
SELECT 
  lm.*,
  sender.full_name as sender_name,
  receiver.full_name as receiver_name
FROM latest_messages lm
LEFT JOIN public.profiles sender ON lm.sender_id = sender.id
LEFT JOIN public.profiles receiver ON lm.receiver_id = receiver.id;

-- Grant access to the view
GRANT SELECT ON public.chat_list_view TO authenticated;

-- Success message
DO $$
BEGIN
  RAISE NOTICE '✅ Chat realtime features added successfully!';
  RAISE NOTICE '✅ Added status and updated_at columns to messages table';
  RAISE NOTICE '✅ Created typing_status table';
  RAISE NOTICE '✅ RLS policies configured';
  RAISE NOTICE '✅ Indexes created for performance';
  RAISE NOTICE '✅ Realtime enabled for both tables';
  RAISE NOTICE '';
  RAISE NOTICE '🚀 Your chat is now realtime-enabled!';
END $$;
