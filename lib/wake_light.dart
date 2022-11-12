import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterfire_ui/auth.dart';
import 'modeAlarm.dart';
import 'modeStopwatch.dart';
import 'modeTimer.dart';
import 'modeLight.dart';
import 'constants.dart';

GlobalKey<_MyPageViewState> _myPageKey = GlobalKey();
GlobalKey<_BottomButtonState> bottomButtonKey = GlobalKey();
GlobalKey<_ModeButtonsState> myModeButtonsKey = GlobalKey();


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationController.initializeLocalNotifications();
  await Firebase.initializeApp();
  runApp(const MyApp());
}


///////////////////////////////// notification /////////////////////////////////
class NotificationController {
  static ReceivedAction? initialAction;

  @pragma("vm:entry-point")
  static Future <void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    // Navigate into pages, avoiding to open the notification details page over another details page already opened
    MyApp.navigatorKey.currentState?.pushNamedAndRemoveUntil('/notification-page',
            (route) => (route.settings.name != '/notification-page') || route.isFirst,
        arguments: receivedAction);
  }

  static Future<void> initializeLocalNotifications() async {
    await AwesomeNotifications().initialize(
        null, //'resource://drawable/res_app_icon',//
        [
          NotificationChannel(
              //channelGroupKey: 'basic_channel_group',
              channelKey: 'alarms_channel',
              channelName: 'Alarms',
              channelDescription: 'Notification tests as alarms',
              importance: NotificationImportance.Max,
              playSound: true,
              defaultRingtoneType: DefaultRingtoneType.Alarm,
              soundSource: 'resource://raw/res_security_alarm',
              //onlyAlertOnce: true,
              //groupAlertBehavior: GroupAlertBehavior.Children,
              defaultPrivacy: NotificationPrivacy.Public,
              defaultColor: COLOR_BACKGROUND,
              ledColor: Colors.orange,
              ledOnMs: 1000,
              ledOffMs: 500,
              enableLights: true,
              enableVibration: true,
              //icon: 'alarm',
          )
        ],
        //debug: true
    );

    initialAction = await AwesomeNotifications()
        .getInitialNotificationAction(removeFromActionEvents: false);
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    AwesomeNotifications().setListeners(
      onActionReceivedMethod:         NotificationController.onActionReceivedMethod,
      //if needed: discomment and also add pragma in NotificationController
      //onNotificationCreatedMethod:    NotificationController.onNotificationCreatedMethod,
      //onNotificationDisplayedMethod:  NotificationController.onNotificationDisplayedMethod,
      //onDismissActionReceivedMethod:  NotificationController.onDismissActionReceivedMethod
    );

    AwesomeNotifications().isNotificationAllowed().then(
          (isAllowed) {
        if (!isAllowed) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Allow Notifications'),
              content: const Text('Our app would like to send you notifications'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Don\'t Allow', style: TextStyle(color: COLOR_TEXT_SEC, fontSize: 18),),
                ),
                TextButton(
                  onPressed: () => AwesomeNotifications()
                      .requestPermissionToSendNotifications()
                      .then((_) => Navigator.pop(context)),
                  child: const Text('Allow', style: TextStyle(color: COLOR_LIGHT, fontSize: 18, fontWeight: FontWeight.bold,),),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        title: 'wake Light', // title of the app
        /*//need to take out const modifier
        theme: ThemeData(
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius:BorderRadius.circular(20),),
            labelStyle: const TextStyle(color: COLOR_TEXT_SEC),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(
                style: BorderStyle.solid,
                color: COLOR_LIGHT,
              ),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: ButtonStyle(
              padding: MaterialStateProperty.all<EdgeInsets>(
                const EdgeInsets.all(24),
              ),
              backgroundColor: MaterialStateProperty.all<Color>(COLOR_WIDGET_BACKGROUND),
              foregroundColor: MaterialStateProperty.all<Color>(COLOR_TEXT_PRIM),
            ),
          ),
          //scaffoldBackgroundColor: COLOR_BACKGROUND,
          textTheme: const TextTheme(
            headline1: TextStyle(color: COLOR_TEXT_PRIM),
            headline2: TextStyle(color: COLOR_TEXT_PRIM),
            headline3: TextStyle(color: COLOR_TEXT_PRIM),
            headline6: TextStyle(color: COLOR_TEXT_SEC),
            bodyText2: TextStyle(color: COLOR_LIGHT),
            //highlited text in COLOR_LIGHT
          ),
        ),*/
        home: AuthGate(),
    );
  }
}

//////////////////////////////// authentication ////////////////////////////////
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

@override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final user = FirebaseAuth.instance.currentUser;
            if(user != null)EMAIL_ADDRESS = user.email!;
            return const SafeArea(child: MyScaffold());
          }
          else {return const SignInScreen(providerConfigs: [
            EmailProviderConfiguration(),
          ]);}
        }
    );
  }
}

////////////////////////////////// MyScaffold //////////////////////////////////
class MyScaffold extends StatelessWidget{
  const MyScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: COLOR_BACKGROUND,
      child: Column(
        children: <Widget> [
          ModeButtons(key: myModeButtonsKey,),
          const SizedBox(height: 20),
          Expanded(
            child: Stack(
              children: [
                //Expanded(
                Positioned.fill(
                    child: MyPageView(key: _myPageKey,)
                ),
                Align(
                  alignment: const Alignment(0,0.85),
                  child: SizedBox(
                      height: 75,
                      width: 75,
                      child: BottomButton(key: bottomButtonKey,)
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

////////////////////////////////// MyPageView //////////////////////////////////
class MyPageView extends StatefulWidget {
  const MyPageView({super.key});
  @override
  State<MyPageView> createState() => _MyPageViewState();
}


class _MyPageViewState extends State<MyPageView> {
  final PageController controller = PageController();

  void changePage({mode = 'Alarm'}){
    switch (mode) {
      case 'Alarm':
        controller.animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut); break;
      case 'Stopwatch':
        controller.animateToPage(1, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut); break;
      case 'Timer':
        controller.animateToPage(2, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut); break;
      case 'Light':
        controller.animateToPage(3, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut); break;
    }
  }

  void _onPageChange(int page){
    switch (page) {
      case 0:
        myModeButtonsKey.currentState?.modeChange('Alarm');
        bottomButtonKey.currentState?.buttonChange('Alarm');
        break;
      case 1:
        myModeButtonsKey.currentState?.modeChange('Stopwatch');
        bottomButtonKey.currentState?.buttonChange('Stopwatch');
        break;
      case 2:
        myModeButtonsKey.currentState?.modeChange('Timer');
        bottomButtonKey.currentState?.buttonChange('Timer');
        break;
      case 3:
        myModeButtonsKey.currentState?.modeChange('Light');
        bottomButtonKey.currentState?.buttonChange('Light');
        break;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  return PageView(
                controller: controller,
                physics: const BouncingScrollPhysics(),
                onPageChanged: _onPageChange,
                children: <Widget>[
                    ModeAlarm(key: myModeAlarmKey,),
                    const ModeStopwatch(),
                    const ModeTimer(),
                    const ModeLight(),
                ],
              );
  }
}


///////////////////////////////// BottomButton /////////////////////////////////
class BottomButton extends StatefulWidget {
  const BottomButton({super.key});
  @override
  State<BottomButton> createState() => _BottomButtonState();
}


class _BottomButtonState extends State<BottomButton> {
  late Widget _bottomButton = IconButton(
    padding: EdgeInsets.zero,
    icon: const Icon(Icons.add_circle_outlined, size: 75),
    tooltip: 'Add a alarm clock',
    color: COLOR_TEXT_PRIM,
    onPressed: () => myModeAlarmKey.currentState?.navigateToAddAlarmScreen({'time':'noAlarm'}),
  );

  void buttonChange (String mode) {
    setState(() {
      switch (mode) {
        case 'Alarm':
          _bottomButton = IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.add_circle_outlined, size: 75),
            tooltip: 'Add a alarm clock',
            color: COLOR_TEXT_PRIM,
            onPressed: () => myModeAlarmKey.currentState?.navigateToAddAlarmScreen({'time':'noAlarm'}),
          );
          break;
        case 'Delete':
          _bottomButton = IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.delete_outline, size: 75),
            tooltip: 'Delete checked alarms',
            color: COLOR_TEXT_PRIM,
            onPressed: () {
              myModeAlarmKey.currentState?.deleteAlarmDataList();
              myModeAlarmKey.currentState?.deleteMode(false);
              myModeButtonsKey.currentState?.modeChange('Alarm');
              buttonChange('Alarm');
            }
          );
          break;
        case 'Stopwatch':
          _bottomButton = IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.play_circle, size: 75),
            tooltip: 'Start the stopwatch',
            color: COLOR_TEXT_PRIM,
            onPressed: () => myModeAlarmKey.currentState?.navigateToAddAlarmScreen({'time':'noAlarm'}),
          );
          break;
        case 'Timer':
          _bottomButton = IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.play_circle, size: 75),
            tooltip: 'Start the Timer',
            color: COLOR_TEXT_PRIM,
            onPressed: () => myModeAlarmKey.currentState?.navigateToAddAlarmScreen({'time':'noAlarm'}),
          );
          break;
        case 'Light':
          _bottomButton = IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.square, size: 0),
            tooltip: '',
            color: COLOR_BACKGROUND,
            onPressed: () {null;},
          );
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _bottomButton;
  }
}


////////////////////////////////// ModeButtons //////////////////////////////////
class ModeButtons extends StatefulWidget {
    const  ModeButtons({super.key});
    @override
    State<ModeButtons> createState() => _ModeButtonsState();
}


class _ModeButtonsState extends State<ModeButtons> {
  Color _colorAlarm = COLOR_TEXT_PRIM;
  Color _colorStopwatch = COLOR_TEXT_TER;
  Color _colorTimer = COLOR_TEXT_TER;
  Color _colorLight = COLOR_TEXT_TER;
  bool modeDelete = false;

  void modeChange(String mode){
    setState(() {
      _colorAlarm = COLOR_TEXT_TER;
      _colorStopwatch = COLOR_TEXT_TER;
      _colorTimer = COLOR_TEXT_TER;
      _colorLight = COLOR_TEXT_TER;
      modeDelete = false;

      switch (mode) {
        case 'Alarm':
          _colorAlarm = COLOR_TEXT_PRIM;
          break;
        case 'Delete':
          modeDelete = true;
          break;
        case 'Stopwatch':
          _colorStopwatch = COLOR_TEXT_PRIM;
          break;
        case 'Timer':
          _colorTimer = COLOR_TEXT_PRIM;
          break;
        case 'Light':
          _colorLight = COLOR_LIGHT;
          break;
      }
    });
  }

  void exitDelete() {
    myModeAlarmKey.currentState?.unCheckDeleteAll();
    bottomButtonKey.currentState?.buttonChange('Alarm');
    modeChange('Alarm');
    setState(() {
      myModeAlarmKey.currentState?.deleteMode(false);
    });
  }

  Row _buttons(){
    return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.alarm, size:30),
                  tooltip: 'Alarm',
                  color: _colorAlarm,
                  onPressed: (){modeChange('Alarm'); _myPageKey.currentState?.changePage(mode:'Alarm');},
                ),
                const SizedBox(width: 5),
                IconButton(
                  icon: const Icon(Icons.timer_outlined, size:30),
                  tooltip: 'Stopwatch',
                  color: _colorStopwatch,
                  onPressed: (){modeChange('Stopwatch'); _myPageKey.currentState?.changePage(mode:'Stopwatch');},
                ),
                const SizedBox(width: 5),
                IconButton(
                  icon: const Icon(Icons.hourglass_empty, size:30),
                  tooltip: 'Timer',
                  color: _colorTimer,
                  onPressed: (){modeChange('Timer'); _myPageKey.currentState?.changePage(mode:'Timer');},
                ),
                const SizedBox(width: 5),
                IconButton(
                  icon: const Icon(Icons.lightbulb_outlined, size:30),
                  tooltip: 'Light',
                  color: _colorLight,
                  onPressed: (){modeChange('Light'); _myPageKey.currentState?.changePage(mode:'Light');},
                ),
              ],
            );
  }

  @override
  Widget build(BuildContext context) {
    if (modeDelete == false) {
      return Container(
        height: 80.0,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Stack(
            children: <Widget>[
              Row( //Row(children: [...]) only because Expanded shouldn't be used in Stack
                children: [
                  Expanded(
                      child: Center(
                        child: _buttons(),
                      )
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.settings, size: 25),
                  tooltip: 'Settings',
                  color: COLOR_TEXT_SEC,
                  onPressed: () => setAlarm({}),
                  //onPressed: () => _signOut(),//print("settings pressed"),
                ),
              ),
            ]
        ),
      );
    }
    else {
      return Container(
        height: 80.0,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.close_outlined, color: COLOR_TEXT_PRIM, size: 30),
              onPressed: () {
                exitDelete();
              },
            ),
            const Spacer(),
            const Text('delete alarm', style: TextStyle(color: COLOR_TEXT_PRIM, fontSize: 20)),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.checklist_rtl_outlined, color: COLOR_TEXT_PRIM, size: 30),
              onPressed: () {
                myModeAlarmKey.currentState?.checkDeleteAll();
              },
            ),
          ],
        ),
      );
    }
  }

  //TODO: in separate settings file with Icon(Icons.logout)
  //password: wakeLight
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}


//TODO: needed work
/*
o git
o background processes
o lockscreen and ringtone
o notification
o settings (also store in firebase) (lock out there)
*/


//TODO: possible optical improvements
/*
o shadow/blurr around addButton (Card?)
o delete bottomButton in LightPage (dont show there)
o theme in MyApp (->LogIn / SignIn Screen)
o animation
o new font
    https://fonts.google.com/specimen/Inter+Tight?category=Sans+Serif,Display&vfonly=true&subset=cyrillic
    https://pub.dev/packages/google_fonts
    https://www.e-recht24.de/google-fonts-scanner
o filled mode icons
o smaller datatypes (often int is way too big)
o get every underline away ... (at tab problems next to Terminal)
o delete unused dependency (pubspec.yaml: firebase_database: ^10.0.3)
*/