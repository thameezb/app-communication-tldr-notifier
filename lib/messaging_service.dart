import 'package:app_communication_tldr_notifier/database_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_options.dart';

DBService _dbService = DBService();

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

    await _registerHandlers();
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

  Future _registerHandlers() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);

    // Also handle any interaction when the app is in foreground via a
    // Stream listener
    FirebaseMessaging.onMessage.listen(handleMessage);
  }

  void handleMessage(RemoteMessage message) {
    _dbService.refCurrentState.set(message.notification!.body!.split(':')[1]);
  }
}
