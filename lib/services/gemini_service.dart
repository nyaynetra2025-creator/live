import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  // Note: This class is kept for backward compatibility but now uses OpenRouter
  static const String _apiKey = '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';
  static const String _baseUrl = 'https://openrouter.ai/api/v1/chat/completions';

  Future<String> analyzeImage(String base64Image, String prompt) async {
    try {
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
        return 'Unable to analyze document. Please try again.';
      }

      return 'No response from AI';
    } catch (e) {
      return 'Error analyzing image. Please check your connection and try again.';
    }
  }
}
