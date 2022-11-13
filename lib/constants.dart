import 'package:flutter/material.dart';
import 'dart:math';
import 'package:awesome_notifications/awesome_notifications.dart';

const COLOR_BACKGROUND = Color(0xFF121212);
const COLOR_WIDGET_BACKGROUND = Color(0xFF303030);
const COLOR_TEXT_PRIM = Color(0xFFFFFFFF);
const COLOR_TEXT_SEC = Color(0xFFB3B3B3);
const COLOR_TEXT_TER = Color(0xFF757575);
const COLOR_LIGHT = Color(0xFFEE9F27);
String EMAIL_ADDRESS = 'nothing';


String daysOutputText(String daysString) {
  if (daysString == '1111111') return 'daily';
  if (daysString == '0000000') return 'once';

  int days = int.parse(daysString);
  List<String> singleDays = ['Mon.', 'Tue.', 'Wed.', 'Thu.', 'Fri.', 'Sat.', 'Sun.'];
  int counter = 0;
  String daysOutput = '';

  for(int i = 6; i >= (-1); i--) {
    if (days >= pow(10,i)) {
      counter++;
      days = days - pow(10,i) as int;
    }
    else if (counter >= 3) {
      daysOutput = '$daysOutput${singleDays[6-(i+counter)]}-${singleDays[6-(i+1)]} ';
      counter = 0;
    }
    else if (counter == 2) {
      daysOutput = '$daysOutput${singleDays[6-(i+counter)]} ${singleDays[6-(i+1)]} ';
      counter = 0;
    }
    else if (counter == 1) {
      daysOutput = '$daysOutput${singleDays[6-(i+counter)]} ';
      counter = 0;
    }
  }

  return daysOutput;
}


String calculateRemainingTime(int hour, int minute, String schedule) {
  DateTime now = DateTime.now();
  final scheduleList = schedule.split('');
  int difference = 0;
  int increment = now.weekday - 1; //(weekday starts at 1)

  if (schedule == '0000000' || schedule == '1111111' ) {
    if (now.hour.toInt() > hour || (now.hour.toInt() == hour && now.minute.toInt() >= minute)) difference = 1;
  }
  else if ((scheduleList[increment] == '0') || (now.hour.toInt() > hour || (now.hour.toInt() == hour && now.minute.toInt() >= minute))) {
    difference = 1;
    increment>=6 ? increment=0 : increment++;
    while (scheduleList[increment] == '0') {
      difference++;
      increment>=6 ? increment=0 : increment++;
    }
  }

  var timerDay = now.add(Duration(days: difference));
  timerDay = DateTime(timerDay.year, timerDay.month, timerDay.day, hour, minute);

  difference = timerDay.difference(now).inMinutes;
  int day = difference ~/ 1440;
  difference -= 1440 * day;
  hour = difference ~/ 60;
  difference -= 60 * hour;
  minute = difference;

  String result = 'alarm in ';
  if (day >= 1) {result += '${day}d ';}
  if (hour >= 1) {result += '${hour}h ';}
  if (minute >= 1) {result += '${minute}min';}
  if (result == 'alarm in ') {result += 'less than 1min';}
  return result;
}


DateTime timeToNextAlarm (int hour, int minute, String schedule) {
  DateTime now = DateTime.now();
  final scheduleList = schedule.split('');
  int difference = 0;
  int increment = now.weekday - 1; //(weekday starts at 1)

  if (schedule == '0000000' || schedule == '1111111' ) {
    if (now.hour.toInt() > hour || (now.hour.toInt() == hour && now.minute.toInt() >= minute)) difference = 1;
  }
  else if ((scheduleList[increment] == '0') || (now.hour.toInt() > hour || (now.hour.toInt() == hour && now.minute.toInt() >= minute))) {
    difference = 1;
    increment>=6 ? increment=0 : increment++;
    while (scheduleList[increment] == '0') {
      difference++;
      increment>=6 ? increment=0 : increment++;
    }
  }

  var timerDay = now.add(Duration(days: difference));
  return  DateTime(timerDay.year, timerDay.month, timerDay.day, hour, minute, 1);
}


//for that to work: app/build.gradle: changed compileSdkVersion and minSdkVersion
void setAlarm(Map mapData) async {
  String timezone = await AwesomeNotifications().getLocalTimeZoneIdentifier();

  await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: -1,
        channelKey: 'alarms_channel',
        title: 'This is Notification title',
        body: 'This is Body of Notification',
        ticker: 'this is a ticker',
        wakeUpScreen: true,
        fullScreenIntent: true,
        category: NotificationCategory.Alarm,
        //customSound: 'resource://raw/res_security_alarm',
        //customSound: 'String',
        criticalAlert: true,
        displayOnForeground: true,
        displayOnBackground: true,
        //autoDismissible: true,
        //icon: 'alarm',
        color: COLOR_LIGHT,
        backgroundColor: COLOR_BACKGROUND,
        //notificationLayout: NotificationLayout.
      ),
      schedule: NotificationInterval(
        interval: 5,
        timeZone: timezone,
        preciseAlarm: true,
        allowWhileIdle: true,
        //repeats: true,  //time interval must be at least 60 if repeating
      ),
      actionButtons: [
        NotificationActionButton(
          key: "DISMISS",
          label: "dismiss",
          color: COLOR_LIGHT,
        ),
      ],

    /*
      schedule: NotificationCalendar(
        preciseAlarm: true,
        allowWhileIdle: true,
        weekday: 1,
        hour: 1,
        minute: 1,
        timeZone: timezone,
        repeats: true,
      )
     */
  );

/*
  await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: -1,
        channelKey: 'key1',
        title: 'wait 5 seconds to show',
        body: 'now is 5 seconds later',
        wakeUpScreen: true,
        category: NotificationCategory.Alarm,
      ),
      schedule: NotificationInterval(
          interval: 5,
          timeZone: timezone,
          preciseAlarm: true,
      )
  );*/

  /*
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 1,
      channelKey: 'key1',
      title: 'This is Notification title',
      body: 'This is Body of Notification',
      fullScreenIntent: true,
    ),
    //schedule of calendar is probably better
    schedule: NotificationInterval(
      interval: 5,
      timeZone: timezone,
      //repeats: true,  //time interval must be at least 60 if repeating
    )
  );*/

  //if sth different than opening app should happen when notification gets tabbed
  //pass context into method
  /*
  AwesomeNotifications().actionStream.listen((receivedNotification){
    Navigator.of(context).pushNamed()
  });
  */
}


//TODO: needed work
/*
o now AlarmScreen

o get alarm to be:
  x fullScreen when open
  o define fullScreen (play Sound and vibrate)
  o right sound (maybe in release mode)

o create alarm with correct data (several alarms for each weekday? (maybe with same groupkey or same id))
 */

/*difficulties with AwesomeNotification:
  debug is not working coherently. Vibrate and show Screen when locked should work
  also always vibrating
 */


//TODO: possible optical improvements
/*
o also Sat.-Tue. (über list? like calculateRemainingTime)
o Zeitumstellung (wie lösen)
 */