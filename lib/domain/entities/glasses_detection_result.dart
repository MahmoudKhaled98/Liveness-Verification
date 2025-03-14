/// Represents the result of glasses detection on a face.
class GlassesDetectionResult {
  /// Whether regular eyeglasses are detected.
  final bool hasEyeglasses;

  /// Whether sunglasses are detected.
  final bool hasSunglasses;

  /// Confidence score for eyeglasses detection.
  final double eyeglassesConfidence;

  /// Confidence score for sunglasses detection.
  final double sunglassesConfidence;

  /// Creates a new [GlassesDetectionResult] instance.
  const GlassesDetectionResult({
    required this.hasEyeglasses,
    required this.hasSunglasses,
    required this.eyeglassesConfidence,
    required this.sunglassesConfidence,
  });

  /// Whether any type of glasses are detected.
  bool get hasAnyGlasses => hasEyeglasses || hasSunglasses;

  /// Gets a message describing the glasses detection result.
  String get message {
    if (hasSunglasses) {
      return 'Please remove your sunglasses and try again';
    }
    if (hasEyeglasses) {
      return 'Please remove your eyeglasses and try again';
    }
    return 'No glasses detected';
  }
} 