import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LottieAnimation extends StatefulWidget {
  final String lottieName;
  final double height;
  final double width;
  final bool repeat;

   const LottieAnimation({
    Key? key,
    required this.lottieName,
    required this.height,
    required this.width,
    this.repeat = false,
  }) : super(key: key);

  @override
  State<LottieAnimation> createState() => _LottieAnimationState();
}

class _LottieAnimationState extends State<LottieAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Lottie.asset(
        "assets/images/${widget.lottieName}",
        controller: controller,
        onLoaded: (composition) {
          if(widget.repeat) {
            controller..duration =  composition.duration..repeat();
          }
          else{
            controller..duration = composition.duration..forward();
          }
          //debugPrint("Lottie Duration: ${composition.duration}");
        },
        height: widget.height,
        width: widget.width,
        repeat: false,
      ),
    );
  }
}
