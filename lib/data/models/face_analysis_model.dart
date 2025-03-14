import '../../domain/entities/face_analysis_result.dart';
import 'glasses_detection_model.dart';
import 'screen_detection_model.dart';


/// Data model representing face analysis results.
///
/// Extends [FaceAnalysisResult] to provide JSON serialization capabilities.
class FaceAnalysisModel extends FaceAnalysisResult {
  /// Creates a new [FaceAnalysisModel] instance.
  FaceAnalysisModel({
    required super.boundingBox,
    required super.confidence,
    required super.landmarks,
    required super.pose,
    required super.quality,
    required super.faceDetails,
    required super.glassesDetection,
    required super.screenDetection,
    super.message,
  });

  /// Creates a [FaceAnalysisModel] from JSON data.
  ///
  /// Handles null values and type conversions from the API response.
  factory FaceAnalysisModel.fromJson(Map<String, dynamic> json) {
    print('FaceAnalysisModel: Starting JSON parsing');
    
    final faceDetails = json['FaceDetails'] as List?;
    print('FaceDetails found: ${faceDetails?.length ?? 0} faces');
    
    if (faceDetails == null || faceDetails.isEmpty) {
      print('FaceAnalysisModel: No face details found');
      return FaceAnalysisModel(
        boundingBox: {},
        confidence: 0.0,
        landmarks: [],
        pose: {},
        quality: {},
        faceDetails: {},
        glassesDetection: GlassesDetectionModel(
          hasEyeglasses: false,
          hasSunglasses: false,
          eyeglassesConfidence: 0.0,
          sunglassesConfidence: 0.0,
        ),
        screenDetection: ScreenDetectionModel(
          isScreenDetected: false,
          occlusionConfidence: 0.0,
          brightness: 0.0,
          sharpness: 100.0,
        ),
        message: 'No face detected',
      );
    }

    try {
      final firstFace = faceDetails.first as Map<String, dynamic>;
      print('FaceAnalysisModel: Processing first face');
      
      // Extract glasses data
      final eyeglasses = firstFace['Eyeglasses'] as Map<String, dynamic>;
      final sunglasses = firstFace['Sunglasses'] as Map<String, dynamic>;
      
      print('Raw eyeglasses data: $eyeglasses');
      print('Raw sunglasses data: $sunglasses');

      final hasEyeglasses = eyeglasses['Value'] as bool;
      final hasSunglasses = sunglasses['Value'] as bool;

      print('Detected: Eyeglasses=$hasEyeglasses, Sunglasses=$hasSunglasses');

      final glassesDetection = GlassesDetectionModel(
        hasEyeglasses: hasEyeglasses,
        hasSunglasses: hasSunglasses,
        eyeglassesConfidence: (eyeglasses['Confidence'] as num).toDouble(),
        sunglassesConfidence: (sunglasses['Confidence'] as num).toDouble(),
      );

      // Create screen detection model
      final screenDetection = ScreenDetectionModel.fromJson(firstFace);

      final model = FaceAnalysisModel(
        boundingBox: Map<String, dynamic>.from(firstFace['BoundingBox'] as Map),
        confidence: (firstFace['Confidence'] as num).toDouble(),
        landmarks: (firstFace['Landmarks'] as List).map((l) => Map<String, dynamic>.from({
          'type': l['Type'].toString().toLowerCase(),
          'x': (l['X'] as num).toDouble(),
          'y': (l['Y'] as num).toDouble(),
        })).toList(),
        pose: Map<String, dynamic>.from(firstFace['Pose'] as Map),
        quality: Map<String, dynamic>.from(firstFace['Quality'] as Map),
        faceDetails: firstFace,
        glassesDetection: glassesDetection,
        screenDetection: screenDetection,
        message: screenDetection.statusMessage,
      );

      print('Model created:');
      print('- Has any glasses: ${glassesDetection.hasAnyGlasses}');
      print('- Glasses message: ${glassesDetection.message}');
      print('- Screen detected: ${screenDetection.isScreenDetected}');
      print('- Screen message: ${screenDetection.statusMessage}');
      print('- Status message: ${model.statusMessage}');

      return model;
    } catch (e, stackTrace) {
      print('FaceAnalysisModel: Error parsing face details');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      
      return FaceAnalysisModel(
        boundingBox: {},
        confidence: 0.0,
        landmarks: [],
        pose: {},
        quality: {},
        faceDetails: {},
        glassesDetection: GlassesDetectionModel(
          hasEyeglasses: false,
          hasSunglasses: false,
          eyeglassesConfidence: 0.0,
          sunglassesConfidence: 0.0,
        ),
        screenDetection: ScreenDetectionModel(
          isScreenDetected: false,
          occlusionConfidence: 0.0,
          brightness: 0.0,
          sharpness: 100.0,
        ),
        message: 'Error processing face data',
      );
    }
  }
} 