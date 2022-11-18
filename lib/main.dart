import 'package:app_communication_tldr_notifier/auth_service.dart';
import 'package:app_communication_tldr_notifier/database_service.dart';
import 'package:app_communication_tldr_notifier/messaging_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

MessagingService _msgService = MessagingService();
DBService _dbService = DBService();
AuthService _authService = AuthService();

String currentState = '';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await _authService.init();
  await _msgService.init();
  _dbService.init();

  runApp(const MyApp());
}

/// Top level function to handle incoming messages when the app is in the background

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Communication ShortCircuit Notifier',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: const MyHomePage(title: 'Communication ShortCircuit Notifier'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<void> handleDBChange() async {
    _dbService.refCurrentState.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as String;
      setState(() {
        currentState = data;
      });
    });
  }

  @override
  void initState() {
    super.initState();

    // Run code required to handle interacted messages in an async function
    // as initState() must not be async
    handleDBChange();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text("Current State: "),
            Text(
              currentState,
              style: Theme.of(context).textTheme.headline4,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
