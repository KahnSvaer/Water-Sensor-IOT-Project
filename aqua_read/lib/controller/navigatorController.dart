import 'package:flutter/material.dart';

class NavigationController {
  final BuildContext context;

  NavigationController(this.context);

  // Push a new widget onto the stack after popping until the root
  void pushAndPopUntilRoot(Widget widget) {
    // Pop all screens until we reach the root
    Navigator.of(context).popUntil((route) => route.isFirst);

    // Then push the new widget
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => widget),
    );
  }

  // Pop the last widget from the stack
  void pop() {
    Navigator.pop(context);
  }

  // Pop until the specified widget is found
  void popUntil(Widget targetWidget) {
    Navigator.popUntil(
      context,
      ModalRoute.withName(targetWidget.toString()), // or any unique identifier
    );
  }
}
