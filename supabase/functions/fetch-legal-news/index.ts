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
}

// Parse Google News RSS feed
async function fetchGoogleNewsRSS(query: string): Promise<NewsItem[]> {
    const rssUrl = `https://news.google.com/rss/search?q=${encodeURIComponent(query)}&hl=en-IN&gl=IN&ceid=IN:en`

    try {
        const response = await fetch(rssUrl)
        const xml = await response.text()

        const items: NewsItem[] = []
        const regex = /<item>.*?<title>(.*?)<\/title>.*?<link>(.*?)<\/link>/gs
        const matches = xml.matchAll(regex)

        for (const match of matches) {
            let title = match[1] || 'Legal Update'
            const link = match[2] || ''

            // Clean up title (remove source name like " - Live Law")
            if (title.includes(' - ')) {
                title = title.split(' - ')[0]
            }

            items.push({
                title,
                link,
                subtitle: 'Tap to read full coverage',
                category: 'general'
            })

            if (items.length >= 20) break // Limit to 20 articles per fetch
        }

        return items
    } catch (error) {
        console.error('Error fetching Google News RSS:', error)
        return []
    }
}

// Fetch from multiple legal news sources
async function fetchAllLegalNews(): Promise<NewsItem[]> {
    const newsQueries = [
        { query: 'India Supreme Court Legal News', category: 'supreme-court' },
        { query: 'India Legal Rights Consumer Protection', category: 'consumer-law' },
        { query: 'India Labor Law Employment Rights', category: 'labor-law' },
        { query: 'India Property Law Real Estate', category: 'property-law' },
    ]

    const allNews: NewsItem[] = []

    for (const { query, category } of newsQueries) {
        const news = await fetchGoogleNewsRSS(query)
        // Add category to each item
        news.forEach(item => {
            item.category = category
            allNews.push(item)
        })
    }

    return allNews
}

serve(async (req) => {
    // Handle CORS preflight
    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders })
    }

    try {
        // Initialize Supabase client
        const supabaseUrl = Deno.env.get('SUPABASE_URL')!
        const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
        const supabase = createClient(supabaseUrl, supabaseServiceKey)

        console.log('Fetching legal news from RSS feeds...')
        const newsItems = await fetchAllLegalNews()
        console.log(`Found ${newsItems.length} news articles`)

        if (newsItems.length === 0) {
            return new Response(
                JSON.stringify({ message: 'No news found', inserted: 0 }),
                { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
            )
        }

        // Check for duplicates before inserting
        const { data: existingNews } = await supabase
            .from('legal_news')
            .select('title, link')
            .limit(100)

        const existingTitles = new Set(existingNews?.map(n => n.title) || [])
        const existingLinks = new Set(existingNews?.map(n => n.link) || [])

        // Filter out duplicates
        const newArticles = newsItems.filter(item =>
            !existingTitles.has(item.title) &&
            (!item.link || !existingLinks.has(item.link))
        )

        console.log(`${newArticles.length} new articles to insert (${newsItems.length - newArticles.length} duplicates skipped)`)

        if (newArticles.length === 0) {
            return new Response(
                JSON.stringify({ message: 'No new articles to insert', inserted: 0 }),
                { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
            )
        }

        // Insert new articles
        const { data, error } = await supabase
            .from('legal_news')
            .insert(newArticles.map(item => ({
                title: item.title,
                subtitle: item.subtitle,
                link: item.link,
                category: item.category,
                is_featured: false, // Auto-fetched articles are not featured by default
            })))

        if (error) {
            console.error('Error inserting news:', error)
            throw error
        }

        console.log(`Successfully inserted ${newArticles.length} new articles`)

        // Optional: Clean up old articles (keep only last 100)
        const { data: allArticles } = await supabase
            .from('legal_news')
            .select('id')
            .order('published_at', { ascending: false })
            .range(100, 9999)

        if (allArticles && allArticles.length > 0) {
            const idsToDelete = allArticles.map(a => a.id)
            await supabase
                .from('legal_news')
                .delete()
                .in('id', idsToDelete)
            console.log(`Cleaned up ${allArticles.length} old articles`)
        }

        return new Response(
            JSON.stringify({
                success: true,
                message: 'News fetched and saved successfully',
                inserted: newArticles.length,
                total: newsItems.length,
                duplicates: newsItems.length - newArticles.length
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
