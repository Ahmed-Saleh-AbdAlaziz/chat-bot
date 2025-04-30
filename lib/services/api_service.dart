import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;

import '../models/ai_model.dart';

class ApiService {
  final String apiKey;
  final String baseUrl;

  ApiService({
    required this.apiKey,
    this.baseUrl = 'https://generativelanguage.googleapis.com/v1beta',
  });

  Future<List<AIModel>> fetchModels() async {
    final url = '$baseUrl/models';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'x-goog-api-key': apiKey},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['models'] as List)
            .map((model) => AIModel.fromJson(model))
            .toList();
      } else {
        debugPrint(
            'خطأ جلب النماذج: ${response.statusCode} - ${response.body}');
        throw Exception('فشل في جلب النماذج: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('استثناء في جلب النماذج: $e');
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  Future<String> generateContent({
    required String message,
    String modelName = 'gemini-1.5-pro',
  }) async {
    final url = '$baseUrl/models/$modelName:generateContent';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': apiKey,
        },
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": message}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        debugPrint(
            'خطأ إنشاء المحتوى: ${response.statusCode} - ${response.body}');
        throw Exception('فشل في إنشاء المحتوى: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('استثناء في إنشاء المحتوى: $e');
      throw Exception('خطأ في الاتصال: $e');
    }
  }
}
