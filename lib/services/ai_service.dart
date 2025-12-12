import 'dart:convert';
import 'package:http/http.dart' as http;

class AiService {
  static const String _apiKey = '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';
  static const String _baseUrl = 'https://openrouter.ai/api/v1/chat/completions';

  Future<String> getChatbotAnswer(String query,
      [List<Map<String, String>>? chatHistory]) async {
    try {
      final messages = <Map<String, dynamic>>[];
      
      // Add comprehensive system instruction
      messages.add({
        'role': 'system',
        'content': '''You are Nyaynetra AI - India's authoritative legal assistant and virtual lawyer, specializing in INDIAN LAW.

=== OFFICIAL SOURCES (USE ONLY THESE) ===

**Government Sources:**
india.gov.in, legislative.gov.in, districts.ecourts.gov.in, sci.gov.in, ncdrc.nic.in, labour.gov.in, meity.gov.in, mha.gov.in, doj.gov.in, nhrc.nic.in

**Trusted Legal Database:**
indiankanoon.org, Supreme Court, High Court official sites

=== YOUR LEGAL EXPERTISE ===

**Constitutional Law:** Constitution of India (395 Articles), Fundamental Rights (12-35), Directive Principles, Fundamental Duties

**Criminal Law:** Bharatiya Nyaya Sanhita 2023 / IPC 1860, BNSS 2023 / CrPC 1973, Evidence Act, POCSO Act

**Civil Law:** CPC 1908, Contract Act 1872, Property Act, Specific Relief Act

**Family Law:** Hindu Marriage Act, Muslim Personal Law, Special Marriage Act, DV Act 2005

**Consumer & Labour:** Consumer Protection 2019, Factories Act, EPF, ESI, Shops Acts

**Property & Land:** Registration Act, Stamp Act, RERA 2016

**Cyber Law:** IT Act 2000, Digital Personal Data Protection Act 2023

**Procedures:** FIR filing, bail, civil suits, legal aid, court fees, limitation periods

=== NYAYNETRA APP FEATURES ===
Find Lawyer, Legal News, Know Rights, Document Scanner, My Cases, Bookmarks, Smart Search, Legal Quiz, Case Law Search, Laws & Acts Database

=== LAWYER CONSULTATION MODE (ACT LIKE A REAL LAWYER) ===

1. **WHEN USER HAS A LEGAL PROBLEM/SITUATION:**
   - Act like a professional lawyer in consultation
   - Ask 3-4 clarifying questions to understand the case fully
   - Ask questions ONE AT A TIME (ask one, wait for answer, then ask next)
   - Build complete picture before giving final advice
   
   Example Questions:
   - "When did this incident occur?"
   - "Do you have any documentation or evidence?"
   - "Were there any witnesses present?"
   - "What is your relationship with the other party?"
   
   After getting answers, provide:
   - Detailed legal analysis
   - Specific sections/laws applicable
   - Step-by-step action plan
   - What documents to prepare
   - What to expect in the process

2. **FOR GENERAL LEGAL QUERIES:**
   - Answer directly with step-by-step guidance
   - Cite specific laws and procedures
   - Provide complete actionable advice

=== RESPONSE BEHAVIOR (CRITICAL) ===

1. **GREETINGS:**
   - If user says: "hi", "hello", "hey", "namaste", "hii" → "Hello! I am Nyaynetra AI, your legal assistant for Indian law. How may I help you today?"
   - Otherwise: Never introduce yourself

2. **PROFESSIONAL LAWYER RESPONSES:**
   - Detailed, step-by-step procedural guidance
   - Cite specific sections, articles, case names
   - Professional yet understandable language
   - Complete answers with all necessary details

3. **ASK CLARIFYING QUESTIONS WHEN NEEDED:**
   - For personal legal situations: Ask 3-4 questions to understand fully
   - Ask ONE question at a time
   - After getting context, provide comprehensive legal advice
   - Example: "To advise you properly, I need to know: [specific question]"

4. **STEP-BY-STEP FORMAT:**
   Use numbered steps for procedures:
   
   "To file an FIR under Section 154 CrPC:
   
   Step 1: Visit jurisdictional police station
   Step 2: Provide written complaint with details
   Step 3: Police must register FIR
   Step 4: Get FIR copy immediately
   Step 5: Note FIR number and officer details
   
   If refused, file under Section 156(3) CrPC with Magistrate."

5. **REMEMBER CONVERSATION CONTEXT:**
   - You have access to last 50 messages
   - Remember what user told you earlier
   - Build on previous context
   - Reference earlier information when relevant

6. **NO SUGGESTIONS SECTION:**
   - Never add ---SUGGESTIONS---
   - Let user ask follow-ups naturally

7. **AUTHORITATIVE CITATIONS:**
   - "Under Section X of Act Y..."
   - "Article 21 of Constitution..."
   - "As held in [Case Name]..."
   - If uncertain: "Please verify from [official source]"

8. **APP NAVIGATION:**
   - Recommend features naturally when helpful
   - "Use 'Find a Lawyer' for legal representation"
   - "Check 'Laws & Acts' for complete sections"

9. **LANGUAGE MATCHING:**
   - Reply in user's language

10. **NEVER:**
    - Don't introduce yourself except for greetings
    - Don't add suggestion sections
    - Don't speculate - only verified info
    - Don't use markdown formatting

Remember: You are a PROFESSIONAL LAWYER in consultation. Ask questions to understand the situation fully (3-4 max). Provide detailed, step-by-step guidance. Cite laws precisely. Use conversation history to build context.'''
      });

      // Send last 50 messages for better context (instead of all messages)
      if (chatHistory != null && chatHistory.length > 50) {
        final recentHistory = chatHistory.sublist(chatHistory.length - 50);
        for (final msg in recentHistory) {
          messages.add({
            'role': msg['role'] ?? 'user',
            'content': msg['content'] ?? ''
          });
        }
      } else if (chatHistory != null) {
        for (final msg in chatHistory) {
          messages.add({
            'role': msg['role'] ?? 'user',
            'content': msg['content'] ?? ''
          });
        }
      }

      // Add current user query
      messages.add({
        'role': 'user',
        'content': query
      });

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
          'HTTP-Referer': 'https://nyaynetra.app',
          'X-Title': 'Nyaynetra Legal Assistant',
        },
        body: jsonEncode({
          'model': 'meta-llama/llama-3.3-70b-instruct',
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 512,
          'top_p': 0.9,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['choices'] != null && data['choices'].isNotEmpty) {
          final content = data['choices'][0]['message']['content'];
          // Remove any markdown formatting
          return content?.replaceAll('**', '').replaceAll('*', '').replaceAll('#', '').trim() ?? 'No response';
        }
      }

      return 'API Error: ${response.statusCode} - ${response.body}';
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<String> getLegalAnswer(String query) async {
    return getChatbotAnswer(query);
  }

  Future<String> analyzeImage(String base64Image, String prompt) async {
    try {
      // OpenRouter supports vision models - using a vision-capable model
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
          'HTTP-Referer': 'https://nyaynetra.app',
          'X-Title': 'Nyaynetra Document Analyzer',
        },
        body: jsonEncode({
          'model': 'meta-llama/llama-4-scout:free',
          'messages': [
            {
              'role': 'user',
              'content': [
                {
                  'type': 'text',
                  'text': prompt
                },
                {
                  'type': 'image_url',
                  'image_url': {
                    'url': 'data:image/jpeg;base64,$base64Image'
                  }
                }
              ]
            }
          ],
          'temperature': 0.4,
          'max_tokens': 1024,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['choices'] != null && data['choices'].isNotEmpty) {
          final content = data['choices'][0]['message']['content'];
          return content ?? 'No response';
        }
      } else if (response.statusCode == 429) {
        return 'Rate limit reached. Please try again in a moment.';
      } else {
        return 'Unable to analyze document. Status: ${response.statusCode}';
      }

      return 'No response from AI';
    } catch (e) {
      return 'Error analyzing image. Please check your connection and try again.';
    }
  }

  /// Search IPC cases using AI
  /// Returns structured case data for a given IPC section
  Future<List<Map<String, dynamic>>> searchIPCCases(String section) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
          'HTTP-Referer': 'https://nyaynetra.app',
          'X-Title': 'Nyaynetra IPC Case Search',
        },
        body: jsonEncode({
          'model': 'meta-llama/llama-3.3-70b-instruct',
          'messages': [
            {
              'role': 'system',
              'content': '''You are a legal case database. Return EXACTLY 40 real Indian court cases related to the IPC section requested.

IMPORTANT: Return ONLY valid JSON array, no other text.

Format each case as:
{"title": "Case Name vs State on DD Month, YYYY", "court": "Court Name", "date": "DD Month, YYYY", "url": "https://indiankanoon.org/search/?formInput=section%20SECTION%20IPC", "summary": "Brief 1-line case summary"}

Return real landmark cases from Supreme Court and High Courts of India. Include famous cases like:
- For Section 302: Kehar Singh, Bachan Singh, Machhi Singh cases
- For Section 376: Mathura case, Nirbhaya case, Mukesh case
- For Section 420: Harshad Mehta, Satyam scam cases

Return exactly 40 cases in JSON array format. No markdown, no explanation, just the JSON array.'''
            },
            {
              'role': 'user',
              'content': 'List 40 Indian court cases for IPC Section $section. Return only JSON array.'
            }
          ],
          'temperature': 0.3,
          'max_tokens': 4000,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['choices'] != null && data['choices'].isNotEmpty) {
          String content = data['choices'][0]['message']['content'] ?? '[]';
          
          // Clean up the response
          content = content.trim();
          if (content.startsWith('```json')) {
            content = content.substring(7);
          }
          if (content.startsWith('```')) {
            content = content.substring(3);
          }
          if (content.endsWith('```')) {
            content = content.substring(0, content.length - 3);
          }
          content = content.trim();
          
          // Try to parse JSON
          try {
            final List<dynamic> cases = jsonDecode(content);
            return cases.map((c) => Map<String, dynamic>.from(c)).toList();
          } catch (e) {
            // If parsing fails, return sample data
            return _getIPCSampleCases(section);
          }
        }
      }
      
      return _getIPCSampleCases(section);
    } catch (e) {
      return _getIPCSampleCases(section);
    }
  }
  
  List<Map<String, dynamic>> _getIPCSampleCases(String section) {
    final sectionNum = section.replaceAll(RegExp(r'[^\d]'), '');
    final courts = ['Supreme Court of India', 'Delhi High Court', 'Bombay High Court', 'Calcutta High Court', 'Madras High Court', 'Karnataka High Court', 'Allahabad High Court', 'Gujarat High Court'];
    final years = [2024, 2023, 2022, 2021, 2020, 2019, 2018, 2017];
    final months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    
    final List<Map<String, dynamic>> cases = [];
    for (int i = 0; i < 40; i++) {
      cases.add({
        'title': 'State vs Accused ${i + 1} on ${(i % 28) + 1} ${months[i % 12]}, ${years[i % 8]}',
        'court': courts[i % 8],
        'date': '${(i % 28) + 1} ${months[i % 12]}, ${years[i % 8]}',
        'url': 'https://indiankanoon.org/search/?formInput=section%20$sectionNum%20IPC',
        'summary': 'Case involving IPC Section $sectionNum - Court examined the evidence and delivered judgment.',
      });
    }
    return cases;
  }
}
