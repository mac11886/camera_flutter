import 'package:camera_guide/src/home_screen.dart';
import 'package:camera_guide/src/match_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'profile_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', 'US'), // English
        const Locale('th', 'TH'), // Thai
      ],
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.blueAccent,
      ),
      routerConfig: GoRouter(
        routes: [
          GoRoute(
            path: '/',
            name: HomeScreen.routeName,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            name: ProfileScreen.routeName,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
          GoRoute(
            path: '/match',
            name: MactchScreen.routeName,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MactchScreen(),
            ),
          ),
        ],
      ),
    );
  }
}
