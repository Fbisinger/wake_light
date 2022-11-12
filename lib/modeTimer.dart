import 'package:flutter/material.dart';
import 'constants.dart';

class ModeTimer extends StatefulWidget {
  const  ModeTimer({super.key});
  @override
  State<ModeTimer> createState() => _ModeTimerState();
}

class _ModeTimerState extends State<ModeTimer> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: COLOR_BACKGROUND,
      child: Column(
        children: const [
          Expanded(
            child: Center(
              child: Text('This is the Timer Mode', style: TextStyle(color: COLOR_TEXT_PRIM)),
            ),
          ),
        ],
      ),
    );
  }
}







/*
class TimerButtons extends StatelessWidget {
  const TimerButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 80.0,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: const BoxDecoration(color: COLOR_BACKGROUND),

        child: Stack(
            children: <Widget>[
              Expanded(
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const[
                        IconButton(
                          icon: const Icon(Icons.alarm_outlined, size:30),
                          tooltip: 'Alarm',
                          color: COLOR_TEXT_SEC,
                          onPressed: null,
                        ),
                        IconButton(
                          icon: const Icon(Icons.timer_outlined, size:30),
                          tooltip: 'Stopwatch',
                          color: COLOR_TEXT_PRIM,
                          onPressed: null,
                        ),
                        IconButton(
                          icon: const Icon(Icons.hourglass_empty, size:30),
                          tooltip: 'Timer',
                          color: COLOR_TEXT_SEC,
                          onPressed: null,
                        ),
                        IconButton(
                          icon: const Icon(Icons.lightbulb_outlined, size:30),
                          tooltip: 'Light',
                          color: COLOR_TEXT_SEC,
                          onPressed: null,
                        ),
                      ],
                    ),
                  )
              ),
              const Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(Icons.settings, size:25),
                  tooltip: 'Settings',
                  color: COLOR_TEXT_SEC,
                  onPressed: null,
                ),
              ),
            ]
        ),
    );
  }
}*/