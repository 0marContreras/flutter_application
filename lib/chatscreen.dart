import 'dart:js_util';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController textcontroller = TextEditingController();
  final List<String> messages = <String>[];
  late IO.Socket socket;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    socket = IO.io("http://localhost:3000", <String, dynamic>{
      "transports": ['websocket'],
      "autoConnect": false,
    });

    socket.connect();
    socket.on("message", (data) {
      setState(() {
        messages.add(data);
      });
    });
  }

  @override
  void dispose() {
    socket.dispose();
    super.dispose();
    _focusNode.dispose();
  }

  void _sendMessage() {
    if (textcontroller.text.isNotEmpty) {
      socket.emit("message", textcontroller.text);
      textcontroller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 22, 21, 21),
        appBar: AppBar(title: const Text("hola"), backgroundColor:Color.fromARGB(255, 0, 0, 0)),
        body: Column(
          children: <Widget>[
            Expanded(
                child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(messages[index]),
                );
              },
            )),
            Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                        child: TextField(
                            controller: textcontroller,
                            focusNode: _focusNode,
                            decoration: InputDecoration(
                                hintText: "send message",
                                hintStyle: TextStyle(color: Colors.blueGrey),
                                filled: true,
                                fillColor: Color(0xFF40444B),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  borderSide: BorderSide.none
                                ),
                                ),
                                onSubmitted: (value) => _sendMessage(),
                                )),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blueGrey
                      ),
                      onPressed: _sendMessage,
                      child: const Text('Send'),
                    )
                  ],
                ))
          ],
        ));
  }
}
