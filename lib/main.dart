import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/injection_container.dart' as di;
import 'core/router/app_router.dart';
import 'firebase_options.dart';

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
        return MaterialApp.router(
          title: 'Movie Discovery',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          routerConfig: goRouter,
        );
      },
    );
  }
}