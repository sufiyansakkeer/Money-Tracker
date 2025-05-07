@echo off
echo Running unit tests...
flutter test test/unit

echo Running widget tests...
flutter test test/widget

echo Running integration tests...
flutter test test/integration

echo Running all tests with coverage...
flutter test --coverage

echo Tests completed!
