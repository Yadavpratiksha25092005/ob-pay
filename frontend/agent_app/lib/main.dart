import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'auth_screen.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const OBPayAgentApp());
}

class OBPayAgentApp extends StatefulWidget {
  const OBPayAgentApp({super.key});

  @override
  State<OBPayAgentApp> createState() => _OBPayAgentAppState();
}

class _OBPayAgentAppState extends State<OBPayAgentApp> {
  @override
  void initState() {
    super.initState();
    _setupFCM();
  }

  Future<void> _setupFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    String? token = await messaging.getToken();
    print('Agent FCM Token: $token');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Agent foreground message: ${message.notification?.title}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OB Pay Agent',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00897B),
        ),
        useMaterial3: true,
      ),
      home: const AuthScreen(),
    );
  }
}