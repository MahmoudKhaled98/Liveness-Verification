/// Represents a face movement with yaw, pitch, and roll angles.
///
/// Used to track head movements for liveness detection.
class FaceMovement {
  /// The yaw angle (left-right rotation) of the face.
  final double yaw;

  /// The pitch angle (up-down rotation) of the face.
  final double pitch;

  /// The roll angle (tilt) of the face.
  final double roll;

  /// Creates a new [FaceMovement] instance.
  const FaceMovement({
    required this.yaw,
    required this.pitch,
    required this.roll,
  });

  /// Determines if the movement exceeds the given threshold.
  ///
  /// Returns true if any angle (yaw, pitch, roll) exceeds [threshold].
  bool isSignificantMovement(double threshold) {
    return yaw.abs() > threshold ||
        pitch.abs() > threshold ||
        roll.abs() > threshold;
  }
} 