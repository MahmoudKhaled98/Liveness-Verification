import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/face_analysis_result.dart';
import '../blocs/face_bloc.dart';
import '../blocs/face_event.dart';
import '../blocs/face_state.dart';
import '../widgets/build_analysis_content.dart';
import '../widgets/video_feed_widget.dart';
import '../widgets/verification_progress_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liveness Verifying'),
      ),
      body: BlocBuilder<FaceBloc, FaceState>(
        builder: (context, state) {
          return Column(
            children: [
              VideoFeedWidget(
                startCapturing: state.isAnalyzing,
                onFrameCaptured: (String imageData) {
                  if (state.isAnalyzing) {
                    context.read<FaceBloc>().add(AnalyzeFace(imageData));
                  }
                },
              ),
              if (state is FaceAnalyzed || state is FaceVerificationComplete)
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: VerificationProgressBar(
                    isFaceDetected: state is FaceAnalyzed
                        ? state.result.isFaceDetected
                        : true,
                    isProperlyPositioned: state is FaceAnalyzed
                        ? state.result.isProperlyPositioned
                        : true,
                    isHeadMovementConfirmed: state is FaceAnalyzed
                        ? state.result.isHeadMovementConfirmed
                        : true,
                    isEyeMovementConfirmed: state is FaceAnalyzed
                        ? state.result.isEyeMovementConfirmed
                        : true,
                    isSmileDetected: state is FaceAnalyzed
                        ? state.result.isSmileDetected
                        : true,
                    showSuccessMessage: state.showingSuccessMessage,
                  ),
                ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      buildAnalysisContent(context, state),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }




}


class FeedbackWidget extends StatelessWidget {
  final FaceAnalysisResult result;

  const FeedbackWidget({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          result.isAligned ? Icons.check_circle : Icons.warning,
          color: result.isAligned ? Colors.green : Colors.orange,
          size: 48,
        ),
        Text(
          result.message ?? 'Please center your face',
          style: TextStyle(fontSize: 18),
        ),
        if (result.isAligned && !result.isLive)
          Text(
            'Please move your head slightly to confirm liveness',
            style: TextStyle(color: Colors.blue),
          ),
      ],
    );
  }
}

class FaceShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Face oval
    final faceWidth = size.width * 0.5;
    final faceHeight = size.height * 1;
    final faceRect = Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: faceWidth,
      height: faceHeight,
    );
    path.addOval(faceRect);

    // Add guidelines for face positioning
    final _ = Paint()
      ..color = Colors.white.withValues(alpha:0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// First, create a StatelessWidget for static content
class AnalysisHeaderWidget extends StatelessWidget {
  const AnalysisHeaderWidget({super.key});


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Face Analysis Results:'),
        const SizedBox(height: 8),
        Text('Position Check:', style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// Create a widget for the dynamic content
class LiveAnalysisResultsWidget extends StatelessWidget {
  final FaceAnalysisResult result;

  const LiveAnalysisResultsWidget({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Distance: ${result.distanceMessage}',
          style: TextStyle(
            color: result.isProperDistance ? Colors.green : Colors.red,
          ),
        ),
        Text('Alignment: ${result.isAligned ? "Good" : "Need Adjustment"}',
          style: TextStyle(
            color: result.isAligned ? Colors.green : Colors.red,
          ),
        ),

        if (result.isProperlyPositioned) ...[
          const SizedBox(height: 16),
          Text(
              'Liveness Check:', style: TextStyle(fontWeight: FontWeight.bold)),
          Text(
            result.livenessMessage,
            style: TextStyle(
              color: result.isLive ? Colors.green : Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }
}