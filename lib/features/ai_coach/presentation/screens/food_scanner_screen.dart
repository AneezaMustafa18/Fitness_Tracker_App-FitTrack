import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../app/themes/app_colors.dart';
import '../../data/datasources/food_scanner_remote_data_source.dart';
import '../../data/repositories/food_scanner_repository_impl.dart';
import '../../domain/usecases/analyze_food.dart';
import '../providers/food_scanner_provider.dart';
import '../widgets/nutrition_result_card.dart';

class FoodScannerScreen extends StatefulWidget {
  const FoodScannerScreen({super.key});

  @override
  State<FoodScannerScreen> createState() =>
      _FoodScannerScreenState();
}

class _FoodScannerScreenState extends State<FoodScannerScreen> {
  final ImagePicker _picker = ImagePicker();

  late final FoodScannerProvider _foodScannerProvider;

  XFile? _selectedImage;
  Uint8List? _imageBytes;

  // ===============================================================
  // INIT PROVIDER
  // ===============================================================

  @override
  void initState() {
    super.initState();

    final remoteDataSource =
    FoodScannerRemoteDataSource();

    final repository = FoodScannerRepositoryImpl(
      remoteDataSource: remoteDataSource,
    );

    final analyzeFood = AnalyzeFood(
      repository: repository,
    );

    _foodScannerProvider = FoodScannerProvider(
      analyzeFood: analyzeFood,
    );
  }

  @override
  void dispose() {
    _foodScannerProvider.dispose();
    super.dispose();
  }

  // ===============================================================
  // PICK IMAGE
  // ===============================================================

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
      );

      if (pickedFile == null) return;

      final Uint8List bytes =
      await pickedFile.readAsBytes();

      if (!mounted) return;

      setState(() {
        _selectedImage = pickedFile;
        _imageBytes = bytes;
      });

      _foodScannerProvider.setImage(bytes);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to select image: $e',
          ),
        ),
      );
    }
  }

  // ===============================================================
  // IMAGE SOURCE SHEET
  // ===============================================================

  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(
            20,
            18,
            20,
            24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius:
                  BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Choose Food Image',
                style: TextStyle(
                  color: AppColors.normalText,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Take a photo or select one from your gallery',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: _SourceOption(
                      icon:
                      Icons.camera_alt_rounded,
                      title: 'Camera',
                      onTap: () {
                        Navigator.pop(
                          sheetContext,
                        );

                        _pickImage(
                          ImageSource.camera,
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _SourceOption(
                      icon:
                      Icons.photo_library_rounded,
                      title: 'Gallery',
                      onTap: () {
                        Navigator.pop(
                          sheetContext,
                        );

                        _pickImage(
                          ImageSource.gallery,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ===============================================================
  // ANALYZE FOOD
  // ===============================================================

  Future<void> _analyzeFood() async {
    if (_imageBytes == null ||
        _selectedImage == null) {
      return;
    }

    final mimeType =
        _selectedImage!.mimeType ?? 'image/jpeg';

    await _foodScannerProvider
        .analyzeSelectedFood(
      mimeType: mimeType,
    );

    if (!mounted) return;

    final error =
        _foodScannerProvider.errorMessage;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
        ),
      );
    }
  }

  // ===============================================================
  // BUILD
  // ===============================================================

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<
        FoodScannerProvider>.value(
      value: _foodScannerProvider,
      child: Scaffold(
        backgroundColor:
        const Color(0xFFF7F9FC),

        appBar: AppBar(
          backgroundColor:
          AppColors.primaryBlue,
          elevation: 0,

          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),

          title: const Text(
            'Scan Your Food',
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),

          centerTitle: true,
        ),

        body: SafeArea(
          child: Consumer<FoodScannerProvider>(
            builder: (
                context,
                provider,
                child,
                ) {
              return SingleChildScrollView(
                padding:
                const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    // =================================================
                    // INTRO CARD
                    // =================================================

                    Container(
                      width: double.infinity,
                      padding:
                      const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                        BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withValues(
                              alpha: 0.05,
                            ),
                            blurRadius: 15,
                            offset:
                            const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration:
                            BoxDecoration(
                              color: AppColors
                                  .primaryBlue
                                  .withValues(
                                alpha: 0.10,
                              ),
                              shape:
                              BoxShape.circle,
                            ),
                            child: Icon(
                              Icons
                                  .restaurant_rounded,
                              color: AppColors
                                  .primaryBlue,
                              size: 36,
                            ),
                          ),

                          const SizedBox(
                            height: 14,
                          ),

                          const Text(
                            'AI Food Scanner',
                            style: TextStyle(
                              color: AppColors
                                  .normalText,
                              fontSize: 21,
                              fontWeight:
                              FontWeight.w700,
                            ),
                          ),

                          const SizedBox(
                            height: 7,
                          ),

                          const Text(
                            'Take a photo of your food and get estimated nutrition information.',
                            textAlign:
                            TextAlign.center,
                            style: TextStyle(
                              color: AppColors
                                  .secondaryText,
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // =================================================
                    // IMAGE AREA
                    // =================================================

                    GestureDetector(
                      onTap:
                      provider.isLoading
                          ? null
                          : _showImageSourceOptions,
                      child: Container(
                        width: double.infinity,
                        height: 280,
                        decoration:
                        BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                          BorderRadius.circular(
                            22,
                          ),
                          border: Border.all(
                            color: AppColors
                                .primaryBlue
                                .withValues(
                              alpha: 0.20,
                            ),
                            width: 1.3,
                          ),
                        ),
                        child:
                        _imageBytes == null
                            ? _buildEmptyImageArea()
                            : _buildSelectedImage(),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // =================================================
                    // CHANGE IMAGE
                    // =================================================

                    if (_selectedImage != null)
                      TextButton.icon(
                        onPressed:
                        provider.isLoading
                            ? null
                            : _showImageSourceOptions,
                        icon: const Icon(
                          Icons.refresh_rounded,
                        ),
                        label: const Text(
                          'Choose Another Image',
                        ),
                        style:
                        TextButton.styleFrom(
                          foregroundColor:
                          AppColors
                              .primaryBlue,
                        ),
                      ),

                    const SizedBox(height: 10),

                    // =================================================
                    // ANALYZE BUTTON
                    // =================================================

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed:
                        _selectedImage == null ||
                            provider.isLoading
                            ? null
                            : _analyzeFood,
                        style:
                        ElevatedButton.styleFrom(
                          backgroundColor:
                          AppColors
                              .primaryBlue,
                          disabledBackgroundColor:
                          Colors.grey.shade300,
                          elevation: 0,
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(
                              16,
                            ),
                          ),
                        ),
                        child: provider.isLoading
                            ? const Row(
                          mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child:
                              CircularProgressIndicator(
                                strokeWidth:
                                2.5,
                                color:
                                Colors.white,
                              ),
                            ),
                            SizedBox(
                              width: 12,
                            ),
                            Text(
                              'Analyzing Food...',
                              style:
                              TextStyle(
                                color:
                                Colors.white,
                                fontSize:
                                15,
                                fontWeight:
                                FontWeight
                                    .w700,
                              ),
                            ),
                          ],
                        )
                            : const Row(
                          mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                          children: [
                            Icon(
                              Icons
                                  .auto_awesome_rounded,
                              color:
                              Colors.white,
                              size: 20,
                            ),
                            SizedBox(
                              width: 9,
                            ),
                            Text(
                              'Analyze Food',
                              style:
                              TextStyle(
                                color:
                                Colors.white,
                                fontSize:
                                15,
                                fontWeight:
                                FontWeight
                                    .w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // =================================================
                    // ERROR
                    // =================================================

                    if (provider.errorMessage != null)
                      Container(
                        width: double.infinity,
                        margin:
                        const EdgeInsets.only(
                          bottom: 18,
                        ),
                        padding:
                        const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.red
                              .withValues(
                            alpha: 0.06,
                          ),
                          borderRadius:
                          BorderRadius.circular(
                            14,
                          ),
                          border: Border.all(
                            color: Colors.red
                                .withValues(
                              alpha: 0.18,
                            ),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons
                                  .error_outline_rounded,
                              color: Colors.red,
                              size: 20,
                            ),
                            const SizedBox(
                              width: 9,
                            ),
                            Expanded(
                              child: Text(
                                provider
                                    .errorMessage!,
                                style:
                                const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12.5,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // =================================================
                    // NUTRITION RESULT
                    // =================================================

                    if (provider.hasResult)
                      NutritionResultCard(
                        analysis:
                        provider.foodAnalysis!,
                      ),

                    const SizedBox(height: 15),

                    // =================================================
                    // NOTE
                    // =================================================

                    Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons
                              .info_outline_rounded,
                          color: AppColors
                              .secondaryText,
                          size: 17,
                        ),

                        const SizedBox(width: 7),

                        Expanded(
                          child: Text(
                            'Nutrition values are estimates. Actual calories and macros may vary depending on ingredients, cooking method, oil and portion size.',
                            style: TextStyle(
                              color: AppColors
                                  .secondaryText,
                              fontSize: 11.5,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // EMPTY IMAGE AREA
  // ===============================================================

  Widget _buildEmptyImageArea() {
    return Column(
      mainAxisAlignment:
      MainAxisAlignment.center,
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue
                .withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.camera_alt_rounded,
            color:
            AppColors.primaryBlue,
            size: 32,
          ),
        ),

        const SizedBox(height: 14),

        const Text(
          'Add Food Photo',
          style: TextStyle(
            color: AppColors.normalText,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 6),

        const Text(
          'Tap to take a photo or choose\none from your gallery',
          textAlign: TextAlign.center,
          style: TextStyle(
            color:
            AppColors.secondaryText,
            fontSize: 12.5,
            height: 1.45,
          ),
        ),
      ],
    );
  }

  // ===============================================================
  // SELECTED IMAGE
  // ===============================================================

  Widget _buildSelectedImage() {
    return ClipRRect(
      borderRadius:
      BorderRadius.circular(22),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.memory(
            _imageBytes!,
            fit: BoxFit.cover,
          ),

          Positioned(
            top: 12,
            right: 12,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.black
                    .withValues(
                  alpha: 0.55,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// IMAGE SOURCE OPTION
// ============================================================================

class _SourceOption
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SourceOption({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius:
      BorderRadius.circular(16),
      child: Container(
        padding:
        const EdgeInsets.symmetric(
          vertical: 18,
        ),
        decoration:
        BoxDecoration(
          color: AppColors
              .primaryBlue
              .withValues(alpha: 0.07),
          borderRadius:
          BorderRadius.circular(16),
          border: Border.all(
            color: AppColors
                .primaryBlue
                .withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color:
              AppColors.primaryBlue,
              size: 30,
            ),

            const SizedBox(height: 8),

            Text(
              title,
              style: const TextStyle(
                color:
                AppColors.normalText,
                fontSize: 14,
                fontWeight:
                FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}