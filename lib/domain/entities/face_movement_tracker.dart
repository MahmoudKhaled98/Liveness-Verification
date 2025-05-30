import 'face_detection_config.dart';
import 'face_movement.dart';
import 'eye_point.dart';

/// Tracks and analyzes face movements for liveness detection.
///
/// Maintains history of head movements, eye positions, and facial expressions
/// to determine if a real person is present based on natural movements.
/// Uses configurable thresholds for movement detection and validation.
class FaceMovementTracker {
  /// Configuration parameters for movement detection thresholds.
  final FaceDetectionConfig config;

  /// History of recorded head pose movements.
  final List<FaceMovement> poseHistory = [];

  /// History of recorded eye positions.
  final List<Map<String, EyePoint>> eyePositionsHistory = [];

  /// Set of unique movement types detected during eye tracking.
  final Set<String> detectedMovements = {};

  /// Whether required head movements have been confirmed.
  bool _headMovementConfirmed = false;

  /// Whether required eye movements have been confirmed.
  bool _eyeMovementConfirmed = false;

  /// Whether a smile has been detected.
  bool _smileDetected = false;

  /// Whether the face is properly positioned and ready for liveness check
  bool _isProperlyPositioned = false;

  /// Creates a new [FaceMovementTracker] instance.
  ///
  /// Optionally accepts [config] for customizing detection parameters.
  /// Uses default configuration if none provided.
  FaceMovementTracker({
    FaceDetectionConfig? config,
  }) : config = config ?? const FaceDetectionConfig(
    movementThreshold: 9,
    eyeMovementThreshold: 0.020, //28
    requiredFrames: 6,
  );

  /// Processes a new frame of face tracking data.
  ///
  /// Takes face position angles ([yaw], [pitch], [roll]), facial [landmarks],
  /// and [faceDetails] to update movement detection state. Processes movements
  /// in sequence: head movement, then eye movement, then smile detection.
  void addFrame(
    double yaw,
    double pitch,
    double roll,
    List<Map<String, dynamic>> landmarks,
    Map<String, dynamic> faceDetails,
  ) {
    print('Adding frame for movement tracking:');
    print('- Current yaw: $yaw');
    print('- Current pitch: $pitch');
    print('- Current roll: $roll');

    // Set properly positioned flag first
    _isProperlyPositioned = true;

    // Track head movement
    if (!_headMovementConfirmed) {
      final movement = FaceMovement(yaw: yaw, pitch: pitch, roll: roll);

      if (poseHistory.length >= config.requiredFrames) {
        poseHistory.removeAt(0);
      }
      poseHistory.add(movement);

      // Check for significant movement
      if (poseHistory.length >= 2) {
        for (int i = 1; i < poseHistory.length; i++) {
          final current = poseHistory[i];
          final previous = poseHistory[i - 1];

          final deltaYaw = (current.yaw - previous.yaw).abs();
          final deltaPitch = (current.pitch - previous.pitch).abs();
          final deltaRoll = (current.roll - previous.roll).abs();

          print('Movement deltas:');
          print('- Delta yaw: $deltaYaw');
          print('- Delta pitch: $deltaPitch');
          print('- Delta roll: $deltaRoll');
          print('- Threshold: ${config.movementThreshold}');

          if (deltaYaw > config.movementThreshold ||
              deltaPitch > config.movementThreshold ||
              deltaRoll > config.movementThreshold) {
            print('Significant movement detected!');
            _headMovementConfirmed = true;
            break;
          }
        }
      }
    }

    // Only proceed with eye tracking if head movement is confirmed
    if (_headMovementConfirmed && !_eyeMovementConfirmed) {
      _trackEyeMovement(landmarks);
    }

    // Only track smile after eye movement is confirmed
    if (_headMovementConfirmed && _eyeMovementConfirmed && !_smileDetected) {
      _trackSmile(faceDetails);
    }

    print('Movement tracking status:');
    print('- Head movement confirmed: $_headMovementConfirmed');
    print('- Eye movement confirmed: $_eyeMovementConfirmed');
    print('- Smile detected: $_smileDetected');
  }

  /// Validates that all required face data is present and valid.
  // bool _isValidFrameData(
  //   double? yaw,
  //   double? pitch,
  //   double? roll,
  //   List<Map<String, dynamic>> landmarks,
  //   Map<String, dynamic> faceDetails,
  // ) {
  //   return yaw != null &&
  //       pitch != null &&
  //       roll != null &&
  //       landmarks.isNotEmpty &&
  //       faceDetails.isNotEmpty;
  // }

  /// Processes eye movement data to detect gaze changes.
  ///
  /// Extracts and tracks eye positions to detect natural eye movements.
  void _trackEyeMovement(List<Map<String, dynamic>> landmarks) {
    if (!_headMovementConfirmed) return;

    final eyePoints = _extractEyePoints(landmarks);
    final currentEyes = _groupEyePoints(eyePoints);

    if (eyePositionsHistory.isEmpty) {
      eyePositionsHistory.add(currentEyes);
      return;
    }

    final movement = _detectEyeMovement(
      eyePositionsHistory.last,
      currentEyes,
    );

    if (movement != "Stable") {
      detectedMovements.add(movement);
      _eyeMovementConfirmed = detectedMovements.length >= 2;
    }

    if (eyePositionsHistory.length >= config.requiredFrames) {
      eyePositionsHistory.removeAt(0);
    }
    eyePositionsHistory.add(currentEyes);
  }

  /// Extracts eye points from facial landmarks.
  ///
  /// Converts landmark data into [EyePoint] objects for tracking.
  List<EyePoint> _extractEyePoints(List<Map<String, dynamic>> landmarks) {
    return landmarks
        .where((l) => l['type'].toString().toLowerCase().contains('eye'))
        .map((l) => EyePoint(
              x: l['x'] as double,
              y: l['y'] as double,
              type: l['type'] as String,
            ))
        .toList();
  }

  /// Groups eye points by left and right eye.
  ///
  /// Takes raw [points] and returns a map with averaged positions for each eye.
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

    final double x = points.map((p) => p.x).reduce((a, b) => a + b) / points.length;
    final double y = points.map((p) => p.y).reduce((a, b) => a + b) / points.length;
    return EyePoint(x: x, y: y, type: points.first.type);
  }

  /// Detects eye movement direction between frames.
  ///
  /// Compares previous and current eye positions to determine movement direction.
  String _detectEyeMovement(
    Map<String, EyePoint> prevEyes,
    Map<String, EyePoint> currEyes,
  ) {
    for (final eyeType in ['left', 'right']) {
      final prev = prevEyes[eyeType]!;
      final curr = currEyes[eyeType]!;

      final dx = curr.x - prev.x;
      final dy = curr.y - prev.y;

      if (dx.abs() > config.eyeMovementThreshold ||
          dy.abs() > config.eyeMovementThreshold) {
        if (dx.abs() > dy.abs()) {
          return dx > 0 ? "Looking Right" : "Looking Left";
        } else {
          return dy > 0 ? "Looking Down" : "Looking Up";
        }
      }
    }
    return "Stable";
  }

  /// Processes smile detection from face details.
  ///
  /// Analyzes smile confidence and emotion data to detect genuine smiles.
  void _trackSmile(Map<String, dynamic> faceDetails) {
    if (!_eyeMovementConfirmed) return;

    if (faceDetails['Smile'] != null) {
      var smile = faceDetails['Smile'];
      if (smile['Value'] == true && (smile['Confidence'] as num) >= 80) {
        _smileDetected = true;
        return;
      }
    }

    if (faceDetails['Emotions'] != null && faceDetails['Emotions'] is List) {
      var emotions = faceDetails['Emotions'] as List;
      for (var emotion in emotions) {
        if (emotion['Type'].toString().toLowerCase() == 'happy' &&
            (emotion['Confidence'] as num) >= 80) {
          _smileDetected = true;
          return;
        }
      }
    }
  }

  /// Resets all tracking state.
  ///
  /// Clears movement history and resets all detection flags.
  void reset() {
    poseHistory.clear();
    eyePositionsHistory.clear();
    detectedMovements.clear();
    _headMovementConfirmed = false;
    _eyeMovementConfirmed = false;
    _smileDetected = false;
    _isProperlyPositioned = false;
  }

  /// Whether all required liveness checks have been confirmed.
  bool get isLivenessConfirmed =>
      _headMovementConfirmed && _eyeMovementConfirmed && _smileDetected;

  /// Gets a message describing the current liveness status.
  String get livenessMessage {
    if (!_isProperlyPositioned) {
      return 'Please move your head...';
    }
    if (!_headMovementConfirmed) {
      return 'Please move your head slightly to the right and left.';
    }
    if (!_eyeMovementConfirmed) {
      return 'Now, please look around naturally';
    }
    if (!_smileDetected) {
      return 'Please smile :)';
    }
    return 'Liveness confirmed';
  }

  // Getters for state
  bool get isHeadMovementConfirmed => _headMovementConfirmed;
  bool get isEyeMovementConfirmed => _eyeMovementConfirmed;
  bool get isSmileDetected => _smileDetected;
  bool get isProperlyPositioned => _isProperlyPositioned;
}