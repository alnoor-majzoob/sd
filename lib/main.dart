import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'core/localization/app_localizations.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'src/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Window Management for Desktop
  await windowManager.ensureInitialized();
  await windowManager.setSize(const Size(1440, 900));
  await windowManager.setMinimumSize(const Size(900, 600));
  await windowManager.center();
  await windowManager.setTitle('Water Academy - Training Scheduler');
  await windowManager.show();
  await windowManager.focus();

  // Initialize Dependency Injection
  await setupLocator();

  runApp(
    const ProviderScope(
      child: TrainingSchedulerApp(),
    ),
  );
}

class TrainingSchedulerApp extends ConsumerWidget {
  const TrainingSchedulerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    return MaterialApp.router(
      title: 'Water Academy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: locale,
      supportedLocales: const [
        Locale('en', ''),
        Locale('ar', ''),
      ],
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: appRouter,
    );
  }
}
