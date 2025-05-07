# Testing Structure

This directory contains tests for the Money Track application, organized into three main categories:

## 1. Unit Tests
Located in the `unit` directory, these tests focus on testing individual components in isolation.
- `core`: Tests for core utilities and helpers
- `data`: Tests for data layer components (repositories, data sources)
- `domain`: Tests for domain layer components (use cases, entities)
- `features`: Tests for feature-specific components

## 2. Widget Tests
Located in the `widget` directory, these tests focus on testing UI components.
- Tests for individual widgets
- Tests for pages and screens

## 3. Integration Tests
Located in the `integration` directory, these tests focus on testing the interaction between components.
- End-to-end tests
- Feature integration tests

## Running Tests

To run all tests:
```
flutter test
```

To run a specific test file:
```
flutter test test/path/to/test_file.dart
```

To run tests with coverage:
```
flutter test --coverage
```
