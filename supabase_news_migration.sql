-- Migration: Create legal_news table for managing news articles
-- This replaces the Google News RSS feed with a Supabase-backed solution

-- Create the legal_news table
CREATE TABLE IF NOT EXISTS legal_news (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  subtitle TEXT,
  content TEXT,
  image_url TEXT,
  link TEXT,
  category TEXT DEFAULT 'general',
  is_featured BOOLEAN DEFAULT false,
  published_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE legal_news ENABLE ROW LEVEL SECURITY;

-- Create policy: Anyone (authenticated or anonymous) can read news
CREATE POLICY "Anyone can view news"
  ON legal_news FOR SELECT
  TO authenticated, anon
  USING (true);

-- Create policy: Authenticated users can insert news (you can restrict this further to admin role)
CREATE POLICY "Authenticated users can insert news"
  ON legal_news FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Create policy: Authenticated users can update news
CREATE POLICY "Authenticated users can update news"
  ON legal_news FOR UPDATE
  TO authenticated
  USING (true);

-- Create policy: Authenticated users can delete news
CREATE POLICY "Authenticated users can delete news"
  ON legal_news FOR DELETE
  TO authenticated
  USING (true);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_legal_news_published_at ON legal_news(published_at DESC);
CREATE INDEX IF NOT EXISTS idx_legal_news_category ON legal_news(category);
CREATE INDEX IF NOT EXISTS idx_legal_news_featured ON legal_news(is_featured) WHERE is_featured = true;

-- Insert sample news articles
INSERT INTO legal_news (title, subtitle, content, category, is_featured, link) VALUES
  ('Supreme Court Landmark Judgment on Privacy', 'New ruling strengthens digital privacy rights', 'The Supreme Court today delivered a landmark judgment that significantly enhances privacy protections for citizens in the digital age...', 'supreme-court', true, 'https://example.com/privacy-judgment'),
  ('Data Protection Bill Passed', 'Parliament approves comprehensive data protection legislation', 'The Parliament has passed the long-awaited Data Protection Bill, bringing India''s privacy laws in line with international standards...', 'legislation', true, 'https://example.com/data-protection-bill'),
  ('Consumer Rights Update', 'New regulations protect online shoppers', 'The Ministry of Consumer Affairs has issued new guidelines to protect consumers making online purchases...', 'consumer-law', false, 'https://example.com/consumer-rights'),
  ('Labor Law Amendments', 'Changes to workplace regulations announced', 'Significant amendments to labor laws have been announced, affecting workplace rights and employer obligations...', 'labor-law', false, 'https://example.com/labor-amendments'),
  ('Tenant Rights Strengthened', 'New protections for residential tenants', 'The government has introduced new measures to protect tenant rights and regulate rental agreements...', 'property-law', false, 'https://example.com/tenant-rights'),
  ('Environmental Law Enforcement', 'Stricter penalties for pollution violations', 'The National Green Tribunal has announced stricter enforcement of environmental protection laws...', 'environmental-law', false, 'https://example.com/environmental-law'),
  ('Digital Signature Validity', 'Courts recognize electronic signatures', 'A recent ruling has clarified the legal validity of digital signatures in contractual agreements...', 'cyber-law', false, 'https://example.com/digital-signatures'),
  ('Family Law Reforms', 'Progressive changes to family law announced', 'The Law Commission has recommended progressive reforms to family law provisions...', 'family-law', false, 'https://example.com/family-law-reforms');

-- Create a function to automatically update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_legal_news_updated_at BEFORE UPDATE ON legal_news
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Grant necessary permissions (adjust as needed for your security requirements)
GRANT SELECT ON legal_news TO anon, authenticated;
GRANT INSERT, UPDATE, DELETE ON legal_news TO authenticated;
