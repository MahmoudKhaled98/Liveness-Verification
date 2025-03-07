import 'package:flutter/material.dart';
import '../../domain/entities/face_analysis_result.dart';
import '../screens/home_screen.dart';

/// Builds a widget to display face analysis results.
///
/// Shows current analysis status, messages, and visual indicators
/// based on the [result] of face analysis.
Widget buildAnalysisResults(FaceAnalysisResult result) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AnalysisHeaderWidget(),
        LiveAnalysisResultsWidget(result: result),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _getStatusColor(result).withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _getStatusColor(result)),
          ),
          child: Column(
            children: [
              const Text(
                'Status:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                result.statusMessage,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(result),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

/// Determines the appropriate status color based on analysis result.
///
/// Returns:
/// - Red for improper distance or alignment
/// - Orange for incomplete liveness check
/// - Green for successful verification
Color _getStatusColor(FaceAnalysisResult result) {
  if (!result.isProperDistance) return Colors.red;
  if (!result.isAligned) return Colors.red;
  if (!result.isLive) return Colors.orange;
  return Colors.green;
}
