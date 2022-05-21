import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/utilities/theme/my_theme.dart';
import 'package:flutter_chat_app/views/pages/status/controller/status_controller.dart';
import 'package:get/get.dart';
import 'package:flutter_chat_app/utilities/json/chat_json.dart';

class StatusPage extends GetView<StatusController> {
  const StatusPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: NestedScrollView(
        controller: ScrollController(),
        //PageScrollPhysics
        physics: const NeverScrollableScrollPhysics(),
        //NeverScrollableScrollPhysics
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            CupertinoSliverNavigationBar(
              stretch: true,
              leading: CupertinoButton(
                padding: EdgeInsets.zero,
                child: Text(
                  "privacy".tr,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {},
              ),
              middle: Text("status".tr),
              border: Border.all(color: Colors.transparent),
              largeTitle: getSearchBox(),
            ),
          ];
        },
        body: getBody(),
      ),
    );
  }

  getSearchBox() {
    return Container(
      width: double.infinity,
      height: 38,
      padding: EdgeInsetsDirectional.only(end: 15),
      child: CupertinoSearchTextField(
        backgroundColor: fieldBackgroundColor,
        padding: EdgeInsetsDirectional.only(start: 5),
        prefixInsets: EdgeInsetsDirectional.only(start: 5),
        placeholder: "search".tr,
        style: TextStyle(
          fontSize: 14,
        ),
      ),
    );
  }

  Widget getBody() {
    return ListView(
      children: [
        Container(
          height: 80,
          width: double.infinity,
          decoration: BoxDecoration(),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: NetworkImage(profile[0]['img']),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        PositionedDirectional(
                          start: 5,
                          bottom: 0,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.add,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 5),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          "My Status",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          "Add to my status",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.camera_alt,
                          size: 20,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.edit,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 30),
        SizedBox(
          height: 40,
          width: double.infinity,
          child: Center(
            child: Text(
              "No recent updates to show right now.",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
