// ignore_for_file: use_build_context_synchronously

import 'dart:math';

import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../main.dart';
import '../helpers/core.dart';
import '../helpers/flutter.dart';
import '../helpers/math.dart';
import '../model/game.dart';
import '../model/player.dart';
import '../providers/wikipedia_api.dart';
import 'wiki_search_box.dart';

class CreateGameDialog extends StatefulWidget {
  const CreateGameDialog({
    super.key,
    required this.gameCode,
    required this.isReset,
  });
  final String gameCode;
  final bool isReset;
  static void show(BuildContext context, {String? gameCode}) {
    showDialog(
      context: context,
      builder: (context) => CreateGameDialog(
        gameCode: gameCode ?? Random().string(8),
        isReset: gameCode != null,
      ),
    );
  }

  @override
  State<CreateGameDialog> createState() => _CreateGameDialogState();
}

class _CreateGameDialogState extends State<CreateGameDialog> {
  final _startPageController = TextEditingController();
  final _endPageController = TextEditingController();
  final _nicknameController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _startPageController.dispose();
    _endPageController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<bool> _validate() async {
    if (_endPageController.text.isEmpty) return false;
    if (_startPageController.text.isEmpty) return false;

    if (!(await wikipedia.dosePageExist(_endPageController.text))) {
      context.displayError("Invalid End Page");
      return false;
    }

    if (!(await wikipedia.dosePageExist(_startPageController.text))) {
      context.displayError("Invalid Start Page");
      return false;
    }
    return true;
  }

  void _create() async {
    if (!(await _validate())) return;
    if (!_formKey.currentState!.validate()) return;

    final game = Game(
      startPage: _startPageController.text,
      endPage: _endPageController.text,
      owner: auth.currentUser!.uid,
    );
    final player = Player(
      name: _nicknameController.text,
      uid: auth.currentUser!.uid,
    );

    await database
        .collection("sessions")
        .doc(widget.gameCode)
        .set(game.toJson()..timestamp());

    await database
        .collection("sessions")
        .doc(widget.gameCode)
        .collection("players")
        .doc(auth.currentUser!.uid)
        .set(player.toJson());

    context.beamToNamed("/session/${widget.gameCode}/play");
  }

  void _reset() async {
    if (!(await _validate())) return;

    final winner = await database
        .collection("sessions")
        .doc(widget.gameCode)
        .collection("players")
        .get();

    for (var elem in winner.docs) {
      final player = Player.fromJson(elem.data());
      player.hasWon = false;
      await database
          .collection("sessions")
          .doc(widget.gameCode)
          .collection("players")
          .doc(player.uid)
          .set(player.toJson());
      final history = await database
          .collection("sessions")
          .doc(widget.gameCode)
          .collection("players")
          .doc(player.uid)
          .collection("history")
          .get();

      for (var e in history.docs) {
        await database
            .collection("sessions")
            .doc(widget.gameCode)
            .collection("players")
            .doc(player.uid)
            .collection("history")
            .doc(e.id)
            .delete();
      }
    }

    await database.collection("sessions").doc(widget.gameCode).update({
      "hasStarted": false,
      "startPage": _startPageController.text,
      "endPage": _endPageController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SimpleDialog(
        title: Text(widget.isReset ? "Reset" : "Create Game"),
        contentPadding: const EdgeInsets.all(20),
        children: [
          WikiSearchBox(
            label: "Start Page",
            controller: _startPageController,
          ),
          WikiSearchBox(
            label: "End Page",
            controller: _endPageController,
          ),
          if (!widget.isReset)
            TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter a nickname";
                }
                return null;
              },
              controller: _nicknameController,
              decoration: const InputDecoration(
                labelText: "Nickname",
                filled: true,
                border: OutlineInputBorder(
                  gapPadding: 10,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
          const SizedBox(
            height: 80,
            width: 200,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: widget.isReset ? _reset : _create,
                child: Text(widget.isReset ? "Reset" : "Create"),
              ),
            ],
          )
        ],
      ),
    );
  }
}
