import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/views/pages/setting/controller/settings_controller.dart';
import 'package:flutter_chat_app/utilities/widgets/setting_item.dart';
import 'package:get/get.dart';


class SettingPage extends GetView<SettingsController> {
  const SettingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SettingsController>(builder: (controller) {
      return CupertinoPageScaffold(
        //backgroundColor: bgColor,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                CupertinoSliverNavigationBar(
                  backgroundColor: CupertinoTheme.of(context).primaryContrastingColor,
                  //backgroundColor: bgColor,
                  stretch: true,
                  leading: CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Icon(CupertinoIcons.qrcode, /*color: MyColors.primaryColorLight,*/),
                    onPressed: () {  },
                  ),
                  /*middle: Text("settings".tr),*/
                  border: Border.all(color: Colors.transparent ),
                  largeTitle: Text("settings".tr),
                  trailing: CupertinoButton(
                    onPressed: () {  },
                    padding: EdgeInsets.zero,
                    child: Text("edit".tr,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,),),
                  ),
                ),
              ];
              },
          body: SafeArea(
            child: Scaffold(
              backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
              body: getBody(controller, context),
            ),
          ),
        ),
      );
    });
  }

  Widget getBody(SettingsController controller, context) {
    return ListView(
      padding: EdgeInsets.only(left: 20, right: 20),
      shrinkWrap: true,
      children: [
        Container(
          /*padding: const EdgeInsets.only(top: 20),*/
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProfileAvatar('',
                    child: Image.file(controller.getUserProfilePhoto()),
                  ),
                ],
              ),
              SizedBox(height: 15,),
              Text(controller.getUsername(),
                style: TextStyle(
                  fontSize: 22,
                  color: CupertinoTheme.of(context).textTheme.textStyle.color,
                  fontWeight: FontWeight.w500
                ),
              ),
              //SizedBox(height: 4,),
              Text("@sangvaleap",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  color: CupertinoTheme.of(context).textTheme.tabLabelTextStyle.color,
                  fontWeight: FontWeight.w500
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20,),
        Card(
          shape: BeveledRectangleBorder(borderRadius:  BorderRadius.circular(5)),
          margin: EdgeInsetsDirectional.only(start: 10, end: 10),
          color: CupertinoTheme.of(context).barBackgroundColor,
          child: Padding(
            padding: const EdgeInsetsDirectional.only(start: 16, end: 16),
            child: Column(children: controller.listSettingsSectionOne.map((SettingItem e) {
              return Column(children: [
                e,
                if(!e.isLast)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: 45),
                    child: Divider(height: 0, color: CupertinoColors.separator,),
                  ),
              ],);
            }).toList(),
            ),
          ),
        ),
        SizedBox(height: 20,),
        Card(
          shape: BeveledRectangleBorder(borderRadius:  BorderRadius.circular(5)),
          margin: EdgeInsetsDirectional.only(start: 10, end: 10),
          color: CupertinoTheme.of(context).barBackgroundColor,
          child: Padding(
            padding: const EdgeInsetsDirectional.only(start: 16, end: 16),
            child: Column(children: controller.listSettingsSectionTwo.map((SettingItem e) {
              return Column(children: [
                e,
                if(!e.isLast)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: 45),
                    child: Divider(height: 0, color: CupertinoColors.separator,),
                  ),
              ],);
            }).toList(),
            ),
          ),
        ),
        SizedBox(height: 20,),
        Card(
          shape: BeveledRectangleBorder(borderRadius:  BorderRadius.circular(5)),
          margin: EdgeInsetsDirectional.only(start: 10, end: 10),
          color: CupertinoTheme.of(context).barBackgroundColor,
          child: Padding(
            padding: const EdgeInsetsDirectional.only(start: 16, end: 16),
            child: SettingItem(title: "log_out".tr, leadingIcon: Icons.logout_outlined, bgIconColor: CupertinoColors.systemPink.darkColor,
              onTap: ()=> controller.signOut(),
            ),
          ),
        ),
        SizedBox(height: 10,),
      ],
    );
  }
}
