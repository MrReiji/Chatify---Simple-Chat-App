// lib/utils/notification_service.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart'; // Dla inicjalizacji Firebase w tle
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

// Funkcja obsługująca wiadomości w tle musi być funkcją globalną
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Inicjalizacja Firebase w izolacie tła
  await Firebase.initializeApp();

  // Inicjalizacja powiadomień w izolacie tła
  await NotificationService.initializeAwesomeNotifications();

  // Wyświetlanie powiadomienia
  await NotificationService.showNotificationFromDataMessage(message);
}

class NotificationService {
  // Singleton
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Inicjalizacja powiadomień
  Future<void> init() async {
    // Inicjalizacja Awesome Notifications
    await initializeAwesomeNotifications();

    // Upewnienie się, że użytkownik zgodził się na otrzymywanie powiadomień
    await FirebaseMessaging.instance.requestPermission();

    // Rejestracja funkcji obsługującej wiadomości w tle
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Nasłuchiwanie na wiadomości w foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      // Wyświetl powiadomienie za pomocą AwesomeNotifications
      await showNotificationFromDataMessage(message);
    });
  }

  // Statyczna metoda inicjalizacji Awesome Notifications
  static Future<void> initializeAwesomeNotifications() async {
    AwesomeNotifications().initialize(
      null, // Ustawienie na null, ikona zostanie pobrana z NotificationChannel
      [
        NotificationChannel(
          channelKey: 'chat_channel',
          channelName: 'Chat Messages',
          channelDescription: 'Notifications for new chat messages',
          icon: 'resource://mipmap/ic_launcher', // Użycie domyślnej ikony aplikacji
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          defaultColor: Colors.blue,
          ledColor: Colors.white,
          playSound: true,
          defaultRingtoneType: DefaultRingtoneType.Notification,
          enableVibration: true,
          defaultPrivacy: NotificationPrivacy.Private,
        ),
      ],
    );
  }

  // Statyczna metoda wyświetlania powiadomienia z danych wiadomości
static Future<void> showNotificationFromDataMessage(RemoteMessage message) async {
  final data = message.data;
  final title = data['title'] ?? 'Nowa wiadomość';
  final body = data['body'] ?? '';
  final imageUrl = data['image'] ?? '';
  final groupId = data['groupId'] ?? '';
  String? largeIconPath;

  // Logging
  debugPrint('--- showNotificationFromDataMessage ---');
  debugPrint('Title: $title');
  debugPrint('Body: $body');
  debugPrint('Image URL: $imageUrl');
  debugPrint('Group ID: $groupId');

  if (imageUrl.isNotEmpty) {
    Uint8List? imageBytes = await _downloadImage(imageUrl);
    if (imageBytes != null) {
      debugPrint('Image downloaded successfully. Size: ${imageBytes.length} bytes');

      // Save the image to a temporary file
      try {
        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/avatar_${_createUniqueId()}.png';
        final file = File(filePath);
        await file.writeAsBytes(imageBytes);
        largeIconPath = filePath;
        debugPrint('Image saved to temporary file: $largeIconPath');
      } catch (e) {
        debugPrint('Error saving image to file: $e');
      }
    } else {
      debugPrint('Failed to download image.');
    }
  } else {
    debugPrint('Image URL is empty.');
  }

  final notificationContent = NotificationContent(
    id: _createUniqueId(),
    channelKey: 'chat_channel',
    title: title.isNotEmpty ? '$title' : 'Nowa wiadomość',
    body: body,
    notificationLayout: NotificationLayout.Messaging,
    largeIcon: largeIconPath,
    groupKey: groupId,
    payload: {
      'senderName': title,
      'message': body,
      'groupId': groupId,
    },
    roundedLargeIcon: true,
    category: NotificationCategory.Message,
  );

  debugPrint('Creating notification with content: $notificationContent');

  await AwesomeNotifications().createNotification(content: notificationContent);
}

  // Statyczna metoda pobierania obrazu
  static Future<Uint8List?> _downloadImage(String url) async {
  try {
    debugPrint('Attempting to download image from URL: $url');
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      debugPrint('Image downloaded successfully.');
      return response.bodyBytes;
    } else {
      debugPrint('Failed to download image. Status code: ${response.statusCode}');
    }
  } catch (e) {
    debugPrint("Error downloading image: $e");
  }
  return null;
}


  // Statyczna metoda generująca unikalne ID
  static int _createUniqueId() {
    return DateTime.now().millisecondsSinceEpoch.remainder(100000);
  }

  // Metoda do subskrybowania tematu powiadomień
  Future<void> subscribeToTopic(String topic) async {
    await FirebaseMessaging.instance.subscribeToTopic(topic);
    debugPrint('Subscribed to topic: $topic');
  }

  // Metoda do odsubskrybowania tematu powiadomień
  Future<void> unsubscribeFromTopic(String topic) async {
    await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
    debugPrint('Unsubscribed from topic: $topic');
  }

  // Nasłuchiwanie powiadomień w foreground i przekazanie ich dalej
  void foregroundMessageHandler(
      void Function(RemoteNotification notification) onMessage) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        onMessage(message.notification!);
      }
    });
  }
}
