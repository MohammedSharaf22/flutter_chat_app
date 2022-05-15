import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/utilities/theme/my_theme.dart';

import '../model/message.dart';

Icon getStateIcon(int state) {
  IconData iconData = Icons.watch_later_outlined;
  Color iconColor = dateAndStateColor;

  if (state == StateType.sent) {
    iconData = CupertinoIcons.check_mark_circled;
  } else if (state == StateType.delivered) {
    iconData = CupertinoIcons.check_mark_circled_solid;
  } else if (state == StateType.seen) {
    iconData = CupertinoIcons.check_mark_circled_solid;
    iconColor = CupertinoColors.link;
  } else {
    iconData = Icons.watch_later_outlined;
  }

  return Icon(
    iconData,
    size: 15,
    color: iconColor,
  );
}
