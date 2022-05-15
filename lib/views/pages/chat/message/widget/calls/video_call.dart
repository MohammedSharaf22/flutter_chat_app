import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/views/pages/chat/message/utilities/agora_manager.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as rtc_local_view;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as rtc_remote_view;

class VideoCall extends StatefulWidget {
  const VideoCall({Key? key}) : super(key: key);

  @override
  _VideoCallState createState() => _VideoCallState();
}

class _VideoCallState extends State<VideoCall> {
  late int _remoteUid = 0;
  late RtcEngine _engine;
  bool muted = false;

  @override
  void initState() {
    initAgora();
    super.initState();
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    super.dispose();
  }

  //Functions
  Future<void> initAgora() async {
    await [Permission.microphone, Permission.camera].request();
    _engine = await RtcEngine.create(AgoraManager.appId);

    _engine.setEventHandler(
      RtcEngineEventHandler(
        joinChannelSuccess: (String channel, int uid, int elapsed) {
          debugPrint('local user $uid joined successfully');
        },
        userJoined: (int uid, int elapsed) {
          // player.stop();
          debugPrint('remote user $uid joined successfully');
          setState(() => _remoteUid = uid);
        },
        userOffline: (int uid, UserOfflineReason reason) {
          debugPrint('remote user $uid left call');
          setState(() => _remoteUid = 0);
          Get.back();
          //Navigator.of(context).pop(true);
        },
        /*rtcStats: (stats) {
          //updates every two seconds
          if (_showStats) {
            _stats = stats;
            setState(() {});
          }
        },*/
      ),
    );
    _engine.enableVideo();
    await _engine.joinChannel(AgoraManager.token, AgoraManager.channelName, null, 0);
  }

  //current User View
  Widget _renderLocalPreview() {
    return rtc_local_view.SurfaceView();
  }

//remote User View

  Widget _renderRemoteVideo() {
    if (_remoteUid != 0) {
      return rtc_remote_view.SurfaceView(
        uid: _remoteUid,
        channelId: AgoraManager.channelName,
      );
    } else {
      return Text(
        'Calling …',
        style: Theme.of(context).textTheme.headline6,
        textAlign: TextAlign.center,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: _renderRemoteVideo(),
          ),
          SafeArea(
            child: Align(
              alignment: AlignmentDirectional.bottomStart,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(150.0),
                child: SizedBox(
                    height: 150, width: 150, child: _renderLocalPreview()),
              ),
            ),
          ),
          /*Align(
            alignment: AlignmentDirectional.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 25.0, right: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {
                      Get.back(result: true);
                    },
                    icon: Icon(
                      Icons.call_end,
                      size: 44,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ),
          ),*/
          _toolbar(),
        ],
      ),
    );
  }

  _toolbar(){
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: _onToggleMute,
            child: Icon(
              muted ? Icons.mic_off : Icons.mic,
              color: muted ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          RawMaterialButton(
            onPressed: () => _onCallEnd(),
            child: Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
          ),
          RawMaterialButton(
            onPressed: _onSwitchCamera,
            child: Icon(
              Icons.switch_camera,
              color: Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12.0),
          )
        ],
      ),
    );
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    _engine.muteLocalAudioStream(muted);
  }

  _onCallEnd() {
    Get.back();
  }

  void _onSwitchCamera() {
    _engine.switchCamera();
  }
}