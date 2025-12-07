import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String _apiKey = 'AIzaSyAYG1C73LE8RDo7sPelOF2aaU1k5A80_0E';
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models';

  Future<String> analyzeImage(String base64Image, String prompt) async {
    try {
      final url = '$_baseUrl/gemini-1.5-flash:generateContent?key=$_apiKey';
      
      final response = await http.post(
        Uri.parse(url),
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
        return 'Unable to analyze document. Please try again.';
      }

      return 'No response from AI';
    } catch (e) {
      return 'Error analyzing image. Please check your connection and try again.';
    }
  }
}
