import 'package:flutter/material.dart';
import 'gemini_chat.dart';
import 'package:flutter_ai/widgets/content_widget.dart';

import '../services/gemini_services.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> prompts = <Map<String, dynamic>>[];
  TextEditingController query = TextEditingController();
  bool addPrompt = false, loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const GeminiMsgScreen()),
              );
            },
            icon: const Icon(Icons.chat),
            tooltip: 'Chat with AI',
          ),
        ],
      ),
      body: prompts.isEmpty
          ? const Center(
              child: Text('No content has been generated yet'),
            )
          : ListView.builder(
              itemCount: prompts.length,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              itemBuilder: (context, index) {
                return ContentWidget(prompts: prompts[index]);
              },
            ),
      floatingActionButton: addPrompt
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                setState(() {
                  addPrompt = !addPrompt;
                });
              },
              tooltip: 'Increment',
              icon: const Icon(Icons.add),
              label: const Text('Add Prompt'),
            ),
      bottomNavigationBar: addPrompt
          ? Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 15,
                right: 15,
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: query,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.send,
                        onChanged: (value) => setState(() {}),
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: 'Write something here...',
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
                    if (query.text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: InkWell(
                          onTap: () async {
                            setState(() {
                              loading = true;
                            });
                            String text = await GeminiServices.generateText(
                              query.text,
                            );
                            prompts.add({'query': query.text, 'content': text});
                            query.clear();
                            loading = false;
                            addPrompt = false;
                            setState(() {});
                          },
                          child: CircleAvatar(
                            radius: 30,
                            child: loading
                                ? const CircularProgressIndicator()
                                : const Icon(Icons.send),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
