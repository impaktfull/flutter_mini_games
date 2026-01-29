import 'package:flutter/material.dart';
import 'package:impaktfull_ui/impaktfull_ui.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ImpaktfullUiScreen(
      child: ImpaktfullUiListView(
        children: [
          ImpaktfullUiListItem(
            title: "2048",
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
