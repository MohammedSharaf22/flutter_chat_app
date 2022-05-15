import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/views/pages/chat/message/model/message.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';

class PhotoFullView extends StatelessWidget {
  const PhotoFullView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var arguments = Get.arguments as Map<String, dynamic>;
    Message message = arguments['message'];
    File imageFile= arguments['imageFile'];
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(backgroundColor: Colors.black.withOpacity(.1)),
      child: PhotoView(
        imageProvider: FileImage(imageFile),
        heroAttributes: PhotoViewHeroAttributes(
            tag: 'ImageMessage_${message.messageId}'),

      ),
    );
  }
}
