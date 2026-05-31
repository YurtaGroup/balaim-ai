/// The Montessori taxonomy shared between client and server.
///
/// MUST stay in lockstep with `functions/src/montessori/taxonomy.ts` —
/// every id below is an enum value the Cloud Function tagger may write
/// back. If a new sensitive period or category is added there, it lands
/// in `unknown` here until it's added on this side too.
library;

enum SensitivePeriod {
  order('order', 'Order', 12, 36),
  language('language', 'Language', 0, 72),
  movement('movement', 'Movement', 0, 48),
  smallObjects('small_objects', 'Small objects', 12, 30),
  refinementOfSenses(
      'refinement_of_senses', 'Refinement of senses', 24, 72),
  social('social', 'Social', 30, 60),
  writing('writing', 'Writing', 42, 54),
  reading('reading', 'Reading', 48, 66),
  unknown('unknown', 'Unknown', 0, 0);

  const SensitivePeriod(this.id, this.label, this.startMonths, this.endMonths);

  final String id;
  final String label;
  final int startMonths;
  final int endMonths;

  static SensitivePeriod fromId(String? id) {
    if (id == null) return SensitivePeriod.unknown;
    for (final p in SensitivePeriod.values) {
      if (p.id == id) return p;
    }
    return SensitivePeriod.unknown;
  }

  /// Sensitive periods whose age window includes [ageMonths].
  static List<SensitivePeriod> activeFor(int? ageMonths) {
    if (ageMonths == null || ageMonths < 0) return const [];
    return SensitivePeriod.values
        .where((p) =>
            p != SensitivePeriod.unknown &&
            ageMonths >= p.startMonths &&
            ageMonths <= p.endMonths)
        .toList();
  }
}

enum MontessoriCategory {
  practicalLife('practical_life', 'Practical Life', '🍞'),
  language('language', 'Language', '💬'),
  sensorial('sensorial', 'Sensorial', '🌀'),
  motor('motor', 'Motor', '🤸'),
  math('math', 'Math', '🔢'),
  cultural('cultural', 'Cultural', '🌍'),
  unknown('unknown', 'Unknown', '·');

  const MontessoriCategory(this.id, this.label, this.icon);

  final String id;
  final String label;
  final String icon;

  static MontessoriCategory fromId(String? id) {
    if (id == null) return MontessoriCategory.unknown;
    for (final c in MontessoriCategory.values) {
      if (c.id == id) return c;
    }
    return MontessoriCategory.unknown;
  }
}

/// A pediatric milestone tag the server attached to an observation.
/// IDs are server-free-form (snake_case) so the canonical list can
/// evolve without forcing client changes — UI uses the label.
class MilestoneTag {
  final String id;
  final String label;
  final int? ageMonthsApprox;

  const MilestoneTag({
    required this.id,
    required this.label,
    this.ageMonthsApprox,
  });

  factory MilestoneTag.fromMap(Map<String, dynamic> raw) {
    return MilestoneTag(
      id: (raw['id'] as String?)?.trim() ?? '',
      label: (raw['label'] as String?)?.trim() ?? '',
      ageMonthsApprox: (raw['ageMonthsApprox'] as num?)?.toInt(),
    );
  }
}
