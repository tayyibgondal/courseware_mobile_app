import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AITutorService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _baseUrl = 'https://api.groq.com/openai/v1';
  
  Future<String?> _getApiKey() async {
    return await _storage.read(key: 'groq_api_key');
  }

  Future<String> getAIResponse(String message, {String? pdfContent}) async {
    final apiKey = await _getApiKey();
    if (apiKey == null) {
      throw Exception('API key not found. Please set your Groq API key first.');
    }

    String systemPrompt = 'You are a helpful AI tutor.';
    if (pdfContent != null) {
      systemPrompt += ' The following is the content from a PDF that the user has uploaded: $pdfContent';
    }

    try {
      final response = await _dio.post(
        '$_baseUrl/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': 'mixtral-8x7b-32768',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': message},
          ],
          'temperature': 0.7,
          'max_tokens': 1000,
        },
      );

      if (response.statusCode == 200) {
        return response.data['choices'][0]['message']['content'];
      } else {
        throw Exception('Failed to get AI response');
      }
    } catch (e) {
      throw Exception('Error communicating with AI service: $e');
    }
  }

  Future<void> setApiKey(String apiKey) async {
    await _storage.write(key: 'groq_api_key', value: apiKey);
  }
} 