// ignore_for_file: use_build_context_synchronously

import 'dart:math';

import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../helpers/core.dart';
import '../helpers/flutter.dart';
import '../helpers/math.dart';
import '../model/game.dart';
import '../model/player.dart';
import '../providers/wikipedia_api.dart';
import 'wiki_search_box.dart';

class CreateGameDialog extends StatefulWidget {
  const CreateGameDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: ((context) => const CreateGameDialog()),
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

  void _create() async {
    //if (!_formKey.currentState!.validate()) return;

    if (_endPageController.text.isEmpty ||
        !(await wikipedia.dosePageExist(_endPageController.text))) {
      context.displayError("Invalid End Page");
    } else if (_startPageController.text.isEmpty ||
        !(await wikipedia.dosePageExist(_startPageController.text))) {
      context.displayError("Invalid Start Page");
    } else {
      final gameCode = Random().string(8);
      final game = Game(
        startPage: _startPageController.text,
        endPage: _endPageController.text,
        owner: context.user.uid,
      );
      final player = Player(
        name: _nicknameController.text,
        uid: context.user.uid,
      );

      await FirebaseFirestore.instance
          .collection("sessions")
          .doc(gameCode)
          .set(game.toJson()..timestamp());

      await FirebaseFirestore.instance
          .collection("sessions")
          .doc(gameCode)
          .collection("players")
          .doc(context.user.uid)
          .set(player.toJson());

      context.beamToNamed("/session/$gameCode/lobby", data: game);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: SimpleDialog(
        title: const Text("Create Game"),
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
          TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter a nickname";
              }
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
                onPressed: _create,
                child: const Text("Create"),
              ),
            ],
          )
        ],
      ),
    );
  }
}
