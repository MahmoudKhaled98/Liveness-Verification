import 'package:flutter/material.dart';

/// A widget that displays the progress of face verification steps.
///
/// Shows a series of steps with icons and labels, indicating the current
/// status of face detection, head movement, eye movement, and smile detection.
class VerificationProgressBar extends StatelessWidget {
  /// Whether a face has been detected.
  final bool isFaceDetected;

  /// Whether the face is properly positioned.
  final bool isProperlyPositioned;

  /// Whether required head movements have been confirmed.
  final bool isHeadMovementConfirmed;

  /// Whether required eye movements have been confirmed.
  final bool isEyeMovementConfirmed;

  /// Whether a smile has been detected.
  final bool isSmileDetected;

  /// Whether to show the success message.
  final bool showSuccessMessage;

  const VerificationProgressBar({
    super.key,
    required this.isHeadMovementConfirmed,
    required this.isEyeMovementConfirmed,
    required this.isSmileDetected,
    required this.isFaceDetected,
    required this.isProperlyPositioned,
    this.showSuccessMessage = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            _buildProgressStep(
              icon: Icons.face,
              label: 'Face Detection',
              isCompleted:
                  showSuccessMessage ||
                  (isFaceDetected && isProperlyPositioned),
              isActive: true,
            ),
            _buildProgressLine(isCompleted: showSuccessMessage),
            _buildProgressStep(
              icon: Icons.rotate_right,
              label: 'Head Movement',
              isCompleted: showSuccessMessage || isHeadMovementConfirmed,
              isActive:
                  !showSuccessMessage &&
                  (isFaceDetected && isProperlyPositioned),
            ),
            _buildProgressLine(isCompleted: showSuccessMessage),
            _buildProgressStep(
              icon: Icons.remove_red_eye,
              label: 'Eye Movement',
              isCompleted: showSuccessMessage || isEyeMovementConfirmed,
              isActive: !showSuccessMessage && isHeadMovementConfirmed,
            ),
            _buildProgressLine(isCompleted: showSuccessMessage),
            _buildProgressStep(
              icon: Icons.sentiment_satisfied_alt,
              label: 'Smile',
              isCompleted: showSuccessMessage || isSmileDetected,
              isActive: !showSuccessMessage && isEyeMovementConfirmed,
            ),
          ],
        ),
        if (showSuccessMessage) ...[
           // SizedBox(height:size.height*0.08),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green),
            ),
            child:  Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline, color: Colors.green, size: 48),
                SizedBox(height:size.height*0.08),
                Text(
                  'Liveness Confirmed\nSuccessfully !',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// Builds a single step in the progress bar.
  Widget _buildProgressStep({
    required IconData icon,
    required String label,
    required bool isCompleted,
    required bool isActive,
  }) {
    final Color stepColor =
        isCompleted
            ? Colors.green
            : isActive
            ? Colors.blue
            : Colors.grey.shade300;

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(shape: BoxShape.circle, color: stepColor),
            child: Icon(
              icon,
              color: isCompleted || isActive ? Colors.white : Colors.grey,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: stepColor,
              fontWeight:
                  isActive || isCompleted ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a line connecting two progress steps.
  Widget _buildProgressLine({bool isCompleted = false}) {
    return Container(
      width: 30,
      height: 2,
      color: isCompleted ? Colors.green : Colors.grey.shade300,
    );
  }
}
