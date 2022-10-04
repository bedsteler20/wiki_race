// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Game _$GameFromJson(Map<String, dynamic> json) => Game(
      startPage: json['startPage'] as String,
      endPage: json['endPage'] as String,
      owner: json['owner'] as String,
      hasStarted: json['hasStarted'] as bool? ?? false,
    );

Map<String, dynamic> _$GameToJson(Game instance) => <String, dynamic>{
      'startPage': instance.startPage,
      'endPage': instance.endPage,
      'owner': instance.owner,
      'hasStarted': instance.hasStarted,
    };
