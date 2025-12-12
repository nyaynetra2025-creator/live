-- ============================================
-- BARE ACTS FEATURE MIGRATION
-- ============================================

-- 1. BARE ACTS TABLE
-- Stores metadata for all acts (Central and State)
CREATE TABLE public.bare_acts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  short_title text,
  act_number text,
  year_enacted integer,
  description text,
  category text NOT NULL,
  subcategory text,
  jurisdiction text DEFAULT 'Central' CHECK (jurisdiction IN ('Central', 'State')),
  state text, -- NULL for Central acts
  ministry text,
  official_url text, -- Link to India Code or official government PDF
  pdf_url text,      -- Direct link to PDF if available
  status text DEFAULT 'Active',
  last_amended_date date,
  total_sections integer,
  total_chapters integer,
  keywords text[],
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- 2. BARE ACT SECTIONS TABLE
-- Stores individual sections/chapters content
CREATE TABLE public.bare_act_sections (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  bare_act_id uuid REFERENCES public.bare_acts(id) ON DELETE CASCADE,
  section_number text NOT NULL,
  chapter_number text,
  title text,
  content text,
  sort_order integer,
  created_at timestamptz DEFAULT now()
);

-- 3. USER BOOKMARKS TABLE
-- Stores user favorites
CREATE TABLE public.user_bare_act_bookmarks (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  bare_act_id uuid REFERENCES public.bare_acts(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  UNIQUE(user_id, bare_act_id)
);

-- 4. INDEXES
CREATE INDEX idx_bare_acts_category ON public.bare_acts(category);
CREATE INDEX idx_bare_acts_jurisdiction ON public.bare_acts(jurisdiction);
CREATE INDEX idx_bare_acts_state ON public.bare_acts(state);
CREATE INDEX idx_bare_acts_title ON public.bare_acts(title);
CREATE INDEX idx_bare_act_sections_act_id ON public.bare_act_sections(bare_act_id);
CREATE INDEX idx_bookmarks_user ON public.user_bare_act_bookmarks(user_id);

-- 5. ENABLE RLS
ALTER TABLE public.bare_acts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bare_act_sections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_bare_act_bookmarks ENABLE ROW LEVEL SECURITY;

-- 6. RLS POLICIES

-- Public read access for acts and sections
CREATE POLICY "Bare acts are viewable by everyone" 
  ON public.bare_acts FOR SELECT 
  USING (true);

CREATE POLICY "Sections are viewable by everyone" 
  ON public.bare_act_sections FOR SELECT 
  USING (true);

-- User specific access for bookmarks
CREATE POLICY "Users can view their own bookmarks" 
  ON public.user_bare_act_bookmarks FOR SELECT 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can add bookmarks" 
  ON public.user_bare_act_bookmarks FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can remove their bookmarks" 
  ON public.user_bare_act_bookmarks FOR DELETE 
  USING (auth.uid() = user_id);

-- 7. AUTO-UPDATE TRIGGER
CREATE TRIGGER update_bare_acts_updated_at
  BEFORE UPDATE ON public.bare_acts
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- 8. SEED DATA - CENTRAL ACTS
INSERT INTO public.bare_acts (title, short_title, category, year_enacted, description, official_url, jurisdiction) VALUES
-- Constitutional
('The Constitution of India', 'Constitution of India', 'Constitutional', 1950, 'The supreme law of India.', 'https://legislative.gov.in/constitution-of-india/', 'Central'),
('Right to Information Act, 2005', 'RTI Act', 'Constitutional', 2005, 'An Act to provide for setting out the practical regime of right to information for citizens.', 'https://indiacode.nic.in/handle/123456789/2065', 'Central'),

-- Criminal Laws
('The Indian Penal Code', 'IPC', 'Criminal', 1860, 'The official criminal code of India.', 'https://indiacode.nic.in/handle/123456789/2263', 'Central'),
('Code of Criminal Procedure, 1973', 'CrPC', 'Criminal', 1974, 'The main legislation on procedure for administration of substantive criminal law.', 'https://indiacode.nic.in/handle/123456789/16225', 'Central'),
('The Indian Evidence Act, 1872', 'Evidence Act', 'Criminal', 1872, 'Consolidates, defines and amends the law of evidence.', 'https://indiacode.nic.in/handle/123456789/2183', 'Central'),
('Bharatiya Nyaya Sanhita, 2023', 'BNS', 'Criminal', 2023, 'To consolidate and amend the provisions relating to offences and for matters connected therewith.', 'https://indiacode.nic.in/handle/123456789/19828', 'Central'),
('Bharatiya Nagarik Suraksha Sanhita, 2023', 'BNSS', 'Criminal', 2023, 'To consolidate and amend the law relating to Criminal Procedure.', 'https://indiacode.nic.in/handle/123456789/19829', 'Central'),
('Bharatiya Sakshya Adhiniyam, 2023', 'BSA', 'Criminal', 2023, 'To consolidate and to provide for general rules and principles of evidence.', 'https://indiacode.nic.in/handle/123456789/19830', 'Central'),
('Prevention of Corruption Act, 1988', 'PCA', 'Criminal', 1988, 'An Act to consolidate and amend the law relating to the prevention of corruption.', 'https://indiacode.nic.in/handle/123456789/1899', 'Central'),
('The Protection of Children from Sexual Offences Act, 2012', 'POCSO', 'Criminal', 2012, 'Protection of children from offences of sexual assault, sexual harassment and pornography.', 'https://indiacode.nic.in/handle/123456789/2079', 'Central'),

-- Civil Laws
('Code of Civil Procedure, 1908', 'CPC', 'Civil', 1908, 'An Act to consolidate and amend the laws relating to the procedure of the Courts of Civil Judicature.', 'https://indiacode.nic.in/handle/123456789/2189', 'Central'),
('The Indian Contract Act, 1872', 'Contract Act', 'Civil', 1872, 'To define and amend certain parts of the law relating to contracts.', 'https://indiacode.nic.in/handle/123456789/2187', 'Central'),
('The Specific Relief Act, 1963', 'Specific Relief Act', 'Civil', 1963, 'An Act to define and amend the law relating to certain kinds of specific relief.', 'https://indiacode.nic.in/handle/123456789/1618', 'Central'),
('The Limitation Act, 1963', 'Limitation Act', 'Civil', 1963, 'An Act to consolidate and amend the law for the limitation of suits and other proceedings.', 'https://indiacode.nic.in/handle/123456789/1572', 'Central'),
('The Consumer Protection Act, 2019', 'Consumer Protection Act', 'Civil', 2019, 'An Act to provide for protection of the interests of consumers.', 'https://indiacode.nic.in/handle/123456789/15256', 'Central'),
('The Arbitration and Conciliation Act, 1996', 'Arbitration Act', 'Civil', 1996, 'An Act to consolidate and amend the law relating to domestic arbitration, international commercial arbitration.', 'https://indiacode.nic.in/handle/123456789/1978', 'Central'),

-- Family Laws
('The Hindu Marriage Act, 1955', 'Hindu Marriage Act', 'Family', 1955, 'An Act to amend and codify the law relating to marriage among Hindus.', 'https://indiacode.nic.in/handle/123456789/1560', 'Central'),
('The Hindu Succession Act, 1956', 'Hindu Succession Act', 'Family', 1956, 'An Act to amend and codify the law relating to intestate succession among Hindus.', 'https://indiacode.nic.in/handle/123456789/1652', 'Central'),
('The Special Marriage Act, 1954', 'Special Marriage Act', 'Family', 1954, 'An Act to provide a special form of marriage in certain cases.', 'https://indiacode.nic.in/handle/123456789/16847', 'Central'),
('The Muslims Women (Protection of Rights on Marriage) Act, 2019', 'Triple Talaq Act', 'Family', 2019, 'An Act to protect the rights of married Muslim women.', 'https://indiacode.nic.in/handle/123456789/15476', 'Central'),
('Protection of Women from Domestic Violence Act, 2005', 'Domestic Violence Act', 'Family', 2005, 'To provide for more effective protection of the rights of women guaranteed under the Constitution.', 'https://indiacode.nic.in/handle/123456789/2021', 'Central'),

-- Corporate Laws
('The Companies Act, 2013', 'Companies Act', 'Corporate', 2013, 'An Act to consolidate and amend the law relating to companies.', 'https://indiacode.nic.in/handle/123456789/2114', 'Central'),
('The Limited Liability Partnership Act, 2008', 'LLP Act', 'Corporate', 2009, 'An Act to make provisions for the formation and regulation of limited liability partnerships.', 'https://indiacode.nic.in/handle/123456789/1957', 'Central'),
('The Competition Act, 2002', 'Competition Act', 'Corporate', 2003, 'An Act to provide for the establishment of a Commission to prevent practices having adverse effect on competition.', 'https://indiacode.nic.in/handle/123456789/2012', 'Central'),
('Insolvency and Bankruptcy Code, 2016', 'IBC', 'Corporate', 2016, 'An Act to consolidate and amend the laws relating to reorganization and insolvency resolution.', 'https://indiacode.nic.in/handle/123456789/2154', 'Central'),

-- Tax Laws
('The Income-tax Act, 1961', 'Income Tax Act', 'Tax', 1961, 'An Act to consolidate and amend the law relating to income-tax and super-tax.', 'https://indiacode.nic.in/handle/123456789/2192', 'Central'),
('The Central Goods and Services Tax Act, 2017', 'CGST Act', 'Tax', 2017, 'An Act to make a provision for levy and collection of tax on intra-State supply of goods or services.', 'https://indiacode.nic.in/handle/123456789/13894', 'Central'),
('The Customs Act, 1962', 'Customs Act', 'Tax', 1962, 'An Act to consolidate and amend the law relating to customs.', 'https://indiacode.nic.in/handle/123456789/1614', 'Central'),

-- Property Laws
('The Transfer of Property Act, 1882', 'TPA', 'Property', 1882, 'An Act to amend the law relating to the Transfer of Property by act of Parties.', 'https://indiacode.nic.in/handle/123456789/2286', 'Central'),
('The Registration Act, 1908', 'Registration Act', 'Property', 1908, 'An Act to consolidate the enactments relating to the Registration of Documents.', 'https://indiacode.nic.in/handle/123456789/2253', 'Central'),

-- Cyber & IT Laws
('The Information Technology Act, 2000', 'IT Act', 'Cyber', 2000, 'An Act to provide legal recognition for transactions carried out by means of electronic data interchange.', 'https://indiacode.nic.in/handle/123456789/1999', 'Central'),
('The Digital Personal Data Protection Act, 2023', 'DPDP Act', 'Cyber', 2023, 'An Act to provide for the processing of digital personal data.', 'https://indiacode.nic.in/handle/123456789/19864', 'Central'),

-- Labor Laws
('The Industrial Disputes Act, 1947', 'IDA', 'Labor', 1947, 'An Act to make provision for the investigation and settlement of industrial disputes.', 'https://indiacode.nic.in/handle/123456789/1519', 'Central'),
('The Factories Act, 1948', 'Factories Act', 'Labor', 1948, 'An Act to consolidate and amend the law regulating labour in factories.', 'https://indiacode.nic.in/handle/123456789/1530', 'Central'),
('The Minimum Wages Act, 1948', 'Minimum Wages Act', 'Labor', 1948, 'An Act to provide for fixing minimum rates of wages in certain employments.', 'https://indiacode.nic.in/handle/123456789/1531', 'Central'),

-- Environment Laws
('The Environment (Protection) Act, 1986', 'EPA', 'Environmental', 1986, 'An Act to provide for the protection and improvement of environment.', 'https://indiacode.nic.in/handle/123456789/1879', 'Central'),
('The Wildlife (Protection) Act, 1972', 'Wildlife Act', 'Environmental', 1972, 'An Act to provide for the protection of wild animals, birds and plants.', 'https://indiacode.nic.in/handle/123456789/1669', 'Central'),

-- Banking & Finance
('The Negotiable Instruments Act, 1881', 'NI Act', 'Banking', 1881, 'An Act to define and amend the law relating to Promissory Notes, Bills of Exchange and Cheques.', 'https://indiacode.nic.in/handle/123456789/2274', 'Central'),
('Prevention of Money-Laundering Act, 2002', 'PMLA', 'Banking', 2003, 'An Act to prevent money-laundering and to provide for confiscation of property derived from money-laundering.', 'https://indiacode.nic.in/handle/123456789/2036', 'Central'),
('The Reserve Bank of India Act, 1934', 'RBI Act', 'Banking', 1934, 'An Act to constitute a Reserve Bank of India.', 'https://indiacode.nic.in/handle/123456789/1594', 'Central');
