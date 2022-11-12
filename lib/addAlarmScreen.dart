import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:async';
import 'modeAlarm.dart';
import 'constants.dart';


class AddAlarmScreen extends StatefulWidget {
  final Map alarm;
  const  AddAlarmScreen({super.key, required this.alarm});
  @override
  State<AddAlarmScreen> createState() => _AddAlarmScreen();
}


class _AddAlarmScreen extends State<AddAlarmScreen> {
  List<int> hourData = [for (int i = 23; i >= 0; i--) i];
  List<int> minuteData = [for (int i = 59; i >= 0; i--) i];
  List<int> lightData = [for (int i = 30; i >= 0; i = i - 5) i, -1];
  int hourIndex = 0;
  int minuteIndex = 0;
  int lightIndex = 0;
  String title = '';
  String scheduleText = 'once';
  String scheduleData = '0000000';
  int preScheduleData = 0;
  String ringtone = 'alarm';
  bool vibrate = true;
  late TextEditingController titleController;
  late FixedExtentScrollController hourController;
  late FixedExtentScrollController minuteController;
  late FixedExtentScrollController lightController;
  late DateTime now;
  String timeRemainingOutput = 'alarm in 23h 59min';
  Timer periodicTimer = Timer.periodic(const Duration(minutes: 1), (Timer t){});
  late Timer initialTimer;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    hourController = FixedExtentScrollController();
    minuteController = FixedExtentScrollController();
    lightController = FixedExtentScrollController();
    now = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback(initListData);

    var nextMinute = DateTime(now.year, now.month, now.day, now.hour, now.minute + 1);
    initialTimer = Timer(nextMinute.difference(now), () {
      periodicTimer = Timer.periodic(
        const Duration(minutes: 1), (Timer t) {
          setState(() {
            timeRemainingOutput = calculateRemainingTime(23-hourIndex, 59-minuteIndex, scheduleData);
          });
        },
      );
      setState(() {
        timeRemainingOutput = calculateRemainingTime(23-hourIndex, 59-minuteIndex, scheduleData);
      });
    });

    if (widget.alarm['time'] != 'noAlarm') {
      title = widget.alarm['title'];
      scheduleData = widget.alarm['schedule'];
      scheduleText = daysOutputText(scheduleData);
      ringtone = widget.alarm['ringtone'];
      vibrate = widget.alarm['vibrate'] == 'true' ? true : false;
    }
  }

  initListData(_) async {
    if (widget.alarm['time'] == 'noAlarm') {
      hourController.jumpToItem(23 - now.hour.toInt());
      minuteController.jumpToItem(59 - now.minute.toInt());
      lightController.jumpToItem(8);
      return;
    }

    hourController.jumpToItem(23 - int.parse(widget.alarm['time'].split(':')[0]));
    minuteController.jumpToItem(59 - int.parse(widget.alarm['time'].split(':')[1]));
    if (widget.alarm['lightTimeLength'] == 'off') { lightController.jumpToItem(8); }
    else { lightController.jumpToItem(6-(int.parse(widget.alarm['lightTimeLength'])/5).round()); }
  }
  @override
  void dispose() {
    titleController.dispose();
    hourController.dispose();
    minuteController.dispose();
    lightController.dispose();
    initialTimer.cancel();
    periodicTimer.cancel();
    super.dispose();
  }

  void submitTitle(){
    Navigator.of(context).pop(titleController.text);
    titleController.clear();
  }
  Future<String?> openTitleDialog() => showDialog<String>(
    context: context,
    barrierColor: COLOR_BACKGROUND.withOpacity(0.6),
    builder: (context) => BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: AlertDialog(
        backgroundColor: COLOR_WIDGET_BACKGROUND,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('set title:', style: TextStyle(color: COLOR_TEXT_PRIM)),
        content: TextField(
          controller: titleController,
          autofocus: true,
          style: const TextStyle(color: COLOR_TEXT_PRIM),
          decoration: const InputDecoration(
            hintText: 'Enter your title',
            hintStyle: TextStyle(color: COLOR_TEXT_SEC),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: COLOR_TEXT_SEC),),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: COLOR_TEXT_SEC),),
          ),
          onSubmitted: (_) => submitTitle(),
        ),
        actions: [
          TextButton(
            style: ButtonStyle(backgroundColor: MaterialStateProperty.all(COLOR_BACKGROUND)),
            child: const Text('ok', style: TextStyle(color: COLOR_TEXT_PRIM)),
            onPressed: () => submitTitle(),
          )
        ],
      ),
    ),
  );

  Future openCustomScheduleDialog() => showDialog(
    barrierColor: COLOR_BACKGROUND.withOpacity(0.6),
    context: context,
    builder: (context) => BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
      child: AlertDialog(
        backgroundColor: COLOR_WIDGET_BACKGROUND,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('custom schedule:', style: TextStyle(color: COLOR_TEXT_PRIM)),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CheckboxListTile(
                  title: const Text('Monday', style: TextStyle(color: COLOR_TEXT_PRIM)),
                  activeColor: COLOR_TEXT_PRIM,
                  checkColor: COLOR_BACKGROUND,
                  autofocus: false,
                  value: preScheduleData & int.parse('1000000', radix: 2) != 0,
                  onChanged: (value) {
                    setState(() {
                      preScheduleData = value==true ? preScheduleData | int.parse('1000000', radix: 2) : preScheduleData & int.parse('0111111', radix: 2);
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('Tuesday', style: TextStyle(color: COLOR_TEXT_PRIM)),
                  activeColor: COLOR_TEXT_PRIM,
                  checkColor: COLOR_BACKGROUND,
                  autofocus: false,
                  value: preScheduleData & int.parse('0100000', radix: 2) != 0,
                  onChanged: (value) {
                    setState(() {
                      preScheduleData = value==true ? preScheduleData | int.parse('0100000', radix: 2) : preScheduleData & int.parse('1011111', radix: 2);
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('Wednesday', style: TextStyle(color: COLOR_TEXT_PRIM)),
                  activeColor: COLOR_TEXT_PRIM,
                  checkColor: COLOR_BACKGROUND,
                  autofocus: false,
                  value: preScheduleData & int.parse('0010000', radix: 2) != 0,
                  onChanged: (value) {
                    setState(() {
                      preScheduleData = value==true ? preScheduleData | int.parse('0010000', radix: 2) : preScheduleData & int.parse('1101111', radix: 2);
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('Thursday', style: TextStyle(color: COLOR_TEXT_PRIM)),
                  activeColor: COLOR_TEXT_PRIM,
                  checkColor: COLOR_BACKGROUND,
                  autofocus: false,
                  value: preScheduleData & int.parse('0001000', radix: 2) != 0,
                  onChanged: (value) {
                    setState(() {
                      preScheduleData = value==true ? preScheduleData | int.parse('0001000', radix: 2) : preScheduleData & int.parse('1110111', radix: 2);
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('Friday', style: TextStyle(color: COLOR_TEXT_PRIM)),
                  activeColor: COLOR_TEXT_PRIM,
                  checkColor: COLOR_BACKGROUND,
                  autofocus: false,
                  value: preScheduleData & int.parse('0000100', radix: 2) != 0,
                  onChanged: (value) {
                    setState(() {
                      preScheduleData = value==true ? preScheduleData | int.parse('0000100', radix: 2) : preScheduleData & int.parse('1111011', radix: 2);
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('Saturday', style: TextStyle(color: COLOR_TEXT_PRIM)),
                  activeColor: COLOR_TEXT_PRIM,
                  checkColor: COLOR_BACKGROUND,
                  autofocus: false,
                  value: preScheduleData & int.parse('0000010', radix: 2) != 0,
                  onChanged: (value) {
                    setState(() {
                      preScheduleData = value==true ? preScheduleData | int.parse('0000010', radix: 2) : preScheduleData & int.parse('1111101', radix: 2);
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('Sunday', style: TextStyle(color: COLOR_TEXT_PRIM)),
                  activeColor: COLOR_TEXT_PRIM,
                  checkColor: COLOR_BACKGROUND,
                  autofocus: false,
                  value: preScheduleData & int.parse('0000001', radix: 2) != 0,
                  onChanged: (value) {
                    setState(() {
                      preScheduleData = value==true ? preScheduleData | int.parse('0000001', radix: 2) : preScheduleData & int.parse('1111110', radix: 2);
                    });
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            style: ButtonStyle(backgroundColor: MaterialStateProperty.all(COLOR_BACKGROUND)),
            child: const Text('ok', style: TextStyle(color: COLOR_TEXT_PRIM)),
            onPressed: () {
              scheduleData = preScheduleData.toRadixString(2);
              while (scheduleData.length <= 6) {scheduleData = '0$scheduleData';}
              setState(() {
                scheduleText = daysOutputText(scheduleData);
                timeRemainingOutput = calculateRemainingTime(23-hourIndex, 59-minuteIndex, scheduleData);
              });
              Navigator.of(context).pop();},
          )
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: COLOR_BACKGROUND,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_outlined, color: COLOR_TEXT_PRIM, size: 30),
          padding: const EdgeInsets.only(top: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Text(widget.alarm['time'] == 'noAlarm' ? 'add alarm':'edit alarm', style: const TextStyle(color: COLOR_TEXT_PRIM, fontSize: 20)),
            const SizedBox(height: 2),
            Text(timeRemainingOutput, style: const TextStyle(color: COLOR_TEXT_PRIM, fontSize: 15))
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: COLOR_TEXT_PRIM, size: 30),
            padding: const EdgeInsets.only(right: 20, top: 20),
            onPressed: () {
              String hourToPass = hourData[hourIndex] <= 9 ? '0${hourData[hourIndex]}' : '${hourData[hourIndex]}';
              String minuteToPass = minuteData[minuteIndex] <= 9 ? '0${minuteData[minuteIndex]}' : '${minuteData[minuteIndex]}';
              String lightToPass = lightData[lightIndex] <= 9 ? (lightData[lightIndex] >= 0 ? '0${lightData[lightIndex]}' : 'off') : '${lightData[lightIndex]}';
              Map alarm = {
                'time' : '$hourToPass:$minuteToPass',
                'title' : title,
                'schedule' : scheduleData,
                'lightTimeLength' : lightToPass,
                'ringtone' : ringtone,
                'vibrate' : '$vibrate',
                'alarmOn' : 'true',
                'delete' : 'false',
                'switchOffOnce' : 'false',
              };
              Navigator.of(context).pop<Map>(alarm);
            },
          ),
        ],
        backgroundColor: COLOR_BACKGROUND,
      ),
      body: Column(
        children: [
          const Spacer(flex: 2),
          Row(
            children: [
              const Spacer(flex: 3),
              SizedBox(
                height: 110,
                width: 50,
                child: ListWheelScrollView.useDelegate(
                  itemExtent: 35,
                  diameterRatio: 4,
                  useMagnifier: true,
                  magnification: 1.3,
                  physics: const FixedExtentScrollPhysics().applyTo(const BouncingScrollPhysics()),
                  squeeze: 0.8,
                  overAndUnderCenterOpacity: 0.5,
                  controller: hourController,
                  onSelectedItemChanged: (index) {
                    hourIndex = index;
                    setState(() {timeRemainingOutput = calculateRemainingTime(23-hourIndex, 59-minuteIndex, scheduleData);});
                  },
                  childDelegate: ListWheelChildLoopingListDelegate(
                    children: [
                      for (int i in hourData) i <= 9 ? Text('0$i', style: const TextStyle(color: COLOR_TEXT_PRIM, fontSize: 30)) : Text('$i', style: const TextStyle(color: COLOR_TEXT_PRIM, fontSize: 30)),
                    ],
                  )
                ),
              ),
              const Spacer(flex: 1),
              SizedBox(
                height: 110,
                width: 50,
                child: ListWheelScrollView.useDelegate(
                  itemExtent: 35,
                  diameterRatio: 4,
                  useMagnifier: true,
                  magnification: 1.3,
                  physics: const FixedExtentScrollPhysics().applyTo(const BouncingScrollPhysics()),
                  squeeze: 0.8,
                  overAndUnderCenterOpacity: 0.5,
                  controller: minuteController,
                  onSelectedItemChanged: (index) {
                    minuteIndex = index;
                    setState(() {timeRemainingOutput = calculateRemainingTime(23-hourIndex, 59-minuteIndex, scheduleData);});
                  },
                  childDelegate: ListWheelChildLoopingListDelegate(
                    children: [
                      for (int i in minuteData) i <= 9 ? Text('0$i', style: const TextStyle(color: COLOR_TEXT_PRIM, fontSize: 30)) : Text('$i', style: const TextStyle(color: COLOR_TEXT_PRIM, fontSize: 30)),
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 2),
              SizedBox(
                height: 110,
                width: 50,
                child: ListWheelScrollView(
                  itemExtent: 35,
                  diameterRatio: 4,
                  useMagnifier: true,
                  magnification: 1.3,
                  physics: const FixedExtentScrollPhysics().applyTo(const BouncingScrollPhysics()),
                  squeeze: 0.8,
                  overAndUnderCenterOpacity: 0.5,
                  controller: lightController,
                  onSelectedItemChanged: (index) => lightIndex = index,
                  children: [
                    for (int i in lightData) i <= 9 ? ( i >= 0 ? Text('0$i', style: const TextStyle(color: COLOR_LIGHT, fontSize: 30)) : const Text('off', style: TextStyle(color: COLOR_TEXT_PRIM, fontSize: 30)) ) : Text('$i', style: const TextStyle(color: COLOR_LIGHT, fontSize: 30)),
                  ],
                ),
              ),
              const Spacer(flex: 3),
            ],
          ),
          const Spacer(flex: 3),
          GestureDetector(
            onTap: () async {
              final title = await openTitleDialog();
              if (title == null || title.isEmpty) return;
              setState(() => this.title = title);
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              decoration: const BoxDecoration(
                color: COLOR_WIDGET_BACKGROUND,
                borderRadius: BorderRadius.all(Radius.circular(20),),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width:5),
                  const Text('title', style: TextStyle(color: COLOR_TEXT_PRIM, fontSize: 20)),
                  const Spacer(),
                  Text(title, style: const TextStyle(color: COLOR_TEXT_SEC, fontSize: 15)),
                  const Icon(Icons.navigate_next_outlined, size: 25, color: COLOR_TEXT_PRIM),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              showMenu(
                context: context,
                elevation: 20,
                color: COLOR_BACKGROUND.withOpacity(0.6),
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width,
                ),
                items: [
                  PopupMenuItem(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.fromLTRB(0, 2, 0, 2),
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: COLOR_WIDGET_BACKGROUND,
                          borderRadius: BorderRadius.all(Radius.circular(20),),
                        ),
                        child: const Center(child: Text('once', style: TextStyle(color: COLOR_TEXT_PRIM, fontSize: 20))),
                      ),
                    ),
                    onTap: () {
                      scheduleData = '0000000';
                      setState(() {
                        scheduleText = 'once';
                        timeRemainingOutput = calculateRemainingTime(23-hourIndex, 59-minuteIndex, scheduleData);
                      });
                    },
                  ),
                  PopupMenuItem(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.fromLTRB(0, 2, 0, 2),
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: COLOR_WIDGET_BACKGROUND,
                        borderRadius: BorderRadius.all(Radius.circular(20),),
                      ),
                      child: const Center(child: Text('daily', style: TextStyle(color: COLOR_TEXT_PRIM, fontSize: 20))),
                    ),
                    onTap: () {
                      scheduleData = '1111111';
                      setState(() {
                        scheduleText = 'daily';
                        timeRemainingOutput = calculateRemainingTime(23-hourIndex, 59-minuteIndex, scheduleData);
                      });
                      },
                  ),
                  PopupMenuItem(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.fromLTRB(0, 2, 0, 2),
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: COLOR_WIDGET_BACKGROUND,
                        borderRadius: BorderRadius.all(Radius.circular(20),),
                      ),
                      child: const Center(child: Text('Mon.-Fri.', style: TextStyle(color: COLOR_TEXT_PRIM, fontSize: 20))),
                    ),
                    onTap: () {
                      scheduleData = '1111100';
                      setState(() {
                        scheduleText = 'Mon.-Fri.';
                        timeRemainingOutput = calculateRemainingTime(23-hourIndex, 59-minuteIndex, scheduleData);
                      });
                      },
                  ),
                  PopupMenuItem(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.fromLTRB(0, 2, 0, 2),
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: COLOR_WIDGET_BACKGROUND,
                        borderRadius: BorderRadius.all(Radius.circular(20),),
                      ),
                      child: const Center(child: Text('custom', style: TextStyle(color: COLOR_TEXT_PRIM, fontSize: 20))),
                    ),
                    onTap: () async {
                      preScheduleData = int.parse(scheduleData, radix: 2);
                      Future.delayed(Duration.zero, () => openCustomScheduleDialog());
                      //setState(() => scheduleText = 'custom');
                    },
                  ),
                ],
                position: RelativeRect.fromSize(
                  //const Rect.fromLTRB(0.0, double.infinity, 0.0, 0.0),
                  Rect.fromCenter(center: Offset.infinite, width: 100, height: 100),
                  const Size(100, 100),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              decoration: const BoxDecoration(
                color: COLOR_WIDGET_BACKGROUND,
                borderRadius: BorderRadius.all(Radius.circular(20),),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width:5),
                  const Text('schedule', style: TextStyle(color: COLOR_TEXT_PRIM, fontSize: 20)),
                  const Spacer(),
                  Text(scheduleText, style: const TextStyle(color: COLOR_TEXT_SEC, fontSize: 15)),
                  const Icon(Icons.navigate_next_outlined, size: 25, color: COLOR_TEXT_PRIM),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              showMenu(
                context: context,
                elevation: 20,
                color: COLOR_BACKGROUND.withOpacity(0.6),
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width,
                ),
                items: [
                  PopupMenuItem(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.fromLTRB(0, 2, 0, 2),
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: COLOR_WIDGET_BACKGROUND,
                          borderRadius: BorderRadius.all(Radius.circular(20),),
                        ),
                        child: const Center(child: Text('alarm', style: TextStyle(color: COLOR_TEXT_PRIM, fontSize: 20))),
                      ),
                    ),
                    onTap: () {setState(() => ringtone = 'alarm');},
                  ),
                  PopupMenuItem(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.fromLTRB(0, 2, 0, 2),
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: COLOR_WIDGET_BACKGROUND,
                        borderRadius: BorderRadius.all(Radius.circular(20),),
                      ),
                      child: const Center(child: Text('summer', style: TextStyle(color: COLOR_TEXT_PRIM, fontSize: 20))),
                    ),
                    onTap: () {setState(() => ringtone = 'summer');},
                  ),
                  PopupMenuItem(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.fromLTRB(0, 2, 0, 2),
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: COLOR_WIDGET_BACKGROUND,
                        borderRadius: BorderRadius.all(Radius.circular(20),),
                      ),
                      child: const Center(child: Text('MRebillet', style: TextStyle(color: COLOR_TEXT_PRIM, fontSize: 20))),
                    ),
                    onTap: () {setState(() => ringtone = 'MRebillet');},
                  ),
                ],
                position: RelativeRect.fromSize(
                  Rect.fromCenter(
                      center: Offset.infinite, width: 100, height: 100),
                  const Size(100, 100),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              decoration: const BoxDecoration(
                color: COLOR_WIDGET_BACKGROUND,
                borderRadius: BorderRadius.all(Radius.circular(20),),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width:5),
                  const Text('ringtone', style: TextStyle(color: COLOR_TEXT_PRIM, fontSize: 20)),
                  const Spacer(),
                  Text(ringtone, style: const TextStyle(color: COLOR_TEXT_SEC, fontSize: 15)),
                  const Icon(Icons.navigate_next_outlined, size: 25, color: COLOR_TEXT_PRIM),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {setState(() => vibrate==true ? vibrate=false : vibrate=true);},
            child: Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              decoration: const BoxDecoration(
                color: COLOR_WIDGET_BACKGROUND,
                borderRadius: BorderRadius.all(Radius.circular(20),),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width:5),
                  Text('vibrate on alarm', style: TextStyle(color: vibrate == true ? COLOR_TEXT_PRIM : COLOR_TEXT_SEC, fontSize: 20)),
                  const Spacer(),
                  Text(vibrate == true? 'yes':'no', style: TextStyle(fontSize: 15, color: vibrate == true ? COLOR_TEXT_PRIM : COLOR_TEXT_SEC)),
                  const SizedBox(width: 25),
                ],
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}


//TODO: needed work
/*
 */


//TODO: possible optical improvements
/*
o bigger clock picker (and sluggish(physics?))
o better spacer()
o barrier Color in show menu
o nicer checkboxes (schedule>custom): rounded checkbox, different TextColor and backgroundcolor when inactive?
o vibrate with switch (also gestureDetector, switch is just for presentation, delete padding?)
o load own ringtone, from Spotify?
 */