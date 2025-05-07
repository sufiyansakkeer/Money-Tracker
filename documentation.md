# Money Track Project Documentation

## 1. Project Overview

Money Track is a mobile application designed to help users manage their personal finances effectively. It allows users to track their income and expenses, set budgets, and customize their profile. The application provides a user-friendly interface and utilizes local storage for data persistence.

## 2. Architecture Overview

The project follows a feature-based architecture, where each feature is a self-contained module with its own presentation, domain, and data layers. This approach promotes modularity, reusability, and maintainability.

The main features of the application are:

- **Transactions:** This feature handles the management of user transactions, including adding, editing, deleting, and listing transactions.
- **Budget:** This feature handles the management of user budgets, including setting budgets for different categories and tracking progress.
- **Profile:** This feature handles the management of user profile settings, such as currency and theme.
- **Onboarding:** This feature handles the initial onboarding experience for new users.

Each feature follows a similar structure:

- **Presentation Layer:** This layer contains the UI components (widgets) and the logic for handling user interactions. It uses the Bloc pattern for state management.
- **Domain Layer:** This layer contains the core business logic of the feature. It defines entities, use cases, and repositories.
- **Data Layer:** This layer is responsible for data access. It includes local data sources (using Hive) and repository implementations.

The Bloc pattern is used for state management to decouple the UI from the business logic. Dependency injection is implemented using the `get_it` package to manage dependencies and improve testability.

## 3. Core Functionalities

- **Transaction Management:** Users can add, edit, and delete transactions, categorizing them as income or expenses.
- **Budget Tracking:** Users can set budgets for different categories and track their progress.
- **Profile Customization:** Users can customize their profile by selecting their preferred currency and theme.

## 4. Key Components

### 4.1. `main.dart`

- **Description:** This file is the entry point of the application. It initializes the Hive database, registers Hive adapters, opens Hive boxes, initializes dependency injection, and runs the app.
- **Key functions:**
  - `main()`: The main function performs the following steps:
    - Sets the system UI overlay style using `SystemChrome.setSystemUIOverlayStyle()`.
    - Ensures Flutter binding is initialized using `WidgetsFlutterBinding.ensureInitialized()`.
    - Initializes Hive using `Hive.initFlutter()`.
    - Registers Hive adapters for data models (`CategoryModel`, `TransactionModel`, `CurrencyModel`, `BudgetModel`) using `Hive.registerAdapter()`.
    - Opens Hive boxes for storing data using `Hive.openBox()`.
    - Initializes dependency injection using `sl.init()`.
    - Runs the `App` widget using `runApp()`.
    - **Important Implementation Details:** The `main()` function also handles the registration of Hive adapters. Hive adapters are required to serialize and deserialize custom data models. The `main()` function checks if the adapters are already registered before registering them. This prevents errors if the `main()` function is called multiple times. This is important because the `main()` function can be called multiple times during development, especially when using hot reload. The `main()` function also sets the system UI overlay style. This is important because it ensures that the app looks good on all devices. The `main()` function also handles the initialization of the Hive database. The Hive database is used to store the application's data locally. The `main()` function also initializes the dependency injection container. The dependency injection container is used to manage the application's dependencies. The `main()` function also calls the `runApp()` function. The `runApp()` function is used to start the Flutter application. The `main()` function is also responsible for handling any errors that occur during the initialization process. If an error occurs, the `main()` function will display an error message to the user.

### 4.2. `app/app.dart`

- **Description:** This file contains the main `App` widget, which is the root of the application's widget tree. It sets up the `MaterialApp` with the application's theme, routes, and home page.
- **Widgets:**
  - `App`: This widget is the root of the application's widget tree. It sets up the `MaterialApp` with the application's theme, routes, and home page. It uses `MultiBlocProvider` to provide the necessary blocs and cubits to the application. \* **Important Implementation Details:** The `App` widget uses `MultiBlocProvider` to provide the necessary blocs and cubits to the application. `MultiBlocProvider` is a widget that provides multiple blocs and cubits to its children. This makes it easy to access the blocs and cubits from anywhere in the application. The `App` widget also uses `MaterialApp` to set up the application's theme, routes, and home page. `MaterialApp` is a widget that provides the basic structure for a Flutter application. The `App` widget also uses `GlobalMaterialLocalizations.delegate`,
    `GlobalWidgetsLocalizations.delegate`,
    `GlobalCupertinoLocalizations.delegate` for localization. This ensures that the app is localized correctly for different languages. The `App` widget also uses `ThemeData` to set up the application's theme. The `ThemeData` is used to set the application's colors, fonts, and other visual properties. The `App` widget also uses `Scaffold` to provide the basic layout for the application. The `App` widget also uses `BlocBuilder` to rebuild the UI when the state changes.

### 4.3. `app/di/injection_container.dart`

- **Description:** This file configures dependency injection using the `get_it` package. It registers instances of repositories, use cases, and Blocs/Cubits.
- **Dependencies:**
  - Repositories: `CategoryRepository`, `TransactionRepository`, `BudgetRepository`, `CurrencyRepository`, `ThemeRepository`
  - Use Cases: `AddCategoryUseCase`, `GetAllCategoriesUseCase`, `SetDefaultCategoriesUseCase`, `AddTransactionUseCase`, `DeleteTransactionUseCase`, `EditTransactionUseCase`, `GetAllTransactionsUseCase`, `AddBudgetUseCase`, `DeleteBudgetUseCase`, `EditBudgetUseCase`, `GetActiveBudgetsUseCase`, `GetAllBudgetsUseCase`, `GetBudgetsByCategoryUseCase`, `ConvertCurrencyUseCase`, `GetAvailableCurrenciesUseCase`, `GetSelectedCurrencyUseCase`, `GetSelectedThemeModeUseCase`, `GetSelectedThemeUseCase`, `GetThemeSettingsUseCase`, `SetSelectedCurrencyUseCase`, `SetSelectedThemeModeUseCase`, `SetSelectedThemeUseCase`, `SetThemeSettingsUseCase`
  - Blocs/Cubits: `TransactionBloc`, `BudgetBloc`, `CategoryBloc`, `ThemeCubit`, `CurrencyCubit`
- **Singleton Instances:** The `injection_container.dart` file registers singleton instances of the repositories, use cases, and blocs/cubits. This ensures that only one instance of each dependency is created throughout the application.
- **Important Implementation Details:** The `injection_container.dart` file uses the `get_it` package to configure dependency injection. The `get_it` package is a simple service locator that allows you to access dependencies from anywhere in the application. The `injection_container.dart` file registers singleton instances of the repositories, use cases, and blocs/cubits. This ensures that only one instance of each dependency is created throughout the application. This is important because it prevents the creation of multiple instances of the same dependency, which can lead to unexpected behavior. The `injection_container.dart` also calls `await sl.init()` to initialize the service locator. This is important because it ensures that the dependencies are available when the application starts. The `injection_container.dart` file also registers the Hive boxes. The Hive boxes are used to store the application's data locally. The `injection_container.dart` file also registers the `SharedPreferences` instance. The `SharedPreferences` instance is used to store the application's settings. The `injection_container.dart` file also handles any errors that occur during the initialization process. If an error occurs, the `injection_container.dart` file will display an error message to the user.

### 4.4. Data Models

- **Description:** The application uses several data models to represent data stored in the Hive database. These models include:
  - `CategoryModel`: Represents a category for transactions (e.g., food, transportation).
    - `id`: The unique identifier of the category.
    - `name`: The name of the category.
    - `type`: The type of the category (income or expense).
    - **Important Implementation Details:** The `CategoryModel` uses a `CategoryTypeAdapter` to serialize and deserialize the `type` property. The `CategoryTypeAdapter` is a custom Hive adapter that converts the `CategoryType` enum to an integer and vice versa. This is necessary because Hive does not support enums by default. The `CategoryModel` is stored in the `category-database` Hive box. The `CategoryModel` is used to represent the categories that the user can choose from when adding a transaction. The `CategoryModel` also has a `toJson()` and `fromJson()` method. These methods are used to convert the `CategoryModel` to and from JSON. The `CategoryModel` also implements the `Equatable` interface. The `Equatable` interface is used to compare two `CategoryModel` instances. The `CategoryModel` also has a `copyWith()` method. The `copyWith()` method is used to create a new `CategoryModel` instance with the same properties as the original instance, but with some of the properties changed.
  - `TransactionModel`: Represents a transaction with details such as amount, date, category, and type (income or expense).
    - `id`: The unique identifier of the transaction.
    - `amount`: The amount of the transaction.
    - `date`: The date of the transaction.
    - `categoryId`: The ID of the category associated with the transaction.
    - `type`: The type of the transaction (income or expense).
    - `description`: A description of the transaction.
    - **Important Implementation Details:** The `TransactionModel` uses a `TransactionTypeAdapter` to serialize and deserialize the `type` property. The `TransactionTypeAdapter` is a custom Hive adapter that converts the `TransactionType` enum to an integer and vice versa. This is necessary because Hive does not support enums by default.
  - `CurrencyModel`: Represents a currency with properties such as name, symbol, and code.
    - `code`: The currency code (e.g., USD, EUR).
    - `name`: The name of the currency (e.g., US Dollar, Euro).
    - `symbol`: The currency symbol (e.g., $, €).
    -        **Important Implementation Details:** The `CurrencyModel` is stored in the `currency-database` Hive box. The `CurrencyModel` is used to represent the currencies that the user can choose from in the profile page.
  - `BudgetModel`: Represents a budget with properties such as category, amount, and period.
    - `id`: The unique identifier of the budget.
    - `categoryId`: The ID of the category associated with the budget.
    - `amount`: The amount of the budget.
    - `period`: The period of the budget (e.g., monthly, weekly).
    - **Important Implementation Details:** The `BudgetModel` uses a `BudgetPeriodTypeAdapter` to serialize and deserialize the `period` property. The `BudgetPeriodTypeAdapter` is a custom Hive adapter that converts the `BudgetPeriodType` enum to an integer and vice versa. This is necessary because Hive does not support enums by default. The `BudgetModel` is stored in the `budget-database` Hive box.

### 4.5. Blocs/Cubits

- **Description:** The application uses the Bloc pattern for state management. Key Blocs/Cubits include: \* **Important Implementation Details:** The blocs and cubits use the `Result` type to handle success and failure states. The `Result` type is a custom type that represents either a success value or a failure. This makes it easy to handle errors and display appropriate messages to the user. The blocs and cubits also use the `emit()` method to emit new states. The `emit()` method is a method provided by the `bloc` package that allows you to emit new states to the UI. The blocs and cubits also use the `mapEventToState()` method to handle events. The `mapEventToState()` method is a method provided by the `bloc` package that allows you to map events to states. The blocs and cubits also use the `BlocProvider` widget to provide the blocs and cubits to the UI. The blocs and cubits also use the `BlocBuilder` widget to rebuild the UI when the state changes. The blocs and cubits also use the `BlocListener` widget to listen for state changes and perform side effects. The blocs and cubits also use the `add()` method to add events to the bloc.
  - `TransactionBloc`: Manages the state of transactions.
    - **Purpose:** This bloc handles the state of transactions, including loading, adding, editing, and deleting transactions.
    - **Events:** `TransactionEvent` (e.g., `LoadTransactions`, `AddTransaction`, `EditTransaction`, `DeleteTransaction`)
    - **States:** `TransactionState` (e.g., `TransactionLoading`, `TransactionLoaded`, `TransactionError`)
    - **Widgets:** `HomePage`, `TransactionListPage`, `TransactionPage`
  - `BudgetBloc`: Manages the state of budgets.
    - **Purpose:** This bloc handles the state of budgets, including loading, adding, editing, and deleting budgets.
    - **Events:** `BudgetEvent` (e.g., `LoadBudgets`, `AddBudget`, `EditBudget`, `DeleteBudget`)
    - **States:** `BudgetState` (e.g., `BudgetLoading`, `BudgetLoaded`, `BudgetError`)
    - **Widgets:** `BudgetPage`, `AddEditBudgetPage`
  - `CategoryBloc`: Manages the state of categories.
    - **Purpose:** This bloc handles the state of categories, including loading, adding, editing, and deleting categories.
    - **Events:** `CategoryEvent` (e.g., `LoadCategories`, `AddCategory`, `EditCategory`, `DeleteCategory`)
    - **States:** `CategoryState` (e.g., `CategoryLoading`, `CategoryLoaded`, `CategoryError`)
    - **Widgets:** `CategoryPage`, `CategoryBottomSheet`
  - `ThemeCubit`: Manages the state of the application's theme.
    - **Purpose:** This cubit handles the state of the application's theme, including setting the theme mode (light or dark) and the theme color.
    - **States:** `ThemeState` (e.g., `ThemeLoading`, `ThemeLoaded`, `ThemeError`)
    - **Widgets:** `ThemePage`
  - `CurrencyCubit`: Manages the state of the selected currency.
    - **Purpose:** This cubit handles the state of the selected currency, including loading and setting the currency.
    - **States:** `CurrencyState` (e.g., `CurrencyLoading`, `CurrencyLoaded`, `CurrencyError`)
    - **Widgets:** `CurrencyPage`

## 5. Use Cases

### 5.1. Category Use Cases

- **AddCategoryUseCase:** Adds a new category to the database.
  - Input: `CategoryEntity`
  - Output: `Result<String>` (success message or failure)
- **GetAllCategoriesUseCase:** Retrieves all categories from the database.
  - Input: `NoParams`
  - Output: `Result<List<CategoryEntity>>` (list of categories or failure)
- **SetDefaultCategoriesUseCase:** Sets the default categories in the database.
  - Input: `NoParams`
  - Output: `Result<void>` (success or failure)

### 5.2. Transaction Use Cases

- **AddTransactionUseCase:** Adds a new transaction to the database.
  - Input: `TransactionEntity`
  - Output: `Result<String>` (success message or failure)
- **DeleteTransactionUseCase:** Deletes a transaction from the database.
  - Input: `String` (transaction ID)
  - Output: `Result<void>` (success or failure)
- **EditTransactionUseCase:** Edits an existing transaction in the database.
  - Input: `TransactionEntity`
  - Output: `Result<String>` (success message or failure)
- **GetAllTransactionsUseCase:** Retrieves all transactions from the database.
  - Input: `NoParams`
  - Output: `Result<List<TransactionEntity>>` (list of transactions or failure)

### 5.3. Budget Use Cases

- **AddBudgetUseCase:** Adds a new budget to the database.
  - Input: `BudgetEntity`
  - Output: `Result<String>` (success message or failure)
- **DeleteBudgetUseCase:** Deletes a budget from the database.
  - Input: `String` (budget ID)
  - Output: `Result<void>` (success or failure)
- **EditBudgetUseCase:** Edits an existing budget in the database.
  - Input: `BudgetEntity`
  - Output: `Result<String>` (success message or failure)
- **GetActiveBudgetsUseCase:** Retrieves all active budgets from the database.
  - Input: `void`
  - Output: `Result<List<BudgetEntity>>` (list of active budgets or failure)
- **GetAllBudgetsUseCase:** Retrieves all budgets from the database.
  - Input: `void`
  - Output: `Result<List<BudgetEntity>>` (list of budgets or failure)
- **GetBudgetsByCategoryUseCase:** Retrieves budgets for a specific category from the database.
  - Input: `String` (category ID)
  - Output: `Result<List<BudgetEntity>>` (list of budgets or failure)

### 5.4. Profile Use Cases

- **ConvertCurrencyUseCase:** Converts an amount from one currency to another.
  - Input: `ConvertCurrencyParams` (amount, fromCurrencyCode, toCurrencyCode)
  - Output: `Result<double>` (converted amount or failure)
- **GetAvailableCurrenciesUseCase:** Retrieves all available currencies from the database.
  - Input: `NoParams`
  - Output: `Result<List<CurrencyEntity>>` (list of currencies or failure)
- **GetSelectedCurrencyUseCase:** Retrieves the currently selected currency from the database.
  - Input: `NoParams`
  - Output: `Result<CurrencyEntity>` (selected currency or failure)
- **GetSelectedThemeModeUseCase:** Retrieves the currently selected theme mode.
  - Input: `void`
  - Output: `Result<String>` (theme mode or failure)
- **GetSelectedThemeUseCase:** Retrieves the currently selected theme.
  - Input: `void`
  - Output: `Result<String>` (theme name or failure)
- **GetThemeSettingsUseCase:** Retrieves both the selected theme and theme mode.
  - Input: `void`
  - Output: `Result<Map<String, String>>` (map containing theme and mode or failure)
- **SetSelectedCurrencyUseCase:** Sets the selected currency in the database.
  - Input: `String` (currency code)
  - Output: `Result<void>` (success or failure)
- **SetSelectedThemeModeUseCase:** Sets the selected theme mode.
  - Input: `String` (theme mode)
  - Output: `Result<void>` (success or failure)
- **SetSelectedThemeUseCase:** Sets the selected theme.
  - Input: `String` (theme name)
  - Output: `Result<void>` (success or failure)
- **SetThemeSettingsUseCase:** Sets both the selected theme and theme mode.
  - Input: `ThemeSettingsParams` (themeName, themeMode)
  - Output: `Result<void>` (success or failure)

## 6. Data Management

The application uses Hive, a lightweight NoSQL database, for local data storage. Hive boxes are used to store data models. Hive adapters are registered to handle the serialization and deserialization of data models.

## 6. Dependency Injection

Dependency injection is implemented using the `get_it` package. The `injection_container.dart` file configures the dependency injection container. The `sl` object is used to access registered dependencies.

## 7. Important Implementation Details

- **Hive Initialization:** The `main()` function initializes Hive and registers Hive adapters before opening Hive boxes. This is crucial for ensuring that data models can be properly serialized and deserialized.
- **Bloc Pattern:** The Bloc pattern is used to separate the UI from the business logic. This improves testability and maintainability.
- **Dependency Injection:** Dependency injection is used to manage dependencies and improve testability. The `get_it` package is used to implement dependency injection.

## 8. App Flow

The application follows a specific flow to provide a seamless user experience.

1.  **Splash Screen:** The app starts with a splash screen (`SplashScreen`) that initializes the app and navigates to the appropriate screen based on the user's onboarding status.
    - **Details:** The splash screen checks if the user has completed the onboarding process. If not, it navigates to the onboarding screen. Otherwise, it navigates to the bottom navigation page.
    - **Edge Cases:** If the app fails to initialize due to database errors or network issues, an error message is displayed, and the app may need to be restarted. Additionally, if the user's authentication token has expired, the app should redirect to the login screen.
2.  **Onboarding:** If the user is new, they are presented with an onboarding flow (`OnboardScreen`) that introduces the app's features and sets default categories.
    - **Details:** The onboarding process guides the user through the app's main features and allows them to set default categories. After completing the onboarding process, the user is navigated to the bottom navigation page.
    - **Edge Cases:** If the user interrupts the onboarding process, the app should save the current state and allow the user to resume the process later. If the app fails to set default categories due to data validation errors or database issues, an error message is displayed, and the user may need to manually set the categories. The onboarding flow should also handle cases where the user's device has limited storage space.
3.  **Bottom Navigation:** After onboarding (or if the user has already completed it), the user is navigated to the `BottomNavigationPage`, which serves as the main navigation hub.
    - **Details:** The bottom navigation page provides access to the home page, transaction list, budget page, and profile page.
    - **Edge Cases:** If the bottom navigation fails to load due to UI errors or network connectivity issues, the app may need to be restarted. The bottom navigation should also handle cases where the user's device has a small screen size.
4.  **Home Page:** The `HomePage` displays a summary of the user's transactions and provides access to add new transactions.
    - **Details:** The home page displays the total income, total expenses, and the balance. It also provides a list of recent transactions.
    - **Edge Cases:** If the app fails to load transactions due to database errors or API unavailability, an error message is displayed. If the user has no transactions, an empty state is displayed with a prompt to add a new transaction. The home page should also handle cases where the user has a large number of transactions, potentially requiring pagination or infinite scrolling.
5.  **Transaction List:** The `TransactionListPage` displays a list of all transactions and allows users to filter and sort them.
    - **Details:** The transaction list allows users to filter transactions by date, category, and type. It also allows users to sort transactions by date, amount, and category.
    - **Edge Cases:** If the app fails to load transactions due to database errors or API unavailability, an error message is displayed. If the user has no transactions, an empty state is displayed with a prompt to add a new transaction. The transaction list should also handle cases where the user has a large number of transactions, potentially requiring pagination or infinite scrolling.
6.  **Add/Edit Transaction:** The `TransactionPage` allows users to add new transactions or edit existing ones.
    - **Details:** The add/edit transaction page allows users to enter the transaction amount, date, category, and type. It also allows users to add a description and an attachment.
    - **Edge Cases:** If the user enters invalid data, such as a negative amount or an invalid date, appropriate validation messages are displayed. If the app fails to save the transaction due to database errors or API unavailability, an error message is displayed. The add/edit transaction page should also handle cases where the user tries to upload a large attachment.
7.  **Budget Page:** The `BudgetPage` displays a list of budgets and allows users to add, edit, or delete budgets.
    - **Details:** The budget page displays a list of budgets, including the category, amount, and period. It also displays the progress of each budget.
    - **Edge Cases:** If the app fails to load budgets due to database errors or API unavailability, an error message is displayed. If the user has no budgets, an empty state is displayed with a prompt to add a new budget. The budget page should also handle cases where the user has a large number of budgets, potentially requiring pagination or infinite scrolling.
8.  **Profile Page:** The `ProfilePage` allows users to customize their profile settings, such as currency and theme.
    - **Details:** The profile page allows users to select their preferred currency and theme. It also provides access to the about page and the logout function.
    - **Edge Cases:** If the app fails to save the profile settings due to database errors or API unavailability, an error message is displayed. The profile page should also handle cases where the user's selected currency or theme is not available. Additionally, the logout function should handle cases where the user's session cannot be terminated properly.
