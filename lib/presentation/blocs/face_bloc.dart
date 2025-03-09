import 'package:flutter_bloc/flutter_bloc.dart';
import 'face_event.dart';
import 'face_state.dart';
import '../../domain/usecases/analyze_face_usecase.dart';
import '../../domain/entities/face_analysis_result.dart';
import 'dart:async';

/// Manages the face verification state and business logic.
///
/// Handles events related to face analysis and verification process,
/// coordinating with the use cases to perform the required operations.
class FaceBloc extends Bloc<FaceEvent, FaceState> {
  final AnalyzeFaceUseCase analyzeFaceUseCase;
  Timer? _successMessageTimer;
  Timer? _verificationTimeoutTimer;
  bool _isTimedOut = false;

  /// Creates a new instance of [FaceBloc].
  ///
  /// Requires [analyzeFaceUseCase] to handle face analysis operations.
  FaceBloc({required this.analyzeFaceUseCase}) : super(const FaceInitial()) {
    // Start verification process
    on<StartVerification>((event, emit) {
      // Reset timeout flag
      _isTimedOut = false;

      // Cancel existing timers
      _verificationTimeoutTimer?.cancel();
      _successMessageTimer?.cancel();

      // Start analyzing
      emit(const FaceAnalyzing());

      // Set timeout for 2 minutes
      _verificationTimeoutTimer = Timer(const Duration(seconds: 120), () {
        if (!_isTimedOut && state.isAnalyzing) {
          print('Verification timeout triggered');
          _isTimedOut = true;
          add(StopVerification(
            verified: false,
            result: null,
            message: 'Verification timed out. Please try again.',
          ));
        }
      });
    });

    // Handle verification completion
    on<StopVerification>((event, emit) {
      print('StopVerification called: verified=${event.verified}, message=${event.message}');

      // Cancel timers
      _verificationTimeoutTimer?.cancel();
      _successMessageTimer?.cancel();

      if (event.verified && event.result != null) {
        emit(FaceVerificationComplete(event.result!));
        _successMessageTimer = Timer(const Duration(seconds: 3), () {
          add(ResetAnalysis());
        });
      } else {
        // Show error state with message
        final errorMessage = _isTimedOut
            ? 'Verification timed out after 2 minutes'
            : (event.message ?? 'Verification failed');

        emit(FaceError(errorMessage));

        // Auto reset after error
        _successMessageTimer = Timer(const Duration(seconds: 3), () {
          add(ResetAnalysis());
        });
      }
    });

    // Process face analysis
    on<AnalyzeFace>((event, emit) async {
      if (!state.isAnalyzing || _isTimedOut) return;

      final result = await analyzeFaceUseCase.execute(event.faceData);

      // Check if still analyzing and not timed out
      if (state.isAnalyzing && !_isTimedOut) {
        emit(result.fold(
              (failure) => FaceError(failure.message),
              (success) => FaceAnalyzed(success),
        ));
      }
    });

    // Reset analysis state
    on<ResetAnalysis>((event, emit) {
      print('Resetting analysis state');
      _verificationTimeoutTimer?.cancel();
      _successMessageTimer?.cancel();
      _isTimedOut = false;
      FaceAnalysisResult.resetLivenessDetection();
      emit(const FaceInitial());
    });
  }

  @override
  Future<void> close() {
    print('Closing FaceBloc');
    _verificationTimeoutTimer?.cancel();
    _successMessageTimer?.cancel();
    return super.close();
  }
} 