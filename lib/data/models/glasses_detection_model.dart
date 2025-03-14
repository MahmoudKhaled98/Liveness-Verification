import '../../domain/entities/glasses_detection_result.dart';

/// Model class for glasses detection data from API.
class GlassesDetectionModel extends GlassesDetectionResult {
  /// Creates a new [GlassesDetectionModel] instance.
  GlassesDetectionModel({
    required super.hasEyeglasses,
    required super.hasSunglasses,
    required super.eyeglassesConfidence,
    required super.sunglassesConfidence,
  });

  /// Creates a [GlassesDetectionModel] from JSON data.
  factory GlassesDetectionModel.fromJson(Map<String, dynamic> json) {
    print('Parsing glasses detection data: ${json.keys}');
    
    final eyeglasses = json['Eyeglasses'] as Map<String, dynamic>?;
    final sunglasses = json['Sunglasses'] as Map<String, dynamic>?;

    print('Eyeglasses data: $eyeglasses');
    print('Sunglasses data: $sunglasses');

    final model = GlassesDetectionModel(
      hasEyeglasses: eyeglasses?['Value'] as bool? ?? false,
      hasSunglasses: sunglasses?['Value'] as bool? ?? false,
      eyeglassesConfidence: (eyeglasses?['Confidence'] as num?)?.toDouble() ?? 0.0,
      sunglassesConfidence: (sunglasses?['Confidence'] as num?)?.toDouble() ?? 0.0,
    );

    print('Created glasses detection model:');
    print('- Has eyeglasses: ${model.hasEyeglasses}');
    print('- Has sunglasses: ${model.hasSunglasses}');
    
    return model;
  }
} 