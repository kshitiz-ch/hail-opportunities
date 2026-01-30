# Wealthy Hail Monorepo

## Quick Links

- [App README](app/README.md)
- [Core README](core/README.md)
- [API SDK README](api_sdk/README.md)

## Requirements

- **Flutter SDK:** >=3.2.0-0 <4.0.0
- **Dart SDK:** >=3.2.0-0 <4.0.0

Check your version with:

```sh
flutter --version
dart --version
```

## Overview

This repository contains the complete Wealthy Hail Flutter project, organized as a monorepo with the following main packages:

- `app/`: The main Flutter application (UI, navigation, and orchestration)
- `core/`: Shared business logic, models, and utilities
- `api_sdk/`: API integration layer (REST and GraphQL)

## Project Structure

- `app/` — Main app, entry points, UI, and feature screens
- `core/` — Business logic, feature modules, and shared utilities
- `api_sdk/` — API clients, handlers, and network utilities
- `assets/` — Images, fonts, HTML, and data files
- `build/`, `ios/`, `android/` — Platform-specific and build files

## State Management

- Uses both `GetX` and `flutter_bloc` for state management, navigation, and dependency injection.
- Controllers and business logic are modularized for scalability and maintainability.

## State Management Usage Guidance

- **AuthenticationBloc**: Use the Bloc pattern (flutter_bloc) exclusively for authentication flows. This ensures robust state transitions, clear event/state separation, and testability for all authentication-related logic.
- **GetX**: Use for all other state management, navigation, and dependency injection throughout the app. Ideal for lightweight controllers, simple state, and rapid development across features and UI modules.
- This separation keeps authentication logic robust and testable, while leveraging GetX for fast, scalable development elsewhere.

## Key Dependencies

- `get`: GetX for state management, navigation, and DI
- `flutter_bloc`: Bloc pattern for state management
- `firebase_*`: Analytics, crashlytics, messaging, remote config
- `graphql_flutter`, `dio`: API and network
- `shared_preferences`, `package_info_plus`, `flutter_udid`, etc.

## Getting Started

1. **Install dependencies:**
   ```sh
   flutter pub get
   ```
2. **Run the app:**
   - Development: `flutter run -t app/lib/main-dev.dart`
   - Production: `flutter run -t app/lib/main-prod.dart`
3. **Configure flavors:**
   - Edit `app/lib/flavors.dart` for environment-specific settings.

## API Integration Guide

This project follows a clean architecture pattern: **Controller → Repository → API Collection → Handler → External API**

### Architecture Layers

- **Controller** (`app/`): UI controllers that call business logic
- **Repository** (`core/`): Business logic layer that orchestrates API calls
- **API Collection** (`api_sdk/`): API-specific methods for different domains
- **Handler** (`api_sdk/`): Low-level API execution (REST/GraphQL)

### Quick Setup

#### REST API

1. **Add endpoint** to `api_sdk/lib/api_constants.dart`
2. **Create API method** in `api_sdk/lib/api_collection/your_domain_api.dart`
3. **Add repository method** in `core/lib/modules/your_domain/resources/`
4. **Use in controller** in `app/lib/src/controllers/`

#### GraphQL API

1. **Create operation** in `api_sdk/lib/graphql_method/graphql_operations/`
2. **Add handler method** in `api_sdk/lib/graphql_method/graphql_handler.dart`
3. **Create API method** in API collection
4. **Add repository method** and use in controller

### Best Practices

- Always wrap API calls in try-catch blocks
- Use `LogUtil.printLog()` for consistent logging
- Ensure API key is available before making calls
- Define proper return types and input parameters
- Check for null responses and handle gracefully

See detailed examples in individual package READMEs.

## Adding Models Guide

Models are located in the `core/` package and follow a consistent pattern for JSON parsing and data handling.

### Model Structure

1. **Create model file** in `core/lib/modules/your_domain/models/`
2. **Use WealthyCast** for type-safe JSON parsing
3. **Add helper methods** for UI formatting

### Example Model

```dart
import 'package:core/modules/common/resources/wealthy_cast.dart';

class YourModel {
  String? id;
  String? name;
  double? amount;
  DateTime? createdAt;

  YourModel.fromJson(Map<String, dynamic> json) {
    id = WealthyCast.toStr(json['id']);
    name = WealthyCast.toStr(json['name']);
    amount = WealthyCast.toDouble(json['amount']);
    createdAt = WealthyCast.toDate(json['created_at']);
  }

  // Helper methods for UI display
  String get formattedAmount {
    if (amount == null) return '₹0';
    return '₹${amount!.toStringAsFixed(0)}';
  }
}
```

### WealthyCast Utilities

- `WealthyCast.toStr()` - Safe string conversion
- `WealthyCast.toInt()` - Safe integer conversion  
- `WealthyCast.toDouble()` - Safe double conversion
- `WealthyCast.toDate()` - Safe DateTime conversion
- `WealthyCast.toList()` - Safe list conversion

### Best Practices

- All fields should be nullable (`String?`, `int?`, etc.)
- Use `WealthyCast` utilities for all JSON parsing
- Add helper methods for UI formatting (currency, dates, etc.)

## Assets

- Place images in `assets/images/`
- Fonts in `assets/fonts/`
- HTML and data files in their respective folders

## Testing

- Widget and unit tests are in each package's `test/` directory
- Run all tests:
  ```sh
  flutter test
  ```

## Development Tips

- Use hot reload for rapid UI iteration.
- Follow modular structure for scalability.
- Use `core` for business logic and `api_sdk` for all API calls.
- Use `GetX` and `flutter_bloc` as appropriate for state management.

## Contributing

- Keep code modular and well-documented.
- Add new features in the appropriate package and folder.
- Write tests for all new logic.

---

See the `README.md` files in `app/`, `core/`, and `api_sdk/` for more details on each package.

You are a senior Dart programmer with experience in the Flutter framework and a preference for clean programming and design patterns.

Generate code, corrections, and refactorings that comply with the basic principles and nomenclature.

## Dart General Guidelines

### Basic Principles

- Use English for all code and documentation.
- Always declare the type of each variable and function (parameters and return value).
  - Avoid using any or dynamic.
  - Create necessary types.
  - Use null safety features.
- Don't leave blank lines within a function.
- One export per file.

### Nomenclature

- Use PascalCase for classes.
- Use camelCase for variables, functions, and methods.
- Use underscores_case for file and directory names.
- Use UPPERCASE for environment variables.
  - Avoid magic numbers and define constants.
- Start each function with a verb.
- Use verbs for boolean variables. Example: isLoading, hasError, canDelete, etc.
- Use complete words instead of abbreviations and correct spelling.
  - Except for standard abbreviations like API, URL, etc.
  - Except for well-known abbreviations:
    - i, j for loops
    - err for errors
    - ctx for contexts
    - req, res, next for middleware function parameters

### Functions

- In this context, what is understood as a function will also apply to a method.
- Write short functions with a single purpose. Less than 20 instructions.
- Name functions with a verb and something else.
  - If it returns a boolean, use isX or hasX, canX, etc.
  - If it doesn't return anything, use executeX or saveX, etc.
- Avoid nesting blocks by:
  - Early checks and returns.
  - Extraction to utility functions.
- Use higher-order functions (map, filter, reduce, etc.) to avoid function nesting.
  - Use arrow functions for simple functions (less than 3 instructions).
  - Use named functions for non-simple functions.
- Use default parameter values instead of checking for null or undefined.
- Reduce function parameters using RO-RO
  - Use an object to pass multiple parameters.
  - Use an object to return results.
  - Declare necessary types for input arguments and output.
- Use a single level of abstraction.

### Data

- Don't abuse primitive types and encapsulate data in composite types.
- Avoid data validations in functions and use classes with internal validation.
- Prefer immutability for data.
  - Use readonly for data that doesn't change.
  - Use as const for literals that don't change.

### Classes

- Follow SOLID principles.
- Prefer composition over inheritance.
- Declare interfaces to define contracts.
- Write small classes with a single purpose.
  - Less than 200 instructions.
  - Less than 10 public methods.
  - Less than 10 properties.

### Exceptions

- Use exceptions to handle errors you don't expect.
- If you catch an exception, it should be to:
  - Fix an expected problem.
  - Add context.
  - Otherwise, use a global handler.

## Specific to Flutter

### Basic Principles

- Use extensions to manage reusable code
- Use ThemeData to manage themes
- Use constants to manage constants values
- When a widget tree becomes too deep, it can lead to longer build times and increased memory usage. Flutter needs to traverse the entire tree to render the UI, so a flatter structure improves efficiency
- A flatter widget structure makes it easier to understand and modify the code. Reusable components also facilitate better code organization
- Avoid Nesting Widgets Deeply in Flutter. Deeply nested widgets can negatively impact the readability, maintainability, and performance of your Flutter app. Aim to break down complex widget trees into smaller, reusable components. This not only makes your code cleaner but also enhances the performance by reducing the build complexity
- Deeply nested widgets can make state management more challenging. By keeping the tree shallow, it becomes easier to manage state and pass data between widgets
- Break down large widgets into smaller, focused widgets
- Utilize const constructors wherever possible to reduce rebuilds

## Project Scripts

- **`clean_project.sh`**: Cleans build artifacts and resets the project state. Run this script before troubleshooting build issues or when switching branches.
  ```sh
  ./clean_project.sh
  ```
- **`run_script.sh`**: Automates cleaning, fetching dependencies, code generation, and running the app for all packages. Supports running in dev or prod flavor:
  ```sh
  ./run_script.sh dev   # Runs the app in development mode
  ./run_script.sh prod  # Runs the app in production mode
  ./run_script.sh       # Defaults to development mode
  ```
