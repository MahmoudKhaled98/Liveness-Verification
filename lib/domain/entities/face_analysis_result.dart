import 'face_movement_tracker.dart';
import 'glasses_detection_result.dart';
import 'screen_detection_result.dart';

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

  /// Result of glasses detection.
  final GlassesDetectionResult glassesDetection;

  /// Result of screen detection
  final ScreenDetectionResult screenDetection;

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
    required this.glassesDetection,
    required this.screenDetection,
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

  /// Whether a face is detected in the frame
  bool get isFaceDetected {
    print('Checking face detection:');
    print('- Bounding box: $boundingBox');
    print('- Landmarks count: ${landmarks.length}');
    print('- Confidence: $confidence');
    
    // Check if bounding box has valid dimensions
    final hasValidBoundingBox = boundingBox.containsKey('Width') && 
                               boundingBox.containsKey('Height') &&
                               boundingBox.containsKey('Left') &&
                               boundingBox.containsKey('Top');
    
    print('- Has valid bounding box: $hasValidBoundingBox');
    
    return hasValidBoundingBox &&
           landmarks.isNotEmpty &&
           confidence > 90;  // Lower threshold slightly
  }

  /// Whether the face is at a proper distance
  bool get isProperDistance {
    if (!isFaceDetected) {
      print('Face not detected, distance check failed');
      return false;
    }
    
    // Get bounding box dimensions
    final width = boundingBox['Width'] as double;
    final height = boundingBox['Height'] as double;
    
    final isTooClose = width > tooCloseThreshold || height > tooCloseThreshold;
    final isTooFar = width < tooFarThreshold || height < tooFarThreshold;
    
    final isProper = !isTooClose && !isTooFar;
    print('Distance check:');
    print('- Width: $width, Height: $height');
    print('- Too close: $isTooClose');
    print('- Too far: $isTooFar');
    print('- Is proper: $isProper');
    
    return isProper;
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

    return yawValue.abs() < 20 && //15
           pitchValue.abs() < 15 && //15
           rollValue.abs() < 5;//15
  }

  /// Whether the face is properly positioned and ready for liveness check
  bool get isProperlyPositioned => 
      isFaceDetected && 
      isProperDistance && 
      isAligned && 
      !glassesDetection.hasAnyGlasses &&
      !screenDetection.isScreenDetected;  // Add screen check here

  /// Whether required head movements have been confirmed.
  bool get isHeadMovementConfirmed => _movementTracker.isHeadMovementConfirmed;

  /// Whether required eye movements have been confirmed.
  bool get isEyeMovementConfirmed => _movementTracker.isEyeMovementConfirmed;

  /// Whether a smile has been detected.
  bool get isSmileDetected => _movementTracker.isSmileDetected;

  bool get isLive {
    // Check all positioning requirements first
    if (!isProperlyPositioned) {
      print('Face not properly positioned or screen detected, resetting liveness detection');
      _movementTracker.reset();
      return false;
    }

    // If all checks pass, track movement
    if (yaw != null && pitch != null && roll != null) {
      print('Tracking movement - Yaw: $yaw, Pitch: $pitch, Roll: $roll');
      _movementTracker.addFrame(
        yaw!,
        pitch!,
        roll!,
        landmarks,
        faceDetails,
      );
    }

    return _movementTracker.isLivenessConfirmed;
  }

  /// Gets the current liveness verification status message.
  String get livenessMessage {
    // Check for glasses first
    if (glassesDetection.hasAnyGlasses) {
      return glassesDetection.message;
    }

    // Only show movement instructions if no glasses detected
    if (!isProperlyPositioned) {
      return 'Adjust position before liveness check';
    }

    // Only show movement tracker messages if no glasses and properly positioned
    return _movementTracker.livenessMessage;
  }

  /// Gets a message describing the current verification status.
  String get statusMessage {
    if (!isFaceDetected) {
      return 'Show your face to the camera';
    }
    
    List<String> issues = [];
    
    if (!isProperDistance) {
      if (isTooClose) {
        issues.add('Move back from the camera');
      } else if (isTooFar) {
        issues.add('Move closer to the camera');
      }
    }
    
    if (!isAligned) {
      issues.add('Center your face and look straight ahead');
    }
    
    if (glassesDetection.hasAnyGlasses) {
      issues.add(glassesDetection.message);
    }

    if (screenDetection.isScreenDetected) {
      issues.add('Please remove screen in front of camera');
    }
    
    // If there are issues, return them all
    if (issues.isNotEmpty) {
      return issues.join('\n');
    }
    
    if (!isLive) {
      return livenessMessage;
    }
    
    return 'Verification Complete';
  }

  /// Gets the raw face details data.
  Map<String, dynamic> get faceDetailsData => faceDetails;

  /// Resets the liveness detection state.
  static void resetLivenessDetection() {
    _movementTracker.reset();
  }

  /// Whether the face is ready for liveness checks
  bool get isReadyForAnalysis {
    if (screenDetection.isScreenDetected) {
      print('Screen detected, not ready for analysis');
      return false;
    }
    
    return isFaceDetected && 
           isProperDistance &&
           isAligned &&
           !glassesDetection.hasAnyGlasses;
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
      yaw.abs() < 15 && pitch.abs() < 2 && roll.abs() < 0.008;   // 15 15 15
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