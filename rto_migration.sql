-- Create table for Traffic Fines
CREATE TABLE IF NOT EXISTS public.rto_fines (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    offense TEXT NOT NULL,
    section TEXT,
    penalty TEXT NOT NULL,
    category TEXT DEFAULT 'General',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable RLS for traffic fines
ALTER TABLE public.rto_fines ENABLE ROW LEVEL SECURITY;

-- Create policy for public read access
CREATE POLICY "Enable read access for all users" ON public.rto_fines
    FOR SELECT USING (true);


-- Create table for Traffic Signs
CREATE TABLE IF NOT EXISTS public.traffic_signs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    image_url TEXT,
    category TEXT NOT NULL, -- Mandatory, Cautionary, Informatory
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable RLS for traffic signs
ALTER TABLE public.traffic_signs ENABLE ROW LEVEL SECURITY;

-- Create policy for public read access
CREATE POLICY "Enable read access for all users" ON public.traffic_signs
    FOR SELECT USING (true);


-- SEED DATA: Traffic Fines
INSERT INTO public.rto_fines (offense, section, penalty, category) VALUES
('Driving without valid license', 'Sec 3 r/w 181', '₹5,000', 'Document Related'),
('Allowing unauthorized person to drive', 'Sec 5 r/w 180', '₹5,000', 'Document Related'),
('Driving when disqualified', 'Sec 23, 24 r/w 182', '₹10,000', 'Document Related'),
('Over-speeding (Light Motor Vehicle)', 'Sec 112 r/w 183 LMV', '₹1,000 - ₹2,000', 'Driving Related'),
('Over-speeding (Medium/Heavy Vehicle)', 'Sec 112 r/w 183 MMV/HMV', '₹2,000 - ₹4,000', 'Driving Related'),
('Dangerous Driving / Rash Driving', 'Sec 184', '₹1,000 - ₹5,000 (1st: 6m - 1y jail)', 'Driving Related'),
('Drunken Driving', 'Sec 185', '₹10,000 (1st offence) / ₹15,000 (2nd)', 'Driving Related'),
('Driving uninsured vehicle', 'Sec 146 r/w 196', '₹2,000', 'Document Related'),
('Racing and speeding', 'Sec 189', '₹5,000', 'Driving Related'),
('Driving without Helmet', 'Sec 129 r/w 194D', '₹1,000 + 3 months disqualification', 'Safety Related'),
('Driving without Seat Belt', 'Sec 194B', '₹1,000', 'Safety Related'),
('Overloading of passengers', 'Sec 194A', '₹200 per extra passenger', 'Load Related'),
('Offences by Juveniles', 'Sec 199A', '₹25,000 + 3 yrs jail for guardian', 'Major Offence'),
('Using mobile phone while driving', 'Sec 184(c)', '₹1,000 - ₹5,000', 'Driving Related'),
('Not giving way to emergency vehicles', 'Sec 194E', '₹10,000', 'General'),
('Driving without Permit', 'Sec 192A', '₹10,000', 'Document Related'),
('Disobedience of orders of Authorities', 'Sec 179', '₹2,000', 'General'),
('Violation of Road Regulations', 'Sec 177', '₹500 (1st) / ₹1,500 (2nd)', 'General');

-- SEED DATA: Traffic Signs (Using externally hosted reliable placeholder images or descriptions)
-- Note: In a real app, these URLs should point to your Supabase Storage. Using placeholders for now.
INSERT INTO public.traffic_signs (name, category, image_url, description) VALUES
('Stop', 'Mandatory', 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/India_road_sign_Stop.svg/600px-India_road_sign_Stop.svg.png', 'Driver must stop completely.'),
('Give Way', 'Mandatory', 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/22/India_road_sign_Give_Way.svg/600px-India_road_sign_Give_Way.svg.png', 'Yield to other traffic.'),
('No Entry', 'Mandatory', 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1d/India_road_sign_No_Entry.svg/600px-India_road_sign_No_Entry.svg.png', 'Entry is prohibited for all vehicles.'),
('One Way', 'Mandatory', 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/18/India_road_sign_One_Way_Traffic_Left.svg/600px-India_road_sign_One_Way_Traffic_Left.svg.png', 'Traffic flows in only one direction.'),
('No Parking', 'Mandatory', 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/91/India_road_sign_No_Parking.svg/600px-India_road_sign_No_Parking.svg.png', 'Parking is not allowed.'),
('No Standing or Parking', 'Mandatory', 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/69/India_road_sign_No_Stopping_or_Standing.svg/600px-India_road_sign_No_Stopping_or_Standing.svg.png', 'Vehicles cannot stop or park.'),
('Right Turn Prohibited', 'Mandatory', 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c3/India_road_sign_No_Right_Turn.svg/600px-India_road_sign_No_Right_Turn.svg.png', 'Do not turn right.'),
('Left Turn Prohibited', 'Mandatory', 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/07/India_road_sign_No_Left_Turn.svg/600px-India_road_sign_No_Left_Turn.svg.png', 'Do not turn left.'),
('U-Turn Prohibited', 'Mandatory', 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8c/India_road_sign_No_U_Turn.svg/600px-India_road_sign_No_U_Turn.svg.png', 'U-turns are not allowed.'),
('Speed Limit 50', 'Mandatory', 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1f/India_road_sign_Speed_Limit_50.svg/600px-India_road_sign_Speed_Limit_50.svg.png', 'Maximum speed limit is 50 km/h.'),
('Right Hand Curve', 'Cautionary', 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/97/India_road_sign_Right_Hand_Curve.svg/600px-India_road_sign_Right_Hand_Curve.svg.png', 'Road curves to the right ahead.'),
('Left Hand Curve', 'Cautionary', 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/62/India_road_sign_Left_Hand_Curve.svg/600px-India_road_sign_Left_Hand_Curve.svg.png', 'Road curves to the left ahead.'),
('Narrow Road Ahead', 'Cautionary', 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/05/India_road_sign_Narrow_Road_Ahead.svg/600px-India_road_sign_Narrow_Road_Ahead.svg.png', 'Road narrows ahead.'),
('School Ahead', 'Cautionary', 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/India_road_sign_School_Ahead.svg/600px-India_road_sign_School_Ahead.svg.png', 'School zone ahead, drive slowly.'),
('Pedestrian Crossing', 'Cautionary', 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/90/India_road_sign_Pedestrian_Crossing.svg/600px-India_road_sign_Pedestrian_Crossing.svg.png', 'Watch for pedestrians crossing.'),
('Men at Work', 'Cautionary', 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3b/India_road_sign_Men_at_Work.svg/600px-India_road_sign_Men_at_Work.svg.png', 'Construction work ahead.'),
('Hospital', 'Informatory', 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a2/India_road_sign_Hospital.svg/600px-India_road_sign_Hospital.svg.png', 'Hospital nearby.'),
('First Aid Post', 'Informatory', 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a8/India_road_sign_First_Aid_Post.svg/600px-India_road_sign_First_Aid_Post.svg.png', 'First aid facility available.'),
('Parking Lot', 'Informatory', 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8d/India_road_sign_Parking_Lot_Scooter_and_Motor_Cycle.svg/600px-India_road_sign_Parking_Lot_Scooter_and_Motor_Cycle.svg.png', 'Designated parking area.');

-- SEED DATA: The Motor Vehicles Act, 1988 (Into bare_acts)
DO $$
DECLARE
    mv_act_id uuid;
BEGIN
    -- Insert the Act if it doesn't exist
    INSERT INTO public.bare_acts (
        id, 
        title, 
        short_title, 
        act_number, 
        year_enacted, 
        description, 
        jurisdiction, 
        category, 
        official_url
    ) VALUES (
        gen_random_uuid(),
        'The Motor Vehicles Act, 1988',
        'Motor Vehicles Act',
        '59',
        1988,
        'An Act to consolidate and amend the law relating to motor vehicles.',
        'Central',
        'Transport',
        'https://morth.nic.in/motor-vehicles-act-1988'
    )
    ON CONFLICT (title) DO UPDATE SET description = EXCLUDED.description
    RETURNING id INTO mv_act_id;

    -- Insert Sections
    IF mv_act_id IS NOT NULL THEN
        INSERT INTO public.bare_act_sections (bare_act_id, section_number, title, content) VALUES
        (mv_act_id, '1', 'Short title, extent and commencement', '(1) This Act may be called the Motor Vehicles Act, 1988.\n(2) It extends to the whole of India.\n(3) It shall come into force on such date as the Central Government may, by notification in the Official Gazette, appoint.'),
        (mv_act_id, '3', 'Necessity for driving licence', '(1) No person shall drive a motor vehicle in any public place unless he holds an effective driving licence issued to him authorising him to drive the vehicle...'),
        (mv_act_id, '4', 'Age limit in connection with driving of motor vehicles', '(1) No person under the age of eighteen years shall drive a motor vehicle in any public place...'),
        (mv_act_id, '5', 'Responsibility of owners of motor vehicles', 'No owner or person in charge of a motor vehicle shall cause or permit any person who does not satisfy the provisions of section 3 or section 4 to drive the vehicle.'),
        (mv_act_id, '112', 'Limits of speed', '(1) No person shall drive a motor vehicle or cause or allow a motor vehicle to be driven in any public place at a speed exceeding the maximum speed or below the minimum speed fixed...'),
        (mv_act_id, '113', 'Limits of weight and limitations on use', '(1) The Central Government may prescribe conditions for the issue of permits for transport vehicles...'),
        (mv_act_id, '129', 'Wearing of protective headgear', 'Every person driving or riding (otherwise than in a side car, on a motor cycle of any class or description) shall, while in a public place, wear protective headgear conforming to the standards of Bureau of Indian Standards...'),
        (mv_act_id, '181', 'Driving vehicles in contravention of section 3 or section 4', 'Whoever drives a motor vehicle in contravention of section 3 or section 4 shall be punishable with imprisonment for a term which may extend to three months, or with fine which may extend to five thousand rupees, or with both.'),
        (mv_act_id, '183', 'Driving at excessive speed, etc.', '(1) Whoever drives or causes any person who is employed by him... to drive a motor vehicle in contravention of the speed limits...'),
        (mv_act_id, '184', 'Driving dangerously', 'Whoever drives a motor vehicle at a speed or in a manner which is dangerous to the public... shall be punishable for the first offence with imprisonment for a term which may extend to one year but shall not be less than six months...'),
        (mv_act_id, '185', 'Driving by a drunken person or by a person under the influence of drugs', 'Whoever, while driving, or attempting to drive, a motor vehicle... (a) has, in his blood, alcohol exceeding 30 mg. per 100 ml. of blood detected in a test by a breath analyser...'),
        (mv_act_id, '194B', 'Use of safety belts and the seating of children', '(1) Whoever drives a motor vehicle without wearing a safety belt or carries passengers not wearing safety belts shall be punishable with a fine of one thousand rupees.');
    END IF;
END $$;
