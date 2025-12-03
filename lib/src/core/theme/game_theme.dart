import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

abstract class GameTheme {
  static T of<T extends GameTheme>(BuildContext context) => Provider.of<T>(context, listen: false);
}
