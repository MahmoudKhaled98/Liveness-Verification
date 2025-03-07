import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/face_movement.dart';
import '../entities/face_detection_config.dart';

/// Use case for detecting and validating head movements.
///
/// Tracks head movements over time to determine if they meet liveness requirements.
class HeadMovementDetectionUseCase {
  /// Configuration parameters for movement detection.
  final FaceDetectionConfig config;

  /// History of recorded face movements.
  final List<FaceMovement> movements;

  /// Creates a new [HeadMovementDetectionUseCase] instance.
  ///
  /// Optionally accepts [initialMovements] to initialize movement history.
  HeadMovementDetectionUseCase({
    required this.config,
    List<FaceMovement>? initialMovements,
  }) : movements = initialMovements ?? [];

  /// Executes head movement detection with a new movement.
  ///
  /// Returns [Either<Failure, bool>] indicating whether significant
  /// movement was detected.
  Either<Failure, bool> execute(FaceMovement newMovement) {
    try {
      if (movements.length >= config.requiredFrames) {
        movements.removeAt(0);
      }
      movements.add(newMovement);

      if (movements.length < config.requiredFrames) {
        return const Right(false);
      }

      for (int i = 1; i < movements.length; i++) {
        final current = movements[i];
        final previous = movements[i - 1];
        
        final movement = FaceMovement(
          yaw: current.yaw - previous.yaw,
          pitch: current.pitch - previous.pitch,
          roll: current.roll - previous.roll,
        );

        if (movement.isSignificantMovement(config.movementThreshold)) {
          return const Right(true);
        }
      }

      return const Right(false);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
} 