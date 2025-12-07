// Supabase Edge Function to automatically fetch legal news from RSS feeds
// This runs on a schedule (e.g., every hour) to keep news updated

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface NewsItem {
    title: string
    link: string
    subtitle?: string
    category: string
    language: string
}

const SUPPORTED_LANGUAGES = [
    { code: 'en', hl: 'en-IN', ceid: 'IN:en' },
    { code: 'hi', hl: 'hi', ceid: 'IN:hi' },
    { code: 'bn', hl: 'bn', ceid: 'IN:bn' }, // Bengali
    { code: 'te', hl: 'te', ceid: 'IN:te' }, // Telugu
    { code: 'mr', hl: 'mr', ceid: 'IN:mr' }, // Marathi
    { code: 'ta', hl: 'ta', ceid: 'IN:ta' }, // Tamil
    // Add others supported by Google News
];

// Parse Google News RSS feed
async function fetchGoogleNewsRSS(query: string, langSettings: any): Promise<NewsItem[]> {
    const rssUrl = `https://news.google.com/rss/search?q=${encodeURIComponent(query)}&hl=${langSettings.hl}&gl=IN&ceid=${langSettings.ceid}`

    try {
        const response = await fetch(rssUrl)
        const xml = await response.text()

        const items: NewsItem[] = []
        // Simple regex to parse RSS (DOMParser is not available in Deno without libraries, this is robust enough for RSS)
        const regex = /<item>.*?<title>(.*?)<\/title>.*?<link>(.*?)<\/link>.*?<pubDate>(.*?)<\/pubDate>/gs
        const matches = xml.matchAll(regex)

        for (const match of matches) {
            let title = match[1] || 'Legal Update'
            const link = match[2] || ''
            // const pubDate = match[3] || ''

            // Clean up title (remove source name like " - Live Law")
            if (title.includes(' - ')) {
                title = title.split(' - ')[0]
            }

            items.push({
                title,
                link,
                subtitle: langSettings.code === 'en' ? 'Latest Legal Update' : 'नवीनतम कानूनी अपडेट',
                category: 'general',
                language: langSettings.code
            })
        }
        return items
    } catch (error) {
        console.error(`Error fetching RSS for ${langSettings.code}:`, error)
        return []
    }
}

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

        let allNewsItems: NewsItem[] = []

        for (const lang of SUPPORTED_LANGUAGES) {
            // Fetch specific queries for each language
            let queries: string[] = []

            if (lang.code === 'en') {
                queries = ['Supreme Court of India', 'High Court Judgment', 'New Laws India', 'Legal Rights India']
            } else if (lang.code === 'hi') {
                queries = ['सुप्रीम कोर्ट भारत', 'हाई कोर्ट फैसला', 'नए कानून भारत', 'कानूनी अधिकार']
            } else if (lang.code === 'mr') {
                queries = ['सर्वोच्च न्यायालय', 'उच्च न्यायालय निर्णय', 'नवीन कायदे']
            } else {
                // Fallback or specific queries for other languages
                // For now, use English or simple translated terms if known, else skip
                // Actually Google News supports English queries even with localized hl, but results might be mixed.
                // Better to try native terms if possible, or broad terms.
                // Let's use English queries for others but request localized content, Google often handles it.
                queries = ['Supreme Court India', 'Legal News']
            }

            for (const query of queries) {
                const items = await fetchGoogleNewsRSS(query, lang)
                allNewsItems = [...allNewsItems, ...items]
            }
        }

        // Remove duplicates within the fetched batch (by link)
        const uniqueNews = allNewsItems.filter((item, index, self) =>
            index === self.findIndex((t) => (
                t.link === item.link
            ))
        )

        console.log(`Fetched ${uniqueNews.length} unique articles across all languages`)

        // Insert into database
        // We need to check for existing articles to avoid unique constraint violations if 'link' is unique
        // But we don't have a unique constraint on link in the code definition I saw.
        // However, avoiding duplicates is good.

        let insertedCount = 0

        // Process in chunks to avoid huge requests
        const chunkSize = 50
        for (let i = 0; i < uniqueNews.length; i += chunkSize) {
            const chunk = uniqueNews.slice(i, i + chunkSize);

            // Check which links already exist
            const links = chunk.map(n => n.link)
            const { data: existing } = await supabase
                .from('legal_news')
                .select('link')
                .in('link', links)

            const existingLinks = new Set(existing?.map(e => e.link) || [])

            const newArticles = chunk.filter(n => !existingLinks.has(n.link))

            if (newArticles.length > 0) {
                const { error } = await supabase
                    .from('legal_news')
                    .insert(newArticles.map(item => ({
                        title: item.title,
                        subtitle: item.subtitle,
                        link: item.link,
                        category: item.category,
                        is_featured: false,
                        language: item.language
                    })))

                if (error) {
                    console.error('Error inserting chunk:', error)
                } else {
                    insertedCount += newArticles.length
                }
            }
        }

        console.log(`Successfully inserted ${insertedCount} new articles`)

        return new Response(
            JSON.stringify({
                success: true,
                message: 'News fetched and saved successfully',
                inserted: insertedCount
            }),
            { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )

    } catch (error) {
        console.error('Error in fetch-legal-news function:', error)
        return new Response(
            JSON.stringify({ error: error.message }),
            {
                status: 500,
                headers: { ...corsHeaders, 'Content-Type': 'application/json' }
            }
        )
    }
})
