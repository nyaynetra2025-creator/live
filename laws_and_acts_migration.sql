-- Migration: Create laws_and_acts table with sample data
-- This table stores Indian laws and acts with their details

CREATE TABLE IF NOT EXISTS laws_and_acts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  category TEXT NOT NULL,
  year_enacted INTEGER,
  last_amended_date DATE,
  description TEXT,
  official_url TEXT,
  status TEXT DEFAULT 'Active',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE laws_and_acts ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can read laws
CREATE POLICY "Anyone can read laws"
  ON laws_and_acts FOR SELECT
  USING (true);

-- Policy: Only authenticated service role can insert/update
CREATE POLICY "Service role can modify laws"
  ON laws_and_acts FOR ALL
  USING (auth.role() = 'service_role');

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_laws_category ON laws_and_acts(category);
CREATE INDEX IF NOT EXISTS idx_laws_status ON laws_and_acts(status);
CREATE INDEX IF NOT EXISTS idx_laws_title ON laws_and_acts USING gin(to_tsvector('english', title));
CREATE INDEX IF NOT EXISTS idx_laws_description ON laws_and_acts USING gin(to_tsvector('english', description));

-- Insert sample Indian laws data
INSERT INTO laws_and_acts (title, category, year_enacted, description, official_url, status) VALUES
-- Constitutional Laws
('Constitution of India', 'Constitutional', 1950, 'The supreme law of India. It lays down the framework defining fundamental political principles, establishes the structure, procedures, powers and duties of government institutions and sets out fundamental rights, directive principles and duties of citizens.', 'https://legislative.gov.in/constitution-of-india', 'Active'),

-- Criminal Laws
('Indian Penal Code (IPC)', 'Criminal', 1860, 'The main criminal code of India that covers all substantive aspects of criminal law. It defines crimes and provides punishments for almost all kinds of criminal and actionable wrongs.', 'https://legislative.gov.in/indian-penal-code-1860', 'Active'),

('Code of Criminal Procedure (CrPC)', 'Criminal', 1973, 'The main legislation on procedural aspects of criminal law in India. It provides the machinery for the investigation of crime, apprehension of suspected criminals, collection of evidence, determination of guilt or innocence of the accused person and the determination of punishment.', 'https://legislative.gov.in/code-criminal-procedure-1973', 'Active'),

('Bharatiya Nyaya Sanhita (BNS)', 'Criminal', 2023, 'Modern replacement for the Indian Penal Code. It modernizes criminal law provisions while retaining the essence of justice delivery. Effective from July 1, 2024.', 'https://legislative.gov.in/bharatiya-nyaya-sanhita-2023', 'Active'),

-- Civil Laws
('Code of Civil Procedure (CPC)', 'Civil', 1908, 'The procedural law governing civil litigation in India. It regulates every action of a civil court and parties until the execution of decree and order.', 'https://legislative.gov.in/code-civil-procedure-1908', 'Active'),

('Indian Contract Act', 'Civil', 1872, 'Regulates contracts in India and determines the circumstances in which promises made by parties to a contract shall be legally binding. It contains the general principles of contract law.', 'https://legislative.gov.in/indian-contract-act-1872', 'Active'),

('Transfer of Property Act', 'Property', 1882, 'Defines and amends the law relating to transfer of property by act of parties. It deals with transfer of property between living persons.', 'https://legislative.gov.in/transfer-property-act-1882', 'Active'),

-- Evidence and Procedure
('Indian Evidence Act', 'Criminal', 1872, 'The law of evidence in India. It contains a set of rules and allied issues governing admissibility of evidence in Indian courts.', 'https://legislative.gov.in/indian-evidence-act-1872', 'Active'),

-- Family Laws
('Hindu Marriage Act', 'Family', 1955, 'Codifies the law relating to marriage among Hindus. It deals with conditions for a Hindu Marriage, registration, divorce, judicial separation, restitution of conjugal rights and legitimacy of children.', 'https://legislative.gov.in/hindu-marriage-act-1955', 'Active'),

('Hindu Succession Act', 'Family', 1956, 'Amends and codifies the law relating to intestate succession among Hindus. It deals with succession and inheritance of property.', 'https://legislative.gov.in/hindu-succession-act-1956', 'Active'),

('Dowry Prohibition Act', 'Family', 1961, 'Prohibits the giving or taking of dowry at or before or any time after the marriage. It provides for penalties for violation.', 'https://legislative.gov.in/dowry-prohibition-act-1961', 'Active'),

('Protection of Women from Domestic Violence Act', 'Family', 2005, 'Provides for protection of women from domestic violence and matters connected therewith or incidental thereto.', 'https://legislative.gov.in/protection-women-domestic-violence-act-2005', 'Active'),

-- Labor and Employment
('Minimum Wages Act', 'Labor', 1948, 'Provides for minimum rates of wages in certain employments. It aims to prevent exploitation of workers.', 'https://legislative.gov.in/minimum-wages-act-1948', 'Active'),

('Payment of Bonus Act', 'Labor', 1965, 'Provides for payment of bonus to employees in certain establishments on the basis of profits or productivity.', 'https://legislative.gov.in/payment-bonus-act-1965', 'Active'),

('Industrial Disputes Act', 'Labor', 1947, 'Provides for investigation and settlement of industrial disputes. It regulates strikes, lockouts, layoffs and retrenchments.', 'https://legislative.gov.in/industrial-disputes-act-1947', 'Active'),

-- Consumer Protection
('Consumer Protection Act', 'Civil', 2019, 'Provides for protection of interests of consumers. It establishes authorities for timely and effective administration and settlement of consumer disputes.', 'https://legislative.gov.in/consumer-protection-act-2019', 'Active'),

-- Information Technology
('Information Technology Act', 'Cyber', 2000, 'Provides legal recognition for transactions carried out by electronic data interchange and electronic communication. It deals with cybercrimes and electronic commerce.', 'https://legislative.gov.in/information-technology-act-2000', 'Active'),

-- Right to Information
('Right to Information Act', 'Constitutional', 2005, 'Provides for setting out the practical regime of right to information for citizens to secure access to information under the control of public authorities.', 'https://legislative.gov.in/right-information-act-2005', 'Active'),

-- Motor Vehicles
('Motor Vehicles Act', 'Civil', 1988, 'Regulates all aspects of road transport vehicles. It deals with registration of vehicles, licensing of drivers, control of traffic, insurance, and compensation.', 'https://legislative.gov.in/motor-vehicles-act-1988', 'Active'),

-- Tax Laws
('Income Tax Act', 'Tax', 1961, 'The charging statute of Income Tax in India. It provides for levy, administration, collection and recovery of Income Tax.', 'https://legislative.gov.in/income-tax-act-1961', 'Active'),

('Central Goods and Services Tax Act (CGST)', 'Tax', 2017, 'Provides for levy and collection of tax on intra-state supply of goods or services or both by the Central Government.', 'https://legislative.gov.in/central-goods-and-services-tax-act-2017', 'Active'),

-- Corporate Law
('Companies Act', 'Corporate', 2013, 'Consolidates and amends the law relating to companies. It regulates incorporation, responsibilities, directors, dissolution, and winding up of companies.', 'https://legislative.gov.in/companies-act-2013', 'Active'),

-- Special Acts
('Prevention of Corruption Act', 'Criminal', 1988, 'Consolidates and amends the law relating to prevention of corruption and matters connected therewith.', 'https://legislative.gov.in/prevention-corruption-act-1988', 'Active'),

('Protection of Children from Sexual Offences Act (POCSO)', 'Criminal', 2012, 'Provides for protection of children from offences of sexual assault, sexual harassment and pornography.', 'https://legislative.gov.in/pocso-act-2012', 'Active'),

('Negotiable Instruments Act', 'Civil', 1881, 'Defines and amends the law relating to promissory notes, bills of exchange and cheques.', 'https://legislative.gov.in/negotiable-instruments-act-1881', 'Active'),

('Arbitration and Conciliation Act', 'Civil', 1996, 'Consolidates and amends the law relating to domestic arbitration, international commercial arbitration and enforcement of foreign arbitral awards.', 'https://legislative.gov.in/arbitration-conciliation-act-1996', 'Active');

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
   NEW.updated_at = NOW();
   RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_laws_and_acts_updated_at BEFORE UPDATE ON laws_and_acts
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
