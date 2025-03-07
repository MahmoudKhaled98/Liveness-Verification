import '../../domain/entities/face_analysis_result.dart';

/// Data model representing face analysis results.
///
/// Extends [FaceAnalysisResult] to provide JSON serialization capabilities.
class FaceAnalysisModel extends FaceAnalysisResult {
  /// Creates a new [FaceAnalysisModel] instance.
  FaceAnalysisModel({
    required super.boundingBox,
    required super.confidence,
    required super.landmarks,
    required super.pose,
    required super.quality,
    required super.faceDetails,
    super.message,
  });

  /// Creates a [FaceAnalysisModel] from JSON data.
  ///
  /// Handles null values and type conversions from the API response.
  factory FaceAnalysisModel.fromJson(Map<String, dynamic> json) {
    return FaceAnalysisModel(
      boundingBox: json['boundingBox'] ?? {},
      confidence: json['confidence']?.toDouble() ?? 0.0,
      landmarks: (json['landmarks'] as List?)?.cast<Map<String, dynamic>>() ?? [],
      pose: json['pose'] ?? {},
      quality: json['quality'] ?? {},
      faceDetails: json['faceDetails'] ?? {},
      message: json['message'],
    );
  }
} 