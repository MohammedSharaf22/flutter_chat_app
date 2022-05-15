import 'package:flutter/material.dart';
import 'package:flutter_chat_app/utilities/theme/my_theme.dart';
import 'package:flutter_chat_app/views/pages/chat/message/utilities/get_stat.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;

///New special chat bubble type
///
///chat bubble color can be customized using [color]
///chat bubble tail can be customized  using [tail]
///chat bubble display message can be changed using [text]
///[text] is the only required parameter
///message sender can be changed using [isSender]
///chat bubble [TextStyle] can be customized using [textStyle]

class BubbleTextMessage extends StatelessWidget {
  final bool isSender;
  final String text;
  final Color color;
  final int state;
  final TextStyle textStyle;
  final String time;

  const BubbleTextMessage({
    Key? key,
    required this.isSender,
    required this.text,
    required this.color,
    required this.state,
    this.textStyle = const TextStyle(
      color: Colors.white70,
      fontSize: 16,
    ),
    required this.time,

  }) : super(key: key);

  TextDirection getTextDirection(String text) {
    var detectRtlDirectionality = intl.Bidi.detectRtlDirectionality(text);
    if (detectRtlDirectionality)
      return TextDirection.rtl;
    return TextDirection.ltr;
  }

  Color invertColor(Color color) {
    final r = 255 - color.red;
    final g = 255 - color.green;
    final b = 255 - color.blue;

    return Color.fromARGB((color.opacity * 255).round(), r, g, b);
  }

  ///chat bubble builder method
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSender
          ? AlignmentDirectional.topStart
          : AlignmentDirectional.topEnd,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: CustomPaint(
          painter: SpecialChatBubbleTwo(
            context: context,
            color: color,
            alignment: isSender ? Alignment.topRight : Alignment.topLeft,),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: Get.width * .8,
            ),
            margin: isSender
                ? EdgeInsetsDirectional.fromSTEB(7, 7, 17, 7)
                : EdgeInsetsDirectional.fromSTEB(7, 7, 17, 7),
            child: Stack(
              children: <Widget>[
                Padding(
                  padding: isSender
                      ? EdgeInsetsDirectional.only(end: 65,)
                      : EdgeInsetsDirectional.only(start: 55,),
                  child: Text(
                    text,
                    textDirection: getTextDirection(text),
                    style: textStyle,
                    textAlign: TextAlign.start,
                  ),
                ),
                isSender
                    ? PositionedDirectional(
                    bottom: 0,
                    end: 0,
                    child: Row(
                      children: [
                        Text(time,
                            style: TextStyle(
                              color: dateAndStateColor,
                              fontSize: 10,
                            )),
                        getStateIcon(state),
                      ],
                    )
                )
                    :
                PositionedDirectional(
                  bottom: 0,
                  start: 0,
                  child: Text(time,
                    style: TextStyle(color: dateAndStateColor,
                        fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

///custom painter use to create the shape of the chat bubble
///
/// [color],[alignment] and [tail] can be changed

class SpecialChatBubbleTwo extends CustomPainter {
  final Color color;
  final Alignment alignment;

  final BuildContext context;

  SpecialChatBubbleTwo({
    required this.context,
    required this.color,
    required this.alignment,
  });

  final double _radius = 10.0;

  isRTL() {
    var direction = Directionality.of(context);
    return direction == TextDirection.rtl;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (alignment == Alignment.topRight) {
      canvas.drawRRect(
          RRect.fromLTRBAndCorners(
            isRTL() ? size.width /*- 8*/ : 0,
            0,
            isRTL() ? 8 : size.width - 8,
            size.height,
            bottomLeft: Radius.circular(_radius),
            topRight: Radius.circular(_radius),
            topLeft: Radius.circular(_radius),
            bottomRight: Radius.circular(_radius),
          ),
          Paint()
            ..color = color
            ..style = PaintingStyle.fill);
    } else {
      canvas.drawRRect(
          RRect.fromLTRBAndCorners(
            isRTL() ? size.width /*- 8*/ : 0,
            0,
            isRTL() ? 0 : size.width - 8,
            size.height,
            bottomRight: Radius.circular(_radius),
            topRight: Radius.circular(_radius),
            topLeft: Radius.circular(_radius),
            bottomLeft: Radius.circular(_radius),
          ),
          Paint()
            ..color = color
            ..style = PaintingStyle.fill);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
