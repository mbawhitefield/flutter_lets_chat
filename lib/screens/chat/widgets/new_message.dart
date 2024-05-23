import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final user = FirebaseAuth.instance.currentUser!;

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _auth = FirebaseAuth.instance;
  User? loggedInUser;

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser;
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('logo');

    const DarwinInitializationSettings iosInitializationSettings =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
      macOS: null,
      linux: null,
    );

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  void _showNotification(
      QueryDocumentSnapshot<Map<String, dynamic>> event) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails("ScheduleNotification001", "Notify Me",
            importance: Importance.high,
            channelDescription: 'To send local notifications');

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
      macOS: null,
      linux: null,
    );

    flutterLocalNotificationsPlugin.show(
        01, event.get('username'), event.get('text'), notificationDetails,
        payload: 'This is the data');
  }

  DateTime dateTime = DateTime.now();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  TextEditingController messageController = TextEditingController();

  void _submitMessage() async {
    final enteredMessage = messageController.text;

    if (enteredMessage.trim().isEmpty) {
      return;
    }

    messageController.clear();
    FocusScope.of(context).unfocus();

    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    FirebaseFirestore.instance.collection('chat').add({
      'text': enteredMessage,
      'createdAt': Timestamp.now(),
      'userID': user.uid,
      'username': userData.data()!['username'],
      'userImage': userData.data()!['image_url'],
    });

    Stream<QuerySnapshot<Map<String, dynamic>>> notificationStream =
        FirebaseFirestore.instance.collection('chat').snapshots();
    notificationStream.listen((event) {
      if (event.docs.isEmpty) {
        return;
      }
     
      _showNotification(event.docs.first);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: messageController,
              textCapitalization: TextCapitalization.sentences,
              enableSuggestions: true,
              decoration: const InputDecoration(
                hintText: 'Send a message...',
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
              ),
            ),
          ),
          IconButton(
              onPressed: _submitMessage,
              icon: Icon(
                Icons.send,
                color: Colors.deepPurple,
              ))
        ],
      ),
    );
  }
}
