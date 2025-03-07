import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/error/failures.dart';

/// Defines the contract for remote face data operations.
abstract class FaceRemoteDataSource {
  /// Analyzes face data using remote API.
  ///
  /// Takes base64 encoded [imageData] and returns parsed JSON response.
  Future<Map<String, dynamic>> analyzeFace(String imageData);
}

/// Implementation of [FaceRemoteDataSource] using HTTP client.
class FaceRemoteDataSourceImpl implements FaceRemoteDataSource {
  final http.Client client;
  final String apiUrl;

  /// Creates a new instance of [FaceRemoteDataSourceImpl].
  ///
  /// Requires an HTTP [client] and optionally an [apiUrl].
  FaceRemoteDataSourceImpl({
    required this.client,
    this.apiUrl = "https://my-aws-worker.mahmoud-khaled-hanafy.workers.dev",
  });

  @override
  Future<Map<String, dynamic>> analyzeFace(String imageData) async {
    try {
      // Send request to API
      final response = await client.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "image": imageData,
          "Attributes": ["ALL"]
        }),
      );

      // Handle non-200 responses
      if (response.statusCode != 200) {
        throw ServerFailure("Server error: ${response.body}");
      }

      // Parse response
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      final faceDetails = jsonResponse['FaceDetails'] as List?;

      // Handle no face detected
      if (faceDetails == null || faceDetails.isEmpty) {
        return {
          'boundingBox': {},
          'confidence': 0.0,
          'landmarks': [],
          'pose': {},
          'quality': {},
          'faceDetails': {},
          'message': 'Show your face to the camera',
        };
      }

      // Extract face details
      final firstFace = faceDetails.first;
      return {
        'boundingBox': firstFace['BoundingBox'],
        'confidence': firstFace['Confidence'],
        'landmarks': (firstFace['Landmarks'] as List).map((l) {
          return {
            'type': l['Type'].toString().toLowerCase(),
            'x': l['X'] as double,
            'y': l['Y'] as double,
          };
        }).toList(),
        'pose': firstFace['Pose'],
        'quality': firstFace['Quality'],
        'faceDetails': firstFace,
      };
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
} 