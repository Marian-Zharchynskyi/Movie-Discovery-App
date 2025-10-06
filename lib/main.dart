import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/injection_container.dart' as di;
import 'features/favorites/presentation/screens/favorites_screen.dart';
import 'features/movies/presentation/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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
  int _selectedIndex = 0;

  static final List<Widget> _screens = [
    const HomeScreen(),
    const FavoritesScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Discovery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: _screens.elementAt(_selectedIndex),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Favorites',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}