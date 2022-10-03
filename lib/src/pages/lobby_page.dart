// ignore_for_file: invalid_return_type_for_catch_error

import 'dart:async';

import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../helpers/flutter.dart';
import '../model/game.dart';
import '../model/player.dart';
import '../widgets/dice_bear.dart';

class LobbyPage extends StatefulWidget {
  const LobbyPage({
    super.key,
    this.game,
    required this.gameCode,
  });
  final String gameCode;
  final Game? game;
  @override
  State<LobbyPage> createState() => _LobbyPageState();
}

class _LobbyPageState extends State<LobbyPage> {
  late Game? _game = widget.game;

  @override
  void initState() {
    super.initState();

    if (_game == null) {
      FirebaseFirestore.instance
          .collection("sessions")
          .doc(widget.gameCode)
          .get()
          .then((value) {
        setState(() {
          _game = Game.fromJson(value.data()!);
        });
      }).catchError((e) => context.displayError(e));
    }
  }

  bool get isOwner {
    if (_game == null) return false;
    return _game!.owner == context.user.uid;
  }

  Stream<List<Player>> get _playersStream {
    return FirebaseFirestore.instance
        .collection("sessions")
        .doc(widget.gameCode)
        .collection("players")
        .snapshots()
        .map((event) {
      return [for (var p in event.docs) Player.fromJson(p.data())];
    });
  }

  void _kickPlayer(Player player) async {
    await FirebaseFirestore.instance
        .collection("sessions")
        .doc(widget.gameCode)
        .collection("players")
        .doc(player.uid)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Player>>(
        stream: _playersStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Container();
          return Wrap(
            alignment: WrapAlignment.center,
            direction: Axis.horizontal,
            children: [
              for (var p in snapshot.data!)
                Chip(
                  labelStyle: const TextStyle(fontSize: 24),
                  label: Text(p.name),
                  deleteIcon: const Icon(Icons.cancel_outlined),
                  onDeleted: isOwner ? () => _kickPlayer(p) : null,
                  avatar: ClipOval(
                    child: DiceBearAvatar(
                      type: DiceBearAvatarType.identicon,
                      seed: p.name,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: isOwner
          ? FloatingActionButton.extended(
              onPressed: () {},
              label: const Text("Start"),
            )
          : null,
    );
  }
}
