import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/eye_point.dart';
import '../entities/face_detection_config.dart';

/// Use case for detecting and validating eye movements.
///
/// Tracks eye movements over time to determine if they meet liveness requirements.
class EyeMovementDetectionUseCase {
  /// Configuration parameters for movement detection.
  final FaceDetectionConfig config;

  /// History of eye positions.
  final List<Map<String, EyePoint>> eyePositionsHistory;

  /// Creates a new [EyeMovementDetectionUseCase] instance.
  ///
  /// Optionally accepts [initialHistory] to initialize eye position history.
  EyeMovementDetectionUseCase({
    required this.config,
    List<Map<String, EyePoint>>? initialHistory,
  }) : eyePositionsHistory = initialHistory ?? [];

  /// Detects eye movement direction from current eye positions.
  ///
  /// Returns [Either<Failure, String>] indicating the direction of movement
  /// or "Stable" if no significant movement is detected.
  Either<Failure, String> detectMovement(Map<String, EyePoint> currentEyes) {
    try {
      if (eyePositionsHistory.isEmpty) {
        eyePositionsHistory.add(currentEyes);
        return const Right("Stable");
      }

      final previousEyes = eyePositionsHistory.last;
      
      for (final eyeType in ['left', 'right']) {
        final prev = previousEyes[eyeType]!;
        final curr = currentEyes[eyeType]!;

        final dx = curr.x - prev.x;
        final dy = curr.y - prev.y;

        if (dx.abs() > config.eyeMovementThreshold || 
            dy.abs() > config.eyeMovementThreshold) {
          if (dx.abs() > dy.abs()) {
            return Right(dx > 0 ? "Looking Right" : "Looking Left");
          } else {
            return Right(dy > 0 ? "Looking Down" : "Looking Up");
          }
        }
      }

      return const Right("Stable");
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
} 