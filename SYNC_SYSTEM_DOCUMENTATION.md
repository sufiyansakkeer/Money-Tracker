# Money Tracker - Data Synchronization System

## Overview

The Money Tracker app features a comprehensive data synchronization system that provides seamless offline-first functionality with real-time cloud synchronization. This system ensures your financial data is always available, whether you're online or offline, and automatically syncs across all your devices.

## Key Features

- **Offline-First Architecture**: All data operations work offline and sync when connectivity is restored
- **Real-Time Synchronization**: Changes are instantly synced across devices when online
- **Conflict Resolution**: Automatic handling of simultaneous edits from multiple devices
- **Authentication-Based Data Isolation**: Each user's data is completely isolated and secure
- **Automatic Data Cleanup**: Local data is cleared on logout for privacy
- **Comprehensive Error Handling**: Robust error handling with automatic retry mechanisms
- **Visual Sync Indicators**: Clear UI feedback about sync status and offline operations

## Architecture Components

### Core Services

1. **SyncService** (`lib/core/services/sync_service.dart`)
   - Central orchestrator for all sync operations
   - Manages bidirectional data synchronization
   - Handles offline queue and conflict resolution

2. **ConnectivityService** (`lib/core/services/connectivity_service.dart`)
   - Monitors network connectivity status
   - Provides real-time connectivity updates
   - Handles connection state changes

3. **SyncCubit** (`lib/core/presentation/bloc/sync_cubit.dart`)
   - Manages sync state for UI components
   - Provides reactive sync status updates
   - Handles user-initiated sync operations

### Data Layer

1. **Firestore Models** (`lib/data/models/firestore/`)
   - `TransactionFirestoreModel`: Cloud-optimized transaction data
   - `CategoryFirestoreModel`: Cloud-optimized category data
   - Version-controlled for conflict resolution

2. **Remote Data Sources** (`lib/data/datasources/remote/`)
   - `TransactionRemoteDataSource`: Firebase Firestore operations for transactions
   - `CategoryRemoteDataSource`: Firebase Firestore operations for categories
   - Real-time listeners and batch operations

3. **Sync-Enhanced Repositories** (`lib/data/repositories/`)
   - `SyncTransactionRepositoryImpl`: Transaction operations with sync integration
   - `SyncCategoryRepositoryImpl`: Category operations with sync integration
   - `SyncAuthRepositoryImpl`: Authentication with sync lifecycle management

### UI Components

1. **Sync Indicators** (`lib/core/presentation/widgets/sync_indicator.dart`)
   - `SyncIndicator`: Shows current sync status
   - `SyncFloatingActionButton`: Manual sync trigger
   - `OfflineBanner`: Offline mode notification

2. **Sync Settings** (`lib/core/presentation/pages/sync_settings_page.dart`)
   - Sync status overview
   - Manual sync controls
   - Sync statistics and information

## Setup and Configuration

### 1. Firebase Configuration

#### Firestore Security Rules
Deploy the provided Firestore rules (`firestore.rules`) to ensure data security:

```bash
firebase deploy --only firestore:rules
```

Key security features:
- User authentication required for all operations
- Data isolation per user (users can only access their own data)
- Data validation for all document fields
- Version-based conflict detection

#### Firebase Project Setup
1. Create a Firebase project at https://console.firebase.google.com
2. Enable Authentication (Email/Password)
3. Enable Firestore Database
4. Add your Flutter app to the Firebase project
5. Download and add configuration files:
   - `android/app/google-services.json` (Android)
   - `ios/Runner/GoogleService-Info.plist` (iOS)

### 2. Dependencies

The following packages are automatically included:
- `cloud_firestore`: Firebase Firestore integration
- `connectivity_plus`: Network connectivity monitoring
- `firebase_auth`: Firebase Authentication

### 3. Initialization

The sync system is automatically initialized when the app starts. No additional setup is required as it's integrated into the dependency injection system.

## Usage Guide

### For Users

#### Sync Indicators
- **Green Cloud Icon**: Data is synced and up-to-date
- **Orange Cloud Icon**: Device is offline, changes will sync when connected
- **Spinning Icon**: Sync in progress
- **Red Icon**: Sync error occurred
- **Number Badge**: Shows pending operations count

#### Manual Sync
- Tap the sync button in the floating action button (when online)
- Pull to refresh on the sync settings page
- Use "Sync Now" button in sync settings

#### Offline Mode
- All operations work normally when offline
- Changes are queued and will sync automatically when connectivity is restored
- Orange banner shows when offline with pending changes
- No data loss occurs during offline periods

### For Developers

#### Adding Sync to New Data Types

1. **Create Firestore Model**
```dart
class YourDataFirestoreModel {
  // Include userId, version, createdAt, updatedAt fields
  // Add toFirestore() and fromFirestore() methods
  // Add conversion methods to/from local models
}
```

2. **Create Remote Data Source**
```dart
class YourDataRemoteDataSource {
  // Implement CRUD operations
  // Add real-time stream methods
  // Include batch operations for sync
}
```

3. **Update Sync Service**
```dart
// Add your data type to SyncDataType enum
// Implement sync operations in SyncService
// Add conflict resolution logic
```

#### Monitoring Sync Status

```dart
// Listen to sync status changes
BlocBuilder<SyncCubit, SyncState>(
  builder: (context, state) {
    if (state is SyncInProgress) {
      return CircularProgressIndicator();
    } else if (state is SyncError) {
      return Text('Sync Error: ${state.message}');
    }
    return SyncIndicator();
  },
);
```

#### Manual Sync Operations

```dart
// Force sync
await context.read<SyncCubit>().forceSync();

// Check sync status
final stats = await context.read<SyncCubit>().getSyncStats();

// Check for pending operations
final hasPending = await context.read<SyncCubit>().hasPendingOperations();
```

## Configuration Options

### Sync Configuration (`lib/core/config/sync_config.dart`)

Key settings you can modify:
- `maxRetryAttempts`: Number of retry attempts for failed operations
- `periodicSyncInterval`: How often to check for sync operations
- `networkTimeout`: Timeout for network requests
- `enableRealTimeSync`: Enable/disable real-time listeners
- `conflictResolutionStrategy`: How to handle conflicts

### Error Handling (`lib/core/utils/sync_error_handler.dart`)

Comprehensive error handling for:
- Firebase Authentication errors
- Firestore operation errors
- Network connectivity issues
- Data validation errors
- Automatic retry logic with exponential backoff

## Troubleshooting

### Common Issues

#### 1. Sync Not Working
**Symptoms**: Changes not appearing on other devices
**Solutions**:
- Check internet connectivity
- Verify Firebase configuration
- Check Firestore security rules
- Review app logs for error messages

#### 2. Authentication Issues
**Symptoms**: "Permission denied" errors
**Solutions**:
- Ensure user is properly authenticated
- Check Firebase Auth configuration
- Verify Firestore security rules allow user access

#### 3. Offline Data Not Syncing
**Symptoms**: Changes made offline don't sync when back online
**Solutions**:
- Check sync settings page for pending operations
- Force manual sync
- Restart the app
- Check for error messages in sync status

#### 4. Conflict Resolution Issues
**Symptoms**: Data inconsistencies between devices
**Solutions**:
- Check version numbers in Firestore documents
- Review conflict resolution strategy
- Manually resolve conflicts if needed

### Debug Information

#### Sync Statistics
Access detailed sync information:
1. Go to Profile → Sync Settings
2. View current sync status
3. Check pending operations count
4. Review last sync time

#### Logs
Enable verbose logging in `SyncConfig`:
```dart
static const bool enableVerboseLogging = true;
static const SyncLogLevel logLevel = SyncLogLevel.verbose;
```

## Performance Considerations

### Optimization Tips

1. **Batch Operations**: Large data sets are automatically batched
2. **Incremental Sync**: Only changed data is synchronized
3. **Connection-Aware Sync**: Sync frequency adapts to connection type
4. **Background Processing**: Sync operations don't block UI

### Monitoring

- Track sync performance through the sync settings page
- Monitor pending operations count
- Review error rates and retry attempts
- Check network usage patterns

## Security

### Data Protection
- All data is encrypted in transit (HTTPS/TLS)
- Firestore security rules prevent unauthorized access
- User data is completely isolated
- Local data is cleared on logout

### Privacy
- No data is shared between users
- All operations require authentication
- Audit trail through Firestore timestamps
- Compliance with data protection regulations

## Maintenance

### Regular Tasks
1. Monitor Firestore usage and costs
2. Review security rules periodically
3. Update dependencies regularly
4. Monitor error rates and performance

### Updates
When updating the sync system:
1. Test thoroughly in development
2. Consider data migration needs
3. Update Firestore security rules if needed
4. Communicate changes to users

## Support

For technical support or questions about the sync system:
1. Check this documentation first
2. Review the troubleshooting section
3. Check application logs
4. Contact the development team with specific error messages and steps to reproduce

## Quick Start Guide

### For New Developers

1. **Clone and Setup**
```bash
git clone <repository-url>
cd Money-Tracker
flutter pub get
```

2. **Firebase Setup**
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase in project
firebase init firestore

# Deploy security rules
firebase deploy --only firestore:rules
```

3. **Run the App**
```bash
flutter run
```

4. **Test Sync Functionality**
- Create an account and sign in
- Add some transactions
- Check sync status in Profile → Sync Settings
- Test offline mode by turning off internet
- Verify data syncs when reconnected

### Key Files to Understand

- `lib/core/services/sync_service.dart` - Main sync logic
- `lib/core/presentation/bloc/sync_cubit.dart` - UI state management
- `lib/data/models/firestore/` - Cloud data models
- `lib/core/config/sync_config.dart` - Configuration settings
- `firestore.rules` - Database security rules

---

**Last Updated**: December 2024
**Version**: 1.0.0
**Compatibility**: Flutter 3.0+, Firebase 10.0+
