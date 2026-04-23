class AppConstants {
  AppConstants._();

  static const appName = 'Balam.AI';
  static const appTagline = 'Your parenting companion';

  // Journey stages
  static const stageTrying = 'trying_to_conceive';
  static const stagePregnant = 'pregnant';
  static const stageNewborn = 'newborn';
  static const stageToddler = 'toddler';
}

enum ParentingStage {
  tryingToConceive('Trying to Conceive', 'Planning your family'),
  pregnant('Pregnant', 'Growing your little one'),
  newborn('Newborn', '0-12 months'),
  toddler('Toddler', '1-5 years');

  const ParentingStage(this.label, this.description);
  /// English-only fallback label. Use [ParentingStageX.labelFor] for
  /// user-facing text.
  final String label;
  final String description;
}

/// Trilingual helpers for [ParentingStage]. Every user-visible place
/// that displays the stage should use [labelFor] instead of [.label]
/// so the string respects the app locale.
extension ParentingStageX on ParentingStage {
  String labelFor(String lang) {
    switch (this) {
      case ParentingStage.tryingToConceive:
        switch (lang) {
          case 'ru':
            return 'Планирование';
          case 'ky':
            return 'Пландаштыруу';
          default:
            return 'Trying to Conceive';
        }
      case ParentingStage.pregnant:
        switch (lang) {
          case 'ru':
            return 'Беременность';
          case 'ky':
            return 'Кош бойлуулук';
          default:
            return 'Pregnant';
        }
      case ParentingStage.newborn:
        switch (lang) {
          case 'ru':
            return 'Новорождённый';
          case 'ky':
            return 'Ымыркай';
          default:
            return 'Newborn';
        }
      case ParentingStage.toddler:
        switch (lang) {
          case 'ru':
            return 'Малыш';
          case 'ky':
            return 'Бөбөк';
          default:
            return 'Toddler';
        }
    }
  }
}
