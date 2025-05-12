import 'dart:convert';
import 'package:http/http.dart' as http;

class GroqService {
  // Replace this with your actual Groq API key
  static const String _apiKey = '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';
  static const String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';

  Future<String> getAIResponse(String message, {bool showSources = false}) async {
    try {
      final systemPrompt = showSources
          ? "You are an AI tutor. Answer the user's question in detail and also provide a list of the most relevant and trustworthy web URLs as sources for further reading."
          : "You are an AI tutor. Help students understand their questions and provide detailed explanations.";

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'llama3-8b-8192',
          'messages': [
            {
              'role': 'system',
              'content': systemPrompt,
            },
            {
              'role': 'user',
              'content': message,
            }
          ],
          'temperature': 0.7,
          'max_tokens': 1024,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        print('Groq API error: ${response.body}');
        throw Exception('Failed to get AI response: ${response.statusCode}\n${response.body}');
      }
    } catch (e) {
      throw Exception('Error communicating with Groq API: $e');
    }
  }
} 