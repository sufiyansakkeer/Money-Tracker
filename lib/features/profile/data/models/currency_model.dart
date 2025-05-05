import 'package:hive/hive.dart';
import 'package:money_track/features/profile/domain/entities/currency_entity.dart';

part 'currency_model.g.dart';

@HiveType(typeId: 5)
class CurrencyModel {
  @HiveField(0)
  final String code;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String symbol;
  
  @HiveField(3)
  final double conversionRate;

  CurrencyModel({
    required this.code,
    required this.name,
    required this.symbol,
    required this.conversionRate,
  });

  /// Convert from domain entity to data model
  factory CurrencyModel.fromEntity(CurrencyEntity entity) {
    return CurrencyModel(
      code: entity.code,
      name: entity.name,
      symbol: entity.symbol,
      conversionRate: entity.conversionRate,
    );
  }

  /// Convert from data model to domain entity
  CurrencyEntity toEntity() {
    return CurrencyEntity(
      code: code,
      name: name,
      symbol: symbol,
      conversionRate: conversionRate,
    );
  }
}
