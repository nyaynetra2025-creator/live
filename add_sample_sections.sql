-- Add sections for Indian Penal Code (IPC)
WITH act AS (SELECT id FROM public.bare_acts WHERE short_title = 'IPC' LIMIT 1)
INSERT INTO public.bare_act_sections (bare_act_id, section_number, chapter_number, title, content, sort_order)
VALUES 
(
  (SELECT id FROM act), 
  '1', 'I', 'Title and extent of operation of the Code', 
  'This Act shall be called the Indian Penal Code, and shall extend to the whole of India.', 
  1
),
(
  (SELECT id FROM act), 
  '2', 'I', 'Punishment of offences committed within India', 
  'Every person shall be liable to punishment under this Code and not otherwise for every act or omission contrary to the provisions thereof, of which he shall be guilty within India.', 
  2
),
(
  (SELECT id FROM act), 
  '3', 'I', 'Punishment of offences committed beyond, but which by law may be tried within, India', 
  'Any person liable, by any Indian law, to be tried for an offence committed beyond India shall be dealt with according to the provisions of this Code for any act committed beyond India in the same manner as if such act had been committed within India.', 
  3
),
(
  (SELECT id FROM act), 
  '4', 'I', 'Extension of Code to extra-territorial offences', 
  'The provisions of this Code apply also to any offence committed by—(1) any citizen of India in any place without and beyond India; (2) any person on any ship or aircraft registered in India wherever it may be.', 
  4
),
(
  (SELECT id FROM act), 
  '5', 'II', 'Certain laws not to be affected by this Act', 
  'Nothing in this Act is intended to repeal, vary, suspend, or affect any of the provisions of any Act for punishing mutiny and desertion of officers, soldiers, sailors or airmen in the service of the Government of India, or the provisions of any special or local law.', 
  5
);

-- Add sections for Constitution
WITH act AS (SELECT id FROM public.bare_acts WHERE short_title = 'Constitution of India' LIMIT 1)
INSERT INTO public.bare_act_sections (bare_act_id, section_number, chapter_number, title, content, sort_order)
VALUES 
(
  (SELECT id FROM act), 
  '1', 'I', 'Name and territory of the Union', 
  '(1) India, that is Bharat, shall be a Union of States. (2) The States and the territories thereof shall be as specified in the First Schedule. (3) The territory of India shall comprise - (a) the territories of the States; (b) the Union territories specified in the First Schedule; and (c) such other territories as may be acquired.', 
  1
),
(
  (SELECT id FROM act), 
  '2', 'I', 'Admission or establishment of new States', 
  'Parliament may by law admit into the Union, or establish, new States on such terms and conditions as it thinks fit.', 
  2
),
(
  (SELECT id FROM act), 
  '5', 'II', 'Citizenship at the commencement of the Constitution', 
  'At the commencement of this Constitution, every person who has his domicile in the territory of India and - (a) who was born in the territory of India; or (b) either of whose parents was born in the territory of India; or (c) who has been ordinarily resident in the territory of India for not less than five years immediately preceding such commencement, shall be a citizen of India.', 
  3
);
