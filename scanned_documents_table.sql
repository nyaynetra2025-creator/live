-- ============================================
-- SCANNED DOCUMENTS TABLE
-- ============================================
-- Stores user-scanned documents with AI analysis

CREATE TABLE IF NOT EXISTS public.scanned_documents (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  document_type text NOT NULL,
  document_title text NOT NULL,
  ai_analysis text NOT NULL,
  image_url text,
  scanned_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable RLS
ALTER TABLE public.scanned_documents ENABLE ROW LEVEL SECURITY;

-- Users can only view their own scanned documents
CREATE POLICY "Users can view own scanned documents"
  ON public.scanned_documents FOR SELECT
  USING (auth.uid() = user_id);

-- Users can insert their own scanned documents
CREATE POLICY "Users can insert own scanned documents"
  ON public.scanned_documents FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can delete their own scanned documents
CREATE POLICY "Users can delete own scanned documents"
  ON public.scanned_documents FOR DELETE
  USING (auth.uid() = user_id);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_scanned_documents_user_id ON public.scanned_documents(user_id);
CREATE INDEX IF NOT EXISTS idx_scanned_documents_scanned_at ON public.scanned_documents(scanned_at DESC);

-- Success message
SELECT 'Scanned documents table created successfully!' as result;
