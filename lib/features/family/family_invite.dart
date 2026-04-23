import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Pre-filled "share Balam with mom / wife / dad" messages the user
/// can send on WhatsApp with one tap. Trilingual. Opens the native
/// share sheet if WhatsApp isn't installed.
class FamilyInvite {
  /// Default message (no specific person). Opens WhatsApp share sheet.
  static Future<void> share({
    required String locale,
    required String senderName,
    String? toPhone,
  }) async {
    final text = _messageFor(locale, senderName);
    final url = toPhone != null && toPhone.isNotEmpty
        ? 'https://wa.me/${_cleanPhone(toPhone)}?text=${Uri.encodeComponent(text)}'
        : 'https://wa.me/?text=${Uri.encodeComponent(text)}';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('[FamilyInvite] Could not launch $url');
    }
  }

  static String _messageFor(String locale, String senderName) {
    switch (locale) {
      case 'ru':
        return 'Привет! Я использую Balam — это приложение для всей семьи, где хранится наша медицинская история и ИИ-доктор отвечает на вопросы с учётом наших анализов и рецептов. Ставь, будем вести всё вместе: https://balam.ai — $senderName';
      case 'ky':
        return 'Салам! Мен Balam колдонмосун пайдаланып жатам — бул бүт үй-бүлөнүн медициналык тарыхын сактоочу жана ИИ-дарыгери биздин анализ, рецепттерибизди эске алып жооп берген колдонмо. Жүктөп ал, чогуу алып барабыз: https://balam.ai — $senderName';
      default:
        return "Hey! I'm using Balam — a family health app that stores all our medical records and has an AI doctor that answers using our actual labs + prescriptions. Grab it so we can manage it together: https://balam.ai — $senderName";
    }
  }

  static String _cleanPhone(String raw) {
    return raw.replaceAll(RegExp(r'[^0-9]'), '');
  }
}
