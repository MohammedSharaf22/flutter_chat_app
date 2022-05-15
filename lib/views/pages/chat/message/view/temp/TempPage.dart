import 'dart:io';
import 'dart:math' as math;
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_app/views/pages/chat/message/view/temp/Temp_2.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart' as jsAudio;
import 'package:path/path.dart' as p;
import 'package:just_waveform/just_waveform.dart';
import 'package:rxdart/rxdart.dart';

class TempPage extends StatefulWidget {
  const TempPage({Key? key}) : super(key: key);

  @override
  State<TempPage> createState() => _TempPageState();
}

class _TempPageState extends State<TempPage> {
  String url="https://firebasestorage.googleapis.com/v0/b/flutter-chat-app-338817.appspot.com/o/audio%2FKUP2csE0BhRoqaGXFyo1xNLjKPA2_10CfP4xhvLPcSzdb4EOPhbQ4lOM2%2F0YehkvQhq1aCVeOoAEBQ.m4a?alt=media&token=ee5b3b21-d5d4-4846-a364-9751af053c02";
  String url2="https://firebasestorage.googleapis.com/v0/b/flutter-chat-app-338817.appspot.com/o/audio%2FKUP2csE0BhRoqaGXFyo1xNLjKPA2_10CfP4xhvLPcSzdb4EOPhbQ4lOM2%2FP8RVOc4KnHbpbj6Kvd9T.m4a?alt=media&token=3ea0a4bd-b962-4abe-bfc4-483b102420b1";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        height: Get.height,
        width: Get.width,
        child: Material(
          type: MaterialType.transparency,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              VoiceMessagePlayer(
                audioSrc: url,
                me: true,
              ),
              /*VoiceMessagePlayer(
                audioSrc: url2,
                me: true,
              ),*/
            ],
          ),
        ),
      ),
    );
  }
}



class VoiceMessagePlayer extends StatefulWidget {
  VoiceMessagePlayer({
    Key? key,
    required this.audioSrc,
    required this.me,
    this.noiseCount = 27,
    this.meBgColor = Colors.pink,
    this.contactBgColor = const Color(0xffffffff),
    this.contactFgColor = Colors.pink,
    this.mePlayIconColor = Colors.black,
    this.contactPlayIconColor = Colors.black26,
    this.meFgColor = const Color(0xffffffff),
    this.played = false,
    this.onPlay,
  }) : super(key: key);

  final String audioSrc;
  final int noiseCount;
  final Color meBgColor,
      meFgColor,
      contactBgColor,
      contactFgColor,
      mePlayIconColor,
      contactPlayIconColor;
  final bool played, me;
  Function()? onPlay;

  @override
  _VoiceMessagePlayerState createState() => _VoiceMessagePlayerState();
}

class _VoiceMessagePlayerState extends State<VoiceMessagePlayer>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _player = AudioPlayer();
  final double maxNoiseHeight = 6.w(), noiseWidth = 26.5.w();
  Duration? _audioDuration;
  double maxDurationForSlider = .0000001;
  bool _isPlaying = false, x2 = false, _audioConfigurationDone = false;
  int _playingStatus = 0, duration = 00;
  String _remaingTime = '';
  //AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    _setDuration();
  }

  @override
  Widget build(BuildContext context) => _sizerChild(context);

  Container _sizerChild(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: .8.w()),
      constraints: BoxConstraints(maxWidth: 100.w() * .7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(6.w()),
          bottomLeft:
          widget.me ? Radius.circular(6.w()) : Radius.circular(2.w()),
          bottomRight:
          !widget.me ? Radius.circular(6.w()) : Radius.circular(1.2.w()),
          topRight: Radius.circular(6.w()),
        ),
        color: widget.me ? widget.meBgColor : widget.contactBgColor,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 4.w(),
          vertical: 2.8.w(),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              child: Icon(CupertinoIcons.play_circle_fill),
              onPressed: (){
                _changePlayingStatus();
              },
            ),
            //_playButton(context),
            SizedBox(width: 3.w()),
            _durationWithNoise(context),
            SizedBox(width: 2.2.w()),
            // _speed(context),
          ],
        ),
      ),
    );
  }

  _playButton(BuildContext context) => InkWell(
    child: Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.me ? widget.meFgColor : widget.contactFgColor,
      ),
      width: 8.w(),
      height: 8.w(),
      child: InkWell(
        onTap: () =>
        !_audioConfigurationDone ? null : _changePlayingStatus(),
        child: !_audioConfigurationDone
            ? Container(
          padding: const EdgeInsets.all(8),
          width: 10,
          height: 0,
          child: CircularProgressIndicator(
            strokeWidth: 1,
            color:
            widget.me ? widget.meFgColor : widget.contactFgColor,
          ),
        )
            : Icon(
          _isPlaying ? Icons.pause : Icons.play_arrow,
          color: widget.me
              ? widget.mePlayIconColor
              : widget.contactPlayIconColor,
          size: 5.w(),
        ),
      ),
    ),
  );

  _durationWithNoise(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _noise(context),
      SizedBox(height: .3.w()),
      Row(
        children: [
          if (!widget.played)
            Widgets.circle(context, 1.w(),
                widget.me ? widget.meFgColor : widget.contactFgColor),
          SizedBox(width: 1.2.w()),
          Text(
            _remaingTime,
            style: TextStyle(
              fontSize: 10,
              color: widget.me ? widget.meFgColor : widget.contactFgColor,
            ),
          )
        ],
      ),
    ],
  );

  _noise(BuildContext context) {

    /// document will be added
    return StreamBuilder<WaveformProgress>(
      stream: progressStream,
      builder: (context, snapshot) {
        final progress = snapshot.data?.progress ?? 0.0;
        final waveform = snapshot.data?.waveform;
        if (snapshot.hasData && waveform!=null) {
          //assert(waveform ==null);
          /// document will be added
          final ThemeData theme = Theme.of(context);
          final newTHeme = theme.copyWith(
            sliderTheme: SliderThemeData(
              trackHeight: 150,
              activeTrackColor: Colors.blue,
              inactiveTrackColor: Colors.white12,
              //disabledInactiveTrackColor: Colors.white12,
              trackShape: AudioWaveformSliderTrackShape(
                  waveform: waveform,
                  start: Duration.zero,
                  duration: waveform.duration) ,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.0),

              //thumbShape: SliderComponentShape.noThumb,
              //minThumbSeparation: 0,
            ),
          );
          //setState(() {
            _audioDuration=waveform.duration;
            duration = _audioDuration!.inSeconds;
          //});

          return Theme(
            data: newTHeme,
            child: Container(
              height: 6.5.w(),
              width: noiseWidth,

              child: Slider(
                min: 0.0,
                max: waveform.duration.inSeconds.toDouble(),
                value: duration.toDouble(),
                //onChangeStart: (__) => _stopPlaying(),
                //onChanged: (value) => _onChangeSlider(value),
                onChanged: (value){
                  setState(() {
                    duration= value.toInt();
                    _player.seek(Duration(seconds: duration));
                  });
                },
              )),
          );

          /*return Theme(
            data: newTHeme,
            child: SizedBox(
              height: 6.5.w(),
              width: noiseWidth,
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  *//*widget.me ?*//* const Noises() *//*: const ContactNoise()*//*,
                  if (_audioConfigurationDone)
                    AnimatedBuilder(
                      animation:
                      CurvedAnimation(parent: _controller!, curve: Curves.ease),
                      builder: (context, child) {
                        return Positioned(
                          left: _controller!.value,
                          child: Container(
                            width: noiseWidth,
                            height: 6.w(),
                            color: widget.me
                                ? widget.meBgColor.withOpacity(.4)
                                : widget.contactBgColor.withOpacity(.35),
                          ),
                        );
                      },
                    ),
                  Opacity(
                    opacity: .0,
                    child: Container(
                      width: noiseWidth,
                      color: Colors.amber.withOpacity(1),
                      child: Slider(
                        min: 0.0,
                        max: maxDurationForSlider,
                        onChangeStart: (__) => _stopPlaying(),
                        onChanged: (_) => _onChangeSlider(_),
                        value: duration + .0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );*/
        }
        return Center(
          child: Text(
            '${(100 * progress).toInt()}%',
            style: Theme.of(context).textTheme.headline6,
          ),
        );
      }
    );
  }

  // _speed(BuildContext context) => InkWell(
  //       onTap: () => _toggle2x(),
  //       child: Container(
  //         alignment: Alignment.center,
  //         padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.6.w),
  //         decoration: BoxDecoration(
  //           borderRadius: BorderRadius.circular(2.8.w),
  //           color: widget.meFgColor.withOpacity(.28),
  //         ),
  //         width: 9.8.w,
  //         child: Text(
  //           !x2 ? '1X' : '2X',
  //           style: TextStyle(fontSize: 9.8, color: widget.meFgColor),
  //         ),
  //       ),
  //     );

  _setPlayingStatus() => _isPlaying = _playingStatus == 1;

  _startPlaying() async {
    var path="/storage/emulated/0/Messages App/audio/KUP2csE0BhRoqaGXFyo1xNLjKPA2_10CfP4xhvLPcSzdb4EOPhbQ4lOM2";

    _playingStatus = await _player.play(p.join(path, "cKfZEX7urExvymX5G3AB.m4a")/*widget.audioSrc*/);
    _setPlayingStatus();
    //_controller!.forward();
  }

  _stopPlaying() async {
    _playingStatus = await _player.pause();
    //_controller!.stop();
  }

  final progressStream = BehaviorSubject<WaveformProgress>();
  void _setDuration() async {
    var path="/storage/emulated/0/Messages App/audio/KUP2csE0BhRoqaGXFyo1xNLjKPA2_10CfP4xhvLPcSzdb4EOPhbQ4lOM2";
    final audioFile =
    File(p.join(path, "cKfZEX7urExvymX5G3AB.m4a"));
    //File(p.join(path, "waveform.mp3"));
    try {
      //await audioFile.writeAsBytes((await rootBundle.load('audio/waveform.mp3')).buffer.asUint8List());
      //await audioFile.writeAsBytes((await rootBundle.load('assets/avatars/waveform.mp3')).buffer.asUint8List());
      final waveFile = File(p.join(path, 'waveform.wave'));
      JustWaveform.extract(audioInFile: audioFile, waveOutFile: waveFile)
          .listen(progressStream.add, onError: (e, StackTrace stackTrace){
        //debugPrintStack(stackTrace: StackTrace.current);
        debugPrint("TempPage2 onError $e"+ stackTrace.toString());
        progressStream.addError(e, stackTrace);
      });
    } catch (e) {//MissingPluginException
      debugPrint("TempPage2 Error $e");
      progressStream.addError(e);
    }

    _audioDuration = await jsAudio.AudioPlayer().setUrl(p.join(path, "cKfZEX7urExvymX5G3AB.m4a")/*widget.audioSrc*/);
    duration = _audioDuration!.inSeconds;
    maxDurationForSlider = duration + .0;

    /// document will be added
    /*_controller = AnimationController(
      vsync: this,
      lowerBound: 0,
      upperBound: noiseWidth,
      duration: _audioDuration,
    );*/

    /// document will be added
    /*_controller!.addListener(() {
      if (_controller!.isCompleted) {
        _controller!.reset();
        _isPlaying = false;
        x2 = false;
        setState(() {});
      }
    });*/
    //_setAnimationCunfiguration(_audioDuration);
  }

  void _setAnimationCunfiguration(Duration? audioDuration) async {
    _listenToRemaningTime();
    _remaingTime = VoiceDuration.getDuration(duration);
    _completeAnimationConfiguration();
  }

  void _completeAnimationConfiguration() =>
      setState(() => _audioConfigurationDone = true);

  // void _toggle2x() {
  //   x2 = !x2;
  //   _controller!.duration = Duration(seconds: x2 ? duration ~/ 2 : duration);
  //   if (_controller!.isAnimating) _controller!.forward();
  //   _player.setPlaybackRate(x2 ? 2 : 1);
  //   setState(() {});
  // }

  void _changePlayingStatus() async {
    if (widget.onPlay != null) widget.onPlay!();
    _isPlaying ? _stopPlaying() : _startPlaying();
    setState(() => _isPlaying = !_isPlaying);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _listenToRemaningTime() {
    _player.onAudioPositionChanged.listen((Duration p) {
      setState(() {
        duration=p.inSeconds;
      });
      final _newRemaingTime1 = p.toString().split('.')[0];
      final _newRemaingTime2 =
      _newRemaingTime1.substring(_newRemaingTime1.length - 5);
      if (_newRemaingTime2 != _remaingTime)
        setState(() => _remaingTime = _newRemaingTime2);
    });
  }

  /// document will be added
  _onChangeSlider(double d) async {
    if (_isPlaying) _changePlayingStatus();
    //_controller?.value = (noiseWidth) * duration / maxDurationForSlider;
    setState(() {
      duration = d.round();
      _remaingTime = VoiceDuration.getDuration(duration);
      _player.seek(Duration(seconds: duration));
    });
    setState(() {});
  }
}

/// document will be added
class CustomTrackShape extends RoundedRectSliderTrackShape {

  /// document will be added
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    const double trackHeight = 10;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }




}


class AudioWaveformSliderTrackShape extends SliderTrackShape  {
  final double scale;
  final double strokeWidth;
  final double pixelsPerStep;
  final Paint wavePaint;
  final Waveform waveform;
  final Duration start;
  final Duration duration;

  AudioWaveformSliderTrackShape({
    required this.waveform,
    required this.start,
    required this.duration,
    Color waveColor = Colors.blue,
    this.scale = 1.0,
    this.strokeWidth = 5.0,
    this.pixelsPerStep = 8.0,
  }) : wavePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = strokeWidth
    ..strokeCap = StrokeCap.round
    ..color = waveColor;

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = true,
    bool isDiscrete = true,
  }) {
    const double trackHeight = 10;
    final double trackLeft = offset.dx;
    final double trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }

  @override
  void paint(PaintingContext context, Offset offset,
      {required RenderBox parentBox,
        required SliderThemeData sliderTheme,
        required Animation<double> enableAnimation,
        required TextDirection textDirection,
        required Offset thumbCenter,
        bool isDiscrete = true,
        bool isEnabled = true,
        double additionalActiveTrackHeight = 2}) {


    assert(context != null);
    assert(offset != null);
    assert(parentBox != null);
    assert(sliderTheme != null);
    assert(sliderTheme.disabledActiveTrackColor != null);
    assert(sliderTheme.disabledInactiveTrackColor != null);
    assert(sliderTheme.activeTrackColor != null);
    assert(sliderTheme.inactiveTrackColor != null);
    assert(sliderTheme.thumbShape != null);
    assert(enableAnimation != null);
    assert(textDirection != null);
    assert(thumbCenter != null);
    assert(isEnabled != null);
    assert(isDiscrete != null);
    // If the slider [SliderThemeData.trackHeight] is less than or equal to 0,
    // then it makes no difference whether the track is painted or not,
    // therefore the painting can be a no-op.
    if (sliderTheme.trackHeight! <= 0) {
      return;
    }

    // Assign the track segment paints, which are left: active, right: inactive,
    // but reversed for right to left text.
    final ColorTween activeTrackColorTween = ColorTween(begin: sliderTheme.disabledActiveTrackColor, end: sliderTheme.activeTrackColor);
    final ColorTween inactiveTrackColorTween = ColorTween(begin: sliderTheme.disabledInactiveTrackColor, end: sliderTheme.inactiveTrackColor);
    final Paint activePaint = Paint()..color = activeTrackColorTween.evaluate(enableAnimation)!
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final Paint inactivePaint = Paint()..color = inactiveTrackColorTween.evaluate(enableAnimation)!
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final Paint leftTrackPaint;
    final Paint rightTrackPaint;
    switch (textDirection) {
      case TextDirection.ltr:
        leftTrackPaint = activePaint;
        rightTrackPaint = inactivePaint;
        break;
      case TextDirection.rtl:
        leftTrackPaint = inactivePaint;
        rightTrackPaint = activePaint;
        break;
    }

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );


    final Rect leftTrackSegment = Rect.fromLTRB(trackRect.left, trackRect.top, thumbCenter.dx, trackRect.bottom);
    //if (!leftTrackSegment.isEmpty)
      //context.canvas.drawRect(leftTrackSegment, leftTrackPaint);
    final Rect rightTrackSegment = Rect.fromLTRB(thumbCenter.dx, trackRect.top, trackRect.right, trackRect.bottom);
    //if (!rightTrackSegment.isEmpty)
      //context.canvas.drawRect(rightTrackSegment, rightTrackPaint);

    if (duration == Duration.zero) return;



    double width = trackRect.width;
    double height = sliderTheme.trackHeight!;

    final waveformPixelsPerWindow = trackRect.right;//waveform.positionToPixel(waveform.duration).toInt();
    final waveformPixelsPerDevicePixel = waveformPixelsPerWindow / width;
    final waveformPixelsPerStep = waveformPixelsPerDevicePixel * pixelsPerStep;
    final sampleOffset = waveform.positionToPixel(start);
    final sampleStart = -sampleOffset % waveformPixelsPerStep;

    debugPrint("sampleOffset= $sampleOffset");
    debugPrint("sampleStart= $sampleStart");
    debugPrint("waveformPixelsPerWindow= $waveformPixelsPerWindow");
    debugPrint("waveformPixelsPerDevicePixel= $waveformPixelsPerDevicePixel");
    debugPrint("trackRect.top= ${trackRect.top}");
    debugPrint("trackRect.bottom= ${trackRect.bottom}");
    try{
      for (var i = trackRect.right;
      i > thumbCenter.dx/*waveformPixelsPerWindow*/ + 1.0;
      i -= waveformPixelsPerStep) {
        final sampleIdx = (sampleOffset + i).toInt();
        final x = i / waveformPixelsPerDevicePixel;
        final minY = normalise(waveform.getPixelMin(sampleIdx), height);
        final maxY = normalise(waveform.getPixelMax(sampleIdx), height);
        if (!rightTrackSegment.isEmpty)
          context.canvas.drawLine(
            Offset(x + strokeWidth / 2, max(strokeWidth * 0.75, minY)),
            Offset(x + strokeWidth / 2, min(height - strokeWidth * 0.75, maxY)),
            rightTrackPaint,
          );
      }

      for (var i = trackRect.left;
      i <= thumbCenter.dx/*waveformPixelsPerWindow*/ + 1.0;
      i += waveformPixelsPerStep) {
        final sampleIdx = (sampleOffset + i).toInt();
        final x = i / waveformPixelsPerDevicePixel;
        final minY = normalise(waveform.getPixelMin(sampleIdx), height);
        final maxY = normalise(waveform.getPixelMax(sampleIdx), height);

        if (!leftTrackSegment.isEmpty)
          context.canvas.drawLine(
            Offset(x + strokeWidth / 2, max(strokeWidth * 0.75, minY)),
            Offset(x + strokeWidth / 2, min(height - strokeWidth * 0.75, maxY)),
            leftTrackPaint,
          );
      }
    }catch(e){
      debugPrint("$e");
    }
  }


  /*@override
  bool shouldRepaint(covariant AudioWaveformPainter oldDelegate) {
    return false;
  }*/

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


class Widgets {
  /// document will be added
  static circle(
      BuildContext context,
      double width,
      Color color, {
        Widget child = const SizedBox(),
      }) =>
      Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        child: child,
        width: width,
        height: width,
      );
}

class VoiceDuration {
  /// document will be added
  static String getDuration(int duration) => duration < 60
      ? '00:' + (duration.toString())
      : (duration ~/ 60).toString() + ':' + (duration % 60).toString();
}



class Noises extends StatelessWidget {
  const Noises({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [for (int i = 0; i < 27; i++) _singleNoise(context)],
    );
  }

  _singleNoise(BuildContext context) {
    final double height = 5.74.w() * math.Random().nextDouble() + .26.w();
    return Container(
      margin: EdgeInsets.symmetric(horizontal: .2.w()),
      width: .56.w(),
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(1000),
        color: Colors.white,
      ),
    );
  }
}


final MediaQueryData media =
MediaQueryData.fromWindow(WidgetsBinding.instance!.window);

/// this extention help us to make widget responsive.
extension NumberParsing on num {
  double w() => this * media.size.width / 100;

  double h() => this * media.size.height / 100;
}

