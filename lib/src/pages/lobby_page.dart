// ignore_for_file: invalid_return_type_for_catch_error

import 'dart:async';

import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wiki_race/src/widgets/qr_code.dart';
import 'package:wiki_race/src/widgets/shape_background.dart';
import '../../main.dart';
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
  StreamSubscription? _sub;
  @override
  void initState() {
    super.initState();

    _sub = database
        .collection("sessions")
        .doc(widget.gameCode)
        .snapshots()
        .map((event) => Game.fromJson(event.data()!))
        .listen((event) {
      if (_game == null) {
        setState(() => _game = event);
      }
      if (event.hasStarted) {
        context.beamToNamed("/session/${widget.gameCode}/play", data: _game);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _sub?.cancel();
  }

  bool get isOwner {
    if (_game == null) return false;
    return _game!.owner == auth.currentUser!.uid;
  }

  Stream<List<Player>> get _playersStream {
    return database
        .collection("sessions")
        .doc(widget.gameCode)
        .collection("players")
        .snapshots()
        .map((event) => [for (var p in event.docs) Player.fromJson(p.data())]);
  }

  void _kickPlayer(Player player) async {
    await database
        .collection("sessions")
        .doc(widget.gameCode)
        .collection("players")
        .doc(player.uid)
        .delete();
  }

  void _start() {
    if (isOwner) {
      database.collection("sessions").doc(widget.gameCode).update({
        "hasStarted": true,
      });
    }
  }

  Widget _buildPlayers(BuildContext context) {
    return StreamBuilder<List<Player>>(
      stream: _playersStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Container();
        return Wrap(
          alignment: WrapAlignment.center,
          direction: Axis.horizontal,
          children: [
            for (var p in snapshot.data!)
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Chip(
                  labelStyle: const TextStyle(fontSize: 24),
                  label: Text(p.name),
                  deleteIcon: const Icon(Icons.cancel_outlined),
                  onDeleted: isOwner && p.uid != auth.currentUser!.uid
                      ? () => _kickPlayer(p)
                      : null,
                  avatar: ClipOval(
                    child: DiceBearAvatar(
                      type: DiceBearAvatarType.identicon,
                      seed: p.name,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ignore: prefer_const_constructors
          Text(
            "Game Code: ${widget.gameCode.toUpperCase()}",
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(width: 20),
          QrCodeWidget(
            data: "https://wiki-race-ae773.web.app/session/${widget.gameCode}/",
            height: 120,
            width: 120,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ShapeBackground(
        children: [
          Column(
            children: [
              _buildHeader(context),
              Center(
                child: Container(
                  child: _buildPlayers(context),
                  constraints: const BoxConstraints(
                    maxWidth: 500,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
      floatingActionButton: isOwner
          ? FloatingActionButton.extended(
              onPressed: _start,
              label: const Text("Start"),
            )
          : null,
    );
  }
}
