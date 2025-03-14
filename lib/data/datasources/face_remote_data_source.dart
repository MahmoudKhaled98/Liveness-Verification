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

      print('API Response received: ${response.statusCode}');
      print('API Response : ${response.body}');

      if (response.statusCode != 200) {
        throw ServerFailure("Server error: ${response.body}");
      }

      // Parse response
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      
      if (jsonResponse['FaceDetails'] == null || 
          (jsonResponse['FaceDetails'] as List).isEmpty) {
        print('No face details in response');
        return {
          'FaceDetails': [],
        };
      }

      print('Face details found in response');
      return jsonResponse; // Return the raw response
    } catch (e) {
      print('Error in analyzeFace: $e');
      throw ServerFailure(e.toString());
    }
  }
} 