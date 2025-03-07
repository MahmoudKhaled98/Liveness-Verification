import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/face_analysis_result.dart';
import '../../domain/repositories/face_repository.dart';
import '../datasources/face_remote_data_source.dart';
import '../models/face_analysis_model.dart';

/// Implementation of [FaceRepository] that coordinates with remote data source.
///
/// Handles face analysis operations by communicating with external APIs through
/// [FaceRemoteDataSource] and converting responses to domain entities.
class FaceRepositoryImpl implements FaceRepository {
  /// Remote data source for face analysis operations.
  final FaceRemoteDataSource remoteDataSource;

  /// Creates a new [FaceRepositoryImpl] instance.
  ///
  /// Requires a [remoteDataSource] to handle API communications.
  FaceRepositoryImpl({required this.remoteDataSource});

  @override
  /// Analyzes face data from an image.
  ///
  /// Takes base64 encoded [imageData] and returns either a [Failure]
  /// or [FaceAnalysisResult]. Handles API communication errors and
  /// data conversion.
  Future<Either<Failure, FaceAnalysisResult>> analyzeFace(String imageData) async {
    try {
      final faceData = await remoteDataSource.analyzeFace(imageData);
      final result = FaceAnalysisModel.fromJson(faceData);
      return Right(result);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  /// Detects liveness from a sequence of video frames.
  ///
  /// Takes a list of base64 encoded [videoFrames] and returns either
  /// a [Failure] or boolean indicating liveness detection result.
  Future<Either<Failure, bool>> detectLiveness(List<String> videoFrames) async {
    try {
      // Implement liveness detection logic here
      return const Right(true);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}

/// Represents a facial landmark point.
///
/// Used for storing and processing facial feature coordinates.
class CustomLandmark {
  /// The type of landmark (e.g., 'eye', 'nose', 'mouth').
  final String type;

  /// X-coordinate of the landmark.
  final double x;

  /// Y-coordinate of the landmark.
  final double y;

  /// Creates a new [CustomLandmark] instance.
  CustomLandmark({required this.type, required this.x, required this.y});

  /// Converts the landmark to a JSON representation.
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'x': x,
      'y': y,
    };
  }
}
