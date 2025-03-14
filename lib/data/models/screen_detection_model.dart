import '../../domain/entities/screen_detection_result.dart';

/// Model class for handling screen detection data from the API.
///
/// This class extends [ScreenDetectionResult] and provides JSON parsing
/// capabilities for screen detection data. It analyzes face occlusion,
/// brightness, and sharpness to determine if a screen is present.
class ScreenDetectionModel extends ScreenDetectionResult {
  /// Creates a new [ScreenDetectionModel] instance.
  ///
  /// All parameters are required except [message]:
  /// * [isScreenDetected] - Whether a screen was detected
  /// * [occlusionConfidence] - Confidence score for face occlusion
  /// * [brightness] - Brightness value of the image
  /// * [sharpness] - Sharpness value of the image
  /// * [message] - Optional detection reason message
  ScreenDetectionModel({
    required super.isScreenDetected,
    required super.occlusionConfidence,
    required super.brightness,
    required super.sharpness,
    super.message,
  });

  /// Creates a [ScreenDetectionModel] from JSON data.
  ///
  /// Expects JSON with the following structure:
  /// ```json
  /// {
  ///   "FaceOccluded": {
  ///     "Value": bool,
  ///     "Confidence": double
  ///   },
  ///   "Quality": {
  ///     "Brightness": double,
  ///     "Sharpness": double
  ///   }
  /// }
  /// ```
  factory ScreenDetectionModel.fromJson(Map<String, dynamic> json) {
    print('ScreenDetectionModel: Starting JSON parsing');
    
    // Extract occlusion and quality data
    final faceOccluded = json['FaceOccluded'] as Map<String, dynamic>?;
    final quality = json['Quality'] as Map<String, dynamic>?;

    print('Raw data:');
    print('- FaceOccluded: $faceOccluded');
    print('- Quality: $quality');

    // Parse individual values with defaults
    final occlusionConfidence = (faceOccluded?['Confidence'] as num?)?.toDouble() ?? 0.0;
    final isOccluded = faceOccluded?['Value'] as bool? ?? false;
    final brightness = (quality?['Brightness'] as num?)?.toDouble() ?? 0.0;
    final sharpness = (quality?['Sharpness'] as num?)?.toDouble() ?? 100.0;

    // Screen detection logic based on thresholds
    // A screen is detected if any of these conditions are met:
    // 1. Face is occluded
    // 2. Brightness is too high (> 86.0)
    // 3. Sharpness is too low (< 70.0)
    final isScreenDetected = isOccluded ||
        brightness > 86.0 ||
        sharpness < 70.0;

    print('Screen Detection Values:');
    print('- Sharpness: $sharpness');
    print('- Brightness: $brightness');
    print('- Occlusion confidence: $occlusionConfidence');
    print('- Is occluded: $isOccluded');
    print('- Screen detected: $isScreenDetected');

    // Determine the specific reason for screen detection
    String detectionReason = "No screen detected";
    if (isScreenDetected) {
      if (isOccluded) {
        detectionReason = "Face occlusion detected";
      } else if (brightness > 86.0) {
        detectionReason = "High brightness detected";
      } else if (sharpness < 70.0) {
        detectionReason = "Low sharpness detected";
      }
      print('Screen detected due to: $detectionReason');
    }

    return ScreenDetectionModel(
      isScreenDetected: isScreenDetected,
      occlusionConfidence: occlusionConfidence,
      brightness: brightness,
      sharpness: sharpness,
      message: detectionReason,
    );
  }
}
