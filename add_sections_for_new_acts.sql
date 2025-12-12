-- Add sections for Bharatiya Nyaya Sanhita (BNS)
WITH act AS (SELECT id FROM public.bare_acts WHERE short_title = 'BNS' LIMIT 1)
INSERT INTO public.bare_act_sections (bare_act_id, section_number, chapter_number, title, content, sort_order)
VALUES 
((SELECT id FROM act), '1', 'I', 'Short title, commencement and application', 'This Sanhita may be called the Bharatiya Nyaya Sanhita, 2023. It shall come into force on such date as the Central Government may, by notification in the Official Gazette, appoint.', 1),
((SELECT id FROM act), '2', 'I', 'Definitions', 'In this Sanhita, unless the context otherwise requires: "act" denotes as well a series of acts as a single act; "animal" denotes any living creature, other than a human being...', 2),
((SELECT id FROM act), '3', 'II', 'General Explanations', 'Throughout this Sanhita, every definition of an offence, every penal provision, and every illustration of every such definition or penal provision, shall be understood subject to the exceptions contained in the Chapter entitled "General Exceptions".', 3)
ON CONFLICT DO NOTHING;

-- Add sections for Bharatiya Nagarik Suraksha Sanhita (BNSS)
WITH act AS (SELECT id FROM public.bare_acts WHERE short_title = 'BNSS' LIMIT 1)
INSERT INTO public.bare_act_sections (bare_act_id, section_number, chapter_number, title, content, sort_order)
VALUES 
((SELECT id FROM act), '1', 'I', 'Short title, extent and commencement', 'This Sanhita may be called the Bharatiya Nagarik Suraksha Sanhita, 2023. It extends to the whole of India except the State of Nagaland and tribal areas...', 1),
((SELECT id FROM act), '2', 'I', 'Definitions', 'In this Sanhita, unless the context otherwise requires: "audio-video electronic means" shall include use of any communication device for the purposes of video conferencing, recording of processes...', 2),
((SELECT id FROM act), '6', 'II', 'Classes of Criminal Courts', 'Besides the High Courts and the Courts constituted under any law, other than this Sanhita, there shall be, in every State, the following classes of Criminal Courts, namely:— (i) Courts of Session; (ii) Judicial Magistrates of the first class; (iii) Judicial Magistrates of the second class; and (iv) Executive Magistrates.', 3)
ON CONFLICT DO NOTHING;

-- Add sections for Digital Personal Data Protection Act (DPDP)
WITH act AS (SELECT id FROM public.bare_acts WHERE short_title = 'DPDP Act' LIMIT 1)
INSERT INTO public.bare_act_sections (bare_act_id, section_number, chapter_number, title, content, sort_order)
VALUES 
((SELECT id FROM act), '1', 'I', 'Short title and commencement', 'This Act may be called the Digital Personal Data Protection Act, 2023. It shall come into force on such date as the Central Government may, by notification in the Official Gazette, appoint.', 1),
((SELECT id FROM act), '2', 'I', 'Definitions', '(a) "Appellate Tribunal" means the Telecom Disputes Settlement and Appellate Tribunal established under section 14 of the Telecom Regulatory Authority of India Act, 1997; (b) "automated" means any digital process capable of operating without human intervention...', 2),
((SELECT id FROM act), '3', 'I', 'Application of Act', 'The provisions of this Act shall apply to the processing of digital personal data within the territory of India where: (a) such personal data is collected in digital form; or (b) such personal data is collected in non-digital form and subsequently digitised.', 3)
ON CONFLICT DO NOTHING;

-- Add sections for Companies Act, 2013
WITH act AS (SELECT id FROM public.bare_acts WHERE short_title = 'Companies Act' LIMIT 1)
INSERT INTO public.bare_act_sections (bare_act_id, section_number, chapter_number, title, content, sort_order)
VALUES 
((SELECT id FROM act), '1', 'I', 'Short title, extent, commencement and application', 'This Act may be called the Companies Act, 2013. It extends to the whole of India...', 1),
((SELECT id FROM act), '2', 'I', 'Definitions', 'In this Act, unless the context otherwise requires,— (1) "abridged prospectus" means a memorandum containing such salient features of a prospectus as may be specified by the Securities and Exchange Board by making regulations in this behalf...', 2),
((SELECT id FROM act), '3', 'II', 'Formation of company', 'A company may be formed for any lawful purpose by— (a) seven or more persons, where the company to be formed is to be a public company; (b) two or more persons, where the company to be formed is to be a private company; or (c) one person, where the company to be formed is to be One Person Company...', 3)
ON CONFLICT DO NOTHING;

-- Add sections for Hindu Marriage Act
WITH act AS (SELECT id FROM public.bare_acts WHERE short_title = 'HMA' LIMIT 1)
INSERT INTO public.bare_act_sections (bare_act_id, section_number, chapter_number, title, content, sort_order)
VALUES 
((SELECT id FROM act), '1', 'I', 'Short title and extent', 'This Act may be called the Hindu Marriage Act, 1955. It extends to the whole of India except the State of Jammu and Kashmir.', 1),
((SELECT id FROM act), '2', 'I', 'Application of Act', 'This Act applies— (a) to any person who is a Hindu by religion in any of its forms or developments, including a Virashaiva, a Lingayat or a follower of the Brahmo, Prarthana or Arya Samaj...', 2),
((SELECT id FROM act), '5', 'II', 'Conditions for a Hindu marriage', 'A marriage may be solemnized between any two Hindus, if the following conditions are fulfilled, namely:— (i) neither party has a spouse living at the time of the marriage; (ii) at the time of the marriage, neither party— (a) is incapable of giving a valid consent to it in consequence of unsoundness of mind...', 3)
ON CONFLICT DO NOTHING;
