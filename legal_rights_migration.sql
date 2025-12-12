-- Migration: Create legal_rights table for comprehensive legal rights information
-- This table stores fundamental rights, constitutional rights, and citizen rights from Indian law

-- Create the legal_rights table
CREATE TABLE IF NOT EXISTS legal_rights (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    category TEXT NOT NULL,
    article_number TEXT,
    source_law TEXT,
    source_url TEXT,
    key_points JSONB DEFAULT '[]'::jsonb,
    examples JSONB DEFAULT '[]'::jsonb,
    related_rights JSONB DEFAULT '[]'::jsonb,
    remedies TEXT,
    applicable_to TEXT DEFAULT 'All Citizens',
    status TEXT DEFAULT 'Active',
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_legal_rights_category ON legal_rights(category);
CREATE INDEX IF NOT EXISTS idx_legal_rights_status ON legal_rights(status);

-- Enable RLS
ALTER TABLE legal_rights ENABLE ROW LEVEL SECURITY;

-- Create policy for public read access
CREATE POLICY "Allow public read access" ON legal_rights
    FOR SELECT USING (true);

-- Insert comprehensive legal rights data from Indian Constitution and Laws

-- FUNDAMENTAL RIGHTS (Part III of Constitution)
INSERT INTO legal_rights (title, description, category, article_number, source_law, key_points, examples, remedies, applicable_to) VALUES

-- Right to Equality (Articles 14-18)
('Right to Equality', 
'The State shall not deny to any person equality before the law or the equal protection of the laws within the territory of India. This is the foundation of democratic governance.',
'Fundamental Rights',
'Article 14',
'Constitution of India',
'["All persons are equal before law", "Equal protection of laws to everyone", "Prohibition of discrimination on grounds of religion, race, caste, sex or place of birth", "Equality of opportunity in public employment", "Abolition of untouchability"]'::jsonb,
'["A person cannot be denied job based on caste", "All citizens can access public places equally", "No special privileges for any class"]'::jsonb,
'Can file writ petition under Article 32 (Supreme Court) or Article 226 (High Court)',
'All Persons'),

('Prohibition of Discrimination',
'The State shall not discriminate against any citizen on grounds only of religion, race, caste, sex, place of birth or any of them. No citizen shall be subjected to any disability, liability, restriction or condition.',
'Fundamental Rights',
'Article 15',
'Constitution of India',
'["No discrimination in access to shops, public restaurants, hotels", "No discrimination in use of wells, tanks, bathing ghats, roads", "Special provisions for women and children allowed", "Special provisions for SC/ST and backward classes allowed"]'::jsonb,
'["Women can have reserved seats in buses", "SC/ST reservations in education", "Separate queues for women at public places"]'::jsonb,
'File complaint with National/State Human Rights Commission or approach courts',
'All Citizens'),

('Right to Freedom of Speech and Expression',
'All citizens have the right to freedom of speech and expression, to assemble peaceably and without arms, to form associations or unions, to move freely throughout India, to reside and settle in any part of India, and to practice any profession.',
'Fundamental Rights',
'Article 19',
'Constitution of India',
'["Freedom of speech and expression", "Right to assemble peacefully", "Right to form associations", "Right to move freely in India", "Right to reside anywhere in India", "Right to practice any profession", "Subject to reasonable restrictions"]'::jsonb,
'["Publishing newspapers", "Conducting peaceful protests", "Starting a business", "Moving to any city for work", "Forming trade unions"]'::jsonb,
'Approach High Court or Supreme Court for protection of these freedoms',
'Citizens Only'),

('Right to Life and Personal Liberty',
'No person shall be deprived of his life or personal liberty except according to procedure established by law. This is the most fundamental of all rights and has been expanded to include right to live with dignity.',
'Fundamental Rights',
'Article 21',
'Constitution of India',
'["Right to life with human dignity", "Right to livelihood", "Right to health", "Right to clean environment", "Right to privacy", "Right to shelter", "Right against torture", "Right to speedy trial", "Right to legal aid"]'::jsonb,
'["Getting free legal aid in criminal cases", "Prisoners right to humane treatment", "Right to clean drinking water", "Right to emergency medical care", "Protection of personal data"]'::jsonb,
'Habeas Corpus petition, writ petitions under Articles 32 and 226',
'All Persons'),

('Right to Education',
'The State shall provide free and compulsory education to all children of the age of six to fourteen years. Every child has right to full time elementary education of satisfactory quality.',
'Fundamental Rights',
'Article 21A',
'Constitution of India, Right to Education Act 2009',
'["Free education from age 6 to 14", "Compulsory education", "No capitation fee", "No screening for admission", "25% reservation in private schools for EWS", "Trained teachers mandatory", "No corporal punishment"]'::jsonb,
'["Free admission in government schools", "No child can be denied admission", "Mid-day meal schemes", "Free textbooks and uniforms for poor students"]'::jsonb,
'Approach school management, Local Authority, or file case under RTE Act',
'Children aged 6-14'),

('Right Against Exploitation',
'Traffic in human beings and begar and other similar forms of forced labour are prohibited. No child below fourteen years shall be employed in any factory or mine or engaged in any hazardous employment.',
'Fundamental Rights',
'Articles 23-24',
'Constitution of India, Child Labour Act',
'["Prohibition of human trafficking", "Prohibition of forced labor", "Prohibition of child labor in hazardous work", "No bondage due to debt", "Penalty for violations"]'::jsonb,
'["Reporting bonded labor to authorities", "Rescue of trafficked persons", "Rehabilitation of child laborers"]'::jsonb,
'Report to Labour Department, Police, or National Commission for Protection of Child Rights',
'All Persons'),

('Right to Freedom of Religion',
'All persons are equally entitled to freedom of conscience and the right freely to profess, practice and propagate religion. Religious denominations can manage their own affairs in matters of religion.',
'Fundamental Rights',
'Articles 25-28',
'Constitution of India',
'["Freedom of conscience", "Right to practice religion", "Right to propagate religion", "Right to manage religious affairs", "Freedom from religious instruction in state institutions", "Subject to public order, morality and health"]'::jsonb,
'["Building places of worship", "Celebrating religious festivals", "Religious organizations running educational institutions"]'::jsonb,
'Approach civil courts or file writ petition in High Court/Supreme Court',
'All Persons'),

('Cultural and Educational Rights',
'Any section of citizens having a distinct language, script or culture shall have the right to conserve the same. All minorities have the right to establish and administer educational institutions of their choice.',
'Fundamental Rights',
'Articles 29-30',
'Constitution of India',
'["Right to conserve distinct culture", "Right to conserve language", "Minorities can establish educational institutions", "No discrimination in state-aided institutions", "State can regulate but not take over minority institutions"]'::jsonb,
'["Minority schools and colleges", "Cultural organizations", "Language preservation programs"]'::jsonb,
'Approach National Commission for Minorities or file writ petition',
'Cultural/Linguistic Minorities'),

('Right to Constitutional Remedies',
'The right to move the Supreme Court for enforcement of fundamental rights is guaranteed. The Supreme Court has power to issue writs including habeas corpus, mandamus, prohibition, quo warranto and certiorari.',
'Fundamental Rights',
'Article 32',
'Constitution of India',
'["Right to approach Supreme Court", "Writs: Habeas Corpus, Mandamus, Prohibition, Certiorari, Quo Warranto", "Cannot be suspended except during emergency", "Dr. Ambedkar called it the heart and soul of Constitution"]'::jsonb,
'["Filing PIL for public issues", "Challenging unlawful detention", "Compelling officials to perform duties"]'::jsonb,
'Direct petition to Supreme Court under Article 32 or High Court under Article 226',
'All Persons'),

-- Consumer Rights
('Right to Safety',
'Consumers have the right to be protected against marketing of goods and services which are hazardous to life and property.',
'Consumer Rights',
NULL,
'Consumer Protection Act 2019',
'["Protection from dangerous products", "Right to safe goods and services", "Product liability", "Manufacturers responsible for defects"]'::jsonb,
'["Defective vehicle causing accident", "Contaminated food products", "Unsafe electrical appliances"]'::jsonb,
'File complaint with Consumer Forum, District/State/National Commission',
'All Consumers'),

('Right to Information (RTI)',
'Every citizen has the right to get information from public authorities. Information includes records, documents, memos, emails, opinions, press releases, circulars, contracts, samples, and electronic data.',
'Civic Rights',
'Section 3',
'Right to Information Act 2005',
'["Request information from any public authority", "Reply within 30 days mandatory", "Nominal fee of Rs.10", "First appeal and second appeal available", "Certain information exempted", "Penalty for non-compliance"]'::jsonb,
'["Asking for road construction details", "Getting information on government schemes", "Checking status of pending applications"]'::jsonb,
'File application with PIO, then First Appellate Authority, then Information Commission',
'All Citizens'),

('Right to Fair Compensation (Land Acquisition)',
'When government acquires private land for public purpose, the affected families are entitled to fair compensation, rehabilitation and resettlement.',
'Property Rights',
NULL,
'Right to Fair Compensation and Transparency in Land Acquisition, Rehabilitation and Resettlement Act 2013',
'["Market value compensation", "Solatium of 100%", "Monthly annuity for livelihood losers", "Jobs for affected families", "Resettlement allowance", "Social Impact Assessment mandatory"]'::jsonb,
'["Compensation for land acquired for highways", "Rehabilitation for dam project affected families"]'::jsonb,
'Appeal to Land Acquisition Authority, then High Court',
'Land Owners and Affected Families'),

('Right to Food Security',
'Entitled persons have the right to receive subsidized food grains from the Government. Priority households receive 5 kg per person per month at Rs.3/2/1 for rice/wheat/coarse grains.',
'Social Rights',
NULL,
'National Food Security Act 2013',
'["5 kg food grains per person per month", "Subsidized rates", "Antyodaya households get 35 kg per month", "Maternity benefit of Rs.6000", "Meal for children under 6", "Mid-day meal for students", "Food security allowance if grains not supplied"]'::jsonb,
'["Getting ration from PDS shops", "Mid-day meals in schools", "Integrated Child Development Services"]'::jsonb,
'Approach District Grievance Redressal Officer or State Food Commission',
'BPL Families, Priority Households'),

('Right to Work (MGNREGA)',
'Every rural household has the right to demand 100 days of guaranteed wage employment in a financial year. Work should be provided within 15 days of demand or unemployment allowance paid.',
'Employment Rights',
NULL,
'Mahatma Gandhi National Rural Employment Guarantee Act 2005',
'["100 days guaranteed employment", "Minimum wages", "Work within 5 km", "If not 5 km, travel allowance", "Unemployment allowance if work not given", "Worksite facilities like creche, drinking water", "Equal wages for men and women"]'::jsonb,
'["Demanding work from Gram Panchayat", "Getting job card", "Water conservation works", "Road construction"]'::jsonb,
'Approach Gram Rozgar Sahayak, then Programme Officer, then Ombudsman',
'Rural Households'),

-- Women Rights
('Protection from Domestic Violence',
'Women have the right to be protected from domestic violence including physical, sexual, verbal, emotional and economic abuse. They have right to residence in shared household.',
'Women Rights',
NULL,
'Protection of Women from Domestic Violence Act 2005',
'["Protection from physical violence", "Protection from sexual abuse", "Protection from verbal abuse", "Right to residence", "Monetary relief", "Custody of children", "Protection orders available"]'::jsonb,
'["Filing complaint against abusive husband", "Seeking residence order", "Getting maintenance"]'::jsonb,
'Approach Protection Officer, file complaint at Magistrate Court, seek help from NGOs',
'All Women'),

('Right to Equal Pay',
'Women are entitled to equal pay for equal work or work of similar nature. No employer shall pay to any worker remuneration less than that payable to the opposite sex.',
'Women Rights',
NULL,
'Equal Remuneration Act 1976',
'["Equal pay for equal work", "No discrimination in recruitment", "No discrimination in promotion", "Complaint mechanism available"]'::jsonb,
'["Same salary for male and female teachers", "Equal wages for factory workers"]'::jsonb,
'File complaint with Labour Inspector or approach Labour Court',
'Working Women'),

('Maternity Benefits',
'Women employees are entitled to 26 weeks of paid maternity leave. For women having 2 or more children, benefit is 12 weeks. Employer cannot terminate during maternity.',
'Women Rights',
NULL,
'Maternity Benefit Act 1961 (Amended 2017)',
'["26 weeks paid leave", "12 weeks for 3rd child onwards", "Work from home option", "Creche facility mandatory for 50+ employees", "Medical bonus", "No termination during maternity"]'::jsonb,
'["Taking maternity leave from private company", "Availing creche facility", "Getting medical bonus"]'::jsonb,
'Approach Labour Commissioner or file case in Labour Court',
'Women Employees'),

('Protection Against Sexual Harassment at Workplace',
'Every woman has the right to be protected from sexual harassment at workplace. Internal Complaints Committee must be constituted by every employer with 10 or more employees.',
'Women Rights',
NULL,
'Sexual Harassment of Women at Workplace (Prevention, Prohibition and Redressal) Act 2013',
'["Protection from sexual harassment", "Internal Complaints Committee mandatory", "Local Complaints Committee at district level", "Inquiry within 90 days", "Employer responsible for safe environment", "Confidentiality of proceedings"]'::jsonb,
'["Filing complaint against colleague", "Reporting harassment to ICC", "Approaching Local Committee if employer has less than 10 employees"]'::jsonb,
'File complaint with Internal Complaints Committee within 3 months, appeal to court',
'Working Women'),

-- Senior Citizen Rights
('Right to Maintenance by Children',
'Senior citizens and parents have the right to claim maintenance from their children if they are unable to maintain themselves. Children are legally bound to support parents.',
'Senior Citizen Rights',
NULL,
'Maintenance and Welfare of Parents and Senior Citizens Act 2007',
'["Children must maintain parents", "Maximum maintenance Rs.10,000/month per parent", "Property can be cancelled if parents evicted", "Old age homes to be established", "Punishment for abandonment", "Tribunal to decide within 90 days"]'::jsonb,
'["Claiming maintenance from son/daughter", "Cancelling property transfer if abandoned", "Seeking admission in old age home"]'::jsonb,
'Approach Maintenance Tribunal (SDM/BDO level), appeal to Appellate Tribunal',
'Senior Citizens (60+)'),

-- Disability Rights
('Rights of Persons with Disabilities',
'Persons with disabilities have equal rights in all aspects of life including education, employment, access to justice, healthcare, and political participation. 4% reservation in government jobs.',
'Disability Rights',
NULL,
'Rights of Persons with Disabilities Act 2016',
'["21 types of disabilities covered", "4% reservation in govt jobs", "5% reservation in higher education", "Free education till 18 years", "Accessible buildings mandatory", "Guardianship rights", "Special courts for speedy trial"]'::jsonb,
'["Getting disability certificate", "Availing reservation in jobs", "Accessible ramps and lifts", "Sign language interpreters"]'::jsonb,
'Approach Chief Commissioner or State Commissioner for Persons with Disabilities',
'Persons with Disabilities'),

-- Children Rights
('Protection from Child Marriage',
'No marriage of a girl below 18 years or boy below 21 years is valid. Such marriages are voidable at the option of the minor. Punishment for promoting child marriage.',
'Children Rights',
NULL,
'Prohibition of Child Marriage Act 2006',
'["Minimum age: 18 for girls, 21 for boys", "Child marriage voidable", "Punishment up to 2 years for adult males marrying child", "Maintenance for girl child", "Child Marriage Prohibition Officers appointed"]'::jsonb,
'["Stopping child marriage ceremony", "Seeking annulment of child marriage", "Claiming maintenance"]'::jsonb,
'Report to Child Marriage Prohibition Officer, Police, or approach court',
'Children'),

('Protection of Children from Sexual Offences (POCSO)',
'Children below 18 years are protected from sexual assault, harassment, and pornography. Special procedures for child-friendly trial. Stringent punishments for offenders.',
'Children Rights',
NULL,
'Protection of Children from Sexual Offences Act 2012',
'["Protects children under 18", "Covers penetrative and non-penetrative assault", "Child pornography punishable", "Special courts for speedy trial", "Child-friendly procedures", "Identity of child protected"]'::jsonb,
'["Reporting sexual abuse of child", "Child-friendly court procedures", "Compensation to victim"]'::jsonb,
'Report to Police (special cell), Child Welfare Committee, or call Childline 1098',
'Children under 18'),

-- Labour Rights
('Right to Minimum Wages',
'Every worker is entitled to be paid at least the minimum wage fixed by the Government. Payment should be regular and cannot be delayed unreasonably.',
'Labour Rights',
NULL,
'Minimum Wages Act 1948, Code on Wages 2019',
'["Minimum wages vary by state and industry", "Overtime at double rate", "Rest days mandatory", "Payment in legal tender", "Deductions limited"]'::jsonb,
'["Construction workers", "Factory workers", "Agricultural laborers", "Domestic workers"]'::jsonb,
'Approach Labour Commissioner, file claim in Labour Court',
'All Workers'),

('Right to Social Security (EPF & ESI)',
'Employees are entitled to provident fund and insurance benefits. 12% contribution from employee and employer each. Medical benefits under ESI.',
'Labour Rights',
NULL,
'Employees Provident Funds Act 1952, ESI Act 1948',
'["12% EPF contribution each from employee and employer", "Pension benefit", "Insurance benefit", "Medical care under ESI", "Gratuity after 5 years"]'::jsonb,
'["Withdrawing PF for medical emergency", "ESI coverage for surgery", "Family pension to widow"]'::jsonb,
'Approach EPF Commissioner, ESI Courts, or Labour Court',
'Organized Sector Employees'),

-- Environment Rights
('Right to Clean Environment',
'Every person has the right to live in a clean and healthy environment. This is part of Right to Life under Article 21. NGT has power to hear environmental disputes.',
'Environmental Rights',
NULL,
'Environment Protection Act 1986, NGT Act 2010',
'["Clean air and water are fundamental rights", "Polluter pays principle", "Environmental clearance mandatory for projects", "National Green Tribunal for environmental issues", "Environmental awareness"]'::jsonb,
'["Filing case against polluting factory", "Challenging illegal mining", "Protecting forests"])","Remedies","Applicable_To",
'Approach National Green Tribunal, Pollution Control Board, or High Court',
'All Persons');

-- Add more rights as needed...
