import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:avatar_glow/avatar_glow.dart';

void main() {
  runApp(const MyTodoApp());
}

@immutable
class MyTodoApp extends StatelessWidget {
  const MyTodoApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Todo App',
      theme: ThemeData(
        primarySwatch: Colors.blue
      ),
      home: const TodoListPage(),
    );
  }
}

@immutable
class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});
  @override
  TodoListPageState createState() => TodoListPageState();
}

class TodoListPageState extends State<TodoListPage> {
  List<String> todoList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('タスク一覧'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        itemCount: todoList.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(todoList[index]),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async{
          final newTaskText = await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              return const TodoAddPage();
            }),
          );
          if (newTaskText != null) {
            setState(() {
              todoList.add(newTaskText);
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}


@immutable
class TodoAddPage extends StatefulWidget {
  const TodoAddPage({super.key});
  @override
  TodoAddPageState createState() => TodoAddPageState();
}


class TodoAddPageState extends State<TodoAddPage> {
  SpeechToText speechToText = SpeechToText();
  var speechEnabled = false;
  var lastWords = '';

  @override
  void initState() {
    super.initState();
    speechToText = SpeechToText();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('タスク追加'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Container(
        padding: const EdgeInsets.all(64),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Text(
                    lastWords,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    )
                  ),
                ),
                AvatarGlow(
                  endRadius: 45.0,
                  animate: speechEnabled,
                  duration: const Duration(milliseconds: 2000),
                  glowColor: Colors.blue,
                  repeatPauseDuration: const Duration(milliseconds: 100),
                  showTwoGlows: true,
                  child: GestureDetector(
                    onTapDown: (details) async {
                      if(!speechEnabled) {
                        var available = await speechToText.initialize();
                        if (available) {
                          setState(() {
                            speechEnabled = true;
                            speechToText.listen(
                              onResult: (result) {
                                if(mounted) {
                                  setState(() {
                                    lastWords = result.recognizedWords;
                                  });
                                }
                              },
                              localeId: 'ja_JP'
                            );
                          });
                        }
                      }
                    },
                    onTapUp: (details) {
                      setState(() {
                        speechEnabled = false;
                      });
                      speechToText.stop();
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.blue,
                      radius: 25,
                      child: Icon(
                        speechEnabled ? Icons.mic : Icons.mic_none,
                        color: Colors.white,
                      ),
                    ),
                  ), 
                ),
              ]
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(lastWords);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: const Text('タスク追加', style: TextStyle(color: Colors.white),),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                  Navigator.of(context).pop();
                },
              child: const Text('キャンセル'),
            ),
          ]
        )
      ),
    );
  }
}