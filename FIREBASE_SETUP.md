# Firebase Setup

This project uses Firebase for backend services. To run the app locally, you'll need to set up your own Firebase project and configuration files.

## Setup Instructions

### 1. Create a Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or use an existing one
3. Enable the services you need (Authentication, Firestore, etc.)

### 2. Android Configuration
1. In Firebase Console, add an Android app to your project
2. Use package name: `com.example.moneyTrack`
3. Download the `google-services.json` file
4. Place it in `android/app/google-services.json`

### 3. iOS Configuration
1. In Firebase Console, add an iOS app to your project
2. Use bundle ID: `com.example.moneyTrack`
3. Download the `GoogleService-Info.plist` file
4. Place it in `ios/Runner/GoogleService-Info.plist`

### 4. Generate Firebase Options (Flutter)
1. Install FlutterFire CLI: `dart pub global activate flutterfire_cli`
2. Run: `flutterfire configure`
3. Select your Firebase project
4. Choose the platforms you want to support
5. This will generate `lib/firebase_options.dart`

### 5. Template Files
Template files are provided to help you understand the structure:
- `android/app/google-services.json.template`
- `ios/Runner/GoogleService-Info.plist.template`
- `lib/firebase_options.dart.template`

**Important**: Never commit the actual configuration files to version control as they contain sensitive information.

## Security Note
The actual Firebase configuration files (`google-services.json`, `GoogleService-Info.plist`, and `firebase_options.dart`) are ignored by git for security reasons. These files contain API keys and other sensitive information that should not be shared publicly.