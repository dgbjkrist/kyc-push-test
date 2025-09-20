import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:kyc/core/ocr/ocr_service.dart';
import 'package:kyc/presentation/cubits/forms/login_form_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/remote/login_api_service.dart';
import '../../data/repositories/kyc_repository_impl.dart';
import '../../data/repositories/login_repository_impl.dart';
import '../../domain/repositories/kyc_repository.dart';
import '../../domain/repositories/login_repository.dart';
import '../../domain/usecases/kyc_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../presentation/cubits/forms/kyc_form_cubit.dart';
import '../../presentation/cubits/kyc_cubit.dart';
import '../../presentation/cubits/login_cubit.dart';
import '../image_picker/image_picker_service.dart';
import '../network/network_info.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../secure/secure_key_manager.dart';
import '../storage/secure_storage.dart';

final GetIt sl = GetIt.instance;

Future<void> setUpLocator() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton(() => SecureStorage());
  sl.registerLazySingleton(() => SecureKeyManager(sl()));
  sl.registerLazySingleton<OcrService>(() => OcrService());
  sl.registerLazySingleton(() => http.Client());

  sl.registerLazySingleton<ImagePickerService>(() => ImagePickerServiceImpl());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  sl.registerLazySingleton<LoginApiService>(() => LoginApiService(sl(), sl()));

  sl.registerLazySingleton<LoginRepository>(() => LoginRepositoryImpl(sl()));
  sl.registerLazySingleton<KycRepository>(() => KycRepositoryImpl(sl(), sl(), sl()));

  sl.registerLazySingleton<LoginUsecase>(() => LoginUsecase(sl()));
  sl.registerLazySingleton<KycUsecase>(() => KycUsecase(sl()));

  sl.registerFactory(() => KycFormCubit(sl(), sl()));
  sl.registerFactory(() => KycCubit(sl()));
  sl.registerLazySingleton<LoginFormCubit>(() => LoginFormCubit());
  sl.registerLazySingleton<LoginCubit>(() => LoginCubit(sl()));
}