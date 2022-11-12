import 'package:flutter/material.dart';
import 'constants.dart';

class ModeLight extends StatefulWidget {
  const  ModeLight({super.key});
  @override
  State<ModeLight> createState() => _ModeLightState();
}

class _ModeLightState extends State<ModeLight> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: COLOR_BACKGROUND,
      child: Column(
        children: const [
          Expanded(
            child: Center(
              child: Text('This is the Light Mode', style: TextStyle(color: COLOR_TEXT_PRIM)),
            ),
          ),
        ],
      ),
    );
  }
}

