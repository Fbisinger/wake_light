import 'package:flutter/material.dart';
import 'constants.dart';

class ModeStopwatch extends StatefulWidget {
  const  ModeStopwatch({super.key});
  @override
  State<ModeStopwatch> createState() => _ModeStopwatchState();
}

class _ModeStopwatchState extends State<ModeStopwatch> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: COLOR_BACKGROUND,
      child: Column(
        children: const [
          Expanded(
            child: Center(
              child: Text('This is the Stopwatch Mode', style: TextStyle(color: COLOR_TEXT_PRIM)),
            ),
          ),
        ],
      ),
    );
  }
}