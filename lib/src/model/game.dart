import 'package:json_annotation/json_annotation.dart';

part 'game.g.dart';

@JsonSerializable()
class Game {
  final String startPage;
  final String endPage;
  final String owner;
  final bool hasStarted;

  Game({
    required this.startPage,
    required this.endPage,
    required this.owner,
    this.hasStarted = false,
  });

  factory Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);

  Map<String, dynamic> toJson() => _$GameToJson(this);
}
