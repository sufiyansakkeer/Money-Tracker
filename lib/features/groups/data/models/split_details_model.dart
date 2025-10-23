import 'package:hive_ce/hive.dart';
import 'package:money_track/features/groups/domain/entities/split_details.dart'
    as domain;

part 'split_details_model.g.dart';

@HiveType(typeId: 9)
class SplitDetailsModel extends HiveObject {
  @HiveField(0)
  final String transactionId;

  @HiveField(1)
  final String payerMemberId;

  @HiveField(2)
  final domain.SplitType splitType;

  @HiveField(3)
  final Map<String, double> splitData;

  @HiveField(4)
  final Map<String, double>? sharesData;

  @HiveField(5)
  final String? notes;

  @HiveField(6)
  final DateTime? createdAt;

  @HiveField(7)
  final DateTime? updatedAt;

  @HiveField(8)
  final String? createdBy;

  @HiveField(9)
  final Map<String, dynamic>? metadata;

  SplitDetailsModel({
    required this.transactionId,
    required this.payerMemberId,
    required this.splitType,
    required this.splitData,
    this.sharesData,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.metadata,
  });

  /// Convert from domain entity to data model
  factory SplitDetailsModel.fromEntity(domain.SplitDetails entity) {
    return SplitDetailsModel(
      transactionId: entity.transactionId,
      payerMemberId: entity.payerMemberId,
      splitType: entity.splitType,
      splitData: entity.splitData,
      sharesData: entity.sharesData,
      notes: entity.notes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      createdBy: entity.createdBy,
      metadata: entity.metadata,
    );
  }

  /// Convert from data model to domain entity
  domain.SplitDetails toEntity() {
    return domain.SplitDetails(
      transactionId: transactionId,
      payerMemberId: payerMemberId,
      splitType: splitType,
      splitData: splitData,
      sharesData: sharesData,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: createdBy,
      metadata: metadata,
    );
  }
}
