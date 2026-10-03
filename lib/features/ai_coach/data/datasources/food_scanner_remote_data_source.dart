import 'dart:typed_data';

import 'package:firebase_ai/firebase_ai.dart';

class FoodScannerRemoteDataSource {
  late final GenerativeModel _model;

  FoodScannerRemoteDataSource() {
    final jsonSchema = Schema.object(
      properties: {
        'foods': Schema.array(
          items: Schema.object(
            properties: {
              'food_name': Schema.string(),
              'serving_size': Schema.string(),
              'calories': Schema.integer(),
              'protein': Schema.number(),
              'carbohydrates': Schema.number(),
              'fat': Schema.number(),
              'fiber': Schema.number(),
              'confidence': Schema.number(),
            },
          ),
        ),
      },
    );

    _model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-3.8-flash',
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: jsonSchema,
      ),
    );
  }

  Future<String> analyzeFoodImage({
    required Uint8List imageBytes,
    required String mimeType,
  }) async {
    final prompt = TextPart(
      '''
You are a food and nutrition analysis assistant.

Analyze the provided food image carefully.

Identify ALL clearly visible food items in the image.

For every food item, estimate:
- food name
- serving size
- calories
- protein in grams
- carbohydrates in grams
- fat in grams
- fiber in grams
- confidence from 0 to 1

Important rules:
- Nutrition values are estimates, not exact measurements.
- Consider visible portion size when estimating nutrition.
- Do not invent foods that are not visible.
- If multiple foods are visible, return each food separately.
- Use realistic nutritional estimates.
- Return numbers only for nutrition values.
- Confidence must be between 0 and 1.
''',
    );

    final imagePart = InlineDataPart(
      mimeType,
      imageBytes,
    );

    final content = Content.multi([
      prompt,
      imagePart,
    ]);

    final response = await _model.generateContent([
      content,
    ]);

    final text = response.text;

    if (text == null || text.trim().isEmpty) {
      throw Exception('AI returned an empty response.');
    }

    return text;
  }
}