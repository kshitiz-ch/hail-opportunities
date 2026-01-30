# Wealthy Hail Opportunities App

## Overview
This is made for Wealthy Hackathon Jan 2026

## Project Structure

- `lib/`
  - `app.dart`: Main app widget and configuration.
  - `main-dev.dart`, `main-prod.dart`: Entry points for different environments (development, production).
  - `flavors.dart`: Environment and flavor configuration.
  - `src/`
    - `common/`: Shared widgets, helpers, and constants.
    - `config/`: App-wide configuration files.
    - `controllers/`: State management and business logic controllers.
    - `screens/`: All UI screens, organized by feature.
    - `utils/`: Utility functions and helpers.
    - `widgets/`: Reusable UI components.

## Key Dependencies

- `flutter_bloc`: State management
- `get`: State management (GetX)
- `firebase_*`: Analytics, crashlytics, messaging, remote config
- `core`: Local package for business logic and models
- `api_sdk`: Local package for API integration
- `cached_network_image`, `contacts_service`, `file_picker`, etc.

## Getting Started

1. **Install dependencies:**
   ```sh
   flutter pub get
   ```
2. **Run the app:**
   - Development: `flutter run -t lib/main-dev.dart`
   - Production: `flutter run -t lib/main-prod.dart`
3. **Configure flavors:**
   - Edit `flavors.dart` for environment-specific settings.

## Assets

- Place images in `assets/images/`
- Fonts in `assets/fonts/`
- HTML and data files in their respective folders

## Testing

- Widget tests: `flutter test test/widget_test.dart`
- Add more tests in the `test/` directory

## Development Tips

- Use hot reload for rapid UI iteration.
- Follow modular structure for scalability.
- Use `core` for business logic and `api_sdk` for all API calls.
- Use `GetX` for state management, navigation, and dependency injection where appropriate. See `lib/src/controllers/` for examples.

## Contributing

- Keep code modular and well-documented.
- Add new features in appropriate `src/` subfolders.
- Write tests for new features.

---

For more details, see the READMEs in `core/` and `api_sdk/`.
