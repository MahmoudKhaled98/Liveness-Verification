import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import '../../data/datasources/face_remote_data_source.dart';
import '../../data/repositories/face_repository_impl.dart';
import '../../domain/repositories/face_repository.dart';
import '../../domain/usecases/analyze_face_usecase.dart';
import '../../presentation/blocs/face_bloc.dart';

/// Dependency injection container using GetIt.
///
/// Initializes and provides access to all dependencies in the application.
final GetIt getIt = GetIt.instance;

/// Initializes all dependencies in the application.
///
/// Sets up repositories, data sources, use cases, and BLoCs.
Future<void> initializeDependencies() async {
  // External dependencies
  getIt.registerLazySingleton(() => http.Client());

  // Data sources
  getIt.registerLazySingleton<FaceRemoteDataSource>(
    () => FaceRemoteDataSourceImpl(client: getIt()),
  );

  // Repositories
  getIt.registerLazySingleton<FaceRepository>(
    () => FaceRepositoryImpl(remoteDataSource: getIt()),
  );

  // Use cases
  getIt.registerLazySingleton(
    () => AnalyzeFaceUseCase(getIt()),
  );

  // BLoCs
  getIt.registerFactory(
    () => FaceBloc(analyzeFaceUseCase: getIt()),
  );
} 