import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// The number to surface as the "call emergency services" CTA. Locale-aware:
/// en → 911 (US default), ru/ky → 112 (the Kyrgyzstan + EU unified number,
/// which also works in the US since 2008 but US users expect 911).
String emergencyDialNumber(String lang) {
  switch (lang) {
    case 'ky':
    case 'ru':
      return '112';
    default:
      return '911';
  }
}

/// Tap-to-dial. Best effort — falls back to copying the number to the
/// clipboard if no dialer responds, so the parent can still call manually.
Future<void> dialEmergency(String lang) async {
  final number = emergencyDialNumber(lang);
  final uri = Uri.parse('tel:$number');
  try {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      return;
    }
  } catch (_) {
    // fall through to clipboard fallback
  }
  await Clipboard.setData(ClipboardData(text: number));
}
