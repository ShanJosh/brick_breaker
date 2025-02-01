import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart';
import 'src/widgets/game_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  FlameAudio.bgm.initialize();

  await FlameAudio.audioCache.loadAll([
    'assets/audio/background_music.mp3',
    'assets/audio/brick_hit.mp3',
    'assets/audio/paddle_hit.mp3',
    'assets/audio/game_over.mp3',
    'assets/audio/you_win.mp3'
  ]);

  runApp(const GameApp());
}
