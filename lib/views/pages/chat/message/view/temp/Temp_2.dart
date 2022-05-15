import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/utilities/files.dart';
import 'package:flutter_chat_app/views/pages/chat/message/view/temp/TempPage.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:rxdart/rxdart.dart';
import 'package:just_waveform/just_waveform.dart';


class TempPage2 extends StatefulWidget {
  const TempPage2({
    Key? key,

  }) : super(key: key);


  @override
  State<TempPage2> createState() => _TempPage2State();
}

class _TempPage2State extends State<TempPage2> {

  double position = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Get.back(), icon: Icon(Icons.arrow_back_ios)),
        title: const Text('Plugin example app'),
      ),
      body: AudioWaveformWidget(
        roomId: "KUP2csE0BhRoqaGXFyo1xNLjKPA2_10CfP4xhvLPcSzdb4EOPhbQ4lOM2",
        messageId: "cKfZEX7urExvymX5G3AB",
        position: position,
        onChanged: (value) {
          /*setState(() {
              position=value;
            });*/
        },
      ),
    );
  }
}


//WaveformSlider
class AudioWaveformWidget extends StatefulWidget {
  final String roomId;
  final String messageId;
  final Color waveColor;
  final double scale;
  final double strokeWidth;
  final double pixelsPerStep;
  final double position;
  final ValueChanged<double> onChanged;

  const AudioWaveformWidget({
    Key? key,
    required this.roomId,
    required this.messageId,
    required this.onChanged,
    required this.position,
    this.waveColor = Colors.blue,
    this.scale = 1.0,
    this.strokeWidth = 5.0,
    this.pixelsPerStep = 8.0,
  }) : super(key: key);

  @override
  State<AudioWaveformWidget> createState() => _AudioWaveformWidgetState();
}

class _AudioWaveformWidgetState extends State<AudioWaveformWidget> {
  final progressStream = BehaviorSubject<WaveformProgress>();
  RxDouble position = 0.0.obs;
  RxDouble duration = 0.0.obs;

  late AudioPlayer audioPlayer;

  late File waveFile;
  RxBool isPlaying = false.obs;

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    _init();
    var path = "/storage/emulated/0/Messages App/audio";
    audioPlayer.setUrl(
        p.join(path, widget.roomId, widget.messageId + ".wave"), isLocal: true);

    audioPlayer.onDurationChanged.listen((Duration d) {
      debugPrint("onDurationChanged= ${d.inMicroseconds}");
      duration.value = d.inMicroseconds.toDouble();
    });

    audioPlayer.onAudioPositionChanged.listen((event) {
      debugPrint("Sliderposition: ${event.inMicroseconds.toDouble()}");
      position.value = event.inMicroseconds.toDouble();
      /*setState(() {
      });*/
    });

    audioPlayer.onPlayerStateChanged.listen((event) {
      isPlaying.value = event == PlayerState.PLAYING;
      /*setState(() {
      });*/
    });
  }

  @override
  void dispose() {
    //progressStream.close();
    super.dispose();
  }

  Future<void> _init() async {
    //var path="/storage/emulated/0/Messages App/audio/";
    final audioFile = File(await getAudioPath(widget.roomId, widget.messageId));
    //File(p.join(path, "waveform.mp3"));
    try {
      //await audioFile.writeAsBytes((await rootBundle.load('audio/waveform.mp3')).buffer.asUint8List());
      //await audioFile.writeAsBytes((await rootBundle.load('assets/avatars/waveform.mp3')).buffer.asUint8List());
      //final waveFile = File(p.join(widget.roomId, 'waveform.wave'));
      //final waveFile = File(await getAudioPath(widget.roomId, widget.messageId, extension: ".wave"));
      waveFile = File(await getAudioPath(
          widget.roomId, widget.messageId, extension: ".wave"));
      JustWaveform.extract(audioInFile: audioFile, waveOutFile: waveFile)
          .listen(progressStream.add, onError: (e, StackTrace stackTrace) {
        debugPrint("TempPage2 onError $e" + stackTrace.toString());
        progressStream.addError(e, stackTrace);
      });
      //JustWaveform.parse(waveFile);
    } catch (e) { //MissingPluginException
      debugPrint("TempPage2 Error $e");
      progressStream.addError(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    var path = "/storage/emulated/0/Messages App/audio";

    waveFile = File(p.join(path, widget.roomId, widget.messageId + ".wave"));
    //waveFile = File(p.join(path, widget.roomId, widget.messageId+".m4a"));
    var future = JustWaveform.parse(waveFile);


    return Column(
      children: [

      Container(
      alignment: Alignment.center,
      margin: EdgeInsets.all(10),
      child: StreamBuilder<WaveformProgress>(
        stream: progressStream,
        builder: (context, snapshot) {
          final progress = snapshot.data?.progress ?? 0.0;
          final waveform = snapshot.data?.waveform;
          if (waveform == null) {
            return Center(
              child: Text(
                '${(100 * progress).toInt()}%',
                style: Theme
                    .of(context)
                    .textTheme
                    .headline6,
              ),
            );
          }

          final ThemeData theme = Theme.of(context);
          final newTHeme = theme.copyWith(
            sliderTheme: SliderThemeData(
              //trackHeight: 300,
              activeTrackColor: Colors.blue,
              //inactiveTrackColor: Colors.,
              //disabledInactiveTrackColor: Colors.white12,
              trackShape: AudioWaveformSliderTrackShape(
                  waveform: waveform,
                  start: Duration.zero,
                  duration: waveform.duration),
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.0),
              //thumbShape: SliderComponentShape.noThumb,
              //minThumbSeparation: 0,
            ),
          );

          return Theme(
            data: newTHeme,
            child: Obx(() {
              return Container(
                width: Get.width/2,
                height: 300,
                child: Slider(
                  //activeColor: Colors.transparent,
                  //inactiveColor: Colors.transparent,
                  thumbColor: widget.waveColor,
                  min: Duration.zero.inMicroseconds.toDouble(),
                  max: max(duration.value,
                      waveform.duration.inMicroseconds.toDouble()),
                  value: position.value,
                  onChanged: (value) {
                    debugPrint("SliderPosition= ${value.milliseconds
                        .inMicroseconds.toDouble()}");
                    var dur = Duration(microseconds: value.toInt());
                    position.value = dur.inMicroseconds.toDouble();
                    audioPlayer.seek(dur);
                  },
                ),
              );
            }),
          );
        },
      ),
    ),
        Row(
          children: [
            CupertinoButton(
              child: Icon(
                  isPlaying.value ? CupertinoIcons.pause_fill : CupertinoIcons
                      .play_fill),
              onPressed: () {
                if (isPlaying.value) {
                  audioPlayer.stop();
                }
                else
                  audioPlayer.play(
                      p.join(path, widget.roomId, widget.messageId + ".m4a"),
                      isLocal: true);
              },
            ),
            //
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(horizontal: 10),
              child: FutureBuilder<Waveform>(
                future: future,
                builder: (context, snapshot) {
                   if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  final waveform = snapshot.data;
                  if (waveform == null) {
                    return Center(
                      child: Text('${(100).toInt()}%',
                        style: Theme
                            .of(context)
                            .textTheme
                            .headline6,
                      ),
                    );
                  }

                   return ClipRect(
                    child: CustomPaint(
                      painter: AudioWaveformPainter(
                        waveColor: widget.waveColor.withOpacity(.5),
                        waveform: waveform,
                        start: Duration.zero,
                        duration: waveform.duration,
                        scale: widget.scale,
                        strokeWidth: widget.strokeWidth,
                        pixelsPerStep: widget.pixelsPerStep,
                        position: waveform.duration.inMicroseconds.toDouble(),
                      ),
                      child: Obx(() {
                        return CustomPaint(
                          //willChange: true,
                          painter: AudioWaveformPainter(
                            waveColor: widget.waveColor,
                            waveform: waveform,
                            start: Duration.zero,
                            duration: waveform.duration,
                            scale: widget.scale,
                            strokeWidth: widget.strokeWidth,
                            pixelsPerStep: widget.pixelsPerStep,
                            position: position.value,
                          ),
                          child: Slider(
                            activeColor: Colors.transparent,
                            inactiveColor: Colors.transparent,
                            thumbColor: widget.waveColor,
                            min: Duration.zero.inMicroseconds.toDouble(),
                            max: max(duration.value,
                                waveform.duration.inMicroseconds.toDouble()),
                            value: position.value,
                            onChanged: (value) {
                              debugPrint("SliderPosition= ${value.milliseconds
                                  .inMicroseconds.toDouble()}");
                              var dur = Duration(microseconds: value.toInt());
                              position.value = dur.inMicroseconds.toDouble();
                              audioPlayer.seek(dur);
                            },
                          ),
                        );
                      }),
                    ),
                  );
                },
              ),
            ),

          ],
        ),
      ],
    );
  }
}


class AudioWaveformPainter extends CustomPainter {
  final double scale;
  final double strokeWidth;
  final double pixelsPerStep;
  final Paint wavePaint;
  final Waveform waveform;
  final Duration start;
  final Duration duration;
  final double position;
  final Color waveColor;

  AudioWaveformPainter({
    required this.waveform,
    required this.start,
    required this.duration,
    this.waveColor = Colors.blue,
    this.scale = 1.0,
    this.strokeWidth = 5.0,
    this.pixelsPerStep = 8.0,
    this.position = 0,
  }) : wavePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = strokeWidth
    ..strokeCap = StrokeCap.round
    ..color = waveColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (duration == Duration.zero) return;

    double width = size.width;
    double height = size.height;
    debugPrint("height= $height");
    final waveformPixelsPerWindow = waveform.positionToPixel(duration).toInt();
    //debugPrint("waveformPixelsPerWindow= $waveformPixelsPerWindow");
    final waveformPixelsPerDevicePixel = waveformPixelsPerWindow / width;
    //debugPrint("waveformPixelsPerDevicePixel= $waveformPixelsPerDevicePixel");
    final waveformPixelsPerStep = waveformPixelsPerDevicePixel * pixelsPerStep;
    final sampleOffset = waveform.positionToPixel(start);
    final sampleStart = -sampleOffset % waveformPixelsPerStep;

    /*wavePaint.color = waveColor.withOpacity(.5);
    for (var i = sampleStart.toDouble();
    i <= waveformPixelsPerWindow + 1.0;
    i += waveformPixelsPerStep) {
      final sampleIdx = (sampleOffset + i).toInt();
      final x = i / waveformPixelsPerDevicePixel;
      final minY = normalise(waveform.getPixelMin(sampleIdx), height);
      final maxY = normalise(waveform.getPixelMax(sampleIdx), height);
      canvas.drawLine(
        Offset(x + strokeWidth / 2, max(strokeWidth * 0.75, minY)),
        //Offset(x + strokeWidth / 2, min(height - strokeWidth * 0.75, maxY)),
        Offset(x + strokeWidth / 2, min(height - strokeWidth * 0.75, maxY)),
        wavePaint,
      );
    }*/

    //wavePaint.color = Colors.blue;
    var pos = position / duration.inMicroseconds;
    debugPrint("pos= $pos");
    for (var i = sampleStart.toDouble();
    i <= waveformPixelsPerWindow * pos + 1.0;
    i += waveformPixelsPerStep) {
      final sampleIdx = (sampleOffset + i).toInt();
      final x = i / waveformPixelsPerDevicePixel;
      final minY = normalise(waveform.getPixelMin(sampleIdx), height);
      final maxY = normalise(waveform.getPixelMax(sampleIdx), height);
      /*debugPrint("waveform.getPixelMax(sampleIdx)= ${waveform.getPixelMax(sampleIdx)}");
      debugPrint("waveform.getPixelMax= ${2 * sampleIdx + 1}");*/
      canvas.drawLine(
        Offset(x + strokeWidth / 2, max(strokeWidth * 0.75, minY)),
        //Offset(x + strokeWidth / 2, min(height - strokeWidth * 0.75, maxY)),
        Offset(x + strokeWidth / 2, min(height - strokeWidth * 0.75, maxY)),
        wavePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant AudioWaveformPainter oldDelegate) {
    return false;
  }

  double normalise(int s, double height) {
    if (waveform.flags == 0) {
      final y = 32768 + (scale * s).clamp(-32768.0, 32767.0).toDouble();
      return height - 1 - y * height / 65536;
    } else {
      final y = 128 + (scale * s).clamp(-128.0, 127.0).toDouble();
      return height - 1 - y * height / 256;
    }
  }
}