import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiServices {
  static String apikey = 'AIzaSyCXDtC9kpACIQRA3groWxaYkMT1YCYyBjw';
  static final GenerativeModel textModel = GenerativeModel(
    model: "gemini-pro",
    apiKey: apikey,
    safetySettings: safetySettings,
    generationConfig: generationConfig,
  );

  static final GenerationConfig generationConfig = GenerationConfig(
    temperature: 0.9,
    topK: 1,
    topP: 1,
    maxOutputTokens: 2048,
  );

  static final List<SafetySetting> safetySettings = [
    SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
    SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
    SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.high),
    SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.high),
  ];

  static Future<String> generateText(String prompt) async {
    debugPrint('prompt: $prompt');
    final content = [Content.text(prompt)];
    final response = await textModel.generateContent(
      content,
      safetySettings: safetySettings,
      generationConfig: generationConfig,
    );
    debugPrint('text: ${response.text}');
    return response.text ?? '';
  }
}
