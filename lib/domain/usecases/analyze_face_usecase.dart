import 'package:dartz/dartz.dart';
import '../repositories/face_repository.dart';
import '../entities/face_analysis_result.dart';
import '../../../core/failure.dart';

class AnalyzeFaceUseCase {
  final FaceRepository repository;

  AnalyzeFaceUseCase(this.repository);

  Future<Either<Failure, FaceAnalysisResult>> execute(String faceData) async {
    print('AnalyzeFaceUseCase: Executing with data length: ${faceData.length}');
    final result = await repository.analyzeFace(faceData);
    print('AnalyzeFaceUseCase: Completed execution');
    return result;
  }
} 