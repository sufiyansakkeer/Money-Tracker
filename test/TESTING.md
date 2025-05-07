# Money Track Testing Documentation

This document outlines the testing strategy for the Money Track application.

## 1. Testing Levels

The testing strategy is divided into three main levels:

1. **Unit Tests**: Testing individual components in isolation
2. **Widget Tests**: Testing UI components
3. **Integration Tests**: Testing the interaction between components

## 2. Test Directory Structure

```
test/
├── helpers/               # Test helpers and utilities
│   ├── generate_mocks.dart
│   └── test_helpers.dart
├── integration/           # Integration tests
│   ├── README.md
│   └── transaction_flow_test.dart
├── unit/                  # Unit tests
│   ├── README.md
│   ├── core/              # Tests for core utilities
│   │   └── utils/
│   │       ├── currency_formatter_test.dart
│   │       ├── date_time_extension_test.dart
│   │       └── string_extensions_test.dart
│   ├── data/              # Tests for data layer
│   │   └── repositories/
│   │       └── category_repository_impl_test.dart
│   ├── domain/            # Tests for domain layer
│   │   └── usecases/
│   │       └── category/
│   │           └── get_all_categories_usecase_test.dart
│   └── features/          # Tests for features
│       └── categories/
│           └── presentation/
│               └── bloc/
│                   └── category_bloc_test.dart
├── widget/                # Widget tests
│   ├── README.md
│   ├── budget_progress_bar_test.dart
│   └── custom_choice_chip_test.dart
└── README.md              # Testing overview
```

## 3. Running Tests

### 3.1. Running All Tests

To run all tests with coverage:

```bash
flutter test --coverage
```

### 3.2. Running Fixed Tests

To run the fixed tests that are known to work:

```bash
.\run_fixed_tests.bat
```

This will run:

- Unit tests: date_time_extension_test.dart, string_extensions_test.dart
- Widget tests: custom_choice_chip_test.dart, budget_progress_bar_test.dart, transaction_page_test_fixed.dart
- Integration tests: simple_transaction_test.dart

### 3.3. Running Specific Test Categories

To run only unit tests:

```bash
flutter test test/unit
```

To run only widget tests:

```bash
flutter test test/widget
```

To run only integration tests:

```bash
flutter test test/integration
```

### 3.4. Running a Specific Test File

```bash
flutter test test/path/to/test_file.dart
```

## 4. Test Helpers

The project includes several test helpers to make testing easier:

- `test_helpers.dart`: Contains utility functions for testing, such as wrapping widgets with MaterialApp for testing
- `generate_mocks.dart`: Generates mock classes using Mockito for mocking dependencies

## 5. Mocking

The project uses Mockito for mocking dependencies. To generate mock classes:

```bash
flutter pub run build_runner build
```

## 6. Integration Tests

Integration tests are located in the `integration_test` directory and can be run on a real device or emulator:

```bash
flutter test integration_test
```

## 7. Test Coverage

To generate a coverage report:

```bash
flutter test --coverage
```

This will generate a `coverage/lcov.info` file that can be used with tools like LCOV to generate HTML reports:

```bash
genhtml coverage/lcov.info -o coverage/html
```

## 8. Testing Best Practices

1. **Test Isolation**: Each test should be independent and not rely on the state from other tests
2. **Arrange-Act-Assert**: Follow the AAA pattern in tests
3. **Mock Dependencies**: Use mocks for external dependencies
4. **Test Edge Cases**: Include tests for error conditions and edge cases
5. **Keep Tests Fast**: Tests should run quickly to encourage frequent testing
6. **Test Behavior, Not Implementation**: Focus on testing what the code does, not how it does it

## 9. Key Components to Test

### 9.1. Core Utilities

- Currency formatter
- Date/time extensions
- String extensions
- Navigation extensions

### 9.2. Data Layer

- Repository implementations
- Local data sources
- Models and their conversions

### 9.3. Domain Layer

- Use cases
- Entity validations
- Business logic

### 9.4. Presentation Layer

- Blocs/Cubits
- Widgets
- Pages
- User interactions

## 10. Test Examples

### 10.1. Unit Test Example (Currency Formatter)

Tests the currency formatting utility to ensure it correctly formats currency values with the appropriate symbol and decimal places.

### 10.2. Widget Test Example (CustomChoiceChip)

Tests the CustomChoiceChip widget to ensure it renders correctly and responds to user interactions as expected.

### 10.3. Integration Test Example (Transaction Flow)

Tests the end-to-end flow of adding a transaction, from selecting a category to entering an amount and description, and finally saving the transaction.
