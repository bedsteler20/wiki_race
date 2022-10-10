import 'dart:async';

import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wiki_race/src/providers/wikipedia_api.dart';
import 'package:wiki_race/src/widgets/create_game_dialog.dart';

import '../../main.dart';
import '../model/game.dart';
import '../model/player.dart';
import '../widgets/wiki_image.dart';

class WinPage extends StatefulWidget {
  const WinPage({super.key, required this.gameCode, this.game});

  final String gameCode;
  final Game? game;

  @override
  State<WinPage> createState() => _WinPageState();
}

class _WinPageState extends State<WinPage> {
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _sub = database
        .collection("sessions")
        .doc(widget.gameCode)
        .snapshots()
        .listen((event) {
      final game = Game.fromJson(event.data()!);
      if (!game.hasStarted) {
        
        context.beamToNamed("/session/${widget.gameCode}/lobby");
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<Player> _future() async {
    final data = await database
        .collection("sessions")
        .doc(widget.gameCode)
        .collection("players")
        .where("hasWon", isEqualTo: true)
        .get();

    return Player.fromJson(data.docs.first.data());
  }

  Future<Game> _getGame(String gameCode) async {
    if (widget.game != null) return widget.game!;
    final data = await database.collection("sessions").doc(gameCode).get();
    return Game.fromJson(data.data()!);
  }

  Stream<List<WikiSummery>> _getHistory(BuildContext context) async* {
    final res = <WikiSummery>[];
    final data = await database
        .collection("sessions")
        .doc(widget.gameCode)
        .collection("players")
        .doc(auth.currentUser!.uid)
        .collection("history")
        .get();

    data.docs.sort((a, b) {
      Timestamp aTime = a["timestamp"];
      Timestamp bTime = b["timestamp"];
      return aTime.compareTo(bTime);
    });

    for (var e in data.docs) {
      res.add(await wikipedia.getPage(e["title"]));
      yield res;
    }
  }

  Widget _buildHistory(BuildContext context) {
    return StreamBuilder(
      stream: _getHistory(context),
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          if (snapshot.hasError) {
            throw snapshot.error!;
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return ListView(
            children: [
              for (var e in snapshot.data!)
                ListTile(
                  leading: WikiImage(
                    height: 120,
                    width: 120,
                    url: e.image,
                  ),
                  title: Text(e.title),
                  subtitle: Text(e.extract ?? ""),
                ),
            ],
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Game>(
        future: _getGame(widget.gameCode),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          final game = snapshot.data!;
          return FutureBuilder<Player>(
            future: _future(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Scaffold(
                  appBar: AppBar(
                    title: Text("${snapshot.data!.name} Won"),
                    leading: IconButton(
                      onPressed: () => context.beamToNamed("/"),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    actions: [
                      if (game.owner == auth.currentUser!.uid)
                        IconButton(
                          onPressed: () {
                            CreateGameDialog.show(
                              context,
                              gameCode: widget.gameCode,
                            );
                          },
                          icon: const Icon(Icons.restore),
                        )
                    ],
                  ),
                  body: _buildHistory(context),
                );
              } else {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
            },
          );
        });
  }
}
