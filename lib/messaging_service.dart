import 'package:firebase_messaging/firebase_messaging.dart';

class MessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  String? _token;
  String? get token => _token;

  Future init() async {
    final settings = await _requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      await _getToken();
      await _firebaseMessaging.subscribeToTopic('TLDR');
    }
  }

  Future _getToken() async {
    _token = await _firebaseMessaging.getToken();

    print("FCM: $_token");

    _firebaseMessaging.onTokenRefresh.listen((token) {
      _token = token;
    });
  }

  Future<NotificationSettings> _requestPermission() async {
    return await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        announcement: false);
  }
}
