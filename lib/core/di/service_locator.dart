import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:kyc/presentation/cubits/forms/login_form_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/local/local_login_service.dart';
import '../../data/datasources/remote/login_api_service.dart';
import '../../data/repositories/login_repository_impl.dart';
import '../../domain/repositories/login_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../presentation/cubits/login_cubit.dart';
import '../network/network_info.dart';

final GetIt sl = GetIt.instance;

Future<void> setUpLocator() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton<Dio>(() => Dio());

  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  sl.registerLazySingleton<LocalLoginService>(() => LocalLoginService(sl()));
  sl.registerLazySingleton<LoginApiService>(() => LoginApiService(sl()));
  sl.registerLazySingleton<LoginRepository>(() => LoginRepositoryImpl(sl(), sl(), sl()));

  sl.registerLazySingleton<LoginUseCase>(() => LoginUseCase(sl()));
  sl.registerLazySingleton<LoginFormCubit>(() => LoginFormCubit());
  sl.registerLazySingleton<LoginCubit>(() => LoginCubit(sl()));
}