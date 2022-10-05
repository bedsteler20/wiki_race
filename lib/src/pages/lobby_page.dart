// ignore_for_file: invalid_return_type_for_catch_error

import 'dart:async';

import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wiki_race/src/widgets/qr_code.dart';
import 'package:wiki_race/src/widgets/shape_background.dart';
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
  StreamSubscription? _sub;
  @override
  void initState() {
    super.initState();

    _sub = FirebaseFirestore.instance
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
    return _game!.owner == context.user.uid;
  }

  Stream<List<Player>> get _playersStream {
    return FirebaseFirestore.instance
        .collection("sessions")
        .doc(widget.gameCode)
        .collection("players")
        .snapshots()
        .map((event) => [for (var p in event.docs) Player.fromJson(p.data())]);
  }

  void _kickPlayer(Player player) async {
    await FirebaseFirestore.instance
        .collection("sessions")
        .doc(widget.gameCode)
        .collection("players")
        .doc(player.uid)
        .delete();
  }

  void _start() {
    if (isOwner) {
      FirebaseFirestore.instance
          .collection("sessions")
          .doc(widget.gameCode)
          .update({
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
                  onDeleted: isOwner && p.uid != context.user.uid
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
    return Row(
      children: [
        Positioned(
          child: Text(widget.gameCode),
          left: 0,
        ),
        Positioned(
          right: 10,
          child: QrCodeWidget(
            data: "https://wiki-race-ae773.web.app/session/${widget.gameCode}/",
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ShapeBackground(
        children: [
          Center(
            child: _buildPlayers(context),
          ),
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
