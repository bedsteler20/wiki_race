import 'dart:js';

import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wiki_race/src/helpers/flutter.dart';
import 'package:wiki_race/src/providers/wikipedia_api.dart';

import '../model/player.dart';
import '../widgets/wiki_image.dart';

class WinPage extends StatelessWidget {
  const WinPage({
    super.key,
    required this.gameCode,
  });

  final String gameCode;

  Future<Player> _future() async {
    final data = await FirebaseFirestore.instance
        .collection("sessions")
        .doc(gameCode)
        .collection("players")
        .where("hasWon", isEqualTo: true)
        .get();

    return Player.fromJson(data.docs.first.data());
  }

  Stream<List<WikiSummery>> _getHistory(BuildContext context) async* {
    final res = <WikiSummery>[];
    final data = await FirebaseFirestore.instance
        .collection("sessions")
        .doc(gameCode)
        .collection("players")
        .doc(context.user.uid)
        .collection("history")
        .get();

    data.docs.sort((a, b) => a["timestamp"] < b["timestamp"]);

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
    return FutureBuilder<Player>(
      future: _future(),
      builder: (BuildContext context, AsyncSnapshot<Player> snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: Text("${snapshot.data!.name} Won"),
              leading: IconButton(
                onPressed: () => context.beamToNamed("/"),
                icon: const Icon(Icons.arrow_back),
              ),
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
  }
}
