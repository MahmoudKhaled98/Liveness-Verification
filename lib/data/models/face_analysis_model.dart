import '../../domain/entities/face_analysis_result.dart';

class FaceAnalysisModel extends FaceAnalysisResult {
  FaceAnalysisModel({
    required super.boundingBox,
    required super.confidence,
    required super.landmarks,
    required super.pose,
    required super.quality,
    super.message,
  });

  factory FaceAnalysisModel.fromJson(Map<String, dynamic> json) {
    return FaceAnalysisModel(
      boundingBox: json['boundingBox'] ?? {},
      confidence: json['confidence']?.toDouble() ?? 0.0,
      landmarks: (json['landmarks'] as List?)?.cast<Map<String, dynamic>>() ?? [],
      pose: json['pose'] ?? {},
      quality: json['quality'] ?? {},
      message: json['message'],
    );
  }
} 