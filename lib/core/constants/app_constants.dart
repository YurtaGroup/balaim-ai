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
  final String label;
  final String description;
}
