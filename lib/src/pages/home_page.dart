// ignore_for_file: use_build_context_synchronously

import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../main.dart';
import '../helpers/flutter.dart';
import '../model/game.dart';
import '../model/player.dart';
import '../widgets/create_game_dialog.dart';
import '../widgets/shape_background.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    this.code,
  });

  final String? code;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ShapeBackground(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "WikiRace",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 250,
                  child: _Form(
                    code: code,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          CreateGameDialog.show(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _Form extends StatefulWidget {
  const _Form({
    super.key,
    this.code,
  });

  final String? code;
  @override
  State<_Form> createState() => __FormState();
}

class __FormState extends State<_Form> {
  final _formKey = GlobalKey<FormState>();
  late String? _code = widget.code?.toLowerCase();
  String? _nickname = "Undefined Username";

  void _join() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      final gameRef = database.collection("sessions").doc(_code!.toLowerCase());
      final data = await gameRef.get();

      if (!data.exists) throw "";

      await gameRef.collection("players").doc(auth.currentUser!.uid).set(Player(
            name: _nickname!,
            uid: auth.currentUser!.uid,
          ).toJson());

      context.beamToNamed(
        "/session/$_code/lobby",
        data: Game.fromJson(data.data()!),
      );
    } catch (e) {
      context.displayError("Could not join game");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).backgroundColor,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: Column(
              children: [
                if (widget.code == null)
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.length != 8) {
                        return 'Invalid Game Code';
                      }
                      return null;
                    },
                    onChanged: ((value) => _code = value.toLowerCase()),
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: "Game Code",
                      filled: true,
                      border: OutlineInputBorder(
                        gapPadding: 10,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                const SizedBox(height: 14),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a nickname';
                    }
                    return null;
                  },
                  onChanged: ((value) => _nickname = value),
                  decoration: const InputDecoration(
                    labelText: "Nickname",
                    filled: true,
                    border: OutlineInputBorder(
                      gapPadding: 10,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: 225,
            height: 50,
            child: ElevatedButton(
              onPressed: _join,
              child: const Text("Join"),
            ),
          ),
        ],
      ),
    );
  }
}
