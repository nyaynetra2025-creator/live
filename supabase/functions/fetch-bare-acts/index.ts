
import { createClient } from 'jsr:@supabase/supabase-js@2'

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

Deno.serve(async (req) => {
    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders })
    }

    try {
        // Create Supabase client
        const supabaseClient = createClient(
            Deno.env.get('SUPABASE_URL') ?? '',
            Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
        )

        // In a real scenario, we would fetch parsing logic here.
        // For now, we simulate "new data" or "updates" coming from a source.
        // This could be replaced with a fetch() to a government RSS feed or scraper API.

        console.log("Fetching latest bare acts data...");

        const newActs = [
            {
                title: 'The Disaster Management Act, 2005',
                short_title: 'DMA',
                category: 'Civil',
                year_enacted: 2005,
                description: 'An Act to provide for the effective management of disasters and for matters connected therewith or incidental thereto.',
                official_url: 'https://indiacode.nic.in/handle/123456789/2153',
                jurisdiction: 'Central',
                status: 'Active'
            },
            {
                title: 'The Epidemic Diseases Act, 1897',
                short_title: 'Epidemic Act',
                category: 'Health',
                year_enacted: 1897,
                description: 'An Act to provide for the better prevention of the spread of Dangerous Epidemic Diseases.',
                official_url: 'https://indiacode.nic.in/handle/123456789/1389',
                jurisdiction: 'Central',
                status: 'Active'
            }
        ];

        // Upsert data into database
        const { data, error } = await supabaseClient
            .from('bare_acts')
            .upsert(newActs, { onConflict: 'title' })
            .select();

        if (error) throw error;

        return new Response(
            JSON.stringify({
                message: "Bare acts data auto-fetched and synced successfully",
                updates: data.length
            }),
            {
                headers: { ...corsHeaders, 'Content-Type': 'application/json' },
                status: 200
            }
        )

    } catch (error) {
        return new Response(
            JSON.stringify({ error: error.message }),
            {
                headers: { ...corsHeaders, 'Content-Type': 'application/json' },
                status: 500
            }
        )
    }
})
