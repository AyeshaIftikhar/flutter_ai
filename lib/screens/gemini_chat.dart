import 'dart:convert';

import 'package:flutter/rendering.dart';
import 'package:flutter_ai/services/gemini_services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class GeminiMsgScreen extends StatefulWidget {
  const GeminiMsgScreen({super.key});

  @override
  State<GeminiMsgScreen> createState() => _GeminiMsgScreenState();
}

class _GeminiMsgScreenState extends State<GeminiMsgScreen> {
  final TextEditingController chatController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  List<Map<String, dynamic>> chatHistory = [];

  sendMessage() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (chatController.text.isNotEmpty) {
      chatHistory.add({
        "time": DateTime.now(),
        "message": chatController.text,
        "isSender": true,
      });
      chatController.clear();
    }
    if (mounted) setState(() {});
    if (scrollController.hasClients) {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    }
    if (mounted) setState(() {});
    getResponses();
  }

  void getResponses() async {
    final url =
        "https://generativelanguage.googleapis.com/v1beta2/models/chat-bison-001:generateMessage?key=${GeminiServices.apikey}";
    final uri = Uri.parse(url);
    List<Map<String, String>> msg = [];
    for (var i = 0; i < chatHistory.length; i++) {
      msg.add({"content": chatHistory[i]["message"]});
    }
    Map<String, dynamic> request = {
      "prompt": {
        "messages": [msg]
      },
      "temperature": 0.25,
      "candidateCount": 1,
      "topP": 1,
      "topK": 1
    };
    chatHistory.add({
      "time": DateTime.now(),
      "message": 'typing',
      "isSender": false,
    });
    if (scrollController.hasClients) {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    }
    final response = await http.post(uri, body: jsonEncode(request));
    chatHistory.removeLast();
    chatHistory.add({
      "time": DateTime.now(),
      "message": json.decode(response.body)["candidates"][0]["content"],
      "isSender": false,
    });
    if (mounted) setState(() {});
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(microseconds: 1),
        curve: Curves.linear,
      );
    }
    if (mounted) setState(() {});
  }

  double previousScrollPosition = 0.0;
  ScrollDirection scrollDirection = ScrollDirection.idle;
  void onScroll() {
    double currentScrollPosition = scrollController.position.pixels;
    if (currentScrollPosition > previousScrollPosition) {
      scrollDirection = ScrollDirection.forward;
      if (mounted) setState(() {});
    } else if (currentScrollPosition < previousScrollPosition) {
      scrollDirection = ScrollDirection.reverse;
      if (mounted) setState(() {});
    }

    previousScrollPosition = currentScrollPosition;
  }

  @override
  void initState() {
    scrollController.addListener(onScroll);
    if (mounted) setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat with Gemini AI')),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          left: 15,
          right: 15,
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: TextFormField(
                  maxLines: null,
                  controller: chatController,
                  keyboardType: TextInputType.multiline,
                  onChanged: (value) => setState(() {}),
                  textInputAction: TextInputAction.send,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: "Type a message",
                    contentPadding: const EdgeInsets.all(12.0),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
              ),
              if (chatController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: InkWell(
                    onTap: () => sendMessage(),
                    child: const CircleAvatar(child: Icon(Icons.send)),
                  ),
                ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: chatHistory.isEmpty
            ? const Center(
                child: Text('Start conservating with Gemini...'),
              )
            : ListView.builder(
                itemCount: chatHistory.length,
                controller: scrollController,
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.only(
                      left: 14,
                      right: 14,
                      top: 10,
                      bottom: 10,
                    ),
                    child: Align(
                      alignment: (chatHistory[index]["isSender"]
                          ? Alignment.topRight
                          : Alignment.topLeft),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                          color: chatHistory[index]["isSender"]
                              ? Colors.pink
                              : Colors.white,
                        ),
                        child: Text(
                          chatHistory[index]["message"],
                          style: TextStyle(
                            fontSize: 15,
                            color: chatHistory[index]["isSender"]
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
