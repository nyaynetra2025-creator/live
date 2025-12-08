// Supabase Edge Function to fetch Legal Rights data from Indian Government sources
// This runs on a schedule to keep legal rights information updated

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface LegalRight {
    title: string
    description: string
    category: string
    article_number?: string
    source_law: string
    source_url?: string
    key_points: string[]
    examples: string[]
    remedies: string
    applicable_to: string
    status: string
}

// Comprehensive legal rights data from Indian Constitution and Laws
const LEGAL_RIGHTS_DATA: LegalRight[] = [
    // FUNDAMENTAL RIGHTS (Part III of Constitution)
    {
        title: 'Right to Equality',
        description: 'The State shall not deny to any person equality before the law or the equal protection of the laws within the territory of India. This is the foundation of democratic governance.',
        category: 'Fundamental Rights',
        article_number: 'Article 14',
        source_law: 'Constitution of India',
        source_url: 'https://legislative.gov.in/constitution-of-india',
        key_points: [
            'All persons are equal before law',
            'Equal protection of laws to everyone',
            'Prohibition of discrimination on grounds of religion, race, caste, sex or place of birth',
            'Equality of opportunity in public employment',
            'Abolition of untouchability'
        ],
        examples: [
            'A person cannot be denied job based on caste',
            'All citizens can access public places equally',
            'No special privileges for any class'
        ],
        remedies: 'Can file writ petition under Article 32 (Supreme Court) or Article 226 (High Court)',
        applicable_to: 'All Persons',
        status: 'Active'
    },
    {
        title: 'Prohibition of Discrimination',
        description: 'The State shall not discriminate against any citizen on grounds only of religion, race, caste, sex, place of birth or any of them. No citizen shall be subjected to any disability, liability, restriction or condition.',
        category: 'Fundamental Rights',
        article_number: 'Article 15',
        source_law: 'Constitution of India',
        source_url: 'https://legislative.gov.in/constitution-of-india',
        key_points: [
            'No discrimination in access to shops, public restaurants, hotels',
            'No discrimination in use of wells, tanks, bathing ghats, roads',
            'Special provisions for women and children allowed',
            'Special provisions for SC/ST and backward classes allowed'
        ],
        examples: [
            'Women can have reserved seats in buses',
            'SC/ST reservations in education',
            'Separate queues for women at public places'
        ],
        remedies: 'File complaint with National/State Human Rights Commission or approach courts',
        applicable_to: 'All Citizens',
        status: 'Active'
    },
    {
        title: 'Right to Freedom of Speech and Expression',
        description: 'All citizens have the right to freedom of speech and expression, to assemble peaceably and without arms, to form associations or unions, to move freely throughout India, to reside and settle in any part of India, and to practice any profession.',
        category: 'Fundamental Rights',
        article_number: 'Article 19',
        source_law: 'Constitution of India',
        source_url: 'https://legislative.gov.in/constitution-of-india',
        key_points: [
            'Freedom of speech and expression',
            'Right to assemble peacefully',
            'Right to form associations',
            'Right to move freely in India',
            'Right to reside anywhere in India',
            'Right to practice any profession',
            'Subject to reasonable restrictions'
        ],
        examples: [
            'Publishing newspapers',
            'Conducting peaceful protests',
            'Starting a business',
            'Moving to any city for work',
            'Forming trade unions'
        ],
        remedies: 'Approach High Court or Supreme Court for protection of these freedoms',
        applicable_to: 'Citizens Only',
        status: 'Active'
    },
    {
        title: 'Right to Life and Personal Liberty',
        description: 'No person shall be deprived of his life or personal liberty except according to procedure established by law. This is the most fundamental of all rights and has been expanded to include right to live with dignity.',
        category: 'Fundamental Rights',
        article_number: 'Article 21',
        source_law: 'Constitution of India',
        source_url: 'https://legislative.gov.in/constitution-of-india',
        key_points: [
            'Right to life with human dignity',
            'Right to livelihood',
            'Right to health',
            'Right to clean environment',
            'Right to privacy',
            'Right to shelter',
            'Right against torture',
            'Right to speedy trial',
            'Right to legal aid'
        ],
        examples: [
            'Getting free legal aid in criminal cases',
            'Prisoners right to humane treatment',
            'Right to clean drinking water',
            'Right to emergency medical care',
            'Protection of personal data'
        ],
        remedies: 'Habeas Corpus petition, writ petitions under Articles 32 and 226',
        applicable_to: 'All Persons',
        status: 'Active'
    },
    {
        title: 'Right to Education',
        description: 'The State shall provide free and compulsory education to all children of the age of six to fourteen years. Every child has right to full time elementary education of satisfactory quality.',
        category: 'Fundamental Rights',
        article_number: 'Article 21A',
        source_law: 'Constitution of India, Right to Education Act 2009',
        source_url: 'https://www.education.gov.in/rte',
        key_points: [
            'Free education from age 6 to 14',
            'Compulsory education',
            'No capitation fee',
            'No screening for admission',
            '25% reservation in private schools for EWS',
            'Trained teachers mandatory',
            'No corporal punishment'
        ],
        examples: [
            'Free admission in government schools',
            'No child can be denied admission',
            'Mid-day meal schemes',
            'Free textbooks and uniforms for poor students'
        ],
        remedies: 'Approach school management, Local Authority, or file case under RTE Act',
        applicable_to: 'Children aged 6-14',
        status: 'Active'
    },
    {
        title: 'Right Against Exploitation',
        description: 'Traffic in human beings and begar and other similar forms of forced labour are prohibited. No child below fourteen years shall be employed in any factory or mine or engaged in any hazardous employment.',
        category: 'Fundamental Rights',
        article_number: 'Articles 23-24',
        source_law: 'Constitution of India, Child Labour Act',
        source_url: 'https://labour.gov.in',
        key_points: [
            'Prohibition of human trafficking',
            'Prohibition of forced labor',
            'Prohibition of child labor in hazardous work',
            'No bondage due to debt',
            'Penalty for violations'
        ],
        examples: [
            'Reporting bonded labor to authorities',
            'Rescue of trafficked persons',
            'Rehabilitation of child laborers'
        ],
        remedies: 'Report to Labour Department, Police, or National Commission for Protection of Child Rights',
        applicable_to: 'All Persons',
        status: 'Active'
    },
    {
        title: 'Right to Freedom of Religion',
        description: 'All persons are equally entitled to freedom of conscience and the right freely to profess, practice and propagate religion. Religious denominations can manage their own affairs in matters of religion.',
        category: 'Fundamental Rights',
        article_number: 'Articles 25-28',
        source_law: 'Constitution of India',
        source_url: 'https://legislative.gov.in/constitution-of-india',
        key_points: [
            'Freedom of conscience',
            'Right to practice religion',
            'Right to propagate religion',
            'Right to manage religious affairs',
            'Freedom from religious instruction in state institutions',
            'Subject to public order, morality and health'
        ],
        examples: [
            'Building places of worship',
            'Celebrating religious festivals',
            'Religious organizations running educational institutions'
        ],
        remedies: 'Approach civil courts or file writ petition in High Court/Supreme Court',
        applicable_to: 'All Persons',
        status: 'Active'
    },
    {
        title: 'Cultural and Educational Rights',
        description: 'Any section of citizens having a distinct language, script or culture shall have the right to conserve the same. All minorities have the right to establish and administer educational institutions of their choice.',
        category: 'Fundamental Rights',
        article_number: 'Articles 29-30',
        source_law: 'Constitution of India',
        source_url: 'https://legislative.gov.in/constitution-of-india',
        key_points: [
            'Right to conserve distinct culture',
            'Right to conserve language',
            'Minorities can establish educational institutions',
            'No discrimination in state-aided institutions',
            'State can regulate but not take over minority institutions'
        ],
        examples: [
            'Minority schools and colleges',
            'Cultural organizations',
            'Language preservation programs'
        ],
        remedies: 'Approach National Commission for Minorities or file writ petition',
        applicable_to: 'Cultural/Linguistic Minorities',
        status: 'Active'
    },
    {
        title: 'Right to Constitutional Remedies',
        description: 'The right to move the Supreme Court for enforcement of fundamental rights is guaranteed. The Supreme Court has power to issue writs including habeas corpus, mandamus, prohibition, quo warranto and certiorari.',
        category: 'Fundamental Rights',
        article_number: 'Article 32',
        source_law: 'Constitution of India',
        source_url: 'https://legislative.gov.in/constitution-of-india',
        key_points: [
            'Right to approach Supreme Court',
            'Writs: Habeas Corpus, Mandamus, Prohibition, Certiorari, Quo Warranto',
            'Cannot be suspended except during emergency',
            'Dr. Ambedkar called it the heart and soul of Constitution'
        ],
        examples: [
            'Filing PIL for public issues',
            'Challenging unlawful detention',
            'Compelling officials to perform duties'
        ],
        remedies: 'Direct petition to Supreme Court under Article 32 or High Court under Article 226',
        applicable_to: 'All Persons',
        status: 'Active'
    },
    // CONSUMER RIGHTS
    {
        title: 'Right to Safety',
        description: 'Consumers have the right to be protected against marketing of goods and services which are hazardous to life and property.',
        category: 'Consumer Rights',
        source_law: 'Consumer Protection Act 2019',
        source_url: 'https://consumeraffairs.nic.in',
        key_points: [
            'Protection from dangerous products',
            'Right to safe goods and services',
            'Product liability',
            'Manufacturers responsible for defects'
        ],
        examples: [
            'Defective vehicle causing accident',
            'Contaminated food products',
            'Unsafe electrical appliances'
        ],
        remedies: 'File complaint with Consumer Forum, District/State/National Commission',
        applicable_to: 'All Consumers',
        status: 'Active'
    },
    {
        title: 'Right to Information (RTI)',
        description: 'Every citizen has the right to get information from public authorities. Information includes records, documents, memos, emails, opinions, press releases, circulars, contracts, samples, and electronic data.',
        category: 'Civic Rights',
        article_number: 'Section 3',
        source_law: 'Right to Information Act 2005',
        source_url: 'https://rti.gov.in',
        key_points: [
            'Request information from any public authority',
            'Reply within 30 days mandatory',
            'Nominal fee of Rs.10',
            'First appeal and second appeal available',
            'Certain information exempted',
            'Penalty for non-compliance'
        ],
        examples: [
            'Asking for road construction details',
            'Getting information on government schemes',
            'Checking status of pending applications'
        ],
        remedies: 'File application with PIO, then First Appellate Authority, then Information Commission',
        applicable_to: 'All Citizens',
        status: 'Active'
    },
    {
        title: 'Right to Fair Compensation (Land Acquisition)',
        description: 'When government acquires private land for public purpose, the affected families are entitled to fair compensation, rehabilitation and resettlement.',
        category: 'Property Rights',
        source_law: 'Right to Fair Compensation and Transparency in Land Acquisition, Rehabilitation and Resettlement Act 2013',
        source_url: 'https://dolr.gov.in',
        key_points: [
            'Market value compensation',
            'Solatium of 100%',
            'Monthly annuity for livelihood losers',
            'Jobs for affected families',
            'Resettlement allowance',
            'Social Impact Assessment mandatory'
        ],
        examples: [
            'Compensation for land acquired for highways',
            'Rehabilitation for dam project affected families'
        ],
        remedies: 'Appeal to Land Acquisition Authority, then High Court',
        applicable_to: 'Land Owners and Affected Families',
        status: 'Active'
    },
    {
        title: 'Right to Food Security',
        description: 'Entitled persons have the right to receive subsidized food grains from the Government. Priority households receive 5 kg per person per month at Rs.3/2/1 for rice/wheat/coarse grains.',
        category: 'Social Rights',
        source_law: 'National Food Security Act 2013',
        source_url: 'https://dfpd.gov.in',
        key_points: [
            '5 kg food grains per person per month',
            'Subsidized rates',
            'Antyodaya households get 35 kg per month',
            'Maternity benefit of Rs.6000',
            'Meal for children under 6',
            'Mid-day meal for students',
            'Food security allowance if grains not supplied'
        ],
        examples: [
            'Getting ration from PDS shops',
            'Mid-day meals in schools',
            'Integrated Child Development Services'
        ],
        remedies: 'Approach District Grievance Redressal Officer or State Food Commission',
        applicable_to: 'BPL Families, Priority Households',
        status: 'Active'
    },
    {
        title: 'Right to Work (MGNREGA)',
        description: 'Every rural household has the right to demand 100 days of guaranteed wage employment in a financial year. Work should be provided within 15 days of demand or unemployment allowance paid.',
        category: 'Employment Rights',
        source_law: 'Mahatma Gandhi National Rural Employment Guarantee Act 2005',
        source_url: 'https://nrega.nic.in',
        key_points: [
            '100 days guaranteed employment',
            'Minimum wages',
            'Work within 5 km',
            'If not 5 km, travel allowance',
            'Unemployment allowance if work not given',
            'Worksite facilities like creche, drinking water',
            'Equal wages for men and women'
        ],
        examples: [
            'Demanding work from Gram Panchayat',
            'Getting job card',
            'Water conservation works',
            'Road construction'
        ],
        remedies: 'Approach Gram Rozgar Sahayak, then Programme Officer, then Ombudsman',
        applicable_to: 'Rural Households',
        status: 'Active'
    },
    // WOMEN RIGHTS
    {
        title: 'Protection from Domestic Violence',
        description: 'Women have the right to be protected from domestic violence including physical, sexual, verbal, emotional and economic abuse. They have right to residence in shared household.',
        category: 'Women Rights',
        source_law: 'Protection of Women from Domestic Violence Act 2005',
        source_url: 'https://wcd.nic.in',
        key_points: [
            'Protection from physical violence',
            'Protection from sexual abuse',
            'Protection from verbal abuse',
            'Right to residence',
            'Monetary relief',
            'Custody of children',
            'Protection orders available'
        ],
        examples: [
            'Filing complaint against abusive husband',
            'Seeking residence order',
            'Getting maintenance'
        ],
        remedies: 'Approach Protection Officer, file complaint at Magistrate Court, seek help from NGOs',
        applicable_to: 'All Women',
        status: 'Active'
    },
    {
        title: 'Right to Equal Pay',
        description: 'Women are entitled to equal pay for equal work or work of similar nature. No employer shall pay to any worker remuneration less than that payable to the opposite sex.',
        category: 'Women Rights',
        source_law: 'Equal Remuneration Act 1976',
        source_url: 'https://labour.gov.in',
        key_points: [
            'Equal pay for equal work',
            'No discrimination in recruitment',
            'No discrimination in promotion',
            'Complaint mechanism available'
        ],
        examples: [
            'Same salary for male and female teachers',
            'Equal wages for factory workers'
        ],
        remedies: 'File complaint with Labour Inspector or approach Labour Court',
        applicable_to: 'Working Women',
        status: 'Active'
    },
    {
        title: 'Maternity Benefits',
        description: 'Women employees are entitled to 26 weeks of paid maternity leave. For women having 2 or more children, benefit is 12 weeks. Employer cannot terminate during maternity.',
        category: 'Women Rights',
        source_law: 'Maternity Benefit Act 1961 (Amended 2017)',
        source_url: 'https://labour.gov.in',
        key_points: [
            '26 weeks paid leave',
            '12 weeks for 3rd child onwards',
            'Work from home option',
            'Creche facility mandatory for 50+ employees',
            'Medical bonus',
            'No termination during maternity'
        ],
        examples: [
            'Taking maternity leave from private company',
            'Availing creche facility',
            'Getting medical bonus'
        ],
        remedies: 'Approach Labour Commissioner or file case in Labour Court',
        applicable_to: 'Women Employees',
        status: 'Active'
    },
    {
        title: 'Protection Against Sexual Harassment at Workplace',
        description: 'Every woman has the right to be protected from sexual harassment at workplace. Internal Complaints Committee must be constituted by every employer with 10 or more employees.',
        category: 'Women Rights',
        source_law: 'Sexual Harassment of Women at Workplace (Prevention, Prohibition and Redressal) Act 2013',
        source_url: 'https://wcd.nic.in',
        key_points: [
            'Protection from sexual harassment',
            'Internal Complaints Committee mandatory',
            'Local Complaints Committee at district level',
            'Inquiry within 90 days',
            'Employer responsible for safe environment',
            'Confidentiality of proceedings'
        ],
        examples: [
            'Filing complaint against colleague',
            'Reporting harassment to ICC',
            'Approaching Local Committee if employer has less than 10 employees'
        ],
        remedies: 'File complaint with Internal Complaints Committee within 3 months, appeal to court',
        applicable_to: 'Working Women',
        status: 'Active'
    },
    // SENIOR CITIZEN RIGHTS
    {
        title: 'Right to Maintenance by Children',
        description: 'Senior citizens and parents have the right to claim maintenance from their children if they are unable to maintain themselves. Children are legally bound to support parents.',
        category: 'Senior Citizen Rights',
        source_law: 'Maintenance and Welfare of Parents and Senior Citizens Act 2007',
        source_url: 'https://socialjustice.gov.in',
        key_points: [
            'Children must maintain parents',
            'Maximum maintenance Rs.10,000/month per parent',
            'Property can be cancelled if parents evicted',
            'Old age homes to be established',
            'Punishment for abandonment',
            'Tribunal to decide within 90 days'
        ],
        examples: [
            'Claiming maintenance from son/daughter',
            'Cancelling property transfer if abandoned',
            'Seeking admission in old age home'
        ],
        remedies: 'Approach Maintenance Tribunal (SDM/BDO level), appeal to Appellate Tribunal',
        applicable_to: 'Senior Citizens (60+)',
        status: 'Active'
    },
    // DISABILITY RIGHTS
    {
        title: 'Rights of Persons with Disabilities',
        description: 'Persons with disabilities have equal rights in all aspects of life including education, employment, access to justice, healthcare, and political participation. 4% reservation in government jobs.',
        category: 'Disability Rights',
        source_law: 'Rights of Persons with Disabilities Act 2016',
        source_url: 'https://disabilityaffairs.gov.in',
        key_points: [
            '21 types of disabilities covered',
            '4% reservation in govt jobs',
            '5% reservation in higher education',
            'Free education till 18 years',
            'Accessible buildings mandatory',
            'Guardianship rights',
            'Special courts for speedy trial'
        ],
        examples: [
            'Getting disability certificate',
            'Availing reservation in jobs',
            'Accessible ramps and lifts',
            'Sign language interpreters'
        ],
        remedies: 'Approach Chief Commissioner or State Commissioner for Persons with Disabilities',
        applicable_to: 'Persons with Disabilities',
        status: 'Active'
    },
    // CHILDREN RIGHTS
    {
        title: 'Protection from Child Marriage',
        description: 'No marriage of a girl below 18 years or boy below 21 years is valid. Such marriages are voidable at the option of the minor. Punishment for promoting child marriage.',
        category: 'Children Rights',
        source_law: 'Prohibition of Child Marriage Act 2006',
        source_url: 'https://wcd.nic.in',
        key_points: [
            'Minimum age: 18 for girls, 21 for boys',
            'Child marriage voidable',
            'Punishment up to 2 years for adult males marrying child',
            'Maintenance for girl child',
            'Child Marriage Prohibition Officers appointed'
        ],
        examples: [
            'Stopping child marriage ceremony',
            'Seeking annulment of child marriage',
            'Claiming maintenance'
        ],
        remedies: 'Report to Child Marriage Prohibition Officer, Police, or approach court',
        applicable_to: 'Children',
        status: 'Active'
    },
    {
        title: 'Protection of Children from Sexual Offences (POCSO)',
        description: 'Children below 18 years are protected from sexual assault, harassment, and pornography. Special procedures for child-friendly trial. Stringent punishments for offenders.',
        category: 'Children Rights',
        source_law: 'Protection of Children from Sexual Offences Act 2012',
        source_url: 'https://wcd.nic.in',
        key_points: [
            'Protects children under 18',
            'Covers penetrative and non-penetrative assault',
            'Child pornography punishable',
            'Special courts for speedy trial',
            'Child-friendly procedures',
            'Identity of child protected'
        ],
        examples: [
            'Reporting sexual abuse of child',
            'Child-friendly court procedures',
            'Compensation to victim'
        ],
        remedies: 'Report to Police (special cell), Child Welfare Committee, or call Childline 1098',
        applicable_to: 'Children under 18',
        status: 'Active'
    },
    // LABOUR RIGHTS
    {
        title: 'Right to Minimum Wages',
        description: 'Every worker is entitled to be paid at least the minimum wage fixed by the Government. Payment should be regular and cannot be delayed unreasonably.',
        category: 'Labour Rights',
        source_law: 'Minimum Wages Act 1948, Code on Wages 2019',
        source_url: 'https://labour.gov.in',
        key_points: [
            'Minimum wages vary by state and industry',
            'Overtime at double rate',
            'Rest days mandatory',
            'Payment in legal tender',
            'Deductions limited'
        ],
        examples: [
            'Construction workers',
            'Factory workers',
            'Agricultural laborers',
            'Domestic workers'
        ],
        remedies: 'Approach Labour Commissioner, file claim in Labour Court',
        applicable_to: 'All Workers',
        status: 'Active'
    },
    {
        title: 'Right to Social Security (EPF & ESI)',
        description: 'Employees are entitled to provident fund and insurance benefits. 12% contribution from employee and employer each. Medical benefits under ESI.',
        category: 'Labour Rights',
        source_law: 'Employees Provident Funds Act 1952, ESI Act 1948',
        source_url: 'https://epfindia.gov.in',
        key_points: [
            '12% EPF contribution each from employee and employer',
            'Pension benefit',
            'Insurance benefit',
            'Medical care under ESI',
            'Gratuity after 5 years'
        ],
        examples: [
            'Withdrawing PF for medical emergency',
            'ESI coverage for surgery',
            'Family pension to widow'
        ],
        remedies: 'Approach EPF Commissioner, ESI Courts, or Labour Court',
        applicable_to: 'Organized Sector Employees',
        status: 'Active'
    },
    // ENVIRONMENTAL RIGHTS
    {
        title: 'Right to Clean Environment',
        description: 'Every person has the right to live in a clean and healthy environment. This is part of Right to Life under Article 21. NGT has power to hear environmental disputes.',
        category: 'Environmental Rights',
        source_law: 'Environment Protection Act 1986, NGT Act 2010',
        source_url: 'https://moef.gov.in',
        key_points: [
            'Clean air and water are fundamental rights',
            'Polluter pays principle',
            'Environmental clearance mandatory for projects',
            'National Green Tribunal for environmental issues',
            'Environmental awareness'
        ],
        examples: [
            'Filing case against polluting factory',
            'Challenging illegal mining',
            'Protecting forests'
        ],
        remedies: 'Approach National Green Tribunal, Pollution Control Board, or High Court',
        applicable_to: 'All Persons',
        status: 'Active'
    }
];

serve(async (req) => {
    // Handle CORS preflight requests
    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders })
    }

    try {
        // Initialize Supabase client
        const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? ''
        const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
        const supabase = createClient(supabaseUrl, supabaseKey)

        console.log(`Starting to insert ${LEGAL_RIGHTS_DATA.length} legal rights...`)

        let insertedCount = 0
        let skippedCount = 0

        // Process in chunks to avoid huge requests
        const chunkSize = 10
        for (let i = 0; i < LEGAL_RIGHTS_DATA.length; i += chunkSize) {
            const chunk = LEGAL_RIGHTS_DATA.slice(i, i + chunkSize);

            // Check which rights already exist by title
            const titles = chunk.map(r => r.title)
            const { data: existing } = await supabase
                .from('legal_rights')
                .select('title')
                .in('title', titles)

            const existingTitles = new Set(existing?.map(e => e.title) || [])

            const newRights = chunk.filter(r => !existingTitles.has(r.title))

            if (newRights.length > 0) {
                const { error } = await supabase
                    .from('legal_rights')
                    .insert(newRights)

                if (error) {
                    console.error('Error inserting chunk:', error)
                } else {
                    insertedCount += newRights.length
                }
            }

            skippedCount += chunk.length - newRights.length
        }

        console.log(`Successfully inserted ${insertedCount} new legal rights, skipped ${skippedCount} existing`)

        return new Response(
            JSON.stringify({
                success: true,
                message: 'Legal rights data fetched and saved successfully',
                inserted: insertedCount,
                skipped: skippedCount,
                total: LEGAL_RIGHTS_DATA.length
            }),
            { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )

    } catch (error) {
        console.error('Error in fetch-legal-rights function:', error)
        return new Response(
            JSON.stringify({ error: error.message }),
            {
                status: 500,
                headers: { ...corsHeaders, 'Content-Type': 'application/json' }
            }
        )
    }
})
