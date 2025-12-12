-- Create table for Quiz Questions
CREATE TABLE IF NOT EXISTS public.quiz_questions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    question TEXT NOT NULL,
    option_a TEXT NOT NULL,
    option_b TEXT NOT NULL,
    option_c TEXT NOT NULL,
    option_d TEXT NOT NULL,
    correct_answer TEXT NOT NULL, -- 'A', 'B', 'C', or 'D'
    category TEXT DEFAULT 'General',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable RLS
ALTER TABLE public.quiz_questions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Enable read access for all users" ON public.quiz_questions FOR SELECT USING (true);

-- SEED DATA: Quiz Questions
INSERT INTO public.quiz_questions (question, option_a, option_b, option_c, option_d, correct_answer, category) VALUES
-- Road Signs
('What does a red octagonal sign indicate?', 'Parking', 'Stop', 'No Entry', 'Speed Limit', 'B', 'Road Signs'),
('What does a triangular sign with red border indicate?', 'Information', 'Warning', 'Prohibition', 'Mandatory', 'B', 'Road Signs'),
('What does a circular sign with red border indicate?', 'Warning', 'Information', 'Prohibition', 'Mandatory', 'C', 'Road Signs'),
('What does a blue circular sign indicate?', 'Warning', 'Prohibition', 'Mandatory', 'Information', 'C', 'Road Signs'),
('Yellow and black stripes on road indicate?', 'Pedestrian crossing', 'School zone', 'Speed breaker', 'No parking', 'C', 'Road Signs'),

-- Traffic Rules
('What is the minimum age to get a learner''s license for a motorcycle?', '16 years', '18 years', '21 years', '25 years', 'A', 'Traffic Rules'),
('What is the minimum age to get a learner''s license for a car?', '16 years', '18 years', '21 years', '25 years', 'B', 'Traffic Rules'),
('What is the validity period of a learner''s license?', '3 months', '6 months', '1 year', '2 years', 'B', 'Traffic Rules'),
('After how many days of getting LL can you apply for permanent DL?', '15 days', '30 days', '45 days', '60 days', 'B', 'Traffic Rules'),
('What is the validity of a driving license?', '10 years', '15 years', '20 years', 'Lifetime', 'C', 'Traffic Rules'),

-- Speed Limits
('What is the speed limit for two-wheelers in residential areas?', '25 km/h', '40 km/h', '50 km/h', '60 km/h', 'B', 'Traffic Rules'),
('What is the speed limit for cars on highways?', '60 km/h', '80 km/h', '100 km/h', '120 km/h', 'C', 'Traffic Rules'),
('What is the speed limit in school zones?', '15 km/h', '25 km/h', '40 km/h', '50 km/h', 'B', 'Traffic Rules'),

-- Safety
('Wearing helmet is mandatory for?', 'Only driver', 'Only pillion rider', 'Both driver and pillion', 'Optional', 'C', 'Safety'),
('What is the legal blood alcohol limit for driving in India?', '0 mg/100ml', '30 mg/100ml', '50 mg/100ml', '80 mg/100ml', 'B', 'Safety'),
('Seat belt is mandatory for?', 'Only driver', 'Only front seat passengers', 'All passengers', 'Optional', 'C', 'Safety'),
('Using mobile phone while driving is?', 'Allowed with hands-free', 'Completely prohibited', 'Allowed for emergencies', 'Allowed at signals', 'B', 'Safety'),
('What should you do when an ambulance approaches from behind?', 'Speed up', 'Give way immediately', 'Continue at same speed', 'Stop suddenly', 'B', 'Safety'),

-- Documents
('Which document is NOT required while driving?', 'Driving License', 'RC (Registration Certificate)', 'Insurance', 'Aadhaar Card', 'D', 'Documents'),
('PUC certificate is valid for?', '3 months', '6 months', '1 year', '2 years', 'B', 'Documents'),
('What does RC stand for?', 'Road Certificate', 'Registration Certificate', 'Route Certificate', 'Rental Certificate', 'B', 'Documents'),

-- Parking & Traffic
('When can you park on the left side of the road?', 'Anytime', 'During day only', 'Only on one-way streets', 'Never', 'C', 'Traffic Rules'),
('What does a double yellow line on the road mean?', 'Parking allowed', 'No parking at all times', 'Parking allowed at night', 'Loading zone', 'B', 'Traffic Rules'),
('Overtaking is prohibited at?', 'Straight roads', 'Curves', 'Highways', 'All roads', 'B', 'Traffic Rules'),

-- Signals
('What does a red traffic light mean?', 'Slow down', 'Stop completely', 'Proceed with caution', 'Wait for green', 'B', 'Traffic Rules'),
('What does a flashing yellow traffic light mean?', 'Stop', 'Proceed with caution', 'Speed up', 'Wait', 'B', 'Traffic Rules'),
('What does a green arrow with red light mean?', 'Stop', 'Proceed in arrow direction only', 'Wait', 'Proceed in any direction', 'B', 'Traffic Rules'),

-- Penalties
('What is the penalty for driving without a license?', '₹500', '₹1,000', '₹5,000', '₹10,000', 'C', 'Traffic Rules'),
('What is the penalty for drunk driving (first offense)?', '₹2,000', '₹5,000', '₹10,000', '₹15,000', 'C', 'Traffic Rules'),
('What is the penalty for not wearing a helmet?', '₹500', '₹1,000', '₹2,000', '₹5,000', 'B', 'Safety'),

-- General Knowledge
('What is the right side of the road called?', 'Fast lane', 'Slow lane', 'Overtaking lane', 'Emergency lane', 'B', 'Traffic Rules'),
('Horn should NOT be used near?', 'Market', 'Highway', 'Hospital/School', 'Residential area', 'C', 'Traffic Rules'),
('What does ABS stand for in vehicles?', 'Automatic Brake System', 'Anti-lock Braking System', 'Advanced Brake System', 'Air Brake System', 'B', 'Safety');
