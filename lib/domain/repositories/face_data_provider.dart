import '../entities/eye_point.dart';
import '../entities/face_movement.dart';

/// Interface for providing face-related data from face detection systems.
///
/// Defines methods for accessing real-time face tracking data including
/// eye positions, head movements, and facial expressions.
abstract class FaceDataProvider {
  /// Gets the current positions of detected eye points.
  ///
  /// Returns a list of [EyePoint] objects containing the coordinates
  /// and types of detected eye landmarks.
  Future<List<EyePoint>> getEyePoints();

  /// Gets the current head movement data.
  ///
  /// Returns a [FaceMovement] object containing the current
  /// yaw, pitch, and roll angles of the head.
  Future<FaceMovement> getFaceMovement();

  /// Checks if the face is currently showing a smile.
  ///
  /// Returns true if a smile is detected with sufficient confidence.
  Future<bool> detectSmile();
} 