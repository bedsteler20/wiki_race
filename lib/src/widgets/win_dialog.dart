import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

class WinDialog extends StatelessWidget {
  const WinDialog({super.key, required this.name});
  final String name;

  static show(BuildContext context, String name) {
    showDialog(
      context: context,
      builder: ((context) => WinDialog(
            name: name,
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Center(
        child: Text(
          name,
        ),
      ),
      children: [
        ElevatedButton(
          onPressed: () => context.beamToNamed("/"),
          child: const Text("Exit"),
        )
      ],
    );
  }
}
