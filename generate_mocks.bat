@echo off
echo Generating mock files...
flutter pub run build_runner build --delete-conflicting-outputs
echo Mock files generated!
