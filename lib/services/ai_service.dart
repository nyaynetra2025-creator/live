import 'dart:convert';
import 'package:http/http.dart' as http;

class AiService {
  static const String _apiKey = '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';
  static const String _baseUrl = 'https://openrouter.ai/api/v1/chat/completions';
  static const String _model = 'x-ai/grok-4.1-fast:free';

  Future<String> getLegalAnswer(String query) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
          // Optional: OpenRouter specific headers
          'HTTP-Referer': 'https://nyaynetra.app', // Site URL for rankings
          'X-Title': 'Nyaynetra', // Site title for rankings
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'system',
              'content': 'You are a legal assistant for Indian law. Provide simple, bullet-point answers for normal users.'
            },
            {
              'role': 'user',
              'content': query
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] ?? 'No answer generated.';
      } else {
        return 'Error: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      return 'Error connecting to AI service: $e';
    }
  }

  Future<String> getNewsSummary(String title) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://nyaynetra.app',
          'X-Title': 'Nyaynetra',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'system',
              'content': 'You are a legal news assistant. Write a comprehensive news report.'
            },
            {
              'role': 'user',
              'content': '''
Write a comprehensive news report based on the following title.
Include:
1. A clear summary of the event.
2. The legal context and significance.
3. Potential impact on the public.
News Title: "$title"
'''
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] ?? 'No summary generated.';
      } else {
        return 'Error: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      return 'Error generating summary: $e';
    }
  }

  Future<String> askAboutNews({
    required String articleTitle,
    required String articleUrl,
    required String userQuestion,
    required List<Map<String, String>> chatHistory,
  }) async {
    try {
      final messages = [
        {
          'role': 'system',
          'content': '''You are a helpful assistant answering questions about a specific news article.
Article Title: "$articleTitle"
Article URL: $articleUrl

Answer questions accurately based on the article context. If you don't know something specific about the article, say so.'''
        },
        ...chatHistory,
        {
          'role': 'user',
          'content': userQuestion
        }
      ];

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://nyaynetra.app',
          'X-Title': 'Nyaynetra',
        },
        body: jsonEncode({
          'model': _model,
          'messages': messages,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] ?? 'No response generated.';
      } else {
        return 'Error: ${response.statusCode}';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }
}
