import 'package:dartz/dartz.dart';
import '../repositories/face_repository.dart';
import '../entities/face_analysis_result.dart';
import '../../core/error/failures.dart';

/// Analyzes face data to determine liveness and facial characteristics.
///
/// This use case coordinates with the face repository to process image data
/// and return analysis results.
class AnalyzeFaceUseCase {
  final FaceRepository repository;

  /// Creates a new instance of [AnalyzeFaceUseCase].
  ///
  /// Requires a [repository] to handle face analysis operations.
  AnalyzeFaceUseCase(this.repository);

  /// Executes the face analysis process.
  ///
  /// Takes [faceData] as base64 encoded image string and returns
  /// either a [Failure] or [FaceAnalysisResult].
  ///
  /// Returns [Either<Failure, FaceAnalysisResult>] containing either
  /// the analysis results or an error.
  Future<Either<Failure, FaceAnalysisResult>> execute(String faceData) async {
    print('AnalyzeFaceUseCase: Executing with data length: ${faceData.length}');
    final result = await repository.analyzeFace(faceData);
    print('AnalyzeFaceUseCase: Completed execution');
    return result;
  }
}