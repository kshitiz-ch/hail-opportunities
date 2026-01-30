# Wealthy Hail Core

## Overview

The `core` package contains all shared business logic, models, and utilities for the Wealthy Hail app. It is designed for maximum reusability and separation of concerns, keeping the main app lean and focused on UI.

## Project Structure

- `lib/`
  - `main.dart`: Entry point for core logic (if needed).
  - `config/`: App-wide constants and utility functions (e.g., `string_constants.dart`, `string_utils.dart`).
  - `modules/`: Feature-based modules, each with its own models and resources:
    - `advisor/`, `ai/`, `authentication/`, `broking/`, `clients/`, `common/`, `dashboard/`, `insurance/`, `mutual_funds/`, `my_business/`, `my_team/`, `notifications/`, `onboarding/`, `proposals/`, `rewards/`, `store/`, `top_up_portfolio/`, `transaction/`, `wealth_academy/`
    - Each module typically contains `models/` and `resources/` for that feature.
  - `storage_service.dart`: Shared storage and persistence utilities.

## Key Dependencies

- `bloc`, `equatable`: State management and value equality
- `shared_preferences`: Local storage
- `package_info_plus`, `flutter_udid`: Device and app info
- `api_sdk`: Local package for API integration
- `intl`, `html_unescape`, `new_version_plus`: Utilities for formatting, parsing, and versioning

## Usage

- Import `core` in your app or other packages to access shared logic:
  ```dart
  import 'package:core/modules/clients/models/client_model.dart';
  ```
- Use feature modules for business logic, models, and resources.

## Extending Core

- Add new features as subfolders in `modules/`.
- Place shared constants in `config/`.
- Keep logic modular and reusable.

## Testing

- Add and run tests in the `test/` directory:
  ```sh
  flutter test
  ```

## Contribution Guidelines

- Document new modules and utilities.
- Write tests for all new logic.
- Keep code DRY and modular.

---

See also: `app/README.md` and `api_sdk/README.md` for integration details.
