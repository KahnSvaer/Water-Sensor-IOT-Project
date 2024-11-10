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

  void changeRootAfterSignIn(Widget widget) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => widget),
          (Route<dynamic> route) => false, // This removes all previous routes
    );
  }

  // Pop the last widget from the stack
  void pop() {
    Navigator.pop(context);
  }
}
