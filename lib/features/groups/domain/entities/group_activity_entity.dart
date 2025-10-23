import 'package:equatable/equatable.dart';

/// Activity type enumeration for group activities
enum GroupActivityType {
  expenseAdded,
  expenseUpdated,
  expenseDeleted,
  settlementAdded,
  settlementConfirmed,
  settlementCancelled,
  memberAdded,
  memberRemoved,
  groupUpdated,
}

/// Group activity entity for tracking all activities in a group
class GroupActivityEntity extends Equatable {
  final String id;
  final String groupId;
  final GroupActivityType type;
  final String actorId; // Member who performed the action
  final String actorName;
  final String title; // Activity title
  final String description; // Detailed description
  final DateTime timestamp;
  final Map<String, dynamic>? metadata; // Additional activity data
  final String? relatedEntityId; // ID of related expense, settlement, etc.
  final double? amount; // Amount involved in the activity
  final String? currency;

  const GroupActivityEntity({
    required this.id,
    required this.groupId,
    required this.type,
    required this.actorId,
    required this.actorName,
    required this.title,
    required this.description,
    required this.timestamp,
    this.metadata,
    this.relatedEntityId,
    this.amount,
    this.currency,
  });

  @override
  List<Object?> get props => [
        id,
        groupId,
        type,
        actorId,
        actorName,
        title,
        description,
        timestamp,
        metadata,
        relatedEntityId,
        amount,
        currency,
      ];

  GroupActivityEntity copyWith({
    String? id,
    String? groupId,
    GroupActivityType? type,
    String? actorId,
    String? actorName,
    String? title,
    String? description,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
    String? relatedEntityId,
    double? amount,
    String? currency,
  }) {
    return GroupActivityEntity(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      type: type ?? this.type,
      actorId: actorId ?? this.actorId,
      actorName: actorName ?? this.actorName,
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
      relatedEntityId: relatedEntityId ?? this.relatedEntityId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
    );
  }

  /// Get activity type display name
  String get typeDisplayName {
    switch (type) {
      case GroupActivityType.expenseAdded:
        return 'Expense Added';
      case GroupActivityType.expenseUpdated:
        return 'Expense Updated';
      case GroupActivityType.expenseDeleted:
        return 'Expense Deleted';
      case GroupActivityType.settlementAdded:
        return 'Payment Recorded';
      case GroupActivityType.settlementConfirmed:
        return 'Payment Confirmed';
      case GroupActivityType.settlementCancelled:
        return 'Payment Cancelled';
      case GroupActivityType.memberAdded:
        return 'Member Added';
      case GroupActivityType.memberRemoved:
        return 'Member Removed';
      case GroupActivityType.groupUpdated:
        return 'Group Updated';
    }
  }

  /// Get activity icon based on type
  String get iconName {
    switch (type) {
      case GroupActivityType.expenseAdded:
        return 'add_circle';
      case GroupActivityType.expenseUpdated:
        return 'edit';
      case GroupActivityType.expenseDeleted:
        return 'delete';
      case GroupActivityType.settlementAdded:
        return 'payment';
      case GroupActivityType.settlementConfirmed:
        return 'check_circle';
      case GroupActivityType.settlementCancelled:
        return 'cancel';
      case GroupActivityType.memberAdded:
        return 'person_add';
      case GroupActivityType.memberRemoved:
        return 'person_remove';
      case GroupActivityType.groupUpdated:
        return 'settings';
    }
  }

  /// Whether this activity involves money
  bool get involvesAmount => amount != null && amount! > 0;

  /// Get formatted amount string
  String get formattedAmount {
    if (!involvesAmount) return '';
    return '$amount $currency';
  }

  /// Get relative time description (e.g., "2 hours ago")
  String getRelativeTime() {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  /// Create activity for expense added
  static GroupActivityEntity expenseAdded({
    required String id,
    required String groupId,
    required String actorId,
    required String actorName,
    required String expenseTitle,
    required double amount,
    required String currency,
    required String expenseId,
  }) {
    return GroupActivityEntity(
      id: id,
      groupId: groupId,
      type: GroupActivityType.expenseAdded,
      actorId: actorId,
      actorName: actorName,
      title: 'Added expense "$expenseTitle"',
      description:
          '$actorName added a new expense "$expenseTitle" for $amount $currency',
      timestamp: DateTime.now(),
      relatedEntityId: expenseId,
      amount: amount,
      currency: currency,
    );
  }

  /// Create activity for settlement added
  static GroupActivityEntity settlementAdded({
    required String id,
    required String groupId,
    required String actorId,
    required String actorName,
    required String receiverName,
    required double amount,
    required String currency,
    required String settlementId,
  }) {
    return GroupActivityEntity(
      id: id,
      groupId: groupId,
      type: GroupActivityType.settlementAdded,
      actorId: actorId,
      actorName: actorName,
      title: 'Recorded payment to $receiverName',
      description:
          '$actorName recorded a payment of $amount $currency to $receiverName',
      timestamp: DateTime.now(),
      relatedEntityId: settlementId,
      amount: amount,
      currency: currency,
    );
  }

  /// Create activity for expense deleted
  static GroupActivityEntity expenseDeleted({
    required String id,
    required String groupId,
    required String actorId,
    required String actorName,
    required String expenseTitle,
    required double amount,
    required String currency,
    required String expenseId,
  }) {
    return GroupActivityEntity(
      id: id,
      groupId: groupId,
      type: GroupActivityType.expenseDeleted,
      actorId: actorId,
      actorName: actorName,
      title: 'Deleted expense "$expenseTitle"',
      description:
          '$actorName deleted the expense "$expenseTitle" ($amount $currency)',
      timestamp: DateTime.now(),
      relatedEntityId: expenseId,
      amount: amount,
      currency: currency,
    );
  }

  /// Create activity for settlement deleted
  static GroupActivityEntity settlementDeleted({
    required String id,
    required String groupId,
    required String actorId,
    required String actorName,
    required String receiverName,
    required double amount,
    required String currency,
    required String settlementId,
  }) {
    return GroupActivityEntity(
      id: id,
      groupId: groupId,
      type: GroupActivityType
          .expenseDeleted, // Using expenseDeleted as there's no settlementDeleted type
      actorId: actorId,
      actorName: actorName,
      title: 'Deleted payment to $receiverName',
      description:
          '$actorName deleted a payment of $amount $currency to $receiverName',
      timestamp: DateTime.now(),
      relatedEntityId: settlementId,
      amount: amount,
      currency: currency,
    );
  }

  /// Create activity for settlement confirmed
  static GroupActivityEntity settlementConfirmed({
    required String id,
    required String groupId,
    required String actorId,
    required String actorName,
    required String receiverName,
    required double amount,
    required String currency,
    required String settlementId,
  }) {
    return GroupActivityEntity(
      id: id,
      groupId: groupId,
      type: GroupActivityType.settlementConfirmed,
      actorId: actorId,
      actorName: actorName,
      title: 'Confirmed payment to $receiverName',
      description:
          '$actorName confirmed a payment of $amount $currency to $receiverName',
      timestamp: DateTime.now(),
      relatedEntityId: settlementId,
      amount: amount,
      currency: currency,
    );
  }

  /// Create activity for settlement cancelled
  static GroupActivityEntity settlementCancelled({
    required String id,
    required String groupId,
    required String actorId,
    required String actorName,
    required String receiverName,
    required double amount,
    required String currency,
    required String settlementId,
  }) {
    return GroupActivityEntity(
      id: id,
      groupId: groupId,
      type: GroupActivityType.settlementCancelled,
      actorId: actorId,
      actorName: actorName,
      title: 'Cancelled payment to $receiverName',
      description:
          '$actorName cancelled a payment of $amount $currency to $receiverName',
      timestamp: DateTime.now(),
      relatedEntityId: settlementId,
      amount: amount,
      currency: currency,
    );
  }

  /// Create activity for settlement updated
  static GroupActivityEntity settlementUpdated({
    required String id,
    required String groupId,
    required String actorId,
    required String actorName,
    required String receiverName,
    required double amount,
    required String currency,
    required String settlementId,
  }) {
    return GroupActivityEntity(
      id: id,
      groupId: groupId,
      type: GroupActivityType
          .settlementAdded, // Using settlementAdded as there's no settlementUpdated type
      actorId: actorId,
      actorName: actorName,
      title: 'Updated payment to $receiverName',
      description:
          '$actorName updated a payment of $amount $currency to $receiverName',
      timestamp: DateTime.now(),
      relatedEntityId: settlementId,
      amount: amount,
      currency: currency,
    );
  }
}
