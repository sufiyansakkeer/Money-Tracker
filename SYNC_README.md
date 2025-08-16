# 🔄 Money Tracker Sync System

A production-ready, offline-first data synchronization system for Flutter applications with Firebase Firestore.

## ✨ Features

- 🔄 **Bidirectional Real-time Sync** - Changes sync instantly across all devices
- 📱 **Offline-First** - Full functionality without internet connection
- 🔐 **Secure & Private** - User data isolation with Firebase security rules
- ⚡ **Conflict Resolution** - Automatic handling of simultaneous edits
- 🎯 **Visual Feedback** - Clear sync status indicators and offline notifications
- 🛡️ **Error Handling** - Comprehensive error handling with automatic retries
- 🧪 **Fully Tested** - Unit tests and integration tests included

## 🚀 Quick Start

### 1. Dependencies Added
```yaml
dependencies:
  cloud_firestore: ^4.13.6
  connectivity_plus: ^5.0.2
```

### 2. Firebase Setup
```bash
# Deploy security rules
firebase deploy --only firestore:rules

# Collections created automatically:
# - transactions (user transaction data)
# - categories (user category data)
```

### 3. Usage in UI
```dart
// Add sync indicator to your UI
const SyncIndicator(showText: true)

// Add offline banner
const OfflineBanner()

// Manual sync button
const SyncFloatingActionButton()

// Access sync settings
Navigator.push(context, MaterialPageRoute(
  builder: (context) => const SyncSettingsPage(),
))
```

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   UI Layer      │    │  Business Logic │    │   Data Layer    │
│                 │    │                 │    │                 │
│ SyncIndicator   │◄──►│   SyncCubit     │◄──►│  SyncService    │
│ OfflineBanner   │    │                 │    │                 │
│ SyncSettings    │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                                       │
                       ┌─────────────────┐            │
                       │ ConnectivitySvc │◄───────────┤
                       └─────────────────┘            │
                                                       │
┌─────────────────┐    ┌─────────────────┐            │
│ Local Storage   │    │ Remote Storage  │            │
│                 │    │                 │            │
│ Hive Database   │◄──►│ Firebase        │◄───────────┘
│ Sync Queue      │    │ Firestore       │
│                 │    │                 │
└─────────────────┘    └─────────────────┘
```

## 📁 File Structure

```
lib/
├── core/
│   ├── services/
│   │   ├── sync_service.dart           # Main sync orchestrator
│   │   └── connectivity_service.dart   # Network monitoring
│   ├── presentation/
│   │   ├── bloc/sync_cubit.dart       # Sync state management
│   │   ├── widgets/sync_indicator.dart # UI components
│   │   └── pages/sync_settings_page.dart
│   ├── config/sync_config.dart        # Configuration
│   └── utils/sync_error_handler.dart  # Error handling
├── data/
│   ├── models/
│   │   ├── firestore/                 # Cloud data models
│   │   └── sync/                      # Sync operation models
│   ├── datasources/
│   │   └── remote/                    # Firebase data sources
│   └── repositories/
│       ├── sync_transaction_repository_impl.dart
│       ├── sync_category_repository_impl.dart
│       └── sync_auth_repository_impl.dart
└── test/
    ├── core/services/sync_service_test.dart
    ├── core/presentation/bloc/sync_cubit_test.dart
    └── integration/sync_integration_test.dart

firestore.rules                       # Firebase security rules
```

## 🔧 Configuration

### Sync Settings (`lib/core/config/sync_config.dart`)
```dart
class SyncConfig {
  static const int maxRetryAttempts = 3;
  static const Duration periodicSyncInterval = Duration(minutes: 5);
  static const bool enableRealTimeSync = true;
  static const ConflictResolutionStrategy conflictResolutionStrategy = 
      ConflictResolutionStrategy.lastWriteWins;
}
```

### Error Handling
```dart
// Automatic retry with exponential backoff
await operation.handleSyncError('transaction_sync', maxRetries: 3);

// Custom error handling
try {
  await syncService.forceSyncNow();
} catch (e) {
  final userMessage = SyncErrorHandler.getUserFriendlyMessage(e);
  showSnackBar(userMessage);
}
```

## 🧪 Testing

### Run Tests
```bash
# Unit tests
flutter test test/core/services/sync_service_test.dart
flutter test test/core/presentation/bloc/sync_cubit_test.dart

# Integration tests
flutter test integration_test/sync_integration_test.dart
```

### Test Coverage
- ✅ Sync service initialization and lifecycle
- ✅ Online/offline state transitions
- ✅ Data synchronization flows
- ✅ Error handling and recovery
- ✅ UI state management
- ✅ End-to-end sync scenarios

## 🔐 Security

### Firebase Security Rules
```javascript
// Users can only access their own data
allow read, write: if request.auth != null && 
                   request.auth.uid == resource.data.userId;

// Data validation
allow create: if isValidTransaction(request.resource.data);
```

### Data Privacy
- 🔒 Complete user data isolation
- 🧹 Automatic local data cleanup on logout
- 🔐 Encrypted data transmission (HTTPS/TLS)
- 📝 Audit trail through Firestore timestamps

## 📊 Monitoring

### Sync Statistics
Access via Profile → Sync Settings:
- Connection status
- Pending operations count
- Last sync timestamp
- Error information

### Performance Metrics
- Sync operation latency
- Network usage optimization
- Offline queue efficiency
- Conflict resolution success rate

## 🐛 Troubleshooting

### Common Issues

| Issue | Symptoms | Solution |
|-------|----------|----------|
| Sync not working | Changes not appearing on other devices | Check internet connection, Firebase config |
| Permission denied | Firestore errors | Verify authentication, security rules |
| Offline data stuck | Changes not syncing when online | Force manual sync, check pending operations |
| Conflicts | Data inconsistencies | Review conflict resolution strategy |

### Debug Mode
```dart
// Enable verbose logging
static const bool enableVerboseLogging = true;
static const SyncLogLevel logLevel = SyncLogLevel.verbose;
```

## 🚀 Production Deployment

### Checklist
- [ ] Firebase project configured
- [ ] Security rules deployed
- [ ] Authentication enabled
- [ ] Error monitoring setup
- [ ] Performance monitoring enabled
- [ ] Backup strategy implemented

### Monitoring
- Track Firestore usage and costs
- Monitor error rates
- Review performance metrics
- Update dependencies regularly

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## 📄 License

This sync system is part of the Money Tracker application.

---

**Built with ❤️ using Flutter & Firebase**
