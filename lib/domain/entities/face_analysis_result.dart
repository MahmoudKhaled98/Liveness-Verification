import 'face_movement_tracker.dart';

class FaceAnalysisResult {
  final Map<String, dynamic> boundingBox;
  final double confidence;
  final List<Map<String, dynamic>> landmarks;
  final Map<String, dynamic> pose;
  final Map<String, dynamic> quality;
  final String? message;
  static final FaceMovementTracker _movementTracker = FaceMovementTracker();

  FaceAnalysisResult({
    required this.boundingBox,
    required this.confidence,
    required this.landmarks,
    required this.pose,
    required this.quality,
    this.message,
  });

  double? get yaw => pose['Yaw']?.toDouble();
  double? get pitch => pose['Pitch']?.toDouble();
  double? get roll => pose['Roll']?.toDouble();

  // Get bounding box values
  double get faceWidth => boundingBox['Width']?.toDouble() ?? 0.0;
  double get faceHeight => boundingBox['Height']?.toDouble() ?? 0.0;

  // Update eye status getters to match AWS Rekognition response structure
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
  static const double TOO_CLOSE_THRESHOLD = 0.65;
  static const double TOO_FAR_THRESHOLD = 0.18;

  bool get isTooClose => faceWidth > TOO_CLOSE_THRESHOLD || faceHeight > TOO_CLOSE_THRESHOLD;
  bool get isTooFar => faceWidth < TOO_FAR_THRESHOLD || faceHeight < TOO_FAR_THRESHOLD;

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

  bool get isLive {
    if (!isProperlyPositioned) {
      return false;
    }

    // Add current frame data to tracker with landmarks
    _movementTracker.addFrame(
      yaw, 
      pitch, 
      roll,
      landmarks,
    );
    
    return confidence > 90 && _movementTracker.isLivenessConfirmed;
  }

  static void resetLivenessDetection() {
    _movementTracker.reset();
  }

  String get livenessMessage {
    if (!isProperlyPositioned) {
      return 'Adjust position before liveness check';
    }
    return _movementTracker.livenessMessage;
  }

  String get statusMessage {
    if (!isFaceDetected) return 'Show your face to the camera';
    if (isTooClose) return 'Move back from the camera';
    if (isTooFar) return 'Move closer to the camera';
    if (!isAligned) return 'Center your face and look straight ahead';
    if (!isLive) return livenessMessage;
    return 'Verification Complete';
  }
}

class FacePosition {
  final double yaw;
  final double pitch;
  final double roll;
  final BoundingBox boundingBox;

  FacePosition({
    required this.yaw,
    required this.pitch,
    required this.roll,
    required this.boundingBox,
  });

  bool get isProperlyAligned =>
      yaw.abs() < 15 && pitch.abs() < 15 && roll.abs() < 15;
}

class BoundingBox {
  final double left;
  final double top;
  final double width;
  final double height;

  BoundingBox({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });
} 