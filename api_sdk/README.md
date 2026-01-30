# Wealthy Hail API SDK

## Overview

The `api_sdk` package manages all API integrations for the Wealthy Hail app, including both REST and GraphQL endpoints. It provides a unified interface for network calls, error handling, and logging.

## Project Structure

- `lib/`
  - `api_constants.dart`: API endpoint constants and configuration.
  - `log_util.dart`: Logging utilities for API calls.
  - `main.dart`: Entry point for SDK logic (if needed).
  - `api_collection/`: Dart files for each API domain (e.g., `advisor_api.dart`, `broking_api.dart`, `client_api.dart`, etc.).
  - `graphql_method/`: GraphQL handlers and helpers (`graphql_handler.dart`, `graphql_helper.dart`, `graphql_operations/`).
  - `rest/`: REST API handlers and helpers (`certified_rest_api_handler.dart`, `rest_api_handler_data.dart`, `api_helpers/`).

## Key Dependencies

- `graphql_flutter`, `graphql`: GraphQL client and helpers
- `dio`, `dio_smart_retry`: REST client and retry logic
- `shared_preferences`: Local storage for tokens, etc.
- `logger`: Logging
- `firebase_performance`: Performance monitoring

## Usage

- Import `api_sdk` in your app or core logic to make API calls:
  ```dart
  import 'package:api_sdk/api_collection/advisor_api.dart';
  ```
- Use provided methods for REST and GraphQL operations.

## Adding New APIs

1. Add a new Dart file in `api_collection/` for the new API domain.
2. For REST: Add handlers in `rest/`.
3. For GraphQL: Add queries/mutations in `graphql_method/`.
4. Update `api_constants.dart` as needed.

## Error Handling & Logging

- Use `log_util.dart` for consistent logging.
- Handle errors using provided patterns and best practices.

## Testing

- Add and run tests in the `test/` directory:
  ```sh
  flutter test
  ```
- Mock API responses for unit tests.

## Contribution Guidelines

- Document new endpoints and helpers.
- Write tests for all new API logic.
- Keep code modular and well-commented.

---

See also: `app/README.md` and `core/README.md` for integration and usage details.
