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

#### Blink Detection
- Calculates Eye Aspect Ratio (EAR)
- Monitors eye state (open/closed)
- Features:
  - Static threshold at 0.429 for blink detection
  - Requires minimum 3 blinks for verification
  - Debounce mechanism to prevent false detections
  - Minimum 200ms interval between blinks

### 3. User Interface
- Real-time video feed with face outline guide
- Visual feedback for face positioning
- Status messages for user guidance
- Progress indicators for liveness verification

## Key Components

### 1. Core Components
- **di.dart**: Dependency injection setup using GetIt
- **failure.dart**: Error handling and failure cases

### 2. Domain Layer

#### Entities
- **FaceAnalysisResult**
  - Handles face detection results
  - Manages bounding box calculations
  - Processes quality metrics
  - Coordinates liveness checks

- **FaceMovementTracker**
  - movementThreshold = 2.7
  - eyeMovementThreshold = 0.021
  - blinkThreshold = 0.4219
  - requiredBlinkCount = 3
  - minBlinkInterval = 200ms
  
  Key Functions:
  - calculateEAR(): Computes Eye Aspect Ratio
  - detectEyeMovement(): Tracks eye position changes
  - hasDetectedBlinking: Validates blink patterns
  - isLivenessConfirmed: Checks all liveness criteria
  

#### Use Cases
- **AnalyzeFaceUseCase**: Coordinates face analysis operations

#### Repositories
- **FaceRepository**: Interface for face analysis operations

### 3. Data Layer

#### Models
- **FaceAnalysisModel**: Converts AWS Rekognition response into application data model, handling face detection results including confidence scores, landmarks, and quality metrics

- **CustomLandmark**: Represents facial landmark points (eyes, nose, mouth) with x,y coordinates and type identification

- **EyePoint**: Specialized model for eye-related landmarks used in blink detection and eye movement tracking

- **BoundingBox**: Handles face frame dimensions and positioning for proper face alignment checks

- **FacePosition**: Tracks face orientation through yaw, pitch, and roll angles for movement detection

- **CustomPose**: Manages head pose data from AWS Rekognition for natural movement validation

- **CustomImageQuality**: Processes image quality metrics including brightness, sharpness, and eye state confidence scores

#### Repositories
- **FaceRepositoryImpl**: 
  - Implements FaceRepository
  - Handles AWS Rekognition API integration
  - Processes face analysis responses

### 4. Presentation Layer

#### Blocs
- **FaceBloc**: 
  - Manages application state
  - Handles face analysis events
  - Coordinates liveness verification

#### Events
- **UpdateFaceData**: Updates face image data
- **AnalyzeFace**: Triggers face analysis
- **CheckLiveness**: Initiates liveness verification
- **ResetAnalysis**: Resets verification state

#### States
- **FaceInitial**: Initial state
- **FaceAnalyzing**: Processing state
- **FaceAnalyzed**: Analysis complete state
- **FaceError**: Error state
- **FaceVerificationComplete**: Verification success state

#### Widgets
- **VideoFeedWidget**:
  - Manages camera feed
  - Handles frame capture
  - Implements face guide overlay

- **LiveAnalysisResultsWidget**:
  - Displays analysis results
  - Shows liveness status
  - Provides user feedback

- **FaceShapeClipper**:
  - Creates face outline guide
  - Implements visual guidelines

### 5. Key Features Implementation

#### Face Detection
- **Properties**:
  - TOO_CLOSE_THRESHOLD = 0.65
  - TOO_FAR_THRESHOLD = 0.18
  - confidence threshold = 90%
#### Liveness Detection
- **Requirements**:
  - Head Movement: Natural movement within thresholds
  - Eye Movement: At least 2 different movements
  - Blinking: Minimum 3 valid blinks
  - Timing: 200ms minimum between blinks
#### Face Alignment
- **Criteria**:
  - Yaw: 0 to 10 degrees
  - Pitch: 0 to 10 degrees
  - Roll: 0 to 10 degrees
  - Distance: Between 18% and 65% of frame


### 6. API Integration

#### AWS Rekognition
- Endpoint: Cloudflare Worker proxy
- Features:
  - Face detection
  - Landmark detection
  - Pose estimation
  - Quality metrics

### 7. Performance Optimizations
- Frame capture rate limiting
- Image compression before analysis
- Efficient state management
- Responsive UI calculations

## Architecture

The project follows Clean Architecture principles:

### Layers
1. **Presentation Layer**
   - Screens and Widgets
   - BLoC for state management
   - User interface components

2. **Domain Layer**
   - Use Cases
   - Entities
   - Repository Interfaces

3. **Data Layer**
   - Repository Implementations
   - Data Models
   - External Services Integration

## Setup and Usage

1. **Environment Setup**
   - Configure AWS Rekognition credentials
   - Setup Cloudflare Worker for API proxy

2. **Running the Application**
   flutter pub get
   flutter run -d chrome
   

## Liveness Verification Process

1. User clicks "Start Verifying"
2. System begins face analysis
3. Guides user to proper position
4. Monitors for:
   - Natural head movements
   - Eye movements
   - Multiple blinks
5. Confirms liveness when all criteria are met

## Security Features

- Debounce mechanisms to prevent rapid-fire attempts
- Confidence thresholds for detection accuracy
- Multiple factor verification requirement
- Natural movement pattern validation

