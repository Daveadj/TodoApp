import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/add_todo.dart';
import 'package:todo_app/db_handler.dart';
import 'package:timezone/timezone.dart' as tz;

import 'package:todo_app/todo.dart';
import 'package:todo_app/main.dart';

class DatabaseNotifier extends StateNotifier<List<Todo>> {
  final DbHandler _dbHandler = DbHandler();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  DatabaseNotifier(this._flutterLocalNotificationsPlugin) : super([]);

  Future<void> fetchData() async {
    final data = await _dbHandler.getDataList();
    state = data;
  }

  Future<void> addData(
      String title, String desc, String date, String time) async {
    final newdata = Todo(title: title, desc: desc, date: date, time: time);
    final db = await _dbHandler.getDatabase();
    await db.insert('todo_list', {
      'id': newdata.id,
      'title': newdata.title,
      'description': newdata.desc,
      'date': newdata.date,
      'time': newdata.time,
    });
    final now = tz.TZDateTime.now(tz.local);
    final dateTimeString = '${newdata.date} ${newdata.time}';
    final dateFormat = DateFormat('M/d/y h:mm a');
    final parsedDateTime = dateFormat.parse(dateTimeString);

    if (parsedDateTime.isAfter(now)) {
      final remainderDateTime = tz.TZDateTime.from(parsedDateTime, tz.local);
      scheduleFutureReminder(newdata.title!, newdata.desc!, remainderDateTime);
    } else {
      final currentTime = TimeOfDay.now();
      TimeOfDay timeOfDayFromString(String formattedTime) {
        final parts = formattedTime.split(' ');
        final time = parts[0];
        final isPM = parts[1].toLowerCase() == 'pm';

        final timeParts = time.split(':');
        var hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);

        // Convert 12-hour format to 24-hour format if it's PM
        if (isPM && hour != 12) {
          hour += 12;
        } else if (!isPM && hour == 12) {
          hour = 0; // Midnight
        }

        return TimeOfDay(hour: hour, minute: minute);
      }

      final selectedTime = timeOfDayFromString(newdata.time!);

      if (newdata.date == formatter.format(DateTime.now()) &&
          currentTime.hour == selectedTime.hour &&
          currentTime.minute == selectedTime.minute) {
        await _scheduleRemainder(newdata.title!, newdata.desc!);
      }
    }

    state = [newdata, ...state];
  }

  Future<void> scheduleFutureReminder(
      String title, String description, tz.TZDateTime futureTime) async {
    int insistentFlag = 4;

    final Int64List vibrationPattern = Int64List(4);
    vibrationPattern[0] = 0;
    vibrationPattern[1] = 4000;
    vibrationPattern[2] = 4000;
    vibrationPattern[3] = 4000;
    final currentTime = tz.TZDateTime.now(tz.local);
    // ignore: unused_local_variable
    final timeDifference = futureTime.difference(currentTime);

    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'Remaind_id2',
      'Remind Channel2',
      channelDescription: 'Channel for Remind',
      importance: Importance.max,
      priority: Priority.high,
      additionalFlags: Int32List.fromList(<int>[insistentFlag]),
      audioAttributesUsage: AudioAttributesUsage.alarm,
      sound: const RawResourceAndroidNotificationSound('pop'),
      vibrationPattern: vibrationPattern,
    );
    final NotificationDetails platformChannelSpecifics =
        // ignore: prefer_const_constructors
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      title,
      description,
      futureTime.add(const Duration(seconds: 2)),
      platformChannelSpecifics,
      // ignore: deprecated_member_use
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> _scheduleRemainder(String title, String description) async {
    int insistentFlag = 4;

    final Int64List vibrationPattern = Int64List(4);
    vibrationPattern[0] = 0;
    vibrationPattern[1] = 4000;
    vibrationPattern[2] = 4000;
    vibrationPattern[3] = 4000;
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'remainder_channel_id10',
      'Remainder Channel10',
      channelDescription: 'Channel for remainders',
      importance: Importance.max,
      priority: Priority.high,
      additionalFlags: Int32List.fromList(<int>[insistentFlag]),
      audioAttributesUsage: AudioAttributesUsage.alarm,
      sound: const RawResourceAndroidNotificationSound('pop'),
      vibrationPattern: vibrationPattern,
    );

    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
        0, title, description, platformChannelSpecifics);
  }

  Future<void> deleteData(String id) async {
    state = state.where((todo) => todo.id != id).toList();
    await _dbHandler.deleteData(id);
  }
}

final flutterLocalNotificationsPluginProvider =
    Provider<FlutterLocalNotificationsPlugin>((ref) {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // // Initialize the plugin.
  // flutterLocalNotificationsPlugin.initialize(
  //   const InitializationSettings(),
  // );

  return flutterLocalNotificationsPlugin;
});

final databaseNotifierProvider =
    StateNotifierProvider<DatabaseNotifier, List<Todo>>(
  (ref) => DatabaseNotifier(ref.read(flutterLocalNotificationsPluginProvider)),
);
