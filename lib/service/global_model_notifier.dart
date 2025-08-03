// global_model_notifier.dart
import 'package:flutter_music_player_ui/model/music_model.dart';
import 'package:flutter/foundation.dart';

class GlobalModelNotifier {
  static final ValueNotifier<MusicModel?> currentSongNotifier = ValueNotifier(null);
}
