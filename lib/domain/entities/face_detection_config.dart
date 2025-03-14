/// Configuration parameters for face detection and liveness checks.
class FaceDetectionConfig {
  /// Threshold for detecting significant head movements.
  final double movementThreshold;

  /// Threshold for detecting eye movements.
  final double eyeMovementThreshold;

  /// Number of frames required for movement validation.
  final int requiredFrames;

  /// Creates a new [FaceDetectionConfig] instance with default values.
  const FaceDetectionConfig({
    this.movementThreshold = 9,  //3.5
    this.eyeMovementThreshold = 0.02, //0.0178
    this.requiredFrames = 6,//4
  });
} 