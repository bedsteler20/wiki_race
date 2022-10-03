import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


extension BuildContextExt on BuildContext {
  double get height => MediaQuery.of(this).size.height;
  double get width => MediaQuery.of(this).size.height;

  void displayError(String message) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(
      content: Text(
        "Error: $message",
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.red,
    ));
  }

  User get user => FirebaseAuth.instance.currentUser!;
}
