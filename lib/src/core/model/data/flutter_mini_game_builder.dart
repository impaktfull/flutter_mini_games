import 'package:flutter/material.dart';

abstract class FlutterMiniGameBuilder {
  final String name;
  final String description;

  bool get isMultiPlayer;

  FlutterMiniGameBuilder({
    required this.name,
    required this.description,
  });

  Future<Widget> build(BuildContext context);
}
