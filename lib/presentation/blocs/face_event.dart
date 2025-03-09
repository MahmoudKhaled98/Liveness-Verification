import '../../domain/entities/face_analysis_result.dart';

/// Base class for all face-related events.
abstract class FaceEvent {}

/// Event to update raw face data.
class UpdateFaceData extends FaceEvent {
  final String faceData;
  UpdateFaceData(this.faceData);
}

/// Event to trigger face analysis.
class AnalyzeFace extends FaceEvent {
  final String faceData;
  AnalyzeFace(this.faceData);
}

/// Event to start the verification process.
class StartVerification extends FaceEvent {}

/// Event to stop the verification process.
class StopVerification extends FaceEvent {
  final bool verified;
  final FaceAnalysisResult? result;
  final String? message;

  StopVerification({
    required this.verified,
    this.result,
    this.message,
  });
}

/// Event to reset the analysis state.
class ResetAnalysis extends FaceEvent {}

/// Event to complete the liveness check.
class CompleteLivenessCheck extends FaceEvent {
  final FaceAnalysisResult result;
  CompleteLivenessCheck(this.result);
} 