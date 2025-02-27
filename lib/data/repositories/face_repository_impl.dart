import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dartz/dartz.dart';
import '../../../core/failure.dart';
import '../../domain/entities/face_analysis_result.dart';
import '../../domain/repositories/face_repository.dart';
import '../models/face_analysis_model.dart';
import '../models/custom_pose.dart';
import '../models/custom_image_quality.dart';

class FaceRepositoryImpl implements FaceRepository {
  final String apiUrl = "https://my-aws-worker.mahmoud-khaled-hanafy.workers.dev";

  @override
  Future<Either<Failure, FaceAnalysisResult>> analyzeFace(String imageData) async {
    print('FaceRepositoryImpl: Starting face analysis');
    try {
      print('FaceRepositoryImpl: Making API call');
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "image": imageData,
          "Attributes": ["ALL"]
        }),
      );

      print('FaceRepositoryImpl: API Response status: ${response.statusCode}');
      print('FaceRepositoryImpl: API Response body: ${response.body}');

      if (response.statusCode != 200) {
        print('FaceRepositoryImpl: Error - Non-200 status code');
        return Left(Failure("Error: ${response.body}"));
      }

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      final faceDetails = jsonResponse['FaceDetails'] as List?;
      
      // Handle no face detected case
      if (faceDetails == null || faceDetails.isEmpty) {
        return Right(FaceAnalysisModel(
          boundingBox: {},
          confidence: 0.0,
          landmarks: [],
          pose: {},
          quality: {},
          message: 'Show your face to the camera',
        ));
      }

      final firstFace = faceDetails.first;
      print('FaceRepositoryImpl: Successfully processed face data');
      final Map<String, dynamic> faceJson = {
        'boundingBox': firstFace['BoundingBox'],
        'confidence': firstFace['Confidence'],
        'landmarks': (firstFace['Landmarks'] as List).map((l) {
          return CustomLandmark(
            type: l['Type'].toString(),
            x: l['X'] ?? 0.0,
            y: l['Y'] ?? 0.0,
          ).toJson();
        }).toList(),
        'pose': {
          'Yaw': firstFace['Pose']['Yaw'],
          'Pitch': firstFace['Pose']['Pitch'],
          'Roll': firstFace['Pose']['Roll'],
        },
        'quality': {
          'EyesOpen': {
            'Value': firstFace['EyesOpen']?['Value'] ?? true,
            'Confidence': firstFace['EyesOpen']?['Confidence'] ?? 0.0,
          },
          'Brightness': firstFace['Quality']?['Brightness'] ?? 0.0,
          'Sharpness': firstFace['Quality']?['Sharpness'] ?? 0.0,
        },
      };

      print('FaceRepositoryImpl: Raw EyesOpen data: ${firstFace['EyesOpen']}');
      print('FaceRepositoryImpl: Processed EyesOpen data: ${faceJson['quality']['EyesOpen']}');
      print('FaceRepositoryImpl: Processed face JSON: $faceJson');

      return Right(FaceAnalysisModel.fromJson(faceJson));
    } catch (e) {
      print('FaceRepositoryImpl: Error processing request: $e');
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> detectLiveness(List<dynamic> videoFrames) async {
    try {
      // If your Cloudflare API supports liveness detection, modify this to send frames to the API
      return const Right(true);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}

class CustomLandmark {
  final String type;
  final double x;
  final double y;

  CustomLandmark({required this.type, required this.x, required this.y});

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'x': x,
      'y': y,
    };
  }
}
