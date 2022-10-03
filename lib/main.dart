import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'src/model/game.dart';
import 'src/pages/home_page.dart';
import 'src/pages/lobby_page.dart';

void main() async {
  // GoogleFonts.config.allowRuntimeFetching = kDebugMode;
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseFirestore.instance.useFirestoreEmulator("localhost", 8080);

  try {
    await FirebaseAuth.instance.signInAnonymously();
    print("Signed in with temporary account.");
    print("Account Id: ${FirebaseAuth.instance.currentUser?.uid}");
  } on FirebaseAuthException catch (e) {
    switch (e.code) {
      case "operation-not-allowed":
        print("Anonymous auth hasn't been enabled for this project.");
        break;
      default:
        print("Unknown error.");
    }
  }

  print("Runnig Main");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key}) {
    print("App Constructed");
  }
  final routerDelegate = BeamerDelegate(
    locationBuilder: RoutesLocationBuilder(
      routes: {
        "/": (context, state, data) => const HomePage(),
        "/session/:gameCode/lobby": (context, state, data) => LobbyPage(
              game: data as Game?,
              gameCode: state.pathParameters["gameCode"]!,
            ),
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    print("App Build");
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(
        useMaterial3: true,
      ),
      themeMode: ThemeMode.dark,
      routerDelegate: routerDelegate,
      routeInformationParser: BeamerParser(),
      backButtonDispatcher:
          BeamerBackButtonDispatcher(delegate: routerDelegate),
    );
  }
}
