import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

const String appId = "YOUR_AGORA_APP_ID"; // Replace with your Agora App ID
const String token = "YOUR_AGORA_TOKEN"; // Replace with your Agora Token
const String channelName = "test_channel"; // Replace with your channel name

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int? _remoteUid;
  bool _localUserJoined = false;
  late RtcEngine _engine;

  @override
  void initState() {
    super.initState();
    _initAgora();
  }

  Future<void> _initAgora() async {
    // Retrieve permissions
    await [Permission.microphone, Permission.camera].request();

    // Create the engine
    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(appId: appId));

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (
          RtcConnection rtcC,
          int uid,
        ) {
          setState(() {
            _localUserJoined = true;
            print("_localUserJoined => $_localUserJoined");
          });
        },
        onUserJoined: (RtcConnection rtcC, int uid, int elapsed) {
          setState(() {
            _remoteUid = uid;
            print("_remoteUid => $_remoteUid");
          });
        },
        onUserOffline: (RtcConnection rtcConnection, int uid,
            UserOfflineReasonType reason) {
          setState(() {
            _remoteUid = null;
            print("_remoteUid => $_remoteUid");
          });
        },
      ),
    );

    await _engine.joinChannel(
      token: token,
      channelId: channelName,
      uid: 0,
      options: ChannelMediaOptions(),
    );
  }

  // Create UI with a local and remote view
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agora Video Call'),
      ),
      body: Stack(
        children: [
          Center(child: _remoteVideo()),
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              width: 100,
              height: 150,
              child: Center(
                  child: _localUserJoined
                      ? AgoraVideoView(
                          controller: VideoViewController(
                          rtcEngine: _engine,
                          canvas: VideoCanvas(uid: 0),
                        ))
                      : CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return AgoraVideoView(
          controller: VideoViewController(
        rtcEngine: _engine,
        canvas: VideoCanvas(uid: _remoteUid),
      ));
    } else {
      return const Text(
        'Waiting for remote user to join...',
        textAlign: TextAlign.center,
      );
    }
  }
}
