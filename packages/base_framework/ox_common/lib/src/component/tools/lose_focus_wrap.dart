import 'package:flutter/widgets.dart';

class LoseFocusWrap extends StatelessWidget {
  final Widget child;

  LoseFocusWrap({required this.child});

  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: child,
    );
  }
}
