import 'package:dartz/dartz.dart';
import '../../../core/failure.dart';
import '../entities/face_analysis_result.dart';

abstract class FaceRepository {
  Future<Either<Failure, FaceAnalysisResult>> analyzeFace(String imageData);
  Future<Either<Failure, bool>> detectLiveness(List<String> videoFrames);
} 