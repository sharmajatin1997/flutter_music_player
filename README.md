<h1 align="center">🎵 Flutter Music Player UI</h1>

A beautifully designed, customizable Flutter music player widget with rich features like Lottie animations, shimmer effects, audio downloads, repeat mode, and song queue UI — all powered by the `audioplayers` and `volume_controller` packages.


[![GitHub Stars](https://img.shields.io/github/stars/sharmajatin1997/flutter_music_player_ui?style=social)](https://github.com/sharmajatin1997/flutter_music_player_ui)
[![Pub Version](https://img.shields.io/pub/v/music_player.svg)](https://pub.dev/packages/flutter_music_player_ui)
[![GitHub Issues](https://img.shields.io/github/issues/sharmajatin1997/flutter_music_player_ui)](https://github.com/sharmajatin1997/flutter_music_player_ui/issues)
[![License](https://img.shields.io/github/license/sharmajatin1997/flutter_music_player_ui)](https://github.com/sharmajatin1997/flutter_music_player_ui/blob/main/LICENSE)

A beautifully designed, customizable Flutter music player...

## ✨ Features

- 🎧 Smooth audio playback using `audioplayers`
- 🌀 Lottie animations (spinning disk, headphones, success check)
- 🔁 Repeat toggle, ⏯️ play/pause, ⏭️ skip next/previous
- ⬇️ Download audio to device with live progress and success animation
- 🎚️ Volume control with system integration
- ✨ Shimmer effects during loading
- 🌈 Gradient UI with customizable theming
- 🎶 Scrollable queue support
- 📱 Fully responsive and touch-friendly
<br>
# Installation

1. Add the latest version of package to your pubspec.yaml:

```
dart
  dependencies:
    flutter:
      sdk: flutter
    flutter_music_player_ui: latest
```
2. Then run:

```
flutter pub get
```

## 🚀 Usage

3. Import the package and use it in your App.

```
import 'package:flutter_music_player_ui/screen/music_player_screen.dart';
import 'package:flutter_music_player_ui/model/music_model.dart';

```

4. How to use
```

// Pass a list of songs and show player screen
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => MusicPlayerScreen(
      songs: [
        MusicModel(
          title: 'Chill Vibes',
          description: 'Lo-Fi Beats',
          url: 'https://yourdomain.com/audio1.mp3',
        ),
        // Add more songs...
      ],
    ),
  ),
);

```
5. Example of Flutter Music Player UI
```
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
            MusicModel(url: "https://onlinetestcase.com/wp-content/uploads/2023/06/500-KB-MP3.mp3",description: 'Relax Music'),
            MusicModel(url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3", title: 'SoundHelix'),
            MusicModel(url: "https://onlinetestcase.com/wp-content/uploads/2023/06/500-KB-MP3.mp3", title: 'Tunes',description: 'Relax Music'),
            MusicModel(url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3", title: 'SoundHelix',description: 'SoundHelix Music'),
            ],
          initialIndex: 0,
          showDownloadIcon: true,
          repeat: true,
          showQueue: true, // Queue will be visible if list have more than 1 items other not showing
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


```
6. For Download Song please add permissions
# Android (Manifest)
```
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="28"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_MEDIA_AUDIO"/>

```
# iOS (Info.plist)
```
<key>NSPhotoLibraryAddUsageDescription</key>
<string>We need access to save songs to your library.</string>
<key>NSDocumentsFolderUsageDescription</key>
<string>Used to store downloaded songs.</string>

```
   
## 📸 UI Preview

<table>
  <thead>
    <tr>
      <th>🔍 <strong>Music Player UI</strong></th>
      <th>⚔️ <strong>Music Download</strong></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>
        <img src="https://github.com/user-attachments/assets/731b4c6c-a91d-47de-bcc4-dd4cf7c8ed02" width="300" height="600">
      </td>
      <td>
        <img src="https://github.com/user-attachments/assets/20f42fbc-bd4e-4ad5-a82a-66a0e8890c00" width="300" height="600">
      </td>
    </tr>
  </tbody>
</table>



## 🎵 Model Format
```
class MusicModel {
  final String? title;
  final String? description;
  final String url;
  final String? imageUrl;

  MusicModel({
    required this.url,
    this.title,
    this.description,
    this.imageUrl,
  });
}
```
### 📦 Dependencies

| 📦 **Package**         | 💡 **Use Case**       |
|------------------------|------------------------|
| `audioplayers`         | Audio playback         |
| `lottie`               | Lottie animations      |
| `shimmer`              | Loading animations     |
| `volume_controller`    | Volume slider          |
| `smooth_page_indicator`| Page indicators        |


## 💡 Future Plans

*  Theme customization

* Playlist support

* Caching downloaded audio

* Background audio support


## 👨‍💻 Author
Jatin Sharma

Feel free to contribute or fork the project!

## 📄 License

MIT License

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.
