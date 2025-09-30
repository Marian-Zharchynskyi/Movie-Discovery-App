# movie_discovery_app

![Flutter CI](https://github.com/Marian-Zharchynskyi/Movie-Discovery-App/actions/workflows/flutter.yml/badge.svg)

A new Flutter project.

## CI / CD

- **Trigger branches**: pushes and pull requests targeting `main` or `develop` run the workflow at `.github/workflows/flutter.yml`.
- **Continuous Integration**: executes `flutter analyze` and `flutter test --coverage`. The generated `coverage/lcov.info` file is uploaded as an artifact (`coverage-lcov`).
- **Continuous Delivery (artifacts)**: builds
  - `app-release-apk` at `build/app/outputs/flutter-apk/app-release.apk`
  - `app-unsigned-ipa` at `build/ios/ipa/`
  Download them from the run summary in the GitHub Actions tab for manual signing and store publishing.
- **Next step**: integrate automated store uploads (e.g., Firebase App Distribution, App Store Connect) once signing credentials are available.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
