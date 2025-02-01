import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../brick_breaker.dart';
import '../config.dart';
import 'overlay_screen.dart';
import 'score_card.dart';

class GameApp extends StatefulWidget {
  const GameApp({super.key});

  @override
  State<GameApp> createState() => _GameAppState();
}

class _GameAppState extends State<GameApp> {
  late final BrickBreaker game;
  bool audioInitialized = false;

  @override
  void initState() {
    super.initState();
    game = BrickBreaker();
    game.playStateNotifier.addListener(_onGameStateChange);
  }

  @override
  void dispose() {
    game.playStateNotifier.removeListener(_onGameStateChange);
    FlameAudio.bgm.stop();
    super.dispose();
  }

  void _onGameStateChange() {
    if (game.playState == PlayState.playing) {
      _startBackgroundMusic();
    } else if (game.playState == PlayState.won) {
      FlameAudio.play('you_win.mp3');
      _stopBackgroundMusic();
    } else {
      _stopBackgroundMusic();
    }
  }

  void _startBackgroundMusic() {
    if (!audioInitialized) {
      FlameAudio.bgm.play('background_music.mp3', volume: 0.5);
      setState(() {
        audioInitialized = true;
      });
    }
  }

  void _stopBackgroundMusic() {
    if (audioInitialized) {
      FlameAudio.bgm.stop();
      setState(() {
        audioInitialized = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (game.playState == PlayState.welcome) {
          game.playState = PlayState.playing;
        }
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          textTheme: GoogleFonts.pressStart2pTextTheme().apply(
            bodyColor: Colors.white,
            displayColor: Colors.white, 
          ),
        ),
        home: Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              color: Colors.black, 
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Column(
                    children: [
                      ScoreCard(score: game.score),
                      Expanded(
                        child: FittedBox(
                          child: SizedBox(
                            width: gameWidth,
                            height: gameHeight,
                            child: GameWidget(
                              game: game,
                              overlayBuilderMap: {
                                PlayState.welcome.name: (context, game) =>
                                    const OverlayScreen(
                                      title: 'TAP TO PLAY',
                                      subtitle: 'Use arrow keys or swipe',
                                    ),
                                PlayState.gameOver.name: (context, game) =>
                                    const OverlayScreen(
                                      title: 'G A M E   O V E R',
                                      subtitle: 'Tap to Play Again',
                                    ),
                                PlayState.won.name: (context, game) =>
                                    const OverlayScreen(
                                      title: 'Y O U   W O N ! ! !',
                                      subtitle: 'Tap to Play Again',
                                    ),
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
