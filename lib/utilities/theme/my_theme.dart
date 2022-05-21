import 'package:flutter/cupertino.dart';


CupertinoDynamicColor fieldBackgroundColor = CupertinoDynamicColor.withBrightness(
  color: MyLightTheme.fieldColor,
  darkColor: MyDarkTheme.fieldColor,
);

CupertinoDynamicColor iconDynamicColor = CupertinoDynamicColor.withBrightness(
  color: MyLightTheme.iconColor,
  darkColor: MyDarkTheme.iconColor,
);

CupertinoDynamicColor primaryDynamicColor = CupertinoDynamicColor.withBrightness(
  color: MyLightTheme.primaryColor,
  darkColor: MyDarkTheme.primaryColor,
);

Color myBubbleColor = Color.fromRGBO(67, 110, 149, 1);
Color anotherBubbleColor = Color.fromRGBO(30, 47, 63, 1);
Color dateAndStateColor = Color.fromRGBO(161, 183, 202, 1);

class MyDarkTheme {
  static const Color primaryColor = Color(0xff2b8ad1);

  static const Color barBackgroundColor = Color.fromRGBO(32, 48, 65, 1);//Color(0xff20222b)

  static const Color scaffoldBackgroundColor = Color.fromRGBO(24, 35, 46, 1);//Color(0xff17171d)

  static const Color primaryContrastingColor = CupertinoColors.white;

  static const Color fieldColor = Color.fromRGBO(24, 35, 48, 1);

  static const Color iconColor = Color.fromRGBO(126, 147, 159, 1);

  static const Color textColor = CupertinoColors.white;

  static CupertinoTextThemeData textTheme = CupertinoTextThemeData(
    primaryColor: primaryColor,
    textStyle: TextStyle(color: textColor),
    tabLabelTextStyle: TextStyle(
      color: textColor.withOpacity(.4),
      fontSize: 12,
    ),
  );

}

class MyLightTheme {
  static const Color primaryColor = Color.fromRGBO(0, 122, 254, 1);

  static const Color barBackgroundColor = Color.fromRGBO(242, 242, 242, 1);//Color.fromRGBO(239, 239, 244, 1)

  static const Color scaffoldBackgroundColor = CupertinoColors.white;

  static const Color primaryContrastingColor = CupertinoColors.white;

  static const Color fieldColor = Color.fromRGBO(228, 228, 228, 1);

  static const Color iconColor = Color.fromRGBO(133, 142, 153, 1);

  static const Color textColor = CupertinoColors.label;

  static CupertinoTextThemeData textTheme = CupertinoTextThemeData(
    primaryColor: primaryColor,
    textStyle: TextStyle(color: textColor),
    tabLabelTextStyle: TextStyle(
      color: textColor.withOpacity(.4),
      fontSize: 12,
    ),
  );
}
