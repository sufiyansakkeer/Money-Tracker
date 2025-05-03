import 'package:equatable/equatable.dart';

class RiveEntity extends Equatable {
  final String src, artBoard, stateMachineName;

  const RiveEntity({
    required this.src,
    required this.artBoard,
    required this.stateMachineName,
  });
  
  @override
  List<Object?> get props => [src, artBoard, stateMachineName];
}
