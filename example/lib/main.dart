import 'package:flutter/material.dart';
import 'package:flutter_music_player_ui/model/music_model.dart';
import 'package:flutter_music_player_ui/screen/music_player_screen.dart';

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
            MusicModel(
              url:
                  "https://onlinetestcase.com/wp-content/uploads/2023/06/500-KB-MP3.mp3",
              description: 'Relax Music',
            ),
            MusicModel(
              url:
                  "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
              title: 'SoundHelix',
            ),
            MusicModel(
              url:
                  "https://onlinetestcase.com/wp-content/uploads/2023/06/500-KB-MP3.mp3",
              title: 'Tunes',
              description: 'Relax Music',
            ),
            MusicModel(
              url:
                  "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
              title: 'SoundHelix',
              description: 'SoundHelix Music',
            ),
          ],
          initialIndex: 0,
          showDownloadIcon: true,
          repeat: true,
          showQueue:
              true, // Queue will be visible if list have more than 1 items other not showing
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onTap,
        tooltip: 'Music Player',
        child: const Icon(Icons.play_arrow),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
