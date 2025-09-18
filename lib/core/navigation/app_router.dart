import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../id_extract_screen.dart';
import '../../presentation/screens/identification_screen.dart';
import '../../presentation/screens/kyc_detail_screen.dart';
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
      path: '/kyc-management',
      builder: (context, state) {
        return const KycManagementScreen();
      },
      routes: [
        GoRoute(path: 'add',
          builder: (BuildContext context, GoRouterState state) {
            return const IdentificationScreen();
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
    if (state.matchedLocation != '/login') return null;
  },
);
