# Money Track - Clean Architecture

This document describes the clean architecture implementation of the Money Track app.

## Architecture Overview

The app follows a feature-based clean architecture with the following layers:

### Core Layer
- Contains common functionality used across features
- Includes constants, error handling, utilities, and themes

### Domain Layer
- Contains business logic
- Includes entities, repository interfaces, and use cases
- Independent of any framework or implementation details

### Data Layer
- Implements the repository interfaces defined in the domain layer
- Includes data sources, models, and repository implementations
- Handles data persistence using Hive

### Feature Modules
- Organized by domain (transactions, categories, profile, etc.)
- Each feature has its own data, domain, and presentation layers
- Follows a modular approach for better maintainability and scalability

### App Layer
- Contains app-wide components
- Includes dependency injection, routing, and the app entry point

## Folder Structure

```
lib/
├── core/                      # Core functionality
│   ├── constants/             # App-wide constants
│   ├── error/                 # Error handling
│   ├── network/               # Network related code
│   ├── theme/                 # App theme
│   └── utils/                 # Utility functions
│
├── data/                      # Data layer
│   ├── datasources/           # Data sources
│   │   ├── local/             # Local data sources (Hive)
│   │   └── remote/            # Remote data sources (if any)
│   ├── models/                # Data models
│   └── repositories/          # Repository implementations
│
├── domain/                    # Domain layer
│   ├── entities/              # Business entities
│   ├── repositories/          # Repository interfaces
│   └── usecases/              # Use cases
│
├── features/                  # Features
│   ├── transactions/          # Transactions feature
│   │   ├── data/              # Feature-specific data
│   │   ├── domain/            # Feature-specific domain
│   │   └── presentation/      # Feature-specific presentation
│   │
│   ├── categories/            # Categories feature
│   │   ├── data/              # Feature-specific data
│   │   ├── domain/            # Feature-specific domain
│   │   └── presentation/      # Feature-specific presentation
│   │
│   └── profile/               # Profile feature
│       ├── data/              # Feature-specific data
│       ├── domain/            # Feature-specific domain
│       └── presentation/      # Feature-specific presentation
│
├── app/                       # App-wide components
│   ├── routes/                # App routes
│   ├── di/                    # Dependency injection
│   └── app.dart               # App entry point
│
└── main.dart                  # Main entry point
```

## Dependency Flow

The dependency flow follows the clean architecture principles:

1. **Domain Layer**: Contains business logic and has no dependencies on other layers
2. **Data Layer**: Depends on the domain layer
3. **Feature Modules**: Depend on the domain and data layers
4. **App Layer**: Depends on all other layers

## Dependency Injection

The app uses a service locator pattern for dependency injection. The `injection_container.dart` file in the `app/di` directory is responsible for registering and providing dependencies.

## State Management

The app uses the BLoC pattern for state management. Each feature has its own BLoCs or Cubits that handle the business logic and state management for that feature.

## Data Flow

1. **UI**: The UI interacts with BLoCs/Cubits
2. **BLoC/Cubit**: Processes events and calls use cases
3. **Use Case**: Contains business logic and calls repositories
4. **Repository**: Abstracts data sources and returns domain entities
5. **Data Source**: Handles data persistence or network requests

## Benefits of This Architecture

- **Separation of Concerns**: Each layer has a specific responsibility
- **Testability**: Business logic is isolated and easy to test
- **Maintainability**: Code is organized and easy to understand
- **Scalability**: New features can be added without affecting existing code
- **Modularity**: Features are independent and can be developed in parallel
