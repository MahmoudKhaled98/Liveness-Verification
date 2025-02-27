import '../../domain/entities/face_analysis_result.dart';

abstract class FaceState {}

class FaceInitial extends FaceState {}

class FaceDataReady extends FaceState {
  final String faceData;
  FaceDataReady(this.faceData);
}

class FaceAnalyzing extends FaceState {}

class FaceAnalyzed extends FaceState {
  final FaceAnalysisResult result;

  FaceAnalyzed(this.result);
}

class FaceError extends FaceState {
  final String message;

  FaceError(this.message);
}

class FaceVerificationComplete extends FaceState {
  final FaceAnalysisResult result;

  FaceVerificationComplete(this.result);
} 