-- Insert major recent and historical acts
INSERT INTO public.bare_acts (title, short_title, act_number, year_enacted, description, jurisdiction, category, official_url)
VALUES
-- 2023 New Criminal Laws
('The Bharatiya Nyaya Sanhita, 2023', 'BNS', '45', 2023, 'Consolidates and amends the provisions relating to offences and for matters connected therewith or incidental thereto. Replaces IPC.', 'Central', 'Criminal Laws', 'https://www.indiacode.nic.in/handle/123456789/1362/browse?type=act'),
('The Bharatiya Nagarik Suraksha Sanhita, 2023', 'BNSS', '46', 2023, 'Consolidates and amends the law relating to Criminal Procedure. Replaces CrPC.', 'Central', 'Criminal Laws', 'https://www.indiacode.nic.in/handle/123456789/1362/browse?type=act'),
('The Bharatiya Sakshya Adhiniyam, 2023', 'BSA', '47', 2023, 'Consolidates and provides for the general rules and principles of evidence for fair trial. Replaces Indian Evidence Act.', 'Central', 'Criminal Laws', 'https://www.indiacode.nic.in/handle/123456789/1362/browse?type=act'),

-- Recent Major Acts (2023-2024)
('The Digital Personal Data Protection Act, 2023', 'DPDP Act', '22', 2023, 'An Act to provide for the processing of digital personal data in a manner that recognises both the right of individuals to protect their personal data and the need to process such personal data for lawful purposes.', 'Central', 'Cyber & IT', 'https://www.indiacode.nic.in/handle/123456789/1362/browse?type=act'),
('The Telecommunications Act, 2023', 'Telecom Act', '44', 2023, 'An Act to amend and consolidate the law relating to development, expansion and operation of telecommunication services and telecommunication networks; assignment of spectrum; and for matters connected therewith.', 'Central', 'Cyber & IT', 'https://www.indiacode.nic.in/handle/123456789/1362/browse?type=act'),
('The Constitution (One Hundred and Sixth Amendment) Act, 2023', 'Nari Shakti Vandan Adhiniyam', '106', 2023, 'To provide 33 percent reservation to women in Lok Sabha and State Legislative Assemblies.', 'Central', 'Constitution', 'https://www.indiacode.nic.in/handle/123456789/1362/browse?type=act'),

-- Corporate & Business
('The Companies Act, 2013', 'Companies Act', '18', 2013, 'An Act to consolidate and amend the law relating to companies.', 'Central', 'Business', 'https://www.indiacode.nic.in/handle/123456789/1362/browse?type=act'),
('The Insolvency and Bankruptcy Code, 2016', 'IBC', '31', 2016, 'An Act to consolidate and amend the laws relating to reorganization and insolvency resolution of corporate persons, partnership firms and individuals.', 'Central', 'Business', 'https://www.indiacode.nic.in/handle/123456789/1362/browse?type=act'),
('The Competition Act, 2002', 'Competition Act', '12', 2003, 'An Act to provide, keeping in view of the economic development of the country, for the establishment of a Commission to prevent practices having adverse effect on competition.', 'Central', 'Business', 'https://www.indiacode.nic.in/handle/123456789/1362/browse?type=act'),

-- Tax
('The Central Goods and Services Tax Act, 2017', 'CGST Act', '12', 2017, 'An Act to make a provision for levy and collection of tax on intra-State supply of goods or services or both.', 'Central', 'Taxation', 'https://www.indiacode.nic.in/handle/123456789/1362/browse?type=act'),
('The Integrated Goods and Services Tax Act, 2017', 'IGST Act', '13', 2017, 'An Act to make a provision for levy and collection of tax on inter-State supply of goods or services or both.', 'Central', 'Taxation', 'https://www.indiacode.nic.in/handle/123456789/1362/browse?type=act'),
('The Income-tax Act, 1961', 'Income Tax Act', '43', 1961, 'An Act to consolidate and amend the law relating to income-tax and super-tax.', 'Central', 'Taxation', 'https://www.indiacode.nic.in/handle/123456789/1362/browse?type=act'),

-- Labor & Employment
('The Code on Wages, 2019', 'Wage Code', '29', 2019, 'An Act to amend and consolidate the laws relating to wages and bonus and matters connected therewith or incidental thereto.', 'Central', 'Employment', 'https://www.indiacode.nic.in/handle/123456789/1362/browse?type=act'),
('The Industrial Relations Code, 2020', 'IR Code', '35', 2020, 'An Act to consolidate and amend the laws relating to Trade Unions, conditions of employment in industrial establishment or undertaking, investigation and settlement of industrial disputes.', 'Central', 'Employment', 'https://www.indiacode.nic.in/handle/123456789/1362/browse?type=act'),
('The Code on Social Security, 2020', 'Social Security Code', '36', 2020, 'An Act to amend and consolidate the laws relating to social security with the goal to extend social security to all employees and workers either in the organised or unorganised or any other sectors.', 'Central', 'Employment', 'https://www.indiacode.nic.in/handle/123456789/1362/browse?type=act'),

-- Cyber & IT
('The Information Technology Act, 2000', 'IT Act', '21', 2000, 'An Act to provide legal recognition for transactions carried out by means of electronic data interchange and other means of electronic communication.', 'Central', 'Cyber & IT', 'https://www.indiacode.nic.in/handle/123456789/1362/browse?type=act'),

-- Property & Family
('The Transfer of Property Act, 1882', 'TPA', '4', 1882, 'An Act to amend the law relating to the Transfer of Property by act of parties.', 'Central', 'Property', 'https://www.indiacode.nic.in/handle/123456789/1362/browse?type=act'),
('The Benami Transactions (Prohibition) Act, 1988', 'Benami Act', '45', 1988, 'An Act to prohibit benami transactions and the right to recover property held benami.', 'Central', 'Property', 'https://www.indiacode.nic.in/handle/123456789/1362/browse?type=act'),
('The Hindu Marriage Act, 1955', 'HMA', '25', 1955, 'An Act to amend and codify the law relating to marriage among Hindus.', 'Central', 'Family', 'https://www.indiacode.nic.in/handle/123456789/1362/browse?type=act'),
('The Special Marriage Act, 1954', 'SMA', '43', 1954, 'An Act to provide a special form of marriage for the people of India and all Indian nationals in foreign countries.', 'Central', 'Family', 'https://www.indiacode.nic.in/handle/123456789/1362/browse?type=act')

ON CONFLICT (title) DO NOTHING;
