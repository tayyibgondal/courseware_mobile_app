import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class AITutorService {
  final List<Map<String, String>> _conversationHistory = [];

  List<Map<String, String>> get conversationHistory => _conversationHistory;

  // Mock responses for reliable demo without API dependency
  final List<String> _mockResponses = [
    "That's an interesting question! In this context, we can understand it by looking at three key principles...",
    "Great question. The concept you're asking about involves several important aspects that are worth exploring...",
    "I'd be happy to explain this. When we look at the fundamentals of this topic, we can see that...",
    "Let me break this down for you. There are several approaches to understanding this material...",
    "This is a complex topic with multiple dimensions. Let's start with the basics and then build from there...",
    "I understand your question. The key insight here is to consider how these concepts relate to each other...",
    "That's a thought-provoking question! When we analyze this from first principles, we discover that...",
    "From an educational perspective, this can be understood by examining the following key factors...",
    "Let me provide some clarity on this topic. The essential elements to consider include...",
    "This is an excellent question for deepening your understanding. Let's explore the core concepts together..."
  ];

  Future<String> getResponse(String userMessage, {String? context}) async {
    try {
      // Add user message to conversation history
      _conversationHistory.add({
        'role': 'user',
        'content': userMessage,
      });

      // Simulate network delay for realism
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Generate a more personalized response based on the question
      String aiResponse = _generateMockResponse(userMessage, context);
      
      // Add AI response to conversation history
      _conversationHistory.add({
        'role': 'assistant',
        'content': aiResponse,
      });

      // Keep conversation history manageable
      if (_conversationHistory.length > 10) {
        _conversationHistory.removeRange(0, 2);
      }

      return aiResponse;
    } catch (e) {
      if (kDebugMode) {
        print('Error in AI Tutor service: $e');
      }
      
      // Fallback response
      final fallbackResponse = 'I apologize, but I encountered an unexpected error. Could you try asking your question again?';
      
      // Add to conversation history for consistency
      _conversationHistory.add({
        'role': 'assistant',
        'content': fallbackResponse,
      });
      
      return fallbackResponse;
    }
  }

  String _generateMockResponse(String question, String? context) {
    // Get a random response template
    final random = Random();
    String baseResponse = _mockResponses[random.nextInt(_mockResponses.length)];
    
    // Keywords to look for and respond to
    final Map<String, String> keywordResponses = {
      'hello': "Hello there! How can I help you with your studies today?",
      'hi': "Hi! I'm your AI tutor. What would you like to learn about?",
      'help': "I'd be happy to help! What specific topic are you having trouble with?",
      'thanks': "You're welcome! Is there anything else you'd like to know?",
      'thank': "You're welcome! Feel free to ask if you have more questions.",
      'flutter': "Flutter is a UI toolkit from Google for building natively compiled applications for mobile, web, and desktop from a single codebase. What specific aspect would you like to know about?",
      'dart': "Dart is a client-optimized programming language for apps on multiple platforms. It's used to build mobile, desktop, server, and web applications. What would you like to know about Dart?",
      'firebase': "Firebase is a platform developed by Google for creating mobile and web applications. It provides tools for tracking analytics, reporting bugs, and creating marketing and product experiments. What specific Firebase service are you interested in?",
      'problem': "I understand you're facing a challenge. Could you describe the problem in more detail so I can help you find a solution?",
      'how to': "That's a good question about implementation. To accomplish this, you would typically need to...",
      'why': "The reasoning behind this concept is important to understand. Essentially...",
      'what is': "Let me explain this concept. In simple terms...",
      'explain': "I'd be happy to explain. The key aspects to understand are...",
      'difference': "The main differences to consider are...",
      'example': "Here's a practical example to illustrate this concept...",
    };

    // Check if question contains any keywords
    String lowerQuestion = question.toLowerCase();
    for (var keyword in keywordResponses.keys) {
      if (lowerQuestion.contains(keyword)) {
        return keywordResponses[keyword]!;
      }
    }

    // If context is provided, mention it
    if (context != null) {
      return "Based on the document you've uploaded, I can answer that. " + baseResponse;
    }

    return baseResponse;
  }

  void clearConversation() {
    _conversationHistory.clear();
  }

  Future<void> saveConversation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('conversation_history', jsonEncode(_conversationHistory));
    } catch (e) {
      if (kDebugMode) {
        print('Error saving conversation: $e');
      }
    }
  }

  Future<void> loadConversation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedHistory = prefs.getString('conversation_history');
      if (savedHistory != null) {
        final List<dynamic> decoded = jsonDecode(savedHistory);
        _conversationHistory.clear();
        _conversationHistory.addAll(
          decoded.map((item) => Map<String, String>.from(item)),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading conversation: $e');
      }
    }
  }
} 