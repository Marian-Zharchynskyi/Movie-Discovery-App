# Movie Discovery App

![Flutter CI](https://github.com/Marian-Zharchynskyi/Movie-Discovery-App/actions/workflows/flutter.yml/badge.svg)

A Flutter application for discovering and managing favorite movies using TMDB API.

## Features

- 🔐 **Firebase Authentication** - Secure user authentication
- 🔒 **Secure Storage** - Token storage using `flutter_secure_storage`
- 🎬 **Movie Discovery** - Browse popular movies with lazy loading (pagination)
- ⭐ **Favorites** - Save and manage favorite movies
- 🖼️ **Optimized Image Caching** - Using `cached_network_image` for efficient image loading
- 📱 **Responsive Design** - Adaptive grid layout for different screen sizes
- 🗄️ **Local Database** - Drift (SQLite) for offline data persistence
- 🔄 **State Management** - Riverpod for reactive state management

## Architecture

The project follows **Clean Architecture** principles with three main layers:

- **Presentation Layer** - UI components, screens, and state management (Riverpod)
- **Domain Layer** - Business logic, entities, and use cases
- **Data Layer** - Repositories, data sources (remote & local), and models

## Security & Optimization

### Secure Storage
Authentication tokens are securely stored using `flutter_secure_storage` to prevent unauthorized access.

### Image Caching
All movie posters and images are cached using `cached_network_image` to:
- Reduce network bandwidth
- Improve loading performance
- Enable offline viewing of previously loaded images

### Lazy Loading
Movie lists implement pagination with automatic loading when scrolling near the bottom (90% threshold), reducing initial load time and memory usage.

### Code Obfuscation
Release builds are configured with ProGuard for Android to:
- Obfuscate code and make reverse engineering difficult
- Shrink resources and reduce APK size
- Remove unused code and optimize performance

## Building the App

### Development Build
```bash
flutter run
```

### Release Build (Android) with Obfuscation
```bash
# Standard release build with obfuscation
flutter build apk --release

# With custom obfuscation symbols file
flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release --obfuscate --split-debug-info=build/app/outputs/symbols
```

### Release Build (iOS)
```bash
flutter build ios --release --obfuscate --split-debug-info=build/ios/symbols
```

**Note**: The `--split-debug-info` flag saves symbol mapping files needed for crash reporting and debugging obfuscated builds.

## CI/CD

- **Trigger branches**: pushes and pull requests targeting `main` or `develop` run the workflow at `.github/workflows/flutter.yml`.
- **Continuous Integration**: executes `flutter analyze` and `flutter test --coverage`. The generated `coverage/lcov.info` file is uploaded as an artifact (`coverage-lcov`).
- **Continuous Delivery (artifacts)**: builds
  - `app-release-apk` at `build/app/outputs/flutter-apk/app-release.apk`
  - `app-unsigned-ipa` at `build/ios/ipa/`
  Download them from the run summary in the GitHub Actions tab for manual signing and store publishing.
- **Next step**: integrate automated store uploads (e.g., Firebase App Distribution, App Store Connect) once signing credentials are available.

## Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/Marian-Zharchynskyi/Movie-Discovery-App.git
   cd Movie-Discovery-App
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Update Firebase configuration in `lib/firebase_options.dart`

4. **Set up environment variables**
   - Create a `.env` file in the root directory
   - Add your TMDB API key:
     ```
     TMDB_API_KEY=your_api_key_here
     ```

5. **Run the app**
   ```bash
   flutter run
   ```

## Dependencies

Key packages used:
- `flutter_riverpod` - State management
- `dio` - HTTP client
- `drift` - SQLite database
- `flutter_secure_storage` - Secure token storage
- `cached_network_image` - Image caching
- `firebase_auth` & `firebase_core` - Authentication
- `get_it` - Dependency injection
- `dartz` - Functional programming (Either type)

## Resources

- [TMDB API Documentation](https://developers.themoviedb.org/3)
- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
