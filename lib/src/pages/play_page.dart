import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wiki_race/src/helpers/core.dart';
import 'package:wiki_race/src/helpers/flutter.dart';
import 'package:wiki_race/src/widgets/wikiframe.dart';
import 'package:wiki_race/src/widgets/win_dialog.dart';

import '../model/game.dart';
import '../model/player.dart';

class PlayPage extends StatefulWidget {
  const PlayPage({
    super.key,
    required this.gameCode,
    this.game,
  });

  final String gameCode;
  final Game? game;
  @override
  State<PlayPage> createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> {
  StreamSubscription? _playersSub;
  late Game? _game = widget.game;

  @override
  void initState() {
    super.initState();
    if (_game == null) {
      FirebaseFirestore.instance
          .collection("sessions")
          .doc(widget.gameCode)
          .get()
          .then(
              (value) => setState(() => _game = Game.fromJson(value.data()!)));
    }
    _playersSub = FirebaseFirestore.instance
        .collection("sessions")
        .doc(widget.gameCode)
        .collection("players")
        .where("hasWon", isEqualTo: true)
        .snapshots()
        .listen((event) {
      for (var doc in event.docChanges) {
        final player = Player.fromJson(doc.doc.data()!);
        if (player.hasWon) {
          if (player.uid == context.user.uid) {
            WinDialog.show(context, "You Won");
          } else {
            WinDialog.show(context, "${player.name} Won");
          }
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _playersSub?.cancel();
  }

  void _onPageChange(String page1) async {
    var page = page1.replaceAll("_", " ");
    FirebaseFirestore.instance
        .collection("sessions")
        .doc(widget.gameCode)
        .collection("players")
        .doc(context.user.uid)
        .collection("history")
        .doc()
        .set({
          "title": page,
        }..timestamp());
    if (page == _game!.endPage) {
      FirebaseFirestore.instance
          .collection("sessions")
          .doc(widget.gameCode)
          .collection("players")
          .doc(context.user.uid)
          .update({"hasWon": true});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_game == null) {
      return Container();
    }
    return WikiFrame(
      onPageChange: _onPageChange,
      startPage: _game!.startPage,
    );
  }
}
