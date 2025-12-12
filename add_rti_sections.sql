-- Add sections for Right to Information Act (RTI)
WITH act AS (SELECT id FROM public.bare_acts WHERE short_title = 'RTI Act' LIMIT 1)
INSERT INTO public.bare_act_sections (bare_act_id, section_number, chapter_number, title, content, sort_order)
VALUES 
(
  (SELECT id FROM act), 
  '1', 'I', 'Short title, extent and commencement', 
  '(1) This Act may be called the Right to Information Act, 2005. (2) It extends to the whole of India. (3) The provisions of sub-section (1) of section 4, sub-sections (1) and (2) of section 5, sections 12, 13, 15,16, 24, 27 and 28 shall come into force at once, and the remaining provisions of this Act shall come into force on the one hundred and twentieth day of its enactment.', 
  1
),
(
  (SELECT id FROM act), 
  '2', 'I', 'Definitions', 
  'In this Act, unless the context otherwise requires,— (a) "appropriate Government" means in relation to a public authority which is established, constituted, owned, controlled or substantially financed by funds provided directly or indirectly— (i) by the Central Government or the Union territory administration, the Central Government; (ii) by the State Government, the State Government;', 
  2
),
(
  (SELECT id FROM act), 
  '3', 'II', 'Right to information', 
  'Subject to the provisions of this Act, all citizens shall have the right to information.', 
  3
),
(
  (SELECT id FROM act), 
  '4', 'II', 'Obligations of public authorities', 
  'Every public authority shall— (a) maintain all its records duly catalogued and indexed in a manner and the form which facilitates the right to information under this Act and ensure that all records that are appropriate to be computerised are, within a reasonable time and subject to availability of resources, computerised and connected through a network all over the country on different systems so that access to such records is facilitated;', 
  4
),
(
  (SELECT id FROM act), 
  '6', 'II', 'Request for obtaining information', 
  'A person, who desires to obtain any information under this Act, shall make a request in writing or through electronic means in English or Hindi or in the official language of the area in which the application is being made, accompanying such fee as may be prescribed, to— (a) the Central Public Information Officer or State Public Information Officer, as the case may be, of the concerned public authority;', 
  5
)
ON CONFLICT DO NOTHING;
