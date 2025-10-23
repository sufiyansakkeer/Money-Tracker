import 'package:hive_ce/hive.dart';
import 'package:money_track/features/groups/domain/entities/group_activity_entity.dart';

part 'group_activity_model.g.dart';

@HiveType(typeId: 18)
enum GroupActivityTypeModel {
  @HiveField(0)
  expenseAdded,
  @HiveField(1)
  expenseUpdated,
  @HiveField(2)
  expenseDeleted,
  @HiveField(3)
  settlementAdded,
  @HiveField(4)
  settlementConfirmed,
  @HiveField(5)
  settlementCancelled,
  @HiveField(6)
  memberAdded,
  @HiveField(7)
  memberRemoved,
  @HiveField(8)
  groupUpdated,
}

@HiveType(typeId: 19)
class GroupActivityModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String groupId;
  @HiveField(2)
  final GroupActivityTypeModel type;
  @HiveField(3)
  final String actorId;
  @HiveField(4)
  final String actorName;
  @HiveField(5)
  final String title;
  @HiveField(6)
  final String description;
  @HiveField(7)
  final DateTime timestamp;
  @HiveField(8)
  final Map<String, dynamic>? metadata;
  @HiveField(9)
  final String? relatedEntityId;
  @HiveField(10)
  final double? amount;
  @HiveField(11)
  final String? currency;

  GroupActivityModel({
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

  factory GroupActivityModel.fromEntity(GroupActivityEntity entity) {
    return GroupActivityModel(
      id: entity.id,
      groupId: entity.groupId,
      type: _mapTypeToModel(entity.type),
      actorId: entity.actorId,
      actorName: entity.actorName,
      title: entity.title,
      description: entity.description,
      timestamp: entity.timestamp,
      metadata: entity.metadata,
      relatedEntityId: entity.relatedEntityId,
      amount: entity.amount,
      currency: entity.currency,
    );
  }

  GroupActivityEntity toEntity() {
    return GroupActivityEntity(
      id: id,
      groupId: groupId,
      type: _mapTypeFromModel(type),
      actorId: actorId,
      actorName: actorName,
      title: title,
      description: description,
      timestamp: timestamp,
      metadata: metadata,
      relatedEntityId: relatedEntityId,
      amount: amount,
      currency: currency,
    );
  }

  static GroupActivityTypeModel _mapTypeToModel(GroupActivityType type) {
    switch (type) {
      case GroupActivityType.expenseAdded:
        return GroupActivityTypeModel.expenseAdded;
      case GroupActivityType.expenseUpdated:
        return GroupActivityTypeModel.expenseUpdated;
      case GroupActivityType.expenseDeleted:
        return GroupActivityTypeModel.expenseDeleted;
      case GroupActivityType.settlementAdded:
        return GroupActivityTypeModel.settlementAdded;
      case GroupActivityType.settlementConfirmed:
        return GroupActivityTypeModel.settlementConfirmed;
      case GroupActivityType.settlementCancelled:
        return GroupActivityTypeModel.settlementCancelled;
      case GroupActivityType.memberAdded:
        return GroupActivityTypeModel.memberAdded;
      case GroupActivityType.memberRemoved:
        return GroupActivityTypeModel.memberRemoved;
      case GroupActivityType.groupUpdated:
        return GroupActivityTypeModel.groupUpdated;
    }
  }

  static GroupActivityType _mapTypeFromModel(GroupActivityTypeModel type) {
    switch (type) {
      case GroupActivityTypeModel.expenseAdded:
        return GroupActivityType.expenseAdded;
      case GroupActivityTypeModel.expenseUpdated:
        return GroupActivityType.expenseUpdated;
      case GroupActivityTypeModel.expenseDeleted:
        return GroupActivityType.expenseDeleted;
      case GroupActivityTypeModel.settlementAdded:
        return GroupActivityType.settlementAdded;
      case GroupActivityTypeModel.settlementConfirmed:
        return GroupActivityType.settlementConfirmed;
      case GroupActivityTypeModel.settlementCancelled:
        return GroupActivityType.settlementCancelled;
      case GroupActivityTypeModel.memberAdded:
        return GroupActivityType.memberAdded;
      case GroupActivityTypeModel.memberRemoved:
        return GroupActivityType.memberRemoved;
      case GroupActivityTypeModel.groupUpdated:
        return GroupActivityType.groupUpdated;
    }
  }
}
