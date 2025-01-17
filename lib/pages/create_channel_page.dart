import 'dart:convert';
import 'dart:math';

import 'package:agora_viedio_app/widgets/pre_joining_dialog.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class CreateChannelPage extends StatefulWidget {
  const CreateChannelPage({super.key});

  @override
  State<CreateChannelPage> createState() => _CreateChannelPageState();
}

class _CreateChannelPageState extends State<CreateChannelPage> {
  final _formKey = GlobalKey<FormState>();

  late final FocusNode _unfocusNode;
  late final TextEditingController _channelNameController;

  bool _isCreatingChannel = false;

  @override
  void initState() {
    super.initState();
    _unfocusNode = FocusNode();
    _channelNameController = TextEditingController();
  }

  @override
  void dispose() {
    _unfocusNode.dispose();
    super.dispose();
  }

  void _showSnackBar(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }

  String? _channelNameValidator(value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a channel name';
    } else if (value.length > 64) {
      return 'Channel name must be less than 64 characters';
    }
    return null;
  }

  Future<void> _joinRoom() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    FocusScope.of(context).requestFocus(_unfocusNode);
    setState(() => _isCreatingChannel = true);
    // final input = <String, dynamic>{
    //   'channelName': _channelNameController.text,
    //   'expiryTime': 3600, // 1 hour
    // };
    try {
      late final token;
      final channelName = _channelNameController.text;

      Random random = new Random();
      int uid = random.nextInt(1000);

      var body = {
        "tokenType": "rtc",
        "channel": channelName,
        "role": "publisher", // "publisher" or "subscriber"
        "uid": "$uid",
        "expire": 3600 // optional: expiration time in seconds (default: 3600)
      };

      final url = "https://agora-token-server-mz8p.onrender.com/getToken";
      // final url = 'http://localhost:8080/access_token?channelName=$channelName&uid=0';
      final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
      print("response:- ${response.body}");
      if (response.statusCode == 200) {
        setState(() {
          final tk = json.decode(response.body)['token'];
          token = tk;
          print("token = $token");

          // client.agoraConnectionData.tempToken = token;
        });
        // await client.initialize();
      } else {
        throw Exception('Failed to load token');
      }
      if (token != null) {
        if (context.mounted) {
          _showSnackBar(
            context,
            'Token generated successfully!',
          );
        }
        await Future.delayed(
          const Duration(seconds: 1),
        );
        if (context.mounted) {
          await showDialog(
            context: context,
            builder: (context) => PreJoiningDialogs(
              channelName: _channelNameController.text,
              token: token,
              uid: uid,
            ),
          );
        }
      }
    } catch (e) {
      _showSnackBar(
        context,
        'Error generating token: $e',
      );
    } finally {
      setState(() => _isCreatingChannel = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(_unfocusNode),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
        ),
        body: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: screenSize.width,
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding:
                    const EdgeInsetsDirectional.symmetric(horizontal: 24.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                          0.0,
                          30.0,
                          0.0,
                          8.0,
                        ),
                        child: Text(
                          'Create Channel',
                          style: TextStyle(
                            fontSize: 32.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsetsDirectional.only(bottom: 24.0),
                        child: Text(
                          'Enter a channel name to generate token. The token will be valid for 1 hour.',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16.0,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                      Form(
                        key: _formKey,
                        child: TextFormField(
                          autofocus: true,
                          controller: _channelNameController,
                          obscureText: false,
                          decoration: InputDecoration(
                            labelText: 'Channel Name',
                            labelStyle: const TextStyle(
                              color: Colors.blue,
                              fontSize: 16.0,
                              fontWeight: FontWeight.normal,
                            ),
                            hintText: 'Enter your channel name...',
                            hintStyle: const TextStyle(
                              color: Color(0xFF57636C),
                              fontSize: 16.0,
                              fontWeight: FontWeight.normal,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.blue,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.blue,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16.0,
                            fontWeight: FontWeight.normal,
                          ),
                          keyboardType: TextInputType.text,
                          validator: _channelNameValidator,
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      _isCreatingChannel
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [CircularProgressIndicator()],
                            )
                          : SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                ),
                                onPressed: _joinRoom,
                                child: const Text('Join Room'),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
