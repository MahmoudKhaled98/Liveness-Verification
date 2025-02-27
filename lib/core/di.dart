import 'package:get_it/get_it.dart';
import 'package:liveness_verify/data/repositories/face_repository_impl.dart';
import 'package:liveness_verify/domain/repositories/face_repository.dart';
import 'package:liveness_verify/domain/usecases/analyze_face_usecase.dart';
import 'package:liveness_verify/presentation/blocs/face_bloc.dart';

final GetIt getIt = GetIt.instance;

void setup() {

  // Repositories
  getIt.registerLazySingleton<FaceRepository>(
    () => FaceRepositoryImpl(),
  );

  // Use cases
  getIt.registerFactory(() => AnalyzeFaceUseCase(getIt<FaceRepository>()));

  // Blocs
  getIt.registerFactory(
    () => FaceBloc(analyzeFaceUseCase: getIt<AnalyzeFaceUseCase>()),
  );
} 
