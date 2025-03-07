import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/eye_point.dart';
import '../../domain/entities/face_detection_config.dart';
import '../../domain/repositories/face_data_provider.dart';
import '../../domain/usecases/eye_movement_detection_usecase.dart';
import '../../domain/usecases/head_movement_detection_usecase.dart';

/// Service responsible for tracking and analyzing face movements in real-time.
///
/// Coordinates the detection of head movements, eye movements, and smiles
/// to verify liveness. Uses [FaceDataProvider] to get face data and
/// specialized use cases for movement detection.
class FaceTrackingService {
  /// Provider for face-related data.
  final FaceDataProvider dataProvider;

  /// Configuration for face detection thresholds and parameters.
  final FaceDetectionConfig config;

  /// Use case for detecting head movements.
  final HeadMovementDetectionUseCase headMovementDetection;

  /// Use case for detecting eye movements.
  final EyeMovementDetectionUseCase eyeMovementDetection;

  /// Whether required head movements have been confirmed.
  bool _headMovementConfirmed = false;

  /// Whether required eye movements have been confirmed.
  bool _eyeMovementConfirmed = false;

  /// Whether a smile has been detected.
  bool _smileDetected = false;

  /// Set of detected eye movement directions.
  final Set<String> detectedMovements = {};

  /// Creates a new [FaceTrackingService] instance.
  ///
  /// Requires a [dataProvider] for face data and [config] for detection parameters.
  FaceTrackingService({required this.dataProvider, required this.config})
    : headMovementDetection = HeadMovementDetectionUseCase(config: config),
      eyeMovementDetection = EyeMovementDetectionUseCase(config: config);

  /// Processes a single frame of face tracking data.
  ///
  /// Returns [Either<Failure, bool>] indicating whether all required
  /// movements have been detected (true) or not yet complete (false).
  Future<Either<Failure, bool>> processFrame() async {
    try {
      // Process head movement if not already confirmed
      if (!_headMovementConfirmed) {
        final movement = await dataProvider.getFaceMovement();
        final result = headMovementDetection.execute(movement);

        result.fold(
          (failure) => throw failure,
          (detected) => _headMovementConfirmed = detected,
        );

        if (!_headMovementConfirmed) return const Right(false);
      }

      // Process eye movement if head movement is confirmed
      if (!_eyeMovementConfirmed) {
        final eyePoints = await dataProvider.getEyePoints();
        final eyes = _groupEyePoints(eyePoints);
        final result = eyeMovementDetection.detectMovement(eyes);

        result.fold((failure) => throw failure, (movement) {
          if (movement != "Stable") {
            detectedMovements.add(movement);
            _eyeMovementConfirmed = detectedMovements.length >= 2;
          }
        });

        if (!_eyeMovementConfirmed) return const Right(false);
      }

      // Process smile if eye movement is confirmed
      if (!_smileDetected) {
        _smileDetected = await dataProvider.detectSmile();
        if (!_smileDetected) return const Right(false);
      }

      return const Right(true);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  /// Groups eye points by left and right eye and calculates center points.
  ///
  /// Takes a list of [points] and returns a map with left and right eye centers.
  Map<String, EyePoint> _groupEyePoints(List<EyePoint> points) {
    final Map<String, List<EyePoint>> grouped = {'left': [], 'right': []};

    for (final point in points) {
      if (point.type.toLowerCase().contains('left')) {
        grouped['left']!.add(point);
      } else if (point.type.toLowerCase().contains('right')) {
        grouped['right']!.add(point);
      }
    }

    return {
      'left': _getEyeCenter(grouped['left']!),
      'right': _getEyeCenter(grouped['right']!),
    };
  }

  /// Calculates the center point from a list of eye points.
  ///
  /// Returns the average position of all points in the list.
  EyePoint _getEyeCenter(List<EyePoint> points) {
    if (points.isEmpty) {
      return EyePoint(x: 0, y: 0, type: 'unknown');
    }

    final double x =
        points.map((p) => p.x).reduce((a, b) => a + b) / points.length;
    final double y =
        points.map((p) => p.y).reduce((a, b) => a + b) / points.length;
    return EyePoint(x: x, y: y, type: points.first.type);
  }

  /// Resets all tracking progress.
  ///
  /// Clears all confirmed movements and detected states.
  void reset() {
    _headMovementConfirmed = false;
    _eyeMovementConfirmed = false;
    _smileDetected = false;
    detectedMovements.clear();
  }

  /// Whether all required movements have been completed.
  bool get isComplete =>
      _headMovementConfirmed && _eyeMovementConfirmed && _smileDetected;
}
