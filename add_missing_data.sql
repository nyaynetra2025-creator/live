-- Add sections for Constitution (106th Amendment) Act, 2023
WITH act AS (SELECT id FROM public.bare_acts WHERE short_title = 'Nari Shakti Vandan Adhiniyam' LIMIT 1)
INSERT INTO public.bare_act_sections (bare_act_id, section_number, chapter_number, title, content, sort_order)
VALUES 
((SELECT id FROM act), '1', 'I', 'Short title and commencement', '(1) This Act may be called the Constitution (One Hundred and Sixth Amendment) Act, 2023. (2) It shall come into force on such date as the Central Government may, by notification in the Official Gazette, appoint.', 1),
((SELECT id FROM act), '2', 'I', 'Insertion of new article 330A', 'After article 330 of the Constitution, the following article shall be inserted, namely:— "330A. (1) Seats shall be reserved for women in the House of the People. (2) The number of seats reserved for women shall be, as nearly as may be, one-third of the total number of seats filled by direct election..."', 2),
((SELECT id FROM act), '3', 'I', 'Insertion of new article 332A', 'After article 332 of the Constitution, the following article shall be inserted, namely:— "332A. (1) Seats shall be reserved for women in the Legislative Assembly of every State..."', 3)
ON CONFLICT DO NOTHING;

-- Add sections for Telecommunications Act, 2023
WITH act AS (SELECT id FROM public.bare_acts WHERE short_title = 'Telecom Act' LIMIT 1)
INSERT INTO public.bare_act_sections (bare_act_id, section_number, chapter_number, title, content, sort_order)
VALUES 
((SELECT id FROM act), '1', 'I', 'Short title, extent and commencement', '(1) This Act may be called the Telecommunications Act, 2023. (2) It extends to the whole of India...', 1),
((SELECT id FROM act), '2', 'I', 'Definitions', 'In this Act, unless the context otherwise requires— (a) "assignment" means the assignment of spectrum; (b) "authorization" means a permission, by whatever name called...', 2),
((SELECT id FROM act), '3', 'II', 'Powers of Authorization and Assignment', 'Any person intending to— (a) establish, operate, maintain or expand telecommunication network; or (b) provide telecommunication services; or (c) possess radio equipment, shall obtain an authorization from the Central Government...', 3)
ON CONFLICT DO NOTHING;

-- Add sections for CGST Act
WITH act AS (SELECT id FROM public.bare_acts WHERE short_title = 'CGST Act' LIMIT 1)
INSERT INTO public.bare_act_sections (bare_act_id, section_number, chapter_number, title, content, sort_order)
VALUES 
((SELECT id FROM act), '1', 'I', 'Short title, extent and commencement', '(1) This Act may be called the Central Goods and Services Tax Act, 2017. (2) It extends to the whole of India...', 1),
((SELECT id FROM act), '7', 'III', 'Scope of supply', '(1) For the purposes of this Act, the expression "supply" includes— (a) all forms of supply of goods or services or both such as sale, transfer, barter, exchange, licence, rental, lease or disposal made or agreed to be made for a consideration by a person in the course or furtherance of business...', 2),
((SELECT id FROM act), '9', 'III', 'Levy and collection', '(1) Subject to the provisions of sub-section (2), there shall be levied a tax called the central goods and services tax on all intra-State supplies of goods or services or both...', 3)
ON CONFLICT DO NOTHING;
