import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/face_analysis_result.dart';
import '../blocs/face_bloc.dart';
import '../blocs/face_event.dart';
import '../blocs/face_state.dart';
import 'build_analysis_results.dart';

/// Builds the main content widget for face analysis based on current state.
///
/// Handles different states of the analysis process including:
/// - Initial state with start button
/// - Analysis in progress with results
/// - Error state with retry option
/// - Success state
Widget buildAnalysisContent(BuildContext context, FaceState state) {
  // Show ongoing analysis results
  if (state.isAnalyzing) {
    if (state is FaceAnalyzed) {
      // Check for liveness confirmation
      if (state.result.isLive) {
        _stopAnalysis(context, verified: true, result: state.result);
      }
      return buildAnalysisResults(state.result);
    }
    return const Center(
      child: CircularProgressIndicator(
        color: Colors.grey,
      ),
    );
  }

  // Show error state
  if (state is FaceError) {
    return _buildErrorState(context, state.message);
  }

  // Show initial state if not showing success
  if (!state.showingSuccessMessage) {
    return _buildInitialState(context);
  }

  // Return empty container when showing success since it's shown in the progress bar
  return const SizedBox.shrink();
}

/// Builds the error state widget with retry button.
///
/// Shows error [message] and provides option to restart analysis.
Widget _buildErrorState(BuildContext context, String message) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Error: $message',
          style: const TextStyle(color: Colors.red),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => _startAnalysis(context),
          child: const Text('Retry Analysis'),
        ),
      ],
    ),
  );
}

/// Builds the initial state widget with start button.
///
/// Shows a styled button to begin the verification process.
Widget _buildInitialState(BuildContext context) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.only(top: 20),
      child: ElevatedButton(
        onPressed: () => _startAnalysis(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.green,
          side: const BorderSide(color: Colors.green),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          elevation: 2,
        ),
        child: const Text(
          'Start Verifying',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );
}

/// Starts the face analysis process.
///
/// Dispatches [StartVerification] event to the [FaceBloc].
void _startAnalysis(BuildContext context) {
  context.read<FaceBloc>().add(StartVerification());
}

/// Stops the face analysis process.
///
/// Dispatches [StopVerification] event with verification status and results.
void _stopAnalysis(BuildContext context, {bool verified = false, FaceAnalysisResult? result}) {
  context.read<FaceBloc>().add(StopVerification(verified: verified, result: result));
}
