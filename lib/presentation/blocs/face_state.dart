import '../../domain/entities/face_analysis_result.dart';

/// Base class for all face-related states.
abstract class FaceState {
  /// Whether face analysis is currently in progress.
  final bool isAnalyzing;

  /// Whether success message should be shown.
  final bool showingSuccessMessage;

  const FaceState({
    this.isAnalyzing = false,
    this.showingSuccessMessage = false,
  });
}

/// Initial state before verification starts.
class FaceInitial extends FaceState {
  const FaceInitial() : super();
}

/// State when face data is ready for analysis.
class FaceDataReady extends FaceState {
  final String faceData;
  FaceDataReady(this.faceData) : super();
}

/// State during face analysis.
class FaceAnalyzing extends FaceState {
  const FaceAnalyzing() : super(isAnalyzing: true);
}

/// State after face analysis is complete.
class FaceAnalyzed extends FaceState {
  final FaceAnalysisResult result;
  const FaceAnalyzed(this.result) : super(isAnalyzing: true);
}

/// State when an error occurs.
class FaceError extends FaceState {
  final String message;
  const FaceError(this.message) : super();
}

/// State when verification is complete.
class FaceVerificationComplete extends FaceState {
  final FaceAnalysisResult result;
  const FaceVerificationComplete(this.result)
      : super(isAnalyzing: false, showingSuccessMessage: true);
}