import 'package:flutter/material.dart' hide Key;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kyc/core/di/service_locator.dart' as di;
import 'package:kyc/core/navigation/app_router.dart';
import 'package:kyc/presentation/cubits/kyc_list_cubit.dart';
import 'package:kyc/presentation/cubits/logout_cubit.dart';

import 'connectivity_listener.dart';
import 'presentation/blocs/sync_bloc.dart';
import 'presentation/cubits/forms/kyc_form_cubit.dart';
import 'presentation/cubits/forms/login_form_cubit.dart';
import 'presentation/cubits/kyc_cubit.dart';
import 'presentation/cubits/login_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.setUpLocator();
  await di.initAsyncDependencies();
  di.sl<ConnectivityListener>();
  // Restore session before building UI so router sees correct auth state
  await di.sl<LoginCubit>().restoreSession();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => di.sl<LoginCubit>()),
        BlocProvider(create: (context) => di.sl<LoginFormCubit>()),
        BlocProvider(create: (context) => di.sl<KycCubit>()),
        BlocProvider(create: (context) => di.sl<KycFormCubit>()),
        BlocProvider(create: (context) => di.sl<SyncBloc>()),
        BlocProvider(create: (context) => di.sl<KycListCubit>()),
        BlocProvider(create: (context) => di.sl<LogoutCubit>()),
      ],
      child: MaterialApp.router(
        title: 'KYC app',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: false),
        routerConfig: router,
      ),
    );
  }
}
