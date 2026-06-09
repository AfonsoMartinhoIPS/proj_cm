// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/core/notifications/notification_service.dart';
import 'package:nutri_scan/presentation/providers/theme_provider.dart';

/// Ponto de entrada da aplicação NutriScan.
///
/// Inicializa as dependências necessárias (Firebase e orientação do ecrã)
/// e lança a árvore de widgets com o [ProviderScope] e o [App].
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDatabase();
  await NotificationService.init();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(const ProviderScope(child: App()));
}

/// Widget raiz da aplicação.
///
/// Configura o [MaterialApp.router] com os temas claro e escuro, o modo de
/// tema atual (carregado de forma assíncrona das preferências) e o sistema
/// de rotas gerido pelo [routerProvider].
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider).value ?? ThemeMode.system;
    return MaterialApp.router(
      title: 'NutriScan',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}