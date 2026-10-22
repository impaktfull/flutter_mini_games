import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';

class FlutterMiniGamesScreen extends StatelessWidget {
  final String title;
  final Widget child;
  final EdgeInsets? padding;

  const FlutterMiniGamesScreen({
    required this.title,
    required this.child,
    this.padding,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CoreGameTheme.of(context);
    return Scaffold(
      backgroundColor: theme.colors.background,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.colors.background,
              boxShadow: [
                BoxShadow(
                  color: theme.colors.shadow.withAlpha(15),
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
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: Icon(Icons.arrow_back, color: theme.colors.text),
                  ),
                  Text(title, style: theme.textStyles.label),
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
                child: Padding(
                  padding: padding ?? EdgeInsets.all(theme.dimens.padding),
                  child: child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
