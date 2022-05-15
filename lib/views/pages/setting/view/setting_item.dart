import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class SettingItem extends StatelessWidget {
  final IconData? leadingIcon;
  final Color? leadingIconColor;
  final Color? bgIconColor;
  final String title;
  final GestureTapCallback? onTap;
  final bool isLast;
  final bool enableArrowIcon;

  const SettingItem({Key? key, required this.title, this.onTap, this.leadingIcon, this.leadingIconColor = Colors
          .white, this.bgIconColor, this.isLast=false, this.enableArrowIcon=true,}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    debugPrint(CupertinoTheme.of(context).textTheme.textStyle.color.toString());
    return InkWell(
      borderRadius: BorderRadius.circular(7),
      //highlightColor: CupertinoColors.systemPurple,
      //hoverColor: CupertinoColors.systemPurple,
      //splashColor: CupertinoTheme.of(context).Colors.systemPurple.withOpacity(.3),
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        child:  Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: leadingIcon != null ?
          [
              Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(color: bgIconColor, borderRadius: BorderRadius.circular(7)),
                child: Icon(
                  leadingIcon,
                  size: 18,
                  color: leadingIconColor,
                ),
              ),
              SizedBox(width: 10,),
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(start: 8.0),
                  child: Text(title,
                    style: TextStyle(
                        fontSize: 16,
                        color: CupertinoTheme.of(context).textTheme.textStyle.color,
                    ) ,
                  ),
                ),
              ),
              if(enableArrowIcon)
              Icon(
                CupertinoIcons.forward,
                color: Colors.grey,
                size: 17,
              )
            ]
                :
            [
              Expanded(
                child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      color: CupertinoTheme.of(context).textTheme.textStyle.color,
                    )
                ),
              ),
              if(enableArrowIcon)
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
                size: 17,
              )
            ],
          ),
        ),
      );
  }
}