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

  /// Creates a new instance of [FaceBloc].
  ///
  /// Requires [analyzeFaceUseCase] to handle face analysis operations.
  FaceBloc({required this.analyzeFaceUseCase}) : super(const FaceInitial()) {
    // Start verification process
    on<StartVerification>((event, emit) {
      emit(const FaceAnalyzing());
    });

    // Handle verification completion
    on<StopVerification>((event, emit) {
      if (event.verified && event.result != null) {
        emit(FaceVerificationComplete(event.result!));
        _successMessageTimer?.cancel();
        _successMessageTimer = Timer(const Duration(seconds: 5), () {
          add(ResetAnalysis());
        });
      } else {
        emit(const FaceInitial());
      }
    });

    // Process face analysis
    on<AnalyzeFace>((event, emit) async {
      final result = await analyzeFaceUseCase.execute(event.faceData);
      emit(result.fold(
        (failure) => FaceError(failure.message),
        (success) => FaceAnalyzed(success),
      ));
    });

    // Reset analysis state
    on<ResetAnalysis>((event, emit) {
      FaceAnalysisResult.resetLivenessDetection();
      emit(const FaceInitial());
    });
  }

  @override
  Future<void> close() {
    _successMessageTimer?.cancel();
    return super.close();
  }
} 