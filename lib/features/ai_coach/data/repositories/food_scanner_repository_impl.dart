import 'dart:convert';
import 'dart:typed_data';

import '../../domain/entities/food_analysis.dart';
import '../../domain/repositories/food_scanner_repository.dart';
import '../datasources/food_scanner_remote_data_source.dart';
import '../models/food_analysis_model.dart';

class FoodScannerRepositoryImpl implements FoodScannerRepository {
  final FoodScannerRemoteDataSource remoteDataSource;

  FoodScannerRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<FoodAnalysis> analyzeFoodImage({
    required Uint8List imageBytes,
    required String mimeType,
  }) async {
    final response = await remoteDataSource.analyzeFoodImage(
      imageBytes: imageBytes,
      mimeType: mimeType,
    );

    final cleanedResponse = response
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    try {
      final decoded = jsonDecode(cleanedResponse);

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException(
          'Invalid food analysis response format.',
        );
      }

      return FoodAnalysisModel.fromJson(decoded);
    } catch (e) {
      throw Exception(
        'Unable to parse AI food analysis response: $e',
      );
    }
  }
}