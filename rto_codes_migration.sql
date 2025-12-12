-- Create table for RTO Codes
CREATE TABLE IF NOT EXISTS public.rto_codes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    code TEXT NOT NULL, -- e.g., MH12
    city TEXT NOT NULL, -- e.g., Pune
    state TEXT NOT NULL, -- e.g., Maharashtra
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable RLS
ALTER TABLE public.rto_codes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Enable read access for all users" ON public.rto_codes FOR SELECT USING (true);

-- SEED DATA: RTO Codes
INSERT INTO public.rto_codes (code, city, state) VALUES
-- Maharashtra
('MH01', 'Mumbai (South)', 'Maharashtra'),
('MH02', 'Mumbai (West)', 'Maharashtra'),
('MH03', 'Mumbai (East)', 'Maharashtra'),
('MH04', 'Thane', 'Maharashtra'),
('MH05', 'Kalyan', 'Maharashtra'),
('MH12', 'Pune', 'Maharashtra'),
('MH14', 'Pimpri-Chinchwad', 'Maharashtra'),
('MH31', 'Nagpur', 'Maharashtra'),
('MH15', 'Nashik', 'Maharashtra'),
('MH09', 'Kolhapur', 'Maharashtra'),
('MH10', 'Sangli', 'Maharashtra'),
('MH20', 'Aurangabad', 'Maharashtra'),

-- Delhi
('DL01', 'Delhi North (Mall Road)', 'Delhi'),
('DL02', 'Delhi New Delhi', 'Delhi'),
('DL03', 'Delhi South (Sheikh Sarai)', 'Delhi'),
('DL04', 'Delhi West (Janakpuri)', 'Delhi'),
('DL05', 'Delhi North East (Loni Road)', 'Delhi'),
('DL06', 'Delhi Central (Sarai Kale Khan)', 'Delhi'),
('DL07', 'Delhi East (Mayur Vihar)', 'Delhi'),
('DL08', 'Delhi North West (Wazir Pur)', 'Delhi'),
('DL09', 'Delhi South West (Palam)', 'Delhi'),
('DL10', 'Delhi West (Raja Garden)', 'Delhi'),

-- Karnataka
('KA01', 'Bangalore Central (Koramangala)', 'Karnataka'),
('KA02', 'Bangalore West (Rajajinagar)', 'Karnataka'),
('KA03', 'Bangalore East (Indiranagar)', 'Karnataka'),
('KA04', 'Bangalore North (Yeshwanthpur)', 'Karnataka'),
('KA05', 'Bangalore South (Jayanagar)', 'Karnataka'),
('KA09', 'Mysore West', 'Karnataka'),
('KA19', 'Mangalore', 'Karnataka'),
('KA22', 'Belgaum', 'Karnataka'),
('KA25', 'Dharwad', 'Karnataka'),

-- Tamil Nadu
('TN01', 'Chennai (Central)', 'Tamil Nadu'),
('TN02', 'Chennai (North West)', 'Tamil Nadu'),
('TN03', 'Chennai (North East)', 'Tamil Nadu'),
('TN04', 'Chennai (East)', 'Tamil Nadu'),
('TN05', 'Chennai (North)', 'Tamil Nadu'),
('TN06', 'Chennai (South East)', 'Tamil Nadu'),
('TN07', 'Chennai (South)', 'Tamil Nadu'),
('TN09', 'Chennai (West)', 'Tamil Nadu'),
('TN38', 'Coimbatore (North)', 'Tamil Nadu'),
('TN66', 'Coimbatore (South)', 'Tamil Nadu'),
('TN45', 'Tiruchirapalli', 'Tamil Nadu'),
('TN58', 'Madurai (South)', 'Tamil Nadu'),

-- Uttar Pradesh
('UP14', 'Ghaziabad', 'Uttar Pradesh'),
('UP16', 'Noida', 'Uttar Pradesh'),
('UP32', 'Lucknow', 'Uttar Pradesh'),
('UP78', 'Kanpur', 'Uttar Pradesh'),
('UP70', 'Allahabad', 'Uttar Pradesh'),
('UP65', 'Varanasi', 'Uttar Pradesh'),
('UP80', 'Agra', 'Uttar Pradesh'),

-- Gujarat
('GJ01', 'Ahmedabad', 'Gujarat'),
('GJ05', 'Surat', 'Gujarat'),
('GJ06', 'Vadodara', 'Gujarat'),
('GJ03', 'Rajkot', 'Gujarat'),

-- West Bengal
('WB01', 'Kolkata (Beltala)', 'West Bengal'),
('WB02', 'Kolkata (Beltala)', 'West Bengal'),
('WB06', 'Kolkata (Alipore)', 'West Bengal'),

-- Telangana
('TS07', 'Rangareddy', 'Telangana'),
('TS08', 'Medchal', 'Telangana'),
('TS09', 'Hyderabad (Central)', 'Telangana'),
('TS10', 'Hyderabad (North)', 'Telangana'),
('TS11', 'Hyderabad (East)', 'Telangana'),
('TS12', 'Hyderabad (South)', 'Telangana'),

-- Rajasthan
('RJ14', 'Jaipur (South)', 'Rajasthan'),
('RJ45', 'Jaipur (North)', 'Rajasthan'),
('RJ27', 'Udaipur', 'Rajasthan'),
('RJ20', 'Kota', 'Rajasthan');
