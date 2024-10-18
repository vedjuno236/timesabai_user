import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseNotification {
   final _firebaseMessaging = FirebaseMessaging.instance;

   Future<void> initNotifitions() async {
      await _firebaseMessaging.requestPermission();

      final fCMToken = await _firebaseMessaging.getToken();

      print("🥴Tokrn:$fCMToken");
   }
}





//
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;
//
// class LocalNotificationService {
//    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//    FlutterLocalNotificationsPlugin();
//
//    Future<void> init() async {
//       // Initialize the timezone database
//       tz.initializeTimeZones();
//
//       const AndroidInitializationSettings initializationSettingsAndroid =
//       AndroidInitializationSettings('@mipmap/ic_launcher');
//
//       const InitializationSettings initializationSettings = InitializationSettings(
//          android: initializationSettingsAndroid,
//       );
//
//       await flutterLocalNotificationsPlugin.initialize(initializationSettings);
//    }
//
//    Future<void> scheduleDailyNotification() async {
//       await flutterLocalNotificationsPlugin.zonedSchedule(
//          0,
//          'Good morning!',
//          'This is your daily 8 AM notification.',
//          _nextInstanceOfEightAMBangkok(),
//          const NotificationDetails(
//             android: AndroidNotificationDetails(
//                'daily_notification_channel_id',
//                'Daily Notifications',
//                channelDescription: 'This channel is used for daily notifications at 8 AM',
//                importance: Importance.high,
//                priority: Priority.high,
//             ),
//          ),
//          androidAllowWhileIdle: true,
//          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
//          matchDateTimeComponents: DateTimeComponents.time,
//       );
//    }
//
//    // This function calculates the next instance of 8 AM in Bangkok time zone
//    tz.TZDateTime _nextInstanceOfEightAMBangkok() {
//       final tz.TZDateTime now = tz.TZDateTime.now(tz.getLocation('Asia/Vientiane'));
//       tz.TZDateTime scheduledDate = tz.TZDateTime(tz.getLocation('Asia/Vientiane'), now.year, now.month, now.day, 11);
//
//       if (scheduledDate.isBefore(now)) {
//          scheduledDate = scheduledDate.add(const Duration(days: 1));
//       }
//       return scheduledDate;
//    }
//
//    // Method to send a test message
//    void sendTestMessage() {
//       print('Send test message');
//    }
// }
