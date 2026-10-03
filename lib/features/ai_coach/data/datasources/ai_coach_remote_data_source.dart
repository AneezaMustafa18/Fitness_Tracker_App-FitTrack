import 'package:firebase_ai/firebase_ai.dart';

class AICoachRemoteDataSource {
  late final GenerativeModel _model;

  AICoachRemoteDataSource() {
    _model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-3.8-flash',
    );
  }

  Future<String> getCoachResponse({
    required String prompt,
  }) async {
    final response = await _model.generateContent([
      Content.text(prompt),
    ]);

    final text = response.text;

    if (text == null || text.trim().isEmpty) {
      throw Exception('AI returned an empty response.');
    }

    return text.trim();
  }
}