import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:developer' as developer;

class GeminiService {
  final String _baseUrl = 'https://openrouter.ai/api/v1/chat/completions';
  
  // Храним историю сообщений для контекста
  final List<Map<String, String>> _messages = [];

  Future<String> getResponse(String text) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    
    // Добавляем сообщение пользователя в историю
    _messages.add({'role': 'user', 'content': text});
    
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://localhost', 
          'X-Title': 'Health App',
        },
        body: jsonEncode({
          'model': 'google/gemini-2.0-flash-001', // Обновленный ID модели для OpenRouter
          'messages': _messages,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final content = data['choices'][0]['message']['content'] as String;
        
        // Добавляем ответ ИИ в историю
        _messages.add({'role': 'assistant', 'content': content});
        return content;
      } else {
        developer.log("OpenRouter Error: ${response.body}", name: "GeminiService");
        return "Error: ${response.statusCode}. ${response.body}";
      }
    } catch (e) {
      developer.log("Connection Error: $e", name: "GeminiService");
      return "Error: $e";
    }
  }

  // Заглушки для совместимости
  dynamic startChat() => this;
  
  Future<dynamic> sendMessage(dynamic content) async {
    final text = (content as dynamic).text ?? content.toString();
    final response = await getResponse(text);
    return _FakeResponse(response);
  }
}

class _FakeResponse {
  final String? text;
  _FakeResponse(this.text);
}
