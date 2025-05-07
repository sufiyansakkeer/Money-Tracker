@echo off
echo Running all fixed tests...
flutter test test\unit\core\utils\date_time_extension_test.dart test\unit\core\utils\string_extensions_test.dart test\widget\custom_choice_chip_test.dart test\widget\budget_progress_bar_test.dart test\widget\transaction_page_test_fixed.dart test\integration\transaction_flow_test_simplified.dart

echo Tests completed!
