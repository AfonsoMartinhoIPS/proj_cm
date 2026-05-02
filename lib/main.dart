import 'package:flutter/material.dart';
import 'package:projeto/core/core.dart';
import 'package:projeto/core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDatabase();

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'NutriScan',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: appRouter,
    );
  }
}
