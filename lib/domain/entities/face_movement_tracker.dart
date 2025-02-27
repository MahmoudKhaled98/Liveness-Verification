class EyePoint {
  final double x;
  final double y;
  final String type;
//0.425
  EyePoint({required this.x, required this.y, required this.type});
}

class FaceMovementTracker {
  final List<Map<String, double>> poseHistory = [];
  final List<Map<String, Map<String, double>>> eyePositionsHistory = [];
  final List<bool> blinkHistory = [];
  final int requiredFrames = 8;
  final double movementThreshold = 2.7;
  final double eyeMovementThreshold = 0.021; // Adjusted threshold for eye movement
  final double blinkThreshold = 0.4219;  // Static threshold for blink detection
  final int minBlinkFrames = 1;  // At least 1 frames of closed eyes for a valid blink
  final int maxBlinkFrames = 5;  // Allow up to 5 frames for slower blinks
  List<String> detectedMovements = [];
  final int requiredBlinkCount = 2;  // Number of blinks needed for liveness
  final List<double> earHistory = [];  // Store EAR values for moving average
  double? baselineEAR;  // Baseline EAR when eyes are fully open
  DateTime? firstBlinkTime;  // Track when blinking started
  final int movingAverageWindow = 2;    // Keep small window for smooth EAR values
  final double blinkThresholdRatio = 0.98;  // Detect very subtle changes (98.0% of baseline)
  final int minBlinkDurationFrames = 1;  // Minimum frames for valid blink
  final int maxBlinkDurationFrames = 5;  // Maximum frames for valid blink
  final double minBlinksPerMinute = 15;  // Minimum normal blink rate
  final double maxBlinksPerMinute = 20;  // Maximum normal blink rate
  final int minRequiredBlinks = 2;  // Minimum number of blinks needed
  bool prevEyesOpen = true;
  int blinkCount = 0;
  DateTime? lastBlinkTime;
  final int minBlinkInterval = 200;  // Minimum time between blinks (milliseconds)
  final double confidenceThreshold = 0.90;  // 90% confidence threshold

  Map<String, double> getEyeCenter(List<EyePoint> eyePoints) {
    double x = eyePoints.map((p) => p.x).reduce((a, b) => a + b) / eyePoints.length;
    double y = eyePoints.map((p) => p.y).reduce((a, b) => a + b) / eyePoints.length;
    return {'x': x, 'y': y};
  }

  String detectEyeMovement(Map<String, double> prevEye, Map<String, double> currEye) {
    double dx = currEye['x']! - prevEye['x']!;
    double dy = currEye['y']! - prevEye['y']!;

    if (dx.abs() < eyeMovementThreshold && dy.abs() < eyeMovementThreshold) {
      return "Stable";
    }

    if (dx.abs() > dy.abs()) {
      return dx > 0 ? "Looking Right" : "Looking Left";
    } else {
      return dy > 0 ? "Looking Down" : "Looking Up";
    }
  }

  double calculateEAR(List<EyePoint> eyePoints) {
    // Filter only eye corner points (left, right, up, down)
    List<EyePoint> cornerPoints = eyePoints.where((point) {
      return point.type.contains('EyeLeft') || 
             point.type.contains('EyeRight') || 
             point.type.contains('EyeUp') || 
             point.type.contains('EyeDown');
    }).toList();

    if (cornerPoints.length < 4) return 1.0;

    try {
      // Find the points
      var leftPoint = cornerPoints.firstWhere((p) => p.type.endsWith('EyeLeft'));
      var rightPoint = cornerPoints.firstWhere((p) => p.type.endsWith('EyeRight'));
      var upPoint = cornerPoints.firstWhere((p) => p.type.endsWith('EyeUp'));
      var downPoint = cornerPoints.firstWhere((p) => p.type.endsWith('EyeDown'));

      // Calculate distances
      double verticalDist = (upPoint.y - downPoint.y).abs();
      double horizontalDist = (leftPoint.x - rightPoint.x).abs();

      if (horizontalDist == 0) return 1.0;

      // Calculate raw EAR without normalization
      double ear = verticalDist / horizontalDist;
      
      print('Eye points - Left: (${leftPoint.x}, ${leftPoint.y}), Right: (${rightPoint.x}, ${rightPoint.y})');
      print('Eye points - Up: (${upPoint.x}, ${upPoint.y}), Down: (${downPoint.x}, ${downPoint.y})');
      print('EAR calculation - Vertical: $verticalDist, Horizontal: $horizontalDist, EAR: $ear');
      return ear;
    } catch (e) {
      print('Error calculating EAR: $e');
      return 1.0;
    }
  }

  // Calculate moving average of EAR values
  double _calculateMovingAverage(double newEAR) {
    earHistory.add(newEAR);
    if (earHistory.length > movingAverageWindow) {
      earHistory.removeAt(0);
    }
    return earHistory.reduce((a, b) => a + b) / earHistory.length;
  }

  // Initialize baseline EAR from initial frames
  void _updateBaselineEAR(double currentEAR) {
    if (baselineEAR == null) {
      baselineEAR = currentEAR;
    } else {
      // More weight on current value to adapt faster
      baselineEAR = baselineEAR! * 0.7 + currentEAR * 0.3;
    }
  }

  void addFrame(double? yaw, double? pitch, double? roll, List<Map<String, dynamic>> landmarks) {
    if (yaw == null || pitch == null || roll == null) return;
    
    poseHistory.add({
      'yaw': yaw,
      'pitch': pitch,
      'roll': roll,
    });

    // Extract eye landmarks
    List<EyePoint> leftEyePoints = [];
    List<EyePoint> rightEyePoints = [];

    for (var landmark in landmarks) {
      String type = landmark['type'] as String;
      double x = landmark['x'] as double;
      double y = landmark['y'] as double;

      // Only collect actual eye points, not eyebrow points
      if (type.contains('leftEye') && !type.contains('Brow')) {
        leftEyePoints.add(EyePoint(x: x, y: y, type: type));
        print('Added left eye point: $type at x:$x, y:$y');
      } else if (type.contains('rightEye') && !type.contains('Brow')) {
        rightEyePoints.add(EyePoint(x: x, y: y, type: type));
        print('Added right eye point: $type at x:$x, y:$y');
      }
    }

    print('Left eye points count: ${leftEyePoints.length}');
    print('Right eye points count: ${rightEyePoints.length}');

    // Calculate EAR values
    double leftEAR = calculateEAR(leftEyePoints);
    double rightEAR = calculateEAR(rightEyePoints);
    double avgEAR = (leftEAR + rightEAR) / 2;
    double smoothedEAR = _calculateMovingAverage(avgEAR);

    // Determine if eyes are open based on EAR
    bool eyesOpen = smoothedEAR >= blinkThreshold;
    double confidence = 1.0 - (smoothedEAR - blinkThreshold).abs();

    // Detect blink with debounce
    DateTime now = DateTime.now();
    if (!eyesOpen && prevEyesOpen && confidence > confidenceThreshold) {
      if (lastBlinkTime == null || 
          now.difference(lastBlinkTime!).inMilliseconds > minBlinkInterval) {
        blinkCount++;
        lastBlinkTime = now;
        print('Valid blink detected! Count: $blinkCount');
      }
    }
    prevEyesOpen = eyesOpen;

    // Store blink state for history
    blinkHistory.add(!eyesOpen);

    // Keep reasonable history
    if (blinkHistory.length > 20) {
      blinkHistory.removeAt(0);
    }

    print('Blink detection - EAR: $smoothedEAR, Eyes Open: $eyesOpen');
    print('Confidence: ${(confidence * 100).toStringAsFixed(1)}%, Blink Count: $blinkCount');

    // Calculate eye centers
    Map<String, Map<String, double>> currentEyePositions = {
      'leftEye': getEyeCenter(leftEyePoints),
      'rightEye': getEyeCenter(rightEyePoints),
    };

    eyePositionsHistory.add(currentEyePositions);

    // Keep only the last N frames
    if (poseHistory.length > requiredFrames) {
      poseHistory.removeAt(0);
      eyePositionsHistory.removeAt(0);
    }

    // Detect eye movements if we have enough history
    if (eyePositionsHistory.length >= 2) {
      var prevFrame = eyePositionsHistory[eyePositionsHistory.length - 2];
      var currFrame = eyePositionsHistory.last;

      String leftEyeMovement = detectEyeMovement(
        prevFrame['leftEye']!, 
        currFrame['leftEye']!
      );
      String rightEyeMovement = detectEyeMovement(
        prevFrame['rightEye']!, 
        currFrame['rightEye']!
      );

      if (leftEyeMovement != "Stable" && rightEyeMovement != "Stable") {
        detectedMovements.add(leftEyeMovement);
        if (detectedMovements.length > 5) {
          detectedMovements.removeAt(0);
        }
      }
    }
  }

  bool get hasDetectedEyeMovement {
    if (detectedMovements.length < 3) return false;

    // Check if we have detected different eye movements
    Set<String> uniqueMovements = detectedMovements.toSet();
    return uniqueMovements.length >= 2; // At least two different eye movements
  }

  bool get hasEnoughFrames => poseHistory.length >= requiredFrames;

  bool get hasDetectedHeadMovement {
    if (!hasEnoughFrames) return false;

    double maxYawDiff = 0;
    double maxPitchDiff = 0;
    double maxRollDiff = 0;

    for (int i = 1; i < poseHistory.length; i++) {
      maxYawDiff = _max(maxYawDiff, 
          (poseHistory[i]['yaw']! - poseHistory[i-1]['yaw']!).abs());
      maxPitchDiff = _max(maxPitchDiff, 
          (poseHistory[i]['pitch']! - poseHistory[i-1]['pitch']!).abs());
      maxRollDiff = _max(maxRollDiff, 
          (poseHistory[i]['roll']! - poseHistory[i-1]['roll']!).abs());
    }

    return maxYawDiff > movementThreshold || 
           maxPitchDiff > movementThreshold || 
           maxRollDiff > movementThreshold;
  }

  bool get hasDetectedBlinking {
    print('Blink validation - Count: $blinkCount/$requiredBlinkCount');
    
    // Simply check if we have detected at least 3 blinks
    return blinkCount >= requiredBlinkCount;
  }

  bool get isLivenessConfirmed => 
      hasDetectedHeadMovement && 
      hasDetectedEyeMovement && 
      hasDetectedBlinking;

  String get livenessMessage {
    if (!hasEnoughFrames) {
      return 'Please move your head and eyes...';
    }
    if (!hasDetectedHeadMovement) {
      return 'Please move your head slightly';
    }
    if (!hasDetectedEyeMovement) {
      return 'Please look around naturally';
    }
    if (!hasDetectedBlinking) {
      return 'Please blink naturally';
    }
    return 'Liveness confirmed';
  }

  double _max(double a, double b) => a > b ? a : b;

  void reset() {
    poseHistory.clear();
    eyePositionsHistory.clear();
    detectedMovements.clear();
    blinkHistory.clear();
    earHistory.clear();
    firstBlinkTime = null;
    blinkCount = 0;
    prevEyesOpen = true;
    lastBlinkTime = null;
  }
} 