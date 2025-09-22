import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kyc/presentation/screens/id_type_screen.dart';

import '../../presentation/cubits/login_cubit.dart';
import '../../presentation/screens/id_pictures_screen.dart';
import '../../presentation/screens/kyc_management_screen.dart';
import '../../presentation/screens/login_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(path: '/',
      builder: (context, state) {
        return const KycManagementScreen();
      },
    ),
    GoRoute(
      path: '/kycs',
      builder: (context, state) {
        return const KycManagementScreen();
      },
      routes: [
        GoRoute(path: 'add/take-picture',
          builder: (context, state) {
            return const IdPicturesScreen();
          }
        ),
        GoRoute(path: 'add/id-type',
          builder: (context, state) {
            return const IdTypeScreen();
          }
        ),
      ]
    ),
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) {
        return const LoginScreen();
      },
    ),
  ],
  redirect: (context, state) {
    final authState = context.read<LoginCubit>().state;

    final goingToLogin = state.matchedLocation == '/login';

    if (authState is! LoginSuccess) {
      return '/login';
    }

    if (goingToLogin) return '/';
    return null;
  },
);
