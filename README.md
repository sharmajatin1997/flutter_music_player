<h1 align="center">Flutter Music Player 🎵</h1>

A Flutter package that helps you build beautiful animated "Searching Opponent" overlays for battle-style apps and games. Ideal for VS matchups, profile reveals, and real-time opponent searching UIs!

[![GitHub Stars](https://img.shields.io/github/stars/sharmajatin1997/flutter_music_player?style=social)](https://github.com/sharmajatin1997/flutter_music_player)
[![Pub Version](https://img.shields.io/pub/v/music_player.svg)](https://pub.dev/packages/flutter_music_player)
[![GitHub Issues](https://img.shields.io/github/issues/sharmajatin1997/flutter_music_player)](https://github.com/sharmajatin1997/flutter_music_player/issues)
[![License](https://img.shields.io/github/license/sharmajatin1997/flutter_music_player)](https://github.com/sharmajatin1997/flutter_music_player/blob/main/LICENSE)

A beautifully designed, customizable Flutter music player...


## ✨ Features

* 🌀 Smooth opponent search loop with timer

* 🔁 Automatically cycles through opponents

* ⏳ Timeout fallback with callback

* 💥 Fade-in animated VS icons

* 👤 Customizable avatar image and name

* ❌ Cancel button to stop search early

* 🧩 Built with Material, clean and reusable

<br>
# Installation

1. Add the latest version of package to your pubspec.yaml:

```
dart
  dependencies:
    flutter:
      sdk: flutter
    battle_search_overlay: latest
```
2. Then run:

```
flutter pub get
```

## 🚀 Usage

3. Import the package and use it in your App.

```
import 'package:battle_search_overlay/battle_search_overlay.dart';

```

4. Show Overlay
```
showDialog(
  context: context,
  barrierDismissible: false,
  builder: (context) => SearchingOpponent(
    me: {
      'name': 'You',
      'image': 'https://yourserver.com/your-image.png',
    },
    users: [
      {'name': 'Opponent 1', 'image': 'https://...'},
      {'name': 'Opponent 2', 'image': 'https://...'},
      // more users...
    ],
    onCancel: () {
      // Dismiss overlay
      Navigator.of(context).pop();
    },
    onTimeout: () {
      // Show "No match found" dialog
    },
    durationInSeconds: 10,
  ),
);

```
5. Example of VS Overlay
```
import 'package:flutter/material.dart';
import 'package:battle_search_overlay/battle_search_overlay.dart';

class Battle extends StatefulWidget {
  const Battle({super.key});

  @override
  State<Battle> createState() => _BattleState();
}

class _BattleState extends State<Battle> {
  bool _showSearching = false;

  final me = {
    'name': 'You',
    'image': 'https://media.tenor.com/zt-PcMT2y3kAAAAe/war-hrithik-roshan.png',
  };

  final users = List.generate(20, (index) {
    return {
      'name': 'User ${index + 1}',
      'image': 'https://images.hindustantimes.com/rf/image_size_640x362/HT/p1/2015/04/03/Incoming/Pictures/1333507_Wallpaper2.jpg',
    };
  });

  void _toggleSearching() {
    setState(() {
      _showSearching = !_showSearching;
    });
  }

  void _handleTimeout() async {
    // Step 1: Hide the overlay
    setState(() => _showSearching = false);
    if (!mounted) return;
    // Below mounted you can use your methods or Functionality
    // if data gets you call this
    VsOverlayUtils.show(
      context: context,
      me: me,
      opponent: {'name': 'Nitish Nanda','image': 'https://images.hindustantimes.com/rf/image_size_640x362/HT/p1/2015/04/03/Incoming/Pictures/1333507_Wallpaper2.jpg',},
    );

  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(title: const Text("Battle")),
          body: Center(
            child: ElevatedButton(
              onPressed: _toggleSearching,
              child: const Text("Search Opponent"),
            ),
          ),
        ),
        if (_showSearching)
          Positioned.fill(
            child: SearchingOpponent(
              me: me,
              users: users,
              durationInSeconds: 10, //Basically this time duration use for Backend Response if Your API take 1 min set 60 sec(Add Time according to API response)
              onCancel: _toggleSearching, //In this method you can do cancel searching functionality
              onTimeout: _handleTimeout, // In this method you can use your Logic If API Data retrieve do whatever you want
            ),
          ),
      ],
    );
  }
}

```
## 📸 UI Preview

<table>
  <thead>
    <tr>
      <th>🔍 <strong>Searching Overlay</strong></th>
      <th>⚔️ <strong>Animated VS</strong></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>
        <img src="https://github.com/user-attachments/assets/cf29a737-2d8a-4ff8-9d55-3adb8db2fcd8" width="300" height="600">
      </td>
      <td>
        <img src="https://github.com/user-attachments/assets/2bc14495-b645-4e36-991c-63f49be8e35a" width="300" height="600">
      </td>
    </tr>
  </tbody>
</table>

## 🔧 Customization

* me: Current user’s data with name and image.

* users: List of potential opponents.

* onCancel: Callback when "Cancel Search" is tapped.

* onTimeout: Callback after timeout.

* durationInSeconds: Duration before timeout triggers.

## 🧠 Developed By
Jatin Sharma

Feel free to contribute or fork the project!

## 📄 License

MIT License

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.
