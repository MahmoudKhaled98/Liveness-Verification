import 'face_movement_tracker.dart';

/// Entity representing the results of face analysis.
///
/// Contains information about face detection, positioning, movements,
/// and liveness verification status. Manages the state of face verification
/// through [FaceMovementTracker].
class FaceAnalysisResult {
  /// Bounding box coordinates of the detected face.
  final Map<String, dynamic> boundingBox;

  /// Confidence score of face detection.
  final double confidence;

  /// List of facial landmarks detected.
  final List<Map<String, dynamic>> landmarks;

  /// Face pose angles (yaw, pitch, roll).
  final Map<String, dynamic> pose;

  /// Quality metrics of the face detection.
  final Map<String, dynamic> quality;

  /// Detailed facial analysis data.
  final Map<String, dynamic> faceDetails;

  /// Optional message describing the analysis result.
  final String? message;

  /// Static tracker for face movements across frames.
  static final FaceMovementTracker _movementTracker = FaceMovementTracker();

  /// Creates a new [FaceAnalysisResult] instance.
  ///
  /// Requires face detection data including [boundingBox], [confidence],
  /// [landmarks], [pose], [quality], and [faceDetails].
  FaceAnalysisResult({
    required this.boundingBox,
    required this.confidence,
    required this.landmarks,
    required this.pose,
    required this.quality,
    required this.faceDetails,
    this.message,
  });

  /// Gets the yaw angle of the face.
  double? get yaw => pose['Yaw']?.toDouble();

  /// Gets the pitch angle of the face.
  double? get pitch => pose['Pitch']?.toDouble();

  /// Gets the roll angle of the face.
  double? get roll => pose['Roll']?.toDouble();

  /// Gets the relative width of the face in the frame.
  double get faceWidth => boundingBox['Width']?.toDouble() ?? 0.0;

  /// Gets the relative height of the face in the frame.
  double get faceHeight => boundingBox['Height']?.toDouble() ?? 0.0;

  /// Whether the left eye is open.
  bool? get leftEyeOpen {
    final eyesOpen = quality['EyesOpen'] as Map<String, dynamic>?;
    if (eyesOpen == null) return null;

    // Get both value and confidence
    final bool? value = eyesOpen['Value'] as bool?;
    final double confidence = (eyesOpen['Confidence'] as num?)?.toDouble() ?? 0.0;

    // Return false if confidence is too low, otherwise return the value
    if (confidence < 60.0) return false;
    return value;
  }

  bool? get rightEyeOpen => leftEyeOpen;  // AWS provides single value for both eyes

  // Add debug method to print eye status data
  void debugPrintEyeStatus() {
    print('Raw quality data: $quality');
    print('EyesOpen data: ${quality['EyesOpen']}');
    print('Left eye open: $leftEyeOpen');
    print('Right eye open: $rightEyeOpen');
  }

  // Constants for face size thresholds
  static const double tooCloseThreshold = 0.65;
  static const double tooFarThreshold = 0.18;

  bool get isTooClose => faceWidth > tooCloseThreshold || faceHeight > tooCloseThreshold;
  bool get isTooFar => faceWidth < tooFarThreshold || faceHeight < tooFarThreshold;

  // Add face detection check
  bool get isFaceDetected =>
      boundingBox.isNotEmpty &&
      landmarks.isNotEmpty &&
      confidence > 90;

  bool get isProperDistance {
    if (!isFaceDetected) return false;
    return !isTooClose && !isTooFar;
  }

  String get distanceMessage {
    if (!isFaceDetected) return 'Show your face to the camera';
    if (isTooClose) return 'Move back from the camera';
    if (isTooFar) return 'Move closer to the camera';
    return 'Distance is good';
  }

  bool get isAligned {
    if (!isFaceDetected) return false;
    if (!isProperDistance) return false;

    final yawValue = yaw;
    final pitchValue = pitch;
    final rollValue = roll;

    if (yawValue == null || pitchValue == null || rollValue == null) {
      return false;
    }

    return yawValue.abs() < 15 &&
           pitchValue.abs() < 15 &&
           rollValue.abs() < 15;
  }

  bool get isProperlyPositioned => isAligned && isProperDistance;

  /// Whether required head movements have been confirmed.
  bool get isHeadMovementConfirmed => _movementTracker.isHeadMovementConfirmed;

  /// Whether required eye movements have been confirmed.
  bool get isEyeMovementConfirmed => _movementTracker.isEyeMovementConfirmed;

  /// Whether a smile has been detected.
  bool get isSmileDetected => _movementTracker.isSmileDetected;

  bool get isLive {
    if (!isProperlyPositioned) {
      print('Face not properly positioned, resetting liveness detection');
      _movementTracker.reset();
      return false;
    }

    _movementTracker.addFrame(
      yaw,
      pitch,
      roll,
      landmarks,
      faceDetails,
    );

    return confidence > 90 && _movementTracker.isLivenessConfirmed;
  }


  /// Gets the current liveness verification status message.
  String get livenessMessage {
    if (!isProperlyPositioned) {
      return 'Adjust position before liveness check';
    }
    return _movementTracker.livenessMessage;
  }

  /// Gets a message describing the current verification status.
  String get statusMessage {
    if (!isFaceDetected) return 'Show your face to the camera';
    if (isTooClose) return 'Move back from the camera';
    if (isTooFar) return 'Move closer to the camera';
    if (!isAligned) return 'Center your face and look straight ahead';
    if (!isLive) return livenessMessage;
    return 'Verification Complete';
  }

  /// Gets the raw face details data.
  Map<String, dynamic> get faceDetailsData => faceDetails;

  /// Resets the liveness detection state.
  static void resetLivenessDetection() {
    _movementTracker.reset();
  }
}

/// Represents the position of a face in 3D space.
class FacePosition {
  /// Yaw angle (left-right rotation).
  final double yaw;

  /// Pitch angle (up-down rotation).
  final double pitch;

  /// Roll angle (tilt).
  final double roll;

  /// Bounding box of the face.
  final BoundingBox boundingBox;

  /// Creates a new [FacePosition] instance.
  FacePosition({
    required this.yaw,
    required this.pitch,
    required this.roll,
    required this.boundingBox,
  });

  /// Whether the face is properly aligned within acceptable angles.
  bool get isProperlyAligned =>
      yaw.abs() < 15 && pitch.abs() < 15 && roll.abs() < 15;
}

/// Represents the bounding box of a detected face.
class BoundingBox {
  /// Left coordinate of the box.
  final double left;

  /// Top coordinate of the box.
  final double top;

  /// Width of the box.
  final double width;

  /// Height of the box.
  final double height;

  /// Creates a new [BoundingBox] instance.
  BoundingBox({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });
} 