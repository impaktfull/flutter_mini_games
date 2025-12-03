import 'package:flutter/material.dart';

class FlutterMiniGamesScreen extends StatelessWidget {
  final String title;
  final Widget child;
  const FlutterMiniGamesScreen({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(15),
                  blurRadius: 4,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(8),
            child: SafeArea(
              bottom: false,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 8,
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Text(title),
                ],
              ),
            ),
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: MediaQuery.removePadding(
                context: context,
                removeLeft: true,
                removeRight: true,
                removeTop: true,
                removeBottom: true,
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
