// Supabase Edge Function to fetch court cases by IPC section from Indian Kanoon
// This scrapes search results to get case data

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface CaseItem {
    title: string
    docId: string
    court: string
    date: string
    url: string
    citedBy?: number
}

// Parse Indian Kanoon search results
async function fetchCasesFromIndianKanoon(section: string, pageNum: number = 0): Promise<CaseItem[]> {
    const searchQuery = `section ${section} IPC`
    const url = `https://indiankanoon.org/search/?formInput=${encodeURIComponent(searchQuery)}${pageNum > 0 ? `&pagenum=${pageNum}` : ''}`

    try {
        const response = await fetch(url, {
            headers: {
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
                'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
            }
        })

        if (!response.ok) {
            console.error(`Failed to fetch page ${pageNum}: ${response.status}`)
            return []
        }

        const html = await response.text()
        const cases: CaseItem[] = []

        // Parse case links - they follow pattern: /doc/123456/ or /docfragment/123456/
        // Title pattern: <a href="/doc/123456/">Case Title vs State on Date</a>
        const casePattern = /\[([^\]]+)\]\(https:\/\/indiankanoon\.org\/doc(?:fragment)?\/(\d+)\/[^)]*\)/g
        const urlPattern = /https:\/\/indiankanoon\.org\/doc(?:fragment)?\/(\d+)\//g

        // Alternative: Parse raw HTML for links
        // Pattern: <a href="/doc/123456/">Title Here</a> or docfragment links
        const linkPattern = /href="\/doc(?:fragment)?\/(\d+)\/[^"]*"[^>]*>([^<]+)</g

        let match
        const seenIds = new Set<string>()

        while ((match = linkPattern.exec(html)) !== null) {
            const docId = match[1]
            let title = match[2].trim()

            // Skip if already seen or if title is too short/generic
            if (seenIds.has(docId) || title.length < 10) continue
            if (title === 'Full Document' || title === 'Entire Act') continue
            if (title.startsWith('Cites') || title.startsWith('Cited by')) continue

            seenIds.add(docId)

            // Try to extract court and date from title
            // Format: "Title vs State on 12 January, 2020"
            let court = 'Unknown Court'
            let date = ''

            // Check for common court patterns in the title line
            if (title.toLowerCase().includes('supreme court')) {
                court = 'Supreme Court of India'
            } else if (title.toLowerCase().includes('high court')) {
                // Extract specific high court
                const hcMatch = title.match(/(\w+)\s+High\s+Court/i)
                court = hcMatch ? `${hcMatch[1]} High Court` : 'High Court'
            }

            // Extract date if present (pattern: "on DD Month, YYYY")
            const dateMatch = title.match(/on\s+(\d{1,2}\s+\w+,?\s+\d{4})/i)
            if (dateMatch) {
                date = dateMatch[1]
            }

            cases.push({
                title: title,
                docId: docId,
                court: court,
                date: date,
                url: `https://indiankanoon.org/doc/${docId}/`,
            })
        }

        return cases
    } catch (error) {
        console.error(`Error fetching cases for section ${section}:`, error)
        return []
    }
}

serve(async (req) => {
    // Handle CORS preflight requests
    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders })
    }

    try {
        // Parse request body
        const { section } = await req.json()

        if (!section) {
            return new Response(
                JSON.stringify({ error: 'IPC section number is required' }),
                {
                    status: 400,
                    headers: { ...corsHeaders, 'Content-Type': 'application/json' }
                }
            )
        }

        // Clean the section number
        const cleanSection = section.toString().trim().replace(/[^\d\w]/g, '')

        console.log(`Fetching cases for IPC Section ${cleanSection}`)

        // Fetch multiple pages to get at least 40 cases
        let allCases: CaseItem[] = []

        // Fetch first 5 pages (about 10 cases per page = ~50 cases)
        for (let page = 0; page < 5; page++) {
            const pageCases = await fetchCasesFromIndianKanoon(cleanSection, page)
            allCases = [...allCases, ...pageCases]

            // If we have enough cases, stop
            if (allCases.length >= 50) break

            // Small delay to be respectful
            if (page < 4) {
                await new Promise(resolve => setTimeout(resolve, 200))
            }
        }

        // Remove duplicates
        const uniqueCases = allCases.filter((case_, index, self) =>
            index === self.findIndex((c) => c.docId === case_.docId)
        )

        console.log(`Found ${uniqueCases.length} unique cases for IPC Section ${cleanSection}`)

        return new Response(
            JSON.stringify({
                success: true,
                section: cleanSection,
                cases: uniqueCases.slice(0, 50), // Return max 50 cases
                total: uniqueCases.length
            }),
            { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )

    } catch (error) {
        console.error('Error in fetch-ipc-cases function:', error)
        return new Response(
            JSON.stringify({ error: error.message }),
            {
                status: 500,
                headers: { ...corsHeaders, 'Content-Type': 'application/json' }
            }
        )
    }
})
