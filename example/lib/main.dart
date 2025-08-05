// import 'package:flutter/material.dart';
// import 'package:flutter_music_player_ui/flutter_music_player.dart';
// import 'package:flutter_music_player_ui/model/music_model.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Music Player',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//       ),
//       home: const MyHomePage(title: 'Music Player'),
//     );
//   }
// }
//
// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});
//
//   final String title;
//
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//
//   final isBackGroundMusic=true;
//
//   void _onTap() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => MusicPlayerScreen(
//           songs: [
//             MusicModel(
//               url:
//                   "https://onlinetestcase.com/wp-content/uploads/2023/06/500-KB-MP3.mp3",
//               description: 'Relax Music',
//             ),
//             MusicModel(
//               url:
//                   "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
//               title: 'SoundHelix',
//             ),
//             MusicModel(
//               url:
//                   "https://onlinetestcase.com/wp-content/uploads/2023/06/500-KB-MP3.mp3",
//               title: 'Tunes',
//               description: 'Relax Music',
//             ),
//             MusicModel(
//               url:
//                   "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
//               title: 'SoundHelix',
//               description: 'SoundHelix Music',
//             ),
//           ],
//           initialIndex: 0,
//           showDownloadIcon: true,
//           repeat: true,
//           isBackMusic: isBackGroundMusic,
//           showQueue: true, // Queue will be visible if list have more than 1 items other not showing
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: Text(widget.title),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _onTap,
//         tooltip: 'Music Player',
//         child: const Icon(Icons.play_arrow),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//       body: Stack(
//         children: [
//           Visibility(
//             visible: isBackGroundMusic,
//               child: MiniPlayerWidget())
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_music_player_ui/flutter_music_player.dart';
import 'package:flutter_music_player_ui/model/music_model.dart';
import 'package:flutter_music_player_ui/service/global_model_notifier.dart';
import 'package:flutter_music_player_ui/service/mini_player_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary, title: Text(widget.title),
      ),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: miniPlayerController,
            builder: (context, _) {
              return miniPlayerController.isVisible && GlobalModelNotifier.currentSongNotifier.value != null
                  ? MiniPlayerWidget(currentSong: GlobalModelNotifier.currentSongNotifier.value!,
              )
                  : const SizedBox.shrink();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          _openMusicPlayer(context);
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

void _openMusicPlayer(BuildContext context) async {
  List<MusicModel> playlist = [
    MusicModel(
      url: "https://onlinetestcase.com/wp-content/uploads/2023/06/500-KB-MP3.mp3",
      title: "Song 1",
      description: "Relaxing tune",
    ),
    MusicModel(
      url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
      title: "Song 2",
    ),
    MusicModel(
      url: "https://onlinetestcase.com/wp-content/uploads/2023/06/500-KB-MP3.mp3",
      title: "Song 3",
      description: "Relaxing tune",
    ),
  ];

  // Only set the playlist, don't start playing yet
  await AudioPlayerService().setPlaylist(playlist, false);

  // Navigate first
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => MusicPlayerScreen(songs: playlist, initialIndex: 0,),
    ),
  );

  // Now defer the actual play until next frame
  WidgetsBinding.instance.addPostFrameCallback((_) {
    AudioPlayerService().play();
    miniPlayerController.showMiniPlayer();
  });
}

