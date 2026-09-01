import 'shade.dart';

class MatchResult {
  const MatchResult({
    required this.shade,
    required this.score,
    required this.grade,
    required this.confidence,
    required this.reason,
    required this.depthDelta,
    required this.undertonePenalty,
  });

  final Shade shade;
  final double score;
  final String grade;
  final String confidence;
  final String reason;
  final int depthDelta;
  final double undertonePenalty;
}
