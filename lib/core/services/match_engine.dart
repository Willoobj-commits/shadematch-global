import 'dart:math' as math;

import '../models/match_result.dart';
import '../models/shade.dart';

class MatchEngine {
  const MatchEngine(this.undertones);

  final List<UndertoneDefinition> undertones;

  List<MatchResult> bestPerBrand({
    required int referenceDepth,
    required String referenceUndertone,
    required List<Shade> shades,
    String? excludeBrand,
    bool currentOnly = true,
    int maximumDepthDelta = 4,
  }) {
    final best = <String, MatchResult>{};
    for (final shade in shades) {
      if (currentOnly && !shade.isCurrent) continue;
      if (excludeBrand != null && shade.brandName == excludeBrand) continue;
      final depthDelta = (referenceDepth - shade.universalDepth).abs();
      if (depthDelta > maximumDepthDelta) continue;
      final tonePenalty = _undertonePenalty(
        referenceUndertone,
        shade.undertoneCode,
      );
      final score = depthDelta * 10.0 + tonePenalty;
      // A brand with no sufficiently close candidate gets no result. Do not
      // fill every brand row with a distant shade merely to complete a table.
      if (score > 24) continue;
      final result = MatchResult(
        shade: shade,
        score: score,
        grade: _grade(score),
        confidence: _confidence(
          referenceUndertone,
          shade,
          score,
        ),
        reason: _reason(
          depthDelta,
          referenceUndertone,
          shade.undertoneCode,
        ),
        depthDelta: depthDelta,
        undertonePenalty: tonePenalty,
      );
      final prior = best[shade.brandName];
      if (prior == null || _isBetter(result, prior)) {
        best[shade.brandName] = result;
      }
    }
    final results = best.values.toList(growable: false);
    results.sort((a, b) {
      final score = a.score.compareTo(b.score);
      return score != 0
          ? score
          : a.shade.brandName.compareTo(b.shade.brandName);
    });
    return results;
  }

  bool _isBetter(MatchResult candidate, MatchResult prior) {
    if (candidate.score != prior.score) return candidate.score < prior.score;
    if (candidate.shade.hasQuantitativeVisual !=
        prior.shade.hasQuantitativeVisual) {
      return candidate.shade.hasQuantitativeVisual;
    }
    if (candidate.shade.hasOfficialImage != prior.shade.hasOfficialImage) {
      return candidate.shade.hasOfficialImage;
    }
    return candidate.shade.displayName.compareTo(prior.shade.displayName) < 0;
  }

  double _undertonePenalty(String first, String second) {
    if (first == second) return 0;
    if (first == 'U' || second == 'U') return 12;
    final firstVector = _vector(first);
    final secondVector = _vector(second);
    if (firstVector == null || secondVector == null) return 16;
    final dx = firstVector[0] - secondVector[0];
    final dy = firstVector[1] - secondVector[1];
    return math.min(20, math.sqrt(dx * dx + dy * dy) * 8).toDouble();
  }

  List<double>? _vector(String code) {
    for (final undertone in undertones) {
      if (undertone.code == code) return undertone.vector;
    }
    return null;
  }

  String _grade(double score) {
    if (score <= 4) return 'Very close profile';
    if (score <= 12) return 'Close profile';
    if (score <= 24) return 'Possible profile';
    return 'Not recommended';
  }

  String _confidence(
    String referenceUndertone,
    Shade candidate,
    double score,
  ) {
    if (referenceUndertone == 'U' || candidate.undertoneCode == 'U') {
      return 'Limited evidence';
    }
    if (candidate.hasQuantitativeVisual) {
      return score <= 12 ? 'High' : 'Moderate–high';
    }
    if (candidate.hasOfficialImage) return 'Moderate';
    return score <= 12 ? 'Moderate profile confidence' : 'Low–moderate';
  }

  String _reason(
    int depthDelta,
    String referenceUndertone,
    String candidateUndertone,
  ) {
    final tone = referenceUndertone == candidateUndertone
        ? 'same undertone profile'
        : candidateUndertone == 'U'
            ? 'candidate undertone is unpublished'
            : referenceUndertone == 'U'
                ? 'your undertone is unspecified'
                : 'nearby undertone profile';
    return 'Depth difference $depthDelta · $tone';
  }
}
