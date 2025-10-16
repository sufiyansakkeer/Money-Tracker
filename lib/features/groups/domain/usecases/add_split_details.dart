import 'package:money_track/core/use_cases/use_case.dart';
import 'package:money_track/features/groups/domain/entities/split_details.dart';
import 'package:money_track/features/groups/domain/repositories/split_details_repository.dart';

class AddSplitDetails implements UseCase<void, SplitDetails> {
  final SplitDetailsRepository repository;

  AddSplitDetails(this.repository);

  @override
  Future<void> call({SplitDetails? params}) {
    if (params == null) {
      throw ArgumentError('SplitDetails cannot be null');
    }
    return repository.addSplitDetails(params);
  }
}
