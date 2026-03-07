import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import '../../data/models/prayer_time.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tzdata.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    await _plugin.initialize(
      settings: const InitializationSettings(android: androidSettings),
    );
  }

  static Future<void> scheduleAdzan({
    required int id,
    required String prayerName,
    required String time,
  }) async {
    final parts = time.split(':');
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );

    if (scheduledDate.isBefore(now)) return;

    await _plugin.zonedSchedule(
      id: id,
      title: 'Waktu $prayerName',
      body: 'Sudah masuk waktu $prayerName',
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'adzan_channel',
          'Adzan',
          channelDescription: 'Notifikasi waktu sholat',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> scheduleAllPrayers(List<PrayerItem> prayers) async {
    await _plugin.cancelAll();
    for (int i = 0; i < prayers.length; i++) {
      if (prayers[i].name == 'Terbit') continue;
      await scheduleAdzan(
        id: i,
        prayerName: prayers[i].name,
        time: prayers[i].time,
      );
    }
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
