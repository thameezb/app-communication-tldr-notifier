import 'package:firebase_database/firebase_database.dart';

class DBService {
  late final DatabaseReference refCurrentState;

  void init() async {
    refCurrentState = FirebaseDatabase.instance.ref('currentState');
  }
}
