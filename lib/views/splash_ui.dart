import 'package:flutter/cupertino.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class SplashUI extends StatelessWidget {
  const SplashUI({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Center(
        child: LoadingAnimationWidget.halfTriangleDot(
          color: CupertinoTheme.of(context).primaryColor,
          size: 70,
        ),
      ),
    );
  }
}
