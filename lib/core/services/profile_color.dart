import 'dart:math' as math;

import 'package:flutter/material.dart';

Color colorFromHex(String? value, {Color fallback = const Color(0xFFB98268)}) {
  if (value == null) return fallback;
  final normalized = value.replaceFirst('#', '');
  if (normalized.length != 6) return fallback;
  return Color(int.parse('FF$normalized', radix: 16));
}

Color readableTextColor(Color background) {
  return background.computeLuminance() > 0.42
      ? const Color(0xFF251B1A)
      : Colors.white;
}

Color profileSampleColor(int depth, String undertone) {
  const adjustments = <String, (double, double)>{
    'N': (0, 0),
    'C': (3, -4),
    'W': (1, 5),
    'G': (0.5, 6),
    'CP': (6, -5),
    'CR': (7, -1),
    'CB': (4, -7),
    'WY': (0, 8),
    'WG': (1, 7),
    'WP': (4, 4),
    'PCH': (5, 2),
    'NP': (3, 1),
    'NG': (0, 3),
    'NR': (5, 0),
    'WN': (0.5, 2.5),
    'CN': (1.5, -2),
    'O': (-3, 1),
    'ON': (-2, 0.5),
    'OY': (-2, 4),
    'OG': (-3, 3),
    'U': (0, 0),
  };
  final fraction = (depth.clamp(1, 30).toDouble() - 1) / 29;
  final delta = adjustments[undertone] ?? adjustments['U']!;
  final lightness = 94 - fraction * 72;
  final aValue = 7 + fraction * 7 + delta.$1;
  final bValue = 13 + fraction * 9 + delta.$2;
  return _labToColor(lightness, aValue, bValue);
}

Color _labToColor(double lightness, double aValue, double bValue) {
  final fy = (lightness + 16) / 116;
  final fx = aValue / 500 + fy;
  final fz = fy - bValue / 200;

  double pivotInverse(double value) {
    final cube = math.pow(value, 3).toDouble();
    return cube > 0.008856 ? cube : (value - 16 / 116) / 7.787;
  }

  final x = 0.95047 * pivotInverse(fx);
  final y = pivotInverse(fy);
  final z = 1.08883 * pivotInverse(fz);
  final linear = <double>[
    x * 3.2404542 + y * -1.5371385 + z * -0.4985314,
    x * -0.9692660 + y * 1.8760108 + z * 0.0415560,
    x * 0.0556434 + y * -0.2040259 + z * 1.0572252,
  ];

  int gamma(double value) {
    final transformed = value <= 0.0031308
        ? 12.92 * value
        : 1.055 * math.pow(value, 1 / 2.4) - 0.055;
    return (transformed * 255).round().clamp(0, 255).toInt();
  }

  return Color.fromARGB(
      255, gamma(linear[0]), gamma(linear[1]), gamma(linear[2]));
}
