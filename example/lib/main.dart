import 'package:flutter/material.dart';
import 'package:music_player/model/music_model.dart';
import 'package:music_player/screen/music_player_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Player',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Music Player'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _onTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MusicPlayerScreen(
          songs: [
            MusicModel(url: "https://onlinetestcase.com/wp-content/uploads/2023/06/500-KB-MP3.mp3",description: 'Relax Music'),
            MusicModel(url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3", title: 'SoundHelix'),
            MusicModel(url: "https://onlinetestcase.com/wp-content/uploads/2023/06/500-KB-MP3.mp3", title: 'Tunes',description: 'Relax Music'),
            MusicModel(url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3", title: 'SoundHelix',description: 'SoundHelix Music'),
            ],
          initialIndex: 0,
          showQueue: true, // Queue will be visible if list have more than 1 items other not showing
        ),
      ),
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onTap,
        tooltip: 'Increment',
        child: const Icon(Icons.play_arrow),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
