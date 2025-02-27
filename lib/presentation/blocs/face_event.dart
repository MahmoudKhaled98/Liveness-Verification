import '../../domain/entities/face_analysis_result.dart';

abstract class FaceEvent {}

class UpdateFaceData extends FaceEvent {
  final String faceData;
  UpdateFaceData(this.faceData);
}

class AnalyzeFace extends FaceEvent {
  final String faceData;
  AnalyzeFace(this.faceData);
}

class CheckLiveness extends FaceEvent {
  final List<dynamic> videoFrames;
  CheckLiveness(this.videoFrames);
}

class ResetAnalysis extends FaceEvent {}

class CompleteLivenessCheck extends FaceEvent {
  final FaceAnalysisResult result;
  CompleteLivenessCheck(this.result);
} 