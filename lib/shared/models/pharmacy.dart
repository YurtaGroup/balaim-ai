import '../../core/l10n/content_localizations.dart';

/// A pharmacy in the Balam directory.
///
/// Directory-only — we do NOT process orders, handle payment, or track
/// inventory in v1. The value is: find a real pharmacy near the family,
/// see what they stock + cost, and hand off to WhatsApp or phone.
/// This keeps the business scalable (zero ops per transaction) while
/// solving the actual customer pain ("where can mom fill this Rx?").
class Pharmacy {
  final String id;
  final L3 name;
  final L3 neighborhood; // e.g. "Bishkek · 7 мкр", "NYC · Brighton Beach"
  final String phone; // E.164 or local, we accept both
  final String whatsapp; // WhatsApp number (usually same as phone, stored separately to decouple)
  final L3 hours; // "Mon-Sun 8:00-22:00" or trilingual
  final bool deliversInCity;
  final bool takesPhotoOfRx; // if true, the pharmacy is known to accept a Rx photo via WhatsApp
  final String? websiteOrInstagram;

  const Pharmacy({
    required this.id,
    required this.name,
    required this.neighborhood,
    required this.phone,
    required this.whatsapp,
    required this.hours,
    required this.deliversInCity,
    required this.takesPhotoOfRx,
    this.websiteOrInstagram,
  });
}
