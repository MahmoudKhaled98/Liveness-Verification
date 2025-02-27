import 'package:flutter_bloc/flutter_bloc.dart';
import 'face_event.dart';
import 'face_state.dart';
import 'package:get_it/get_it.dart';
import '../../domain/usecases/analyze_face_usecase.dart';
import '../../domain/entities/face_analysis_result.dart';

class FaceBloc extends Bloc<FaceEvent, FaceState> {
  final AnalyzeFaceUseCase analyzeFaceUseCase;

  FaceBloc({required this.analyzeFaceUseCase}) : super(FaceInitial()) {
    on<UpdateFaceData>((event, emit) {
      print('FaceBloc: Received UpdateFaceData event');
      emit(FaceDataReady(event.faceData));
    });

    on<AnalyzeFace>((event, emit) async {
      print('FaceBloc: Received AnalyzeFace event');
      emit(FaceAnalyzing());
      
      print('FaceBloc: Calling analyzeFaceUseCase');
      final result = await analyzeFaceUseCase.execute(event.faceData);
      
      print('FaceBloc: Got result from analyzeFaceUseCase');
      emit(result.fold(
        (failure) {
          print('FaceBloc: Analysis failed - ${failure.message}');
          return FaceError(failure.message);
        },
        (success) {
          print('FaceBloc: Analysis succeeded');
          return FaceAnalyzed(success);
        },
      ));
    });

    on<CompleteLivenessCheck>((event, emit) {
      print('FaceBloc: Liveness check completed');
      emit(FaceVerificationComplete(event.result));
    });

    on<ResetAnalysis>((event, emit) {
      print('FaceBloc: Received ResetAnalysis event');
      FaceAnalysisResult.resetLivenessDetection();
      emit(FaceInitial());
    });
  }
} 