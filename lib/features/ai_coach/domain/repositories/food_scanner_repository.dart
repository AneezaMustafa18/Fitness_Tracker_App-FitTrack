import 'dart:typed_data';

import '../entities/food_analysis.dart';

abstract class FoodScannerRepository {
  Future<FoodAnalysis> analyzeFoodImage({
    required Uint8List imageBytes,
    required String mimeType,
  });
}