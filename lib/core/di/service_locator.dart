import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:kyc/core/ocr/ocr_service.dart';
import 'package:kyc/domain/usecases/get_customer_usecase.dart';
import 'package:kyc/get_config.dart';
import 'package:kyc/presentation/cubits/forms/login_form_cubit.dart';

import '../../connectivity_listener.dart';
import '../../data/datasources/local/kyc_local_data_source.dart';
import '../../data/datasources/remote/kyc_api_client.dart';
import '../../data/datasources/remote/login_api_service.dart';
import '../../data/repositories/kyc_repository_impl.dart';
import '../../data/repositories/login_repository_impl.dart';
import '../../domain/repositories/kyc_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/create_kyc_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../http_client.dart';
import '../../presentation/blocs/sync_bloc.dart';
import '../../presentation/cubits/forms/kyc_form_cubit.dart';
import '../../presentation/cubits/kyc_cubit.dart';
import '../../presentation/cubits/kyc_list_cubit.dart';
import '../../presentation/cubits/login_cubit.dart';
import '../../presentation/cubits/logout_cubit.dart';
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
  sl.registerLazySingleton<KycApiClient>(() => KycApiClient(sl(), sl(), sl()));
  sl.registerLazySingleton<KycRepository>(
    () => KycRepositoryImpl(sl(), kycLocal, sl(), sl()),
  );
  sl.registerLazySingleton<CreateKycUsecase>(() => CreateKycUsecase(sl()));
  sl.registerLazySingleton<GetCustomerUsecase>(() => GetCustomerUsecase(sl()));
  sl.registerLazySingleton<SyncBloc>(() => SyncBloc(sl()));
  sl.registerLazySingleton<KycFormCubit>(() => KycFormCubit(sl(), sl()));
  sl.registerLazySingleton<KycCubit>(() => KycCubit(sl()));
  sl.registerLazySingleton<KycListCubit>(() => KycListCubit(sl()));
}

Future<void> setUpLocator() async {
  await GetConfig.initialize();
  // sl.registerLazySingleton<List<String>>(
  //       () => GetConfig.getCertificatePins(),
  //   instanceName: 'certificatePins',
  // );
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton<FlutterSecureStorage>(() => FlutterSecureStorage());
  sl.registerLazySingleton(() => HiveKeyManager(sl()));
  sl.registerLazySingleton<TextRecognizer>(() => TextRecognizer());
  sl.registerLazySingleton<OcrService>(() => OcrService(sl()));
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton<SecureStorage>(() => SecureStorage(sl()));
  sl.registerLazySingleton<HttpClient>(
    () => HttpClient(
      certificatePins: GetConfig.getCertificatePins(),
      storage: sl(),
    ),
  );

  sl.registerLazySingleton<ImagePickerService>(() => ImagePickerServiceImpl());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  sl.registerLazySingleton<AuthApiService>(() => AuthApiService(sl(), sl()));

  sl.registerLazySingleton<AuthRepository>(() => LoginRepositoryImpl(sl()));

  sl.registerLazySingleton<LoginUsecase>(() => LoginUsecase(sl()));
  sl.registerLazySingleton<LoginFormCubit>(() => LoginFormCubit());
  sl.registerLazySingleton<LoginCubit>(() => LoginCubit(sl(), sl()));
  sl.registerLazySingleton<LogoutUsecase>(() => LogoutUsecase(sl()));
  sl.registerLazySingleton<LogoutCubit>(() => LogoutCubit(sl()));

  sl.registerLazySingleton<ConnectivityListener>(
    () => ConnectivityListener(sl()),
  );
}
