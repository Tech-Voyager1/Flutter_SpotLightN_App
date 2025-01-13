import 'package:flutter/material.dart';
import 'home.dart';

void main() {
  runApp(Spotlight());
}

class Spotlight extends StatefulWidget {
  const Spotlight({super.key});

  @override
  State<Spotlight> createState() => _SpotlightState();
}

class _SpotlightState extends State<Spotlight> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
    );
  }
}
