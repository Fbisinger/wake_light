import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'addAlarmScreen.dart';
import 'constants.dart';
import 'wake_light.dart';

GlobalKey<ModeAlarmState> myModeAlarmKey = GlobalKey();


class ModeAlarm extends StatefulWidget {
  const  ModeAlarm({super.key});

  @override
  State<ModeAlarm> createState() => ModeAlarmState();
}


class ModeAlarmState extends State<ModeAlarm> {
  /*List<Map> alarmDataList = [{
    'time':'10:10',
    'title':'title',
    'schedule':'0101010',
    'lightTimeLength':'30',
    'ringtone' : 'alarm',
    'vibrate' : 'true',
    'alarmOn' : 'true',
    'delete' : 'false',
    'switchOffOnce' : 'false',
  }];*/
  //empty in the end
  List<Map> alarmDataList = [];
  bool modeDelete = false;

  @override
  void initState() {
    super.initState();
    fetchAlarms();
  }

  Future fetchAlarms() async {
    if(emailCheck()) return;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection(EMAIL_ADDRESS).doc('alarmMode').collection('alarms').get();
    for (var i = 0; i < querySnapshot.docs.length ; i++) {
        alarmDataList.add(querySnapshot.docs[i].data() as Map<String, dynamic>);
    }
    setState(() {alarmDataList.sort((a, b) => a['time'].compareTo(b['time']));});
  }
  Future updateAddFbAlarmData(Map alarm) async {
    if(emailCheck()) return;
    final docAlarm = FirebaseFirestore.instance.collection(EMAIL_ADDRESS).doc('alarmMode').collection('alarms').doc(alarm['uid']);
    await docAlarm.set(alarm.cast<String, dynamic>());
  }
  Future deleteFbAlarmData(Map alarm) async {
    if(emailCheck()) return;
    final docAlarm = FirebaseFirestore.instance.collection(EMAIL_ADDRESS).doc('alarmMode').collection('alarms').doc(alarm['uid']);
    await docAlarm.delete();
  }
  bool emailCheck() {
    if(EMAIL_ADDRESS == 'nothing') {return true;}
    return false;
  }

  void addAlarmDataList (Map alarm) {
    if(alarm['time'] != 'noAdd') {
      alarm['uid'] = alarm.hashCode.toString();
      alarmDataList.add(alarm);
      updateAddFbAlarmData(alarm);
    }
    setState(() {alarmDataList.sort((a, b) => a['time'].compareTo(b['time']));});
  }
  void deleteAlarmDataList() {
    var listLength = alarmDataList.length;
    var decrement = 0;
    for (var i = 0; i < listLength; i++){
      if(alarmDataList[i-decrement]['delete'] == 'true'){
        deleteFbAlarmData(alarmDataList[i-decrement]);
        alarmDataList.remove(alarmDataList[i-decrement]);
        decrement++;
      }
    }
    setState(() {alarmDataList;});
  }

  void navigateToAddAlarmScreen(Map alarm) {
    if (alarm['time'] != 'noAlarm') {deleteAlarmDataList();}

    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => AddAlarmScreen(alarm: alarm)))
        .then((newAlarm) {
          if (newAlarm == null) {
            if(alarm['time'] != 'noAlarm') addAlarmDataList(alarm);
            return;
          }
          addAlarmDataList(newAlarm);
        });
  }

  void deleteMode(bool state) {
    setState(() {modeDelete = state;});
  }
  void checkDeleteAll() {
    for (var alarm in alarmDataList) {
      if (alarm['delete'] == 'false') {
        setState(() {for (var alarm in alarmDataList) {alarm['delete'] = 'true';}});
        return;
      }
    }
    setState(() {for (var alarm in alarmDataList) {alarm['delete'] = 'false';}});
  }
  void unCheckDeleteAll() {
    setState(() {for (var alarm in alarmDataList) {alarm['delete'] = 'false';}});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (modeDelete == true) {
          myModeButtonsKey.currentState?.exitDelete();
          return false;
        }
        return true;
      },
      child: Material(
        color: COLOR_BACKGROUND,
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [for (var alarm in alarmDataList) AlarmWidget(alarmData: alarm)],
                      //children: alarmWidgetList,
                        //const AlarmWidget(alarmData: {'time':'05:20', 'title':'title of this alarm', 'schedule':'0000000', 'lightTimeLength':'30', 'alarmOn':'true'}),
                        //AlarmWidget(alarmData: {'time':'05:22', 'title':'title of this alarm', 'schedule':'1111100', 'lightTimeLength':'15'}),
                        //AlarmWidget(alarmData: {'time':'04:20', 'title':'this is my longest title check for how long i can go', 'schedule':'1101011', 'lightTimeLength':'20'}),
                        //AlarmWidget(alarmData: {'time':'10:10', 'title':'title', 'schedule':'010101', 'lightTimeLength':'30'}), //assume leading 0
                        //AlarmWidget(alarmData: {'time':'10:10', 'title':'title', 'schedule':'1010101', 'lightTimeLength':'30'}),
                        //AlarmWidget(alarmData: {'time':'10:10', 'title':'title', 'schedule':'1010101', 'lightTimeLength':'30'}),
                        //AlarmWidget(alarmData: {'time':'10:10', 'title':'title', 'schedule':'1010101', 'lightTimeLength':'30'}),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
            /*Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 50,
              child: Column(
                children: [
                  Container(
                    height: 20,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.green, Colors.green.withOpacity(1)]
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
              ),
            ),*/
            /*Align(
              alignment: const Alignment(-0.1,0.8),
              child: IconButton(
                icon: const Icon(Icons.add_circle_outlined, size:75),
                tooltip: 'Add a alarm clock',
                color: COLOR_TEXT_PRIM,
                onPressed: (){_navigateToNextScreen(context);},
              ),
            ),*/
          ],
        ),
      ),
    );
  }
}


////////////////////////////////// AlarmWidget //////////////////////////////////
class AlarmWidget extends StatefulWidget {
  final Map alarmData;
  const AlarmWidget ({ Key? key, required this.alarmData}): super(key: key);

  @override
  AlarmWidgetState createState() => AlarmWidgetState();
}


class AlarmWidgetState extends State<AlarmWidget> {
  late String additionalAlarmInfoString;
  late DateTime now;
  late Timer initialTimer;
  Timer periodicTimer = Timer.periodic(const Duration(minutes: 1), (Timer t){});
  bool qsInit = true;
  List<int> qsHourData = [for (int i = 23; i >= 0; i--) i];
  List<int> qsMinuteData = [for (int i = 59; i >= 0; i--) i];
  List<int> qsLightData = [for (int i = 30; i >= 0; i = i - 5) i, -1];
  late FixedExtentScrollController qsHourController;
  late FixedExtentScrollController qsMinuteController;
  late FixedExtentScrollController qsLightController;
  String qsHour = '';
  String qsMinute = '';
  String qsLight = '';
  int qsHourIndex = 0;
  int qsMinuteIndex = 0;
  int qsLightIndex = 0;
  String qsTimeRemainingOutput = '';

  @override
  void initState() {
    super.initState();
    additionalAlarmInfo();

    now = DateTime.now();
    var nextMinute = DateTime(now.year, now.month, now.day, now.hour, now.minute + 1);
    initialTimer = Timer(nextMinute.difference(now), () {
      periodicTimer = Timer.periodic(
        const Duration(minutes: 1), (Timer t) {
        if (widget.alarmData['alarmOn'] == 'true') additionalAlarmInfo();
        },
      );
      additionalAlarmInfo();
    });

    qsHourController = FixedExtentScrollController();
    qsMinuteController = FixedExtentScrollController();
    qsLightController = FixedExtentScrollController();
  }
  @override
  void dispose() {
    initialTimer.cancel();
    periodicTimer.cancel();
    qsHourController.dispose();
    qsMinuteController.dispose();
    qsLightController.dispose();
    super.dispose();
  }

  void additionalAlarmInfo() {
    additionalAlarmInfoString = daysOutputText(widget.alarmData['schedule']);
    if (widget.alarmData['alarmOn'] == 'true') {
      if (additionalAlarmInfoString != 'once') {additionalAlarmInfoString = '$additionalAlarmInfoString | ';}
      else {additionalAlarmInfoString = '';}


      additionalAlarmInfoString = '$additionalAlarmInfoString${calculateRemainingTime(
          int.parse(widget.alarmData['time'].split(':')[0]),
          int.parse(widget.alarmData['time'].split(':')[1]),
          widget.alarmData['schedule'])}';
    }
    else if (widget.alarmData['switchOffOnce'] == 'true') {
    additionalAlarmInfoString = '${additionalAlarmInfoString.split(' | ')[0]} | switched off once';
    }

    setState(() {additionalAlarmInfoString;});
  }

  initQuickSettings(_) async {
    qsInit = false;
    qsHour = widget.alarmData['time'].split(':')[0];
    qsMinute = widget.alarmData['time'].split(':')[1];
    qsHourController.jumpToItem(23-int.parse(qsHour));
    qsMinuteController.jumpToItem(59-int.parse(qsMinute));
    if (widget.alarmData['lightTimeLength'] == 'off') { qsLightController.jumpToItem(8); }
    else { qsLightController.jumpToItem(6-(int.parse(widget.alarmData['lightTimeLength'])/5).round()); }
    qsTimeRemainingOutput = calculateRemainingTime(int.parse(qsHour), int.parse(qsMinute), widget.alarmData['schedule']);
    qsLight = widget.alarmData['lightTimeLength'];
  }
  Future openQuickSettingsDialog() => showDialog<String>(
    barrierColor: COLOR_BACKGROUND.withOpacity(0.6),
    context: context,
    builder: (context) => BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
      child: AlertDialog(
        backgroundColor: COLOR_WIDGET_BACKGROUND,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 20,
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            if (qsInit) WidgetsBinding.instance.addPostFrameCallback(initQuickSettings);
            return SizedBox(
              width: 260,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text('$qsHour:$qsMinute',
                            style: const TextStyle(fontSize: 30, color: COLOR_TEXT_PRIM),
                          ),
                          const SizedBox(width: 10),
                          Text(qsLight,
                            style: const TextStyle(fontSize: 20, color: COLOR_LIGHT),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(widget.alarmData['title'],
                              style: const TextStyle(fontSize: 15, color: COLOR_TEXT_SEC),
                              softWrap: false,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text('${additionalAlarmInfoString.split(' | ')[0]} | $qsTimeRemainingOutput',
                        style: const TextStyle(fontSize: 15, color: COLOR_TEXT_SEC),
                        softWrap: false,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
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
                          physics: const FixedExtentScrollPhysics().applyTo(
                              const BouncingScrollPhysics()),
                          squeeze: 0.8,
                          overAndUnderCenterOpacity: 0.5,
                          controller: qsHourController,
                          onSelectedItemChanged: (index) {
                            qsHourIndex = index;
                            setState(() {
                              qsHour = qsHourData[qsHourIndex] <= 9 ? '0${qsHourData[qsHourIndex]}' : '${qsHourData[qsHourIndex]}';
                              qsTimeRemainingOutput = calculateRemainingTime(
                                  23 - qsHourIndex, 59 - qsMinuteIndex,
                                  widget.alarmData['schedule']);
                            });
                          },
                          childDelegate: ListWheelChildLoopingListDelegate(
                            children: [
                              for (int i in qsHourData) i <= 9 ? Text(
                                  '0$i', style: const TextStyle(
                                  color: COLOR_TEXT_PRIM, fontSize: 30)) : Text(
                                  '$i', style: const TextStyle(
                                  color: COLOR_TEXT_PRIM, fontSize: 30)),
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
                          physics: const FixedExtentScrollPhysics().applyTo(
                              const BouncingScrollPhysics()),
                          squeeze: 0.8,
                          overAndUnderCenterOpacity: 0.5,
                          controller: qsMinuteController,
                          onSelectedItemChanged: (index) {
                            qsMinuteIndex = index;
                            setState(() {
                              qsMinute = qsMinuteData[qsMinuteIndex] <= 9 ? '0${qsMinuteData[qsMinuteIndex]}' : '${qsMinuteData[qsMinuteIndex]}';
                              qsTimeRemainingOutput = calculateRemainingTime(
                                  23 - qsHourIndex, 59 - qsMinuteIndex,
                                  widget.alarmData['schedule']);
                            });
                          },
                          childDelegate: ListWheelChildLoopingListDelegate(
                            children: [
                              for (int i in qsMinuteData) i <= 9 ? Text(
                                  '0$i', style: const TextStyle(
                                  color: COLOR_TEXT_PRIM, fontSize: 30)) : Text(
                                  '$i', style: const TextStyle(
                                  color: COLOR_TEXT_PRIM, fontSize: 30)),
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
                          physics: const FixedExtentScrollPhysics().applyTo(
                              const BouncingScrollPhysics()),
                          squeeze: 0.8,
                          overAndUnderCenterOpacity: 0.5,
                          controller: qsLightController,
                          onSelectedItemChanged: (index) {
                            qsLightIndex = index;
                            setState(() {
                              qsLight = qsLightData[qsLightIndex] <= 9 ? (qsLightData[qsLightIndex] >= 0 ? '0${qsLightData[qsLightIndex]}' : 'off') : '${qsLightData[qsLightIndex]}';
                            });
                          },
                          children: [
                            for (int i in qsLightData) i <= 9 ? (i >= 0 ? Text(
                                '0$i', style: const TextStyle(
                                color: COLOR_LIGHT, fontSize: 30)) : const Text(
                                'off', style: TextStyle(
                                color: COLOR_TEXT_PRIM, fontSize: 30))) : Text('$i',
                                style: const TextStyle(
                                    color: COLOR_LIGHT, fontSize: 30)),
                          ],
                        ),
                      ),
                      const Spacer(flex: 3),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            style: ButtonStyle(backgroundColor: MaterialStateProperty.all(COLOR_BACKGROUND)),
            child: const Text('more settings', style: TextStyle(color: COLOR_TEXT_PRIM)),
            onPressed: () {
              widget.alarmData['delete'] = 'true';
              Navigator.of(context).pop();
              myModeAlarmKey.currentState?.navigateToAddAlarmScreen(widget.alarmData);
            },
          ),
          TextButton(
            style: ButtonStyle(backgroundColor: MaterialStateProperty.all(COLOR_BACKGROUND)),
            child: const Text('ok', style: TextStyle(color: COLOR_TEXT_PRIM)),
            onPressed: () {
              setState(() {
                widget.alarmData['time'] = '$qsHour:$qsMinute';
                widget.alarmData['lightTimeLength'] = qsLight;
                widget.alarmData['alarmOn'] = 'true';
              });
              additionalAlarmInfo();
              myModeAlarmKey.currentState?.addAlarmDataList({'time': 'noAdd'});
              myModeAlarmKey.currentState?.updateAddFbAlarmData(widget.alarmData);
              Navigator.of(context).pop();
            },
          )
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    additionalAlarmInfo();
    return GestureDetector(
      onTap: () async {
        if (myModeAlarmKey.currentState?.modeDelete == false) {
          qsInit = true;
          Future.delayed(Duration.zero, () => openQuickSettingsDialog());
        }
        else{setState(() {
          widget.alarmData['delete'] == 'true' ? widget.alarmData['delete']='false' : widget.alarmData['delete']='true';
        });}
      },
      onLongPress: () {
        myModeAlarmKey.currentState?.deleteMode(true);
        widget.alarmData['delete'] = 'true';
        bottomButtonKey.currentState?.buttonChange('Delete');
        myModeButtonsKey.currentState?.modeChange('Delete');
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        margin: const EdgeInsets.all(5),
        decoration: const BoxDecoration(
          color: COLOR_WIDGET_BACKGROUND,
          borderRadius: BorderRadius.all(Radius.circular(20),),
        ),
        child: Row(
          children: [
            Expanded(
              child:Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(widget.alarmData['time'],
                           style: TextStyle(fontSize: 30, color: widget.alarmData['alarmOn'] == 'true' ? COLOR_TEXT_PRIM : COLOR_TEXT_TER),
                      ),
                      const SizedBox(width: 10),
                      Text(widget.alarmData['lightTimeLength'],
                        style: TextStyle(fontSize: 20, color: widget.alarmData['alarmOn'] == 'true' ? COLOR_LIGHT : COLOR_TEXT_TER),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(widget.alarmData['title'],
                          style: TextStyle(fontSize: 15, color: widget.alarmData['alarmOn'] == 'true' ? COLOR_TEXT_SEC : COLOR_TEXT_TER),
                          softWrap: false,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(additionalAlarmInfoString,
                    style: TextStyle(fontSize: 15, color: widget.alarmData['alarmOn'] == 'true' ? COLOR_TEXT_SEC : COLOR_TEXT_TER),
                    softWrap: false,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
             if (myModeAlarmKey.currentState?.modeDelete == false)...[ Switch(value: widget.alarmData['alarmOn'] == 'true',
                activeTrackColor: COLOR_TEXT_SEC,
                inactiveTrackColor: COLOR_TEXT_TER,
                activeColor: COLOR_TEXT_PRIM,
                onChanged: (bool value) {
                  if (value == true || widget.alarmData['schedule'] == '0000000') {
                    widget.alarmData['switchOffOnce'] = 'false';
                    setState(() {
                      widget.alarmData['alarmOn'] = '$value';
                    });
                    additionalAlarmInfo();
                    myModeAlarmKey.currentState?.updateAddFbAlarmData(widget.alarmData);
                    return;
                  }
                  showMenu(
                    context: context,
                    elevation: 20,
                    color: COLOR_BACKGROUND.withOpacity(0.6),
                    constraints: BoxConstraints(
                      minWidth: MediaQuery.of(context).size.width,
                    ),
                    position: RelativeRect.fromSize(
                      Rect.fromCenter(
                          center: Offset.infinite, width: 100, height: 100),
                      const Size(100, 100),
                    ),
                    items: [
                      PopupMenuItem(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2,),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.fromLTRB(0, 2, 0, 2),
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              color: COLOR_WIDGET_BACKGROUND,
                              borderRadius: BorderRadius.all(Radius.circular(20),),
                            ),
                            child: const Center(child: Text('switch off once', style: TextStyle(color: COLOR_TEXT_PRIM, fontSize: 20))),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            widget.alarmData['alarmOn'] = '$value';
                            widget.alarmData['switchOffOnce'] = 'true';
                          });
                          myModeAlarmKey.currentState?.updateAddFbAlarmData(widget.alarmData);
                          var alarmOnAgain = timeToNextAlarm(
                            int.parse(widget.alarmData['time'].split(':')[0]),
                            int.parse(widget.alarmData['time'].split(':')[1]),
                            widget.alarmData['schedule']);
                          now = DateTime.now();
                          Timer(alarmOnAgain.difference(now), () {
                            widget.alarmData['switchOffOnce'] = 'false';
                            setState(() {widget.alarmData['alarmOn'] = 'true';});
                            additionalAlarmInfo();
                            myModeAlarmKey.currentState?.updateAddFbAlarmData(widget.alarmData);
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
                          child: const Center(child: Text('switch off alarm', style: TextStyle(color: COLOR_TEXT_PRIM, fontSize: 20))),
                        ),
                        onTap: () {
                          setState(() {
                            widget.alarmData['alarmOn'] = '$value';
                          });
                          additionalAlarmInfo();
                          myModeAlarmKey.currentState?.updateAddFbAlarmData(widget.alarmData);
                        },
                      ),
                    ],
                  );
                },
            ),]
            else ...[Checkbox(
               activeColor: COLOR_TEXT_PRIM,
               checkColor: COLOR_BACKGROUND,
               autofocus: false,
               value: widget.alarmData['delete'] == 'true',
               onChanged: (bool? value) {
                 setState(() {
                   widget.alarmData['delete'] = value == true ? 'true' : 'false';
                 });
               },
            ),]
          ],
        ),
      ),
    );
  }
}


//TODO: needed work
/*
 */


//TODO: possible optical improvements
/*
o checkboxes nicer
o shadow/blurr from top and bottom of SingleChildScrollView (bottom big, top small?)
o quicksettings nicer (especially buttons, open better (position, animation), spaces, rollView more pleasant)(background (blurr)
    do the same in addAlarmScreen
o barrier Color in show menu
o switch off once: add when the one time will be
o authentification with firebase
o upload visible:
    by color of lightMinutes (like green triangle in upper right corner of EverNote with arrow in it)
      grey if not updated
      orange if turned of but not updated
    dark grey (offline) deleted alarms (when tabbed on: info that it will be deleted as soon as connected to internet)
o airPlaneMode, add alarm, close app, reconnect to WIFI -> is firebase updated?
 */