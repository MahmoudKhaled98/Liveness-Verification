# Liveness Verification 

A sophisticated FlutterWeb application designed for real-time face alignment and liveness detection using WebRTC 
and AWS Rekognition. This system provides a secure and user-friendly way to verify the presence of a real person through facial analysis and movement detection.
## Dependencies
### Core Dependencies
yaml
dependencies:
flutter:
sdk: flutter
flutter_bloc: ^8.1.3 # State management
get_it: ^7.6.4 # Dependency injection
flutter_webrtc: ^0.9.47 # Camera and video handling
http: ^1.1.0 # HTTP requests
dartz: ^0.10.1 # Functional programming
image: ^4.1.3 # Image processing


## Features

### 1. Real-time Face Analysis
- Face detection and tracking
- Distance checking (too close/far from camera)
- Face alignment verification (yaw, pitch, roll)
- Real-time feedback for user positioning

### 2. Liveness Detection
The system uses multiple factors to verify liveness:

#### Head Movement Detection
- Tracks natural head movements
- Monitors yaw, pitch, and roll angles
- Requires subtle head movements within acceptable ranges

#### Eye Movement Detection
- Tracks eye positions and movements
- Detects looking left, right, up, and down
- Validates natural eye movement patterns

#### Smile Detection
 Verifies natural facial expressions
 Requires a genuine smile with high confidence
 Completes the liveness verification process

### 3. User Interface
- Real-time video feed with face outline guide
- Visual feedback for face positioning
- Status messages for user guidance
- Progress indicators for liveness verification


## Architecture

The project follows Clean Architecture principles with three main layers:

### 1. Domain Layer

#### Entities
- **FaceAnalysisResult**: Processes face detection results and verification status
- **FaceMovement**: Handles head movement tracking
- **EyePoint**: Manages eye position tracking
- **FaceDetectionConfig**: Configures detection thresholds

#### Use Cases
- **AnalyzeFaceUseCase**: Coordinates face analysis
- **HeadMovementDetectionUseCase**: Validates head movements
- **EyeMovementDetectionUseCase**: Validates eye movements

#### Repositories
- **FaceRepository**: Interface for face analysis operations
- **FaceDataProvider**: Interface for face tracking data

### 2. Data Layer

#### Models
- **FaceAnalysisModel**: Converts face analysis data
- **CustomLandmark**: Represents facial landmark points

#### Repositories
- **FaceRepositoryImpl**: Implements face analysis operations
- **FaceRemoteDataSource**: Handles external API communication

### 3. Presentation Layer

#### BLoC Pattern
- **FaceBloc**: Manages verification state and process
- **Events**: StartVerification, StopVerification, AnalyzeFace
- **States**: Initial, Analyzing, Analyzed, Error, Complete

#### Widgets
- **VideoFeedWidget**: Camera feed and frame capture
- **VerificationProgressBar**: Step-by-step progress
- **LiveAnalysisResultsWidget**: Real-time feedback

## Verification Process

1. **Initial Setup**
   - User clicks "Start Verifying"
   - Camera initializes
   - Face detection begins

2. **Face Positioning**
   - Guide user to proper distance
   - Ensure face is centered
   - Verify proper alignment

3. **Liveness Checks**
   - Detect natural head movements
   - Track eye movements in different directions
   - Verify genuine smile
   - Confirm all movements within thresholds

4. **Verification Complete**
   - All checks passed
   - Success confirmation
   - Process completion

## Configuration Parameters

### Face Detection
- Proper distance thresholds: 20% - 80% of frame
- Face alignment tolerance: ±15 degrees
- Minimum confidence: 90%

### Movement Detection
- Head movement threshold: 3.5
- Eye movement threshold: 0.0178
- Required frames for validation: 4


## Setup and Usage
 **Installation**

1. **Environment Setup**
   - Configure AWS Rekognition credentials
   - Setup Cloudflare Worker for API proxy

2. **Running the Application**
   flutter pub get
   flutter run -d chrome
   


# Security Features

- Multi-factor liveness verification
- Natural movement pattern validation
- Confidence thresholds for accuracy
- Progressive verification steps

## Notes

- Designed for web platform using WebRTC
- Optimized for real-time processing
- Provides intuitive user feedback
- Implements secure verification flow