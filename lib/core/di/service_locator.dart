import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:kyc/core/ocr/ocr_service.dart';
import 'package:kyc/presentation/cubits/forms/login_form_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../connectivity_listener.dart';
import '../../data/datasources/local/kyc_local_data_source.dart';
import '../../data/datasources/remote/kyc_api_client.dart';
import '../../data/datasources/remote/login_api_service.dart';
import '../../data/repositories/kyc_repository_impl.dart';
import '../../data/repositories/login_repository_impl.dart';
import '../../domain/repositories/kyc_repository.dart';
import '../../domain/repositories/login_repository.dart';
import '../../domain/usecases/kyc_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../http_client.dart';
import '../../presentation/blocs/sync_bloc.dart';
import '../../presentation/cubits/forms/kyc_form_cubit.dart';
import '../../presentation/cubits/kyc_cubit.dart';
import '../../presentation/cubits/login_cubit.dart';
import '../image_picker/image_picker_service.dart';
import '../network/network_info.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../secure_storage/hive_key_manager.dart';
import '../secure_storage/secure_file_storage.dart';
import '../secure_storage/secure_storage.dart';

final GetIt sl = GetIt.instance;

Future<void> initAsyncDependencies() async {
  final keyManager = sl<HiveKeyManager>();
  final encryptionKey = await keyManager.getOrCreateKey();

  final fileStorage = SecureFileStorage(encryptionKey);
  sl.registerSingleton<SecureFileStorage>(fileStorage);

  final kycLocal = KycLocalDataSource(
    fileStorage: fileStorage,
    encryptionKey: encryptionKey,
  );
  await kycLocal.init();
  sl.registerLazySingleton<KycRepository>(() => KycRepositoryImpl(sl(), kycLocal, sl()));
}

Future<void> setUpLocator() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton<FlutterSecureStorage>(() => FlutterSecureStorage());
  sl.registerLazySingleton(() => HiveKeyManager(sl()));
  sl.registerLazySingleton<TextRecognizer>(() => TextRecognizer());
  sl.registerLazySingleton<OcrService>(() => OcrService(sl()));
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton<SecureStorage>(() => SecureStorage(sl()));
  sl.registerLazySingleton<HttpClient>(() => HttpClient(certificatePins: ['Gq3GnUZztqAe0KcYE2IEdhWQhgWe/0J2PD3jnRC84eI='], storage: sl()));

  sl.registerLazySingleton<KycApiClient>(() => KycApiClient(sl(), sl()));
  sl.registerLazySingleton<ImagePickerService>(() => ImagePickerServiceImpl());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  sl.registerLazySingleton<LoginApiService>(() => LoginApiService(sl(), sl()));

  sl.registerLazySingleton<LoginRepository>(() => LoginRepositoryImpl(sl()));

  sl.registerLazySingleton<LoginUsecase>(() => LoginUsecase(sl()));
  sl.registerLazySingleton<KycUsecase>(() => KycUsecase(sl()));

  sl.registerLazySingleton<SyncBloc>(() => SyncBloc(sl()));
  sl.registerFactory(() => KycFormCubit(sl(), sl()));
  sl.registerFactory(() => KycCubit(sl()));
  sl.registerLazySingleton<LoginFormCubit>(() => LoginFormCubit());
  sl.registerLazySingleton<LoginCubit>(() => LoginCubit(sl()));

  sl.registerLazySingleton<ConnectivityListener>(() => ConnectivityListener(sl()));
}