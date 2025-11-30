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
  year_enacted integer,
  status text DEFAULT 'Active',
  official_url text,
  last_amended_date date,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
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
CREATE INDEX idx_laws_year_enacted ON public.laws(year_enacted);
CREATE INDEX idx_laws_status ON public.laws(status);

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
-- 14. INSERT COMPREHENSIVE INDIAN LAWS DATA
-- ============================================
INSERT INTO public.laws (title, description, category, year_enacted, status, official_url) VALUES
-- Constitutional Laws
('Constitution of India', 'The supreme law of India. It lays down the framework defining fundamental political principles, establishes the structure, procedures, powers and duties of government institutions and sets out fundamental rights, directive principles and duties of citizens.', 'Constitutional', 1950, 'Active', 'https://legislative.gov.in/constitution-of-india'),

-- Criminal Laws
('Indian Penal Code (IPC)', 'The main criminal code of India that covers all substantive aspects of criminal law. It defines crimes and provides punishments for almost all kinds of criminal and actionable wrongs.', 'Criminal', 1860, 'Active', 'https://legislative.gov.in/sites/default/files/A1860-45.pdf'),
('Code of Criminal Procedure (CrPC)', 'The main legislation on procedural aspects of criminal law in India. It provides the machinery for the investigation of crime, apprehension of suspected criminals, collection of evidence, determination of guilt or innocence of the accused person and the determination of punishment.', 'Criminal', 1973, 'Active', 'https://legislative.gov.in/sites/default/files/A1974-2.pdf'),
('Bharatiya Nyaya Sanhita (BNS)', 'Modern replacement for the Indian Penal Code. It modernizes criminal law provisions while retaining the essence of justice delivery. Effective from July 1, 2024.', 'Criminal', 2023, 'Active', 'https://legislative.gov.in/sites/default/files/sansad_TV/LS_bill39of2023_1.pdf'),
('Indian Evidence Act', 'The law of evidence in India. It contains a set of rules and allied issues governing admissibility of evidence in Indian courts.', 'Criminal', 1872, 'Active', 'https://legislative.gov.in/sites/default/files/A1872-01.pdf'),
('Prevention of Corruption Act', 'Consolidates and amends the law relating to prevention of corruption and matters connected therewith.', 'Criminal', 1988, 'Active', 'https://legislative.gov.in/sites/default/files/A1988-49.pdf'),
('Protection of Children from Sexual Offences Act (POCSO)', 'Provides for protection of children from offences of sexual assault, sexual harassment and pornography.', 'Criminal', 2012, 'Active', 'https://legislative.gov.in/sites/default/files/A2012-32_0.pdf'),

-- Civil Laws
('Code of Civil Procedure (CPC)', 'The procedural law governing civil litigation in India. It regulates every action of a civil court and parties until the execution of decree and order.', 'Civil', 1908, 'Active', 'https://legislative.gov.in/sites/default/files/A1908-05.pdf'),
('Indian Contract Act', 'Regulates contracts in India and determines the circumstances in which promises made by parties to a contract shall be legally binding. It contains the general principles of contract law.', 'Civil', 1872, 'Active', 'https://legislative.gov.in/sites/default/files/A1872-09.pdf'),
('Consumer Protection Act', 'Provides for protection of interests of consumers. It establishes authorities for timely and effective administration and settlement of consumer disputes.', 'Civil', 2019, 'Active', 'https://legislative.gov.in/sites/default/files/A2019-35.pdf'),
('Motor Vehicles Act', 'Regulates all aspects of road transport vehicles. It deals with registration of vehicles, licensing of drivers, control of traffic, insurance, and compensation.', 'Civil', 1988, 'Active', 'https://legislative.gov.in/sites/default/files/A1988-59.pdf'),
('Negotiable Instruments Act', 'Defines and amends the law relating to promissory notes, bills of exchange and cheques.', 'Civil', 1881, 'Active', 'https://legislative.gov.in/sites/default/files/A1881-26.pdf'),
('Arbitration and Conciliation Act', 'Consolidates and amends the law relating to domestic arbitration, international commercial arbitration and enforcement of foreign arbitral awards.', 'Civil', 1996, 'Active', 'https://legislative.gov.in/sites/default/files/A1996-26.pdf'),

-- Property Laws
('Transfer of Property Act', 'Defines and amends the law relating to transfer of property by act of parties. It deals with transfer of property between living persons.', 'Property', 1882, 'Active', 'https://legislative.gov.in/sites/default/files/A1882-04.pdf'),
('Registration Act', 'Consolidates the law relating to registration of documents. It provides for registration of certain documents and matters connected therewith.', 'Property', 1908, 'Active', 'https://legislative.gov.in/sites/default/files/A1908-16_0.pdf'),
('Land Acquisition Act', 'Provides for acquisition of land for public purposes and for matters connected therewith or incidental thereto.', 'Property', 2013, 'Active', 'https://legislative.gov.in/sites/default/files/A2013-30_0.pdf'),

-- Family Laws
('Hindu Marriage Act', 'Codifies the law relating to marriage among Hindus. It deals with conditions for a Hindu Marriage, registration, divorce, judicial separation, restitution of conjugal rights and legitimacy of children.', 'Family', 1955, 'Active', 'https://legislative.gov.in/sites/default/files/A1955-25.pdf'),
('Hindu Succession Act', 'Amends and codifies the law relating to intestate succession among Hindus. It deals with succession and inheritance of property.', 'Family', 1956, 'Active', 'https://legislative.gov.in/sites/default/files/A1956-30.pdf'),
('Dowry Prohibition Act', 'Prohibits the giving or taking of dowry at or before or any time after the marriage. It provides for penalties for violation.', 'Family', 1961, 'Active', 'https://legislative.gov.in/sites/default/files/A1961-28.pdf'),
('Protection of Women from Domestic Violence Act', 'Provides for protection of women from domestic violence and matters connected therewith or incidental thereto.', 'Family', 2005, 'Active', 'https://legislative.gov.in/sites/default/files/A2005-43.pdf'),
('Muslim Personal Law (Shariat) Application Act', 'Provides for the application of Muslim personal law to Muslims in matters of succession, inheritance, marriage and others.', 'Family', 1937, 'Active', 'https://legislative.gov.in/sites/default/files/A1937-26.pdf'),
('Hindu Adoption and Maintenance Act', 'Amends and codifies the law relating to adoptions and maintenance among Hindus.', 'Family', 1956, 'Active', 'https://legislative.gov.in/sites/default/files/A1956-78.pdf'),
('Special Marriage Act', 'Provides a special form of marriage in certain cases and for registration of certain marriages. It applies to all citizens of India.', 'Family', 1954, 'Active', 'https://legislative.gov.in/sites/default/files/A1954-43.pdf'),

-- Labor and Employment Laws
('Minimum Wages Act', 'Provides for minimum rates of wages in certain employments. It aims to prevent exploitation of workers.', 'Labor', 1948, 'Active', 'https://legislative.gov.in/sites/default/files/A1948-11.pdf'),
('Payment of Bonus Act', 'Provides for payment of bonus to employees in certain establishments on the basis of profits or productivity.', 'Labor', 1965, 'Active', 'https://legislative.gov.in/sites/default/files/A1965-21_0.pdf'),
('Industrial Disputes Act', 'Provides for investigation and settlement of industrial disputes. It regulates strikes, lockouts, layoffs and retrenchments.', 'Labor', 1947, 'Active', 'https://legislative.gov.in/sites/default/files/A1947-14.pdf'),
('Employees Provident Funds and Miscellaneous Provisions Act', 'Provides for institution of provident funds, family pension fund and deposit-linked insurance fund for employees.', 'Labor', 1952, 'Active', 'https://legislative.gov.in/sites/default/files/A1952-19.pdf'),
('Employees State Insurance Act', 'Provides for certain benefits to employees in case of sickness, maternity and employment injury.', 'Labor', 1948, 'Active', 'https://legislative.gov.in/sites/default/files/A1948-34.pdf'),
('Payment of Gratuity Act', 'Provides for payment of gratuity to employees engaged in factories, mines, oilfields, plantations, ports, railway companies, shops or other establishments.', 'Labor', 1972, 'Active', 'https://legislative.gov.in/sites/default/files/A1972-39.pdf'),
('Factories Act', 'Regulates labour in factories. It provides for health, safety, welfare, working hours, leave and other matters in relation to workers employed therein.', 'Labor', 1948, 'Active', 'https://legislative.gov.in/sites/default/files/A1948-63.pdf'),
('Sexual Harassment of Women at Workplace Act', 'Provides for protection against sexual harassment of women at workplace and prevention and redressal of complaints.', 'Labor', 2013, 'Active', 'https://legislative.gov.in/sites/default/files/A2013-14_0.pdf'),

-- Tax Laws
('Income Tax Act', 'The charging statute of Income Tax in India. It provides for levy, administration, collection and recovery of Income Tax.', 'Tax', 1961, 'Active', 'https://incometaxindia.gov.in/pages/acts/income-tax-act.aspx'),
('Central Goods and Services Tax Act (CGST)', 'Provides for levy and collection of tax on intra-state supply of goods or services or both by the Central Government.', 'Tax', 2017, 'Active', 'https://legislative.gov.in/sites/default/files/A2017-12.pdf'),
('Customs Act', 'Consolidates and amends the law relating to customs. It regulates imports and exports, and levies customs duties.', 'Tax', 1962, 'Active', 'https://legislative.gov.in/sites/default/files/A1962-52_0.pdf'),
('Integrated Goods and Services Tax Act (IGST)', 'Provides for levy and collection of tax on inter-state supply of goods or services or both.', 'Tax', 2017, 'Active', 'https://legislative.gov.in/sites/default/files/A2017-13.pdf'),

-- Corporate Laws
('Companies Act', 'Consolidates and amends the law relating to companies. It regulates incorporation, responsibilities, directors, dissolution, and winding up of companies.', 'Corporate', 2013, 'Active', 'https://legislative.gov.in/sites/default/files/A2013-18.pdf'),
('Limited Liability Partnership Act', 'Provides for the formation and regulation of limited liability partnerships.', 'Corporate', 2008, 'Active', 'https://legislative.gov.in/sites/default/files/A2009-6.pdf'),
('Securities and Exchange Board of India Act', 'Provides for establishment of Securities and Exchange Board of India to protect interests of investors in securities and to regulate the securities market.', 'Corporate', 1992, 'Active', 'https://legislative.gov.in/sites/default/files/A1992-15.pdf'),
('Competition Act', 'Provides for establishment of Competition Commission of India to prevent practices having adverse effect on competition and to promote and sustain competition in markets.', 'Corporate', 2002, 'Active', 'https://legislative.gov.in/sites/default/files/A2003-12.pdf'),

-- Cyber and IT Laws
('Information Technology Act', 'Provides legal recognition for transactions carried out by electronic data interchange and electronic communication. It deals with cybercrimes and electronic commerce.', 'Cyber', 2000, 'Active', 'https://legislative.gov.in/sites/default/files/A2000-21.pdf'),
('Digital Personal Data Protection Act', 'Provides for the processing of digital personal data in a manner that recognizes both the right of individuals to protect their personal data and the need to process such data for lawful purposes.', 'Cyber', 2023, 'Active', 'https://legislative.gov.in/sites/default/files/A2023-22.pdf'),

-- Constitutional and Rights Laws
('Right to Information Act', 'Provides for setting out the practical regime of right to information for citizens to secure access to information under the control of public authorities.', 'Constitutional', 2005, 'Active', 'https://legislative.gov.in/sites/default/files/A2005-22.pdf'),
('Right to Education Act', 'Provides for free and compulsory education to all children of age six to fourteen years.', 'Constitutional', 2009, 'Active', 'https://legislative.gov.in/sites/default/files/A2009-35.pdf'),
('Scheduled Castes and Scheduled Tribes (Prevention of Atrocities) Act', 'Prevents atrocities against members of Scheduled Castes and Scheduled Tribes.', 'Constitutional', 1989, 'Active', 'https://legislative.gov.in/sites/default/files/A1989-33.pdf'),

-- Other Important Acts
('Juvenile Justice (Care and Protection of Children) Act', 'Consolidates and amends the law relating to children alleged and found to be in conflict with law and children in need of care and protection.', 'Criminal', 2015, 'Active', 'https://legislative.gov.in/sites/default/files/A2016-2.pdf'),
('Environment Protection Act', 'Provides for protection and improvement of environment and for matters connected therewith.', 'Civil', 1986, 'Active', 'https://legislative.gov.in/sites/default/files/A1986-29.pdf'),
('Indian Divorce Act', 'Amends and consolidates the law relating to divorce among Christians.', 'Family', 1869, 'Active', 'https://legislative.gov.in/sites/default/files/A1869-04.pdf'),
('Citizenship Act', 'Provides for acquisition and determination of citizenship.', 'Constitutional', 1955, 'Active', 'https://legislative.gov.in/sites/default/files/A1955-57.pdf'),
('Protection of Human Rights Act', 'Provides for constitution of National Human Rights Commission, State Human Rights Commissions and Human Rights Courts for better protection of human rights.', 'Constitutional', 1993, 'Active', 'https://legislative.gov.in/sites/default/files/A1994-10.pdf');

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
