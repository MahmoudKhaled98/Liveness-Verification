/// Entity representing the result of screen detection analysis.
///
/// This class contains information about whether a screen was detected
/// in front of the face, along with related metrics like brightness,
/// sharpness, and occlusion confidence.
class ScreenDetectionResult {
  /// Whether a screen was detected in front of the face.
  final bool isScreenDetected;

  /// Confidence score for face occlusion detection (0-100).
  final double occlusionConfidence;

  /// Brightness value of the image (0-100).
  /// Higher values indicate potential screen presence.
  final double brightness;

  /// Sharpness value of the image (0-100).
  /// Lower values might indicate screen reflection or interference.
  final double sharpness;

  /// Message describing the detection result or reason.
  final String message;

  /// Creates a new [ScreenDetectionResult] instance.
  ///
  /// All parameters are required except [message]:
  /// * [isScreenDetected] - Whether a screen was detected
  /// * [occlusionConfidence] - Confidence score for face occlusion
  /// * [brightness] - Brightness value of the image
  /// * [sharpness] - Sharpness value of the image
  /// * [message] - Optional detection reason message
  const ScreenDetectionResult({
    required this.isScreenDetected,
    required this.occlusionConfidence,
    required this.brightness,
    required this.sharpness,
    this.message = '',
  });

  /// Gets a user-friendly message describing the screen detection status.
  ///
  /// Returns different messages based on what triggered the screen detection:
  /// * High brightness
  /// * Low sharpness
  /// * General screen detection
  String get statusMessage {
    if (isScreenDetected) {
      if (brightness > 90.0) {
        return 'Please remove screen - high brightness detected';
      }
      if (sharpness < 40.0) {
        return 'Please remove screen - low image quality';
      }
      return 'Please remove screen in front of camera';
    }
    return message;
  }
} 