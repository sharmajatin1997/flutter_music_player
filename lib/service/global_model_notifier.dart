import 'package:flutter/material.dart';
import 'package:flutter_music_player_ui/model/music_model.dart';

class GlobalModelNotifier {
  static final ValueNotifier<MusicModel?> currentSongNotifier = ValueNotifier(null);
}
