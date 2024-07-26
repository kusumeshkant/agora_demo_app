import 'dart:convert';

import 'package:agora_uikit/agora_uikit.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class VideoScreenPage extends StatefulWidget {
  @override
  _VideoScreenPageState createState() => _VideoScreenPageState();
}

class _VideoScreenPageState extends State<VideoScreenPage> {
  final String appId = "YOUR_AGORA_APP_ID";
  final String channelName = "test";
  String? token;

    // late AgoraClient client;


  // Instantiate the client
  final AgoraClient client = AgoraClient(
    agoraConnectionData: AgoraConnectionData(
        appId: "90c495efaac84b87840ad4d3b1a61d57",
        channelName: "test",
        username: "kant",
        ),
  );

// Initialize the Agora Engine
  @override
  void initState() {
    super.initState();
    fetchToken();
  }

  void fetchToken() async {
    final response = await http.get(Uri.parse('https://agora-token-server-mz8p.onrender.com/getToken'));
    print("response -> $response");
    if (response.statusCode == 200) {
      setState(() {
        token = json.decode(response.body)['token'];
        // client = AgoraClient(
        //   agoraConnectionData: AgoraConnectionData(
        //     appId: appId,
        //     channelName: channelName,
        //     tempToken: token!,
        //   ),
          enabledPermission: [
            Permission.camera,
            Permission.microphone,
          ];

        client.initialize();
      });
    } else {
      throw Exception('Failed to load token');
    }}
  
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              AgoraVideoViewer(
                client: client,
                layoutType: Layout.grid,
                enableHostControls: true,
              ),
              AgoraVideoButtons(
                client: client,
                onDisconnect: () {
                  Navigator.pop(context);
                },
                addScreenSharing: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
