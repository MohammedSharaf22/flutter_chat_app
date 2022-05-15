import 'package:flutter/material.dart';
import 'package:flutter_chat_app/utilities/theme/my_theme.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

Widget getStretchedDotsLoading() {
  return Center(
    child: LoadingAnimationWidget.stretchedDots(
      color: MyDarkTheme.primaryColor,
      size: 70,
    ),
  );
}

//
