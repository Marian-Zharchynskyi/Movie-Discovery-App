import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';

class FirebaseInitializer {
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      
      if (kDebugMode) {
        debugPrint('Firebase initialized successfully');
      }
    } catch (e, stackTrace) {
      debugPrint('Error initializing Firebase: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }
}
