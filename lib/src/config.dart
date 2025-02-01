import 'dart:math' show Random;

import 'package:flutter/material.dart';

const brickColors = [
  Color(0xff4A00E0),
  Color(0xff8E2DE2),
  Color(0xff00C9FF),
  Color(0xff3C40C6),
  Color(0xffFFC312),
  Color(0xffEE5A24),
  Color(0xff12CBC4),
  Color(0xffB53471),
  Color(0xff5758BB),
  Color(0xffA3CB38),
];

const gameWidth = 820.0;
const gameHeight = 1200.0;

const ballRadius = gameWidth * 0.02;
const ballColor = Color(0xffFFC312);

const batWidth = gameWidth * 0.18;
const batHeight = ballRadius * 2.2;
const batStep = gameWidth * 0.03;
const batColor = Color(0xff3C40C6);

const brickRows = 7; 
const brickGutter = gameWidth * 0.008;
const brickVerticalGutter = gameHeight * 0.01;
const brickHeight = gameHeight * 0.035;
final brickWidth =
    (gameWidth - (brickGutter * (brickColors.length + 1))) / brickColors.length;

const brickOutlineWidth = 2.0;
const brickCornerRadius = 4.0;

const difficultyModifier = 1.02;

const crtScanlineOpacity = 0.18;
const crtVignetteStrength = 0.4;
const pixelateEffect = 2.5;

List<Color> getShuffledBrickColors() {
  final random = Random();
  final colors = List<Color>.from(brickColors);
  colors.shuffle(random);
  return colors;
}
