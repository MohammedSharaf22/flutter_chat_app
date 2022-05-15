import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_chat_app/main.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class SquareCameraWidget extends StatefulWidget {
  final Color borderColor;
  final Size size;
  final double borderRadius;
  final double borderWidth;

  const SquareCameraWidget({
    Key? key,
    this.borderColor = Colors.black,
    this.size = const Size.square(100),
    this.borderRadius = 10, 
    this.borderWidth = 1,
  }) : super(key: key);

  @override
  _SquareCameraWidgetState createState() => _SquareCameraWidgetState();
}

class _SquareCameraWidgetState extends State<SquareCameraWidget> {
  late CameraController controller;

  @override
  void initState() {
    super.initState();
    controller = CameraController(cameras[0], ResolutionPreset.medium);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: widget.size.width,
            height: widget.size.height,
            foregroundDecoration: BoxDecoration(
              border: Border.all(width: widget.borderWidth, color: widget.borderColor),
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            child: getChild(),
          ),
          Icon(CupertinoIcons.camera_fill, size: 40, color: CupertinoColors.white.withOpacity(.5)),
        ],
      ),
    );
  }

  getChild(){
    if (!controller.value.isInitialized) {
      return Center(child: Text(
        'Error',
        style: Theme.of(context).textTheme.headline6,
      ),);
    }
    return AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: CameraPreview(controller)
    );
  }
}