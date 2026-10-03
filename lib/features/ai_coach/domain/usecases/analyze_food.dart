import 'dart:typed_data';

import '../entities/food_analysis.dart';
import '../repositories/food_scanner_repository.dart';

class AnalyzeFood {
  final FoodScannerRepository repository;

  AnalyzeFood({
    required this.repository,
  });

  Future<FoodAnalysis> call({
    required Uint8List imageBytes,
    required String mimeType,
  }) {
    return repository.analyzeFoodImage(
      imageBytes: imageBytes,
      mimeType: mimeType,
    );
  }
}