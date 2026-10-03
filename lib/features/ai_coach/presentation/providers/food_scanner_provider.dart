import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import '../../domain/entities/food_analysis.dart';
import '../../domain/usecases/analyze_food.dart';

class FoodScannerProvider extends ChangeNotifier {
  final AnalyzeFood analyzeFood;

  FoodScannerProvider({
    required this.analyzeFood,
  });

  Uint8List? _selectedImage;
  FoodAnalysis? _foodAnalysis;

  bool _isLoading = false;
  String? _errorMessage;

  Uint8List? get selectedImage => _selectedImage;

  FoodAnalysis? get foodAnalysis => _foodAnalysis;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool get hasResult =>
      _foodAnalysis != null && _foodAnalysis!.foods.isNotEmpty;

  void setImage(Uint8List imageBytes) {
    _selectedImage = imageBytes;
    _foodAnalysis = null;
    _errorMessage = null;

    notifyListeners();
  }

  void clearImage() {
    _selectedImage = null;
    _foodAnalysis = null;
    _errorMessage = null;

    notifyListeners();
  }

  Future<void> analyzeSelectedFood({
    required String mimeType,
  }) async {
    if (_selectedImage == null) {
      _errorMessage = 'Please select a food image first.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _foodAnalysis = null;

    notifyListeners();

    try {
      _foodAnalysis = await analyzeFood(
        imageBytes: _selectedImage!,
        mimeType: mimeType,
      );
    } catch (e) {
      _errorMessage = e.toString().replaceFirst(
        'Exception: ',
        '',
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}