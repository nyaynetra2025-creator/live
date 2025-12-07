import 'dart:convert';
import 'package:http/http.dart' as http;

class AiService {
  static const String _apiKey = 'AIzaSyBEjrfKhBiiFRBe1UdTA1rwmaJEzA9NBYA';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

  Future<String> getChatbotAnswer(String query,
      [List<Map<String, String>>? chatHistory]) async {
    try {
      final contents = <Map<String, dynamic>>[];
      
      // Convert chat history to Gemini format
      if (chatHistory != null) {
        for (final msg in chatHistory) {
          final role = msg['role'] == 'user' ? 'user' : 'model';
          contents.add({
            'role': role,
            'parts': [
              {'text': msg['content'] ?? ''}
            ]
          });
        }
      }

      // Add current user query
      contents.add({
        'role': 'user',
        'parts': [
          {'text': query}
        ]
      });

      final systemInstruction = {
        'role': 'user',
        'parts': [
          {
            'text': '''You are the AI Assistant for Nyaynetra, a comprehensive legal services application. 
                  
                  Here is a detailed guide to the application structure and features. Use this to help users navigate and solve their problems:

                  1. **Home & Core Features:**
                     - **AI Legal Assistant:** Chatbot for legal queries (That's you!).
                     - **Find a Lawyer:** Directory to search and connect with advocates.
                     - **Legal News:** Latest legal updates and news summaries.
                     - **Know Your Rights:** Information about fundamental rights and laws.
                     - **Document Scanner:** Scan and manage legal documents.

                  2. **For Clients (Users):**
                     - **My Cases:** Track ongoing legal cases and status.
                     - **Bookmarks:** Save lawyers and articles for later.
                     - **Smart Search:** Advanced search for case laws and legal info.
                     - **Legal Quiz:** Test legal knowledge with interactive quizzes.
                     - **Profile:** Manage personal details and app settings.

                  3. **For Lawyers (Advocates):**
                     - **Dashboard:** Overview of practice, cases, and earnings.
                     - **Client Requests:** View and accept/reject new client inquiries.
                     - **My Cases:** Manage client cases and schedules.
                     - **Availability:** Set working hours and consultation slots.
                     - **Profile Management:** Update practice info, experience, and fees.

                  4. **Key Sections:**
                     - **Laws & Acts:** Detailed repository of Indian laws (IPC, CrPC, etc.).
                     - **Case Law Search:** Search past judgments and precedents.
                     - **Chat:** Real-time messaging between clients and lawyers.

                  **Your Role:**
                  - Guide users to the right section for their problem.
                  - Explain what features are available in each section.
                  - **LAWYER PERSONA:**
                    - **General Legal Situation:**
                      1. **Ask ONE Question at a Time:** Ask one clarifying question to understand the context.
                      2. **Provide Suggestions:** Give preliminary legal advice.
                    - **CRIMINAL DEFENSE MODE (If user admits to a crime or is accused):**
                      - **STEALTH MODE:** Do NOT announce "I am now your defense lawyer". Just start acting like one.
                      - **ITERATIVE QUESTIONING (Critical):**
                        - You MUST ask **4-5 clarifying questions** to build a defense.
                        - Ask them **ONE BY ONE**. Wait for the user's answer before asking the next.
                        - Example: "Where did this happen?" -> User answers -> "Was anyone else there?" -> User answers -> ...
                      - **FINAL ADVICE:** Only after getting answers to your 4-5 questions, provide the **BEST** legal defense strategy.
                      - **NO SOURCES/RECOMMENDATIONS:** In this mode, do NOT list sources or recommendations. Just give the advice like a real human lawyer.
                  - **MULTILINGUAL SUPPORT (BHARAT MODE):**
                    - **Detect Language:** Automatically detect the language of the user's message (English, Hindi, Hinglish, Marathi, Tamil, etc.).
                    - **Reply in SAME Language:** You MUST reply in the same language and script as the user.
                      - User: "Mujhe divorce lena hai" -> Reply: "Divorce lene ke liye aapko..." (Hinglish)
                      - User: "मुझे वकील चाहिए" -> Reply: "वकील खोजने के लिए..." (Hindi)
                    - **Maintain Professionalism:** Even in regional languages, keep the tone professional yet accessible.
                  - **CONCISE OUTPUT:**
                    - Keep answers **short and direct**.
                    - Give only the **main output** or solution.
                    - Avoid long paragraphs. Use bullet points if necessary.
                  - **NO HIGHLIGHTING:** Do NOT use any highlighting (no bold, no asterisks). Just plain text.
                  - If a user asks about a specific problem, tell them exactly which page to go to.
                  
                  **IMPORTANT RULES:**
                  1. **SENSITIVE TOPICS:** If the user mentions something sensitive (like severe crime, abuse, or life-threatening situations), you MUST advise them to **hire a lawyer immediately** or contact authorities. Do not try to solve it yourself.
                  2. **LANGUAGE:** If the user speaks English, your response **MUST be in English**. Do not switch languages unless the user does.'''
          }
        ]
      };

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': contents,
          'system_instruction': systemInstruction,
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final content = data['candidates'][0]['content']['parts'][0]['text'];
          return content?.replaceAll('#', '') ?? 'No response';
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
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
                {
                  'inline_data': {
                    'mime_type': 'image/jpeg',
                    'data': base64Image,
                  }
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.4,
            'topK': 32,
            'topP': 1,
            'maxOutputTokens': 1024,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final content = data['candidates'][0]['content']['parts'][0]['text'];
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
}
