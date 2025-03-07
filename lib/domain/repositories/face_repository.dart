import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/face_analysis_result.dart';

/// Defines the contract for face-related data operations.
///
/// This repository interface handles face analysis and liveness detection
/// operations, abstracting the data source implementation details.
abstract class FaceRepository {
  /// Analyzes a face from image data.
  ///
  /// Takes base64 encoded [imageData] and returns analysis results
  /// or a failure.
  Future<Either<Failure, FaceAnalysisResult>> analyzeFace(String imageData);

  /// Detects liveness from a sequence of video frames.
  ///
  /// Takes a list of base64 encoded [videoFrames] and returns
  /// whether the face is live or not.
  Future<Either<Failure, bool>> detectLiveness(List<String> videoFrames);
} 