import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

class IttoApp extends StatelessWidget {
  const IttoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Itto',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
    );
  }
}
