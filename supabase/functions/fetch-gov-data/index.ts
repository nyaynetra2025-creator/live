// Import the Supabase client
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.0.0';

// Define the GovUpdate interface
interface GovUpdate {
  title: string;
  body: string;
  source_url: string;
  published_at: string;
}

// Define the structure of the government data source
interface GovDataSource {
  title: string;
  description: string;
  url: string;
  date: string;
}

Deno.serve(async (_req) => {
  try {
    // Create a Supabase client with the service role key
    // This allows us to bypass RLS and write to the database
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    );

    // Fetch government data from an external source
    // In a real application, this would be replaced with actual government APIs
    const govData: GovDataSource[] = [
      {
        title: 'New Cybersecurity Regulations',
        description: 'India introduces new cybersecurity framework for businesses',
        url: 'https://example.com/cybersecurity-regulations',
        date: new Date().toISOString()
      },
      {
        title: 'Property Tax Updates',
        description: 'Changes to property tax calculations in major cities',
        url: 'https://example.com/property-tax-updates',
        date: new Date().toISOString()
      },
      {
        title: 'Labor Law Amendments',
        description: 'Recent amendments to labor laws affecting employment contracts',
        url: 'https://example.com/labor-law-amendments',
        date: new Date().toISOString()
      }
    ];

    // Transform the data to match our database schema
    const updates: GovUpdate[] = govData.map(item => ({
      title: item.title,
      body: item.description,
      source_url: item.url,
      published_at: item.date
    }));

    // Insert the data into the gov_updates table
    const { error } = await supabaseClient
      .from('gov_updates')
      .upsert(updates, { onConflict: 'source_url' });

    if (error) {
      throw error;
    }

    return new Response(
      JSON.stringify({ message: 'Government data updated successfully' }),
      { headers: { 'Content-Type': 'application/json' },
        status: 200 
      }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { headers: { 'Content-Type': 'application/json' },
        status: 500 
      }
    );
  }
});