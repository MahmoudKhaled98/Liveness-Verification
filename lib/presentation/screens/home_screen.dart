import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/face_analysis_result.dart';
import '../blocs/face_bloc.dart';
import '../blocs/face_event.dart';
import '../blocs/face_state.dart';
import '../widgets/video_feed_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isAnalyzing = false;
  bool _showingSuccessMessage = false;
  static const Duration _successMessageDuration = Duration(seconds: 5);

  void _startAnalysis() {
    print('HomeScreen: Starting analysis');
    setState(() {
      _isAnalyzing = true;
      _showingSuccessMessage = false;
    });
  }

  void _stopAnalysis({bool verified = false, FaceAnalysisResult? result}) {
    print('HomeScreen: Stopping analysis');

    if (verified && result != null) {
      setState(() {
        _isAnalyzing = false;
        _showingSuccessMessage = true;
      });

      context.read<FaceBloc>().add(CompleteLivenessCheck(result));

      // Wait for the full duration before resetting everything
      Future.delayed(_successMessageDuration, () {
        if (mounted) {
          setState(() {
            _showingSuccessMessage = false;
          });
          context.read<FaceBloc>().add(ResetAnalysis());
        }
      });
    } else {
      setState(() {
        _isAnalyzing = false;
        _showingSuccessMessage = false;
      });
      context.read<FaceBloc>().add(ResetAnalysis());
    }
  }

  @override
  Widget build(BuildContext context) {
    print('HomeScreen: Building, isAnalyzing: $_isAnalyzing');
    return Scaffold(
      appBar: AppBar(
        title: Text('Liveness Verifying'),
      ),
      body: Column(
        children: [
          VideoFeedWidget(
            startCapturing: _isAnalyzing,
            onFrameCaptured: (String imageData) {
              if (_isAnalyzing) {  // Only process frames if analyzing
                context.read<FaceBloc>().add(AnalyzeFace(imageData));
              }
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              child: BlocBuilder<FaceBloc, FaceState>(
                builder: (context, state) {
                  print('HomeScreen: BlocBuilder state: ${state.runtimeType}');

                  // Check for liveness confirmation
                  if (state is FaceAnalyzed && state.result.isLive && _isAnalyzing) {
                    // Stop capturing and show success message
                    Future.delayed(Duration(milliseconds: 250), () {
                      if (mounted && _isAnalyzing) {
                        _stopAnalysis(verified: true, result: state.result);
                      }
                    });
                  }

                  // Show success message
                  if ((state is FaceVerificationComplete || _showingSuccessMessage)) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                color: Colors.green,
                                size: 64,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Liveness Confirmed\nSuccessfully !',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                  height: 1.3,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  // Then check for analysis states
                  if (state is FaceAnalyzed && state.result.isLive) {
                    Future.delayed(Duration(milliseconds: 1), () {
                      if (mounted && _isAnalyzing) {
                        _stopAnalysis(verified: true, result: state.result);
                      }
                    });
                  }

                  // Show ongoing analysis results
                  if ((state is FaceAnalyzing || state is FaceAnalyzed) && _isAnalyzing) {
                    final result = state is FaceAnalyzed ? state.result : null;

                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnalysisHeaderWidget(),
                          if (result != null)
                            LiveAnalysisResultsWidget(result: result),

                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: result != null
                                  ? _getStatusColor(result).withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: result != null
                                    ? _getStatusColor(result)
                                    : Colors.grey,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Status:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                if (result != null)
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

                  // Show error state
                  if (state is FaceError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Error: ${state.message}',
                            style: TextStyle(color: Colors.red),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _startAnalysis,
                            child: Text('Retry Analysis'),
                          ),
                        ],
                      ),
                    );
                  }

                  // Show initial state - only if not showing success message
                  if (!_isAnalyzing && !_showingSuccessMessage) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top:100),
                        child: ElevatedButton(
                          onPressed: _startAnalysis,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.green,
                            side: BorderSide(color: Colors.green),
                            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            elevation: 2,
                          ),
                          child: Text(
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

                  return Container();
                },
              ),
            ),
          ),
          if (_isAnalyzing)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _stopAnalysis,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red,
                  side: BorderSide(color: Colors.red),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  elevation: 2,
                ),
                child: Text(
                  'Stop Analysis',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // String _getOverallStatus(FaceAnalysisResult result) {
  //   if (!result.isProperlyPositioned) return 'Adjust Position';
  //   if (!result.isLive) return 'Checking Liveness';
  //   return 'Verification Complete';
  // }

  Color _getStatusColor(FaceAnalysisResult result) {
    if (!result.isProperDistance) return Colors.red;
    if (!result.isAligned) return Colors.red;
    if (!result.isLive) return Colors.orange;
    return Colors.green;
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
    final faceWidth = size.width * 0.25;
    final faceHeight = size.height * 1;
    final faceRect = Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: faceWidth,
      height: faceHeight,
    );
    path.addOval(faceRect);

    // Add guidelines for face positioning
    final guidelinesPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
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

  const LiveAnalysisResultsWidget({Key? key, required this.result}) : super(key: key);

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
          Text('Liveness Check:', style: TextStyle(fontWeight: FontWeight.bold)),
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