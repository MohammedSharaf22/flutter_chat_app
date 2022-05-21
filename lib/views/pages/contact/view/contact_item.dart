import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ContactItem extends StatelessWidget {
  final String name;
  final String photoURL;
  final String phone;
  final bool isLastItem;
  final Function() onClick;

  const ContactItem({
    Key? key,
    required this.name,
    required this.photoURL,
    required this.phone,
    this.isLastItem = false,
    required this.onClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var nameTextStyle = CupertinoTheme.of(context).textTheme.textStyle;
    var phoneTextStyle = CupertinoTheme.of(context).textTheme.tabLabelTextStyle;
    /*nameTextStyle.copyWith(
      color: nameTextStyle.color!.withOpacity(.5),

    );*/
    //debugPrint("fontSize= ${nameTextStyle.fontSize}");
    return Column(
      children: [
        Material(
          type: MaterialType.transparency,
          child: InkWell(
            child: ListTile(
              leading: CircularProfileAvatar( //NetworkToFileImage
                photoURL,
                imageFit: BoxFit.cover,
                radius: 23,
                onTap: () {
                  Get.snackbar("title", "message");
                },
              ),
              title: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: nameTextStyle,
                ),
              ),
              subtitle: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  phone,
                  style: phoneTextStyle,
                  textDirection: TextDirection.ltr,
                ),
              ),
            ),
            onTap: onClick,
          ),
        ),
        if(!isLastItem)
          Divider(
            color: CupertinoColors.separator.darkColor,
            endIndent: 10,
            indent: 80,
          ),
      ],
    );
  }
}