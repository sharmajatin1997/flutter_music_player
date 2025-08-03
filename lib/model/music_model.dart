/// A model class representing a music track.
///
/// Contains the essential information for audio playback,
/// such as the [url] of the audio file, an optional [title],
/// and an optional [description].
class MusicModel {
  /// The URL of the music track.
  final String url;

  /// The title of the music track (optional).
  final String? title;

  /// A short description or metadata about the track (optional).
  final String? description;
  final int? progress;

  /// Creates a new [MusicModel] instance.
  ///
  /// The [url] is required and must not be null.
  MusicModel({required this.url, this.title, this.description, this.progress});
}
