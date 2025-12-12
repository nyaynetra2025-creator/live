-- Create table for RTO Services Information
CREATE TABLE IF NOT EXISTS public.rto_services (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title TEXT NOT NULL,
    content TEXT NOT NULL, -- Detailed text content
    icon_name TEXT, -- Name of the icon to display
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable RLS
ALTER TABLE public.rto_services ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Enable read access for all users" ON public.rto_services FOR SELECT USING (true);

-- SEED DATA: RTO Services Info
INSERT INTO public.rto_services (title, icon_name, sort_order, content) VALUES
(
    'Apply for Learner''s Licence', 
    'person_add', 
    1, 
    '1. Visit the Sarathi Parivahan website.\n2. Select your State.\n3. Choose "Apply for Learner Licence".\n4. Fill in the application details.\n5. Upload required documents (Age Proof, Address Proof).\n6. Pay the fee online.\n7. Book a slot for the LL Test.\n8. Visit the RTO for the test.'
),
(
    'Permanent Driving Licence', 
    'drive_eta', 
    2, 
    '1. Must hold a valid Learner''s Licence for at least 30 days.\n2. Apply online on Sarathi Parivahan.\n3. Select "Apply for Driving Licence".\n4. Pay the fees.\n5. Book a slot for the Driving Test.\n6. Visit the RTO with your vehicle for the skill test.\n7. Pass the test to receive your DL via post.'
),
(
    'Vehicle Registration (RC)', 
    'directions_car', 
    3, 
    '1. New vehicles are usually registered by the dealer.\n2. For temporary registration, apply with Form 20.\n3. Documents needed: Identity proof, Sale Certificate, Insurance, Roadworthiness Certificate.\n4. Pay road tax and fees.\n5. Physical inspection of vehicle at RTO.\n6. RC is dispatched by post.'
),
(
    'Transfer of Ownership', 
    'compare_arrows', 
    4, 
    '1. Required when buying/selling a used car.\n2. Submit Form 29 (Notice of Transfer) and Form 30 (Report of Transfer) to RTO.\n3. Documents: Original RC, Insurance, PUC, Address proof of buyer.\n4. Pay transfer fee.\n5. Both seller and buyer may need to visit RTO for verification.'
),
(
    'Renewal of Licence', 
    'refresh', 
    5, 
    '1. DL is valid for 20 years or until age 50.\n2. Apply for renewal via Form 9.\n3. Medical Certificate (Form 1A) required if age > 40.\n4. Submit photos and expired DL.\n5. Pay renewal fees online.'
),
(
    'Duplicate RC / DL', 
    'content_copy', 
    6, 
    '1. File an FIR/NCR if original is lost/stolen.\n2. Apply online for Duplicate Document.\n3. Submit copy of FIR, Address proof, and Insurance.\n4. Pay the required fee.\n5. Visit RTO for biometric verification if required.'
);
