import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';
import 'package:image/image.dart' as img;
import '../screens/home_screen.dart';

class VideoFeedWidget extends StatefulWidget {
  final Function(String) onFrameCaptured;
  final bool startCapturing;

  const VideoFeedWidget({
    super.key,
    required this.onFrameCaptured,
    this.startCapturing = false,
  });

  @override
  VideoFeedWidgetState createState() => VideoFeedWidgetState();
}

class VideoFeedWidgetState extends State<VideoFeedWidget> {
  final _localRenderer = RTCVideoRenderer();
  MediaStream? _localStream;
  bool _isCameraInitialized = false;
  Timer? _captureTimer;

  @override
  void initState() {
    super.initState();
    print('VideoFeedWidget: initState called');
    _initCamera();
  }

  @override
  void didUpdateWidget(VideoFeedWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('VideoFeedWidget: didUpdateWidget called, startCapturing: ${widget.startCapturing}');
    if (widget.startCapturing != oldWidget.startCapturing) {
      if (widget.startCapturing) {
        print('VideoFeedWidget: Starting capture');
        _startCapturing();
      } else {
        print('VideoFeedWidget: Stopping capture');
        _stopCapturing();
      }
    }
  }

  Future<void> _initCamera() async {
    print('VideoFeedWidget: Initializing camera');
    await _localRenderer.initialize();

    final Map<String, dynamic> mediaConstraints = {
      'audio': false,
      'video': {
        'facingMode': 'user',
        'width': {'ideal': 1280},
        'height': {'ideal': 720}
      }
    };

    try {
      final stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      _localStream = stream;
      _localRenderer.srcObject = stream;
      setState(() {
        _isCameraInitialized = true;
      });
      print('VideoFeedWidget: Camera initialized successfully');
    } catch (e) {
      print('VideoFeedWidget: Error initializing camera: $e');
    }
  }

  void _startCapturing() {
    print('VideoFeedWidget: Starting capture timer');
    _captureTimer?.cancel();
    _captureTimer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (widget.startCapturing) {
        print('VideoFeedWidget: Capturing frame');
        _captureFrame();
      }
    });
  }

  void _stopCapturing() {
    print('VideoFeedWidget: Stopping capture timer');
    _captureTimer?.cancel();
    _captureTimer = null;
  }

  Future<void> _captureFrame() async {
    if (_localRenderer.srcObject != null) {
      try {
        final videoTrack = _localRenderer.srcObject!.getVideoTracks().first;
        final frameBuffer = await videoTrack.captureFrame();

        final Uint8List bytes = frameBuffer.asUint8List();

        // Decode the image
        final image = img.decodeImage(bytes);
        if (image == null) {
          print('VideoFeedWidget: Failed to decode image');
          return;
        }

        // Resize the image to a smaller size (e.g., 640x480)
        final resizedImage = img.copyResize(image, width: 640, height: 480);

        // Encode to JPEG with lower quality
        final compressedBytes = img.encodeJpg(resizedImage, quality: 85);

        // Convert to base64
        final base64Image = base64Encode(compressedBytes);

        print('VideoFeedWidget: Frame captured, size after compression: ${base64Image.length}');
        widget.onFrameCaptured(base64Image);
      } catch (e) {
        print('VideoFeedWidget: Error capturing frame: $e');
      }
    } else {
      print('VideoFeedWidget: No video source available');
    }
  }

  @override
  void dispose() {
    print('VideoFeedWidget: Disposing');
    _stopCapturing();
    _localRenderer.dispose();
    _localStream?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('VideoFeedWidget: Building, camera initialized: $_isCameraInitialized');
    if (!_isCameraInitialized) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.grey,
        ),
      );
    }
    final screenSize = MediaQuery.of(context).size;

    return Stack(
      children: [
        Container(
          height:screenSize.height/2.2,
          width: double.infinity,
          color: Colors.white12,
          child: ClipPath(
            clipper: FaceShapeClipper(),
            child: RTCVideoView(
              _localRenderer,
              mirror: true,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
            ),
          ),
        ),
        // Overlay with guidelines
        CustomPaint(
          painter: FaceGuidelinesPainter(),
          child: SizedBox(
            height: screenSize.height/1.7,
            width: screenSize.width/1.8,
          ),
        ),
      ],
    );
  }
}

class FaceGuidelinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final centerX = size.width / 1.113;
    final centerY = size.height / 2.6;

    // Draw face outline
    final faceWidth = size.width * 0.9;
    final faceHeight = size.height *0.79;
    final faceRect = Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: faceWidth,
      height: faceHeight,
    );
    canvas.drawOval(faceRect, paint);

    // Draw center crosshair
    final crosshairSize = size.width * 0.02;
    canvas.drawLine(
      Offset(centerX - crosshairSize, centerY),
      Offset(centerX + crosshairSize, centerY),
      paint,
    );
    canvas.drawLine(
      Offset(centerX, centerY - crosshairSize),
      Offset(centerX, centerY + crosshairSize),
      paint,
    );

    // Add text guide
    // final textPainter = TextPainter(
    //   text: TextSpan(
    //     text: 'Align face within outline',
    //     style: TextStyle(
    //       color: Colors.yellow,
    //       fontSize: size.width/90,fontWeight: FontWeight.bold
    //     ),
    //   ),
    //   textDirection: TextDirection.ltr,
    // );
    // textPainter.layout();
    // textPainter.paint(
    //   canvas,
    //   Offset(
    //     centerX - textPainter.width / 2,
    //     size.height * 0.9,
    //   ),
    // );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}