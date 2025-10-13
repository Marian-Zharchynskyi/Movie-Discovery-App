import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/injection_container.dart' as di;
import 'core/router/app_router.dart';
import 'firebase_options.dart';
import 'features/settings/presentation/providers/settings_provider.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await di.init();
  
  runApp(
    const ProviderScope(
      child: MovieDiscoveryApp(),
    ),
  );
}

class MovieDiscoveryApp extends StatefulWidget {
  const MovieDiscoveryApp({super.key});
  @override
  State<MovieDiscoveryApp> createState() => _MovieDiscoveryAppState();
}

class _MovieDiscoveryAppState extends State<MovieDiscoveryApp> {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final goRouter = ref.watch(goRouterProvider);
        final settings = ref.watch(settingsProvider);
        return MaterialApp.router(
          title: 'Movie Discovery',
          debugShowCheckedModeBanner: false,
          locale: settings.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          themeMode: settings.themeMode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          routerConfig: goRouter,
        );
      },
    );
  }
}