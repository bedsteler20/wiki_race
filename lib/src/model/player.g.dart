// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Player _$PlayerFromJson(Map<String, dynamic> json) => Player(
      name: json['name'] as String,
      uid: json['uid'] as String,
      hasWon: json['hasWon'] as bool? ?? false,
    );

Map<String, dynamic> _$PlayerToJson(Player instance) => <String, dynamic>{
      'name': instance.name,
      'uid': instance.uid,
      'hasWon': instance.hasWon,
    };
