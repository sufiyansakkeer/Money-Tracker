# Money Track

A personal finance management application built with Flutter that helps you track your income and expenses, visualize your financial data, and manage your budget effectively.

<table>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/28aa3cec-7196-44b0-84c1-e1eb75d04d70" width="250"/></td>
    <td><img src="https://github.com/user-attachments/assets/74312a9b-f423-4c46-92bb-3154f78c8ecc" width="250"/></td>
  </tr>
</table>

## 📱 Project Overview

Money Track is a comprehensive personal finance management application designed to help users track their income and expenses, categorize transactions, set and monitor budgets, and visualize their financial data through interactive charts. The app provides a clean and intuitive interface for managing personal finances on the go, with full support for both light and dark themes.

## ✨ Features

### 💰 Transaction Management

Easily record your income and expenses with detailed information including category, date, and notes. View your transaction history and filter by date, category, or transaction type. The transaction UI is fully compatible with both light and dark modes.

<table>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/181a9b5e-809f-4c27-9031-8b01ff0eaf0b" width="250"/></td>
    <td><img src="https://github.com/user-attachments/assets/cc906aa7-baab-4e1b-a8e2-f2916112bfdb" width="250"/></td>
    <td><img src="https://github.com/user-attachments/assets/56835b4e-e27d-4e79-a0ae-66a0100140ab" width="250"/></td>
  </tr>
</table>

### 📊 Financial Analytics

Visualize your financial data with interactive charts including pie charts, line charts, bar charts, column charts, and area charts. Filter data by date range and transaction type to gain insights into your spending habits.

<table>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/0863583b-d627-456f-b8c2-5903884630c4" width="250"/></td>
    <td><img src="https://github.com/user-attachments/assets/2c1851b0-043f-470c-8a53-2321a9d4427c" width="250"/></td>
    <td><img src="https://github.com/user-attachments/assets/ae555fca-cd88-4a62-908e-170143c37606" width="250"/></td>
  </tr>
</table>

### 📝 Budget Planning

Set up monthly or weekly budgets for different expense categories. Track your spending against budget limits with visual progress indicators. Get notified when you're approaching your budget limits to help maintain financial discipline.

<table>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/0c52efdd-4acc-47eb-bf25-7ada4d10ac47" width="250"/></td>
    <td><img src="https://github.com/user-attachments/assets/d613ec0d-e408-4382-8351-70dadab6bbf8" width="250"/></td>
    <td><img src="https://github.com/user-attachments/assets/ff107f0c-56b4-47b3-b1e4-7180b93d30a6" width="250"/></td>
  </tr>
</table>

### 🏷️ Category Management

Create and manage custom categories for your transactions. The app comes with default categories to get you started quickly.

<table>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/e80b3385-1490-4f45-9054-7efeb06b078f" width="250"/></td>
    <td><img src="https://github.com/user-attachments/assets/bc5aff8e-7cb6-413e-88f8-9f370e3a096a" width="250"/></td>
    <td><img src="https://github.com/user-attachments/assets/88078fbf-783b-4afc-8702-8e12de432d21" width="250"/></td>
  </tr>
</table>

### 💱 Currency Conversion

Convert between different currencies with real-time exchange rates. Set your preferred currency for the app to display all financial data.

<table>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/045f868b-350f-41c6-b0a1-3afa9529c1c3" width="250"/></td>
    <td><img src="https://github.com/user-attachments/assets/725b2327-0a73-412a-9891-d5a6bcc5a921" width="250"/></td>
  </tr>
</table>

### 🎨 Customizable Themes

Personalize your app experience with different color themes. Choose between light and dark modes for comfortable usage in any environment. All UI components, including transaction and budget pages, are fully compatible with dark mode, ensuring a consistent experience across the app.

<table>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/89431eb1-4602-46b0-b4f2-7761396c7e8c" width="250"/></td>
    <td><img src="https://github.com/user-attachments/assets/a6c6f903-68a2-438c-b0b6-d9f4627eeb36" width="250"/></td>
  </tr>
</table>

## 🏗️ Architecture

Money Track follows a feature-based clean architecture pattern to ensure maintainability, testability, and scalability.

```
lib/
├── core/                      # Core functionality
│   ├── constants/             # App-wide constants
│   ├── error/                 # Error handling
│   ├── theme/                 # App theme
│   └── utils/                 # Utility functions
│
├── data/                      # Data layer
│   ├── datasources/           # Data sources
│   ├── models/                # Data models
│   └── repositories/          # Repository implementations
│
├── domain/                    # Domain layer
│   ├── entities/              # Business entities
│   ├── repositories/          # Repository interfaces
│   └── usecases/              # Business logic
│
├── features/                  # Feature modules
│   ├── transactions/          # Transaction feature
│   ├── categories/            # Category feature
│   ├── budget/                # Budget planning feature
│   ├── profile/               # Profile feature
│   ├── navigation/            # Navigation feature
│   └── onboarding/            # Onboarding feature
│
├── app/                       # App-wide components
│   ├── routes/                # App routes
│   ├── di/                    # Dependency injection
│   └── app.dart               # App entry point
│
└── main.dart                  # Main entry point
```

### Dependency Flow

The dependency flow follows the clean architecture principles:

1. **Domain Layer**: Contains business logic and has no dependencies on other layers
2. **Data Layer**: Depends on the domain layer
3. **Feature Modules**: Depend on the domain and data layers
4. **App Layer**: Depends on all other layers

## 🛠️ Tech Stack

- **Framework**: Flutter
- **State Management**: BLoC/Cubit
- **Database**: Hive (NoSQL local database)
- **Dependency Injection**: Custom service locator
- **UI Components**: Material Design
- **Charts**: Syncfusion Flutter Charts
- **Animations**: Lottie, Rive
- **SVG Rendering**: SVG Flutter
- **Theme Management**: Custom theme system with light/dark mode support
- **Utilities**: Intl, UUID, Equatable
- **Architecture**: Feature-based Clean Architecture

## 🚀 Installation

1. **Prerequisites**:

   - Flutter SDK (version 3.4.0 or higher)
   - Dart SDK (version 3.4.0 or higher)
   - Android Studio / VS Code with Flutter extensions

2. **Clone the repository**:

   ```bash
   git clone https://github.com/yourusername/money_track.git
   cd money_track
   ```

3. **Install dependencies**:

   ```bash
   flutter pub get
   ```

4. **Run the app**:
   ```bash
   flutter run
   ```

## 🔄 CI/CD

This project uses GitHub Actions for Continuous Integration and Continuous Deployment (CI/CD). The workflow automates the following processes:

- **Build & Test**: On every push to `main` or `develop` branches, and on every pull request to `main`, the workflow:
  - Sets up the Flutter environment.
  - Gets dependencies (`flutter pub get`).
  - Analyzes the project (`flutter analyze`).
  - Runs tests (`flutter test`).
  - Builds Android APK and App Bundle.
  - Builds iOS (with provisions for IPA generation).
- **Deployment (Optional)**: The workflow includes an optional step to deploy Android App Bundles to Firebase App Distribution upon pushes to the `main` branch.

## 🤝 Contributing

Contributions are welcome! If you'd like to contribute to Money Track, please follow these steps:

1. Fork the repository
2. Create a new branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Commit your changes (`git commit -m 'Add some amazing feature'`)
5. Push to the branch (`git push origin feature/amazing-feature`)
6. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 Contact

If you have any questions or suggestions, feel free to reach out at sufiyansakkeer616@gmail.com.
