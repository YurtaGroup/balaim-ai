import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/persona.dart';

/// Maps a child age in months to one of the buckets defined in the JSON
/// library. Returns null when no bucket applies (e.g. negative age).
String? ageBucketFor(int? ageMonths) {
  if (ageMonths == null || ageMonths < 0) return null;
  if (ageMonths < 3) return '0-3m';
  if (ageMonths < 6) return '3-6m';
  if (ageMonths < 12) return '6-12m';
  if (ageMonths < 24) return '12-24m';
  if (ageMonths < 36) return '2-3y';
  // No 3+ content yet; fall back to the closest mature bucket so the
  // carousel still shows something useful.
  return '2-3y';
}

class PromptQuestion {
  final String en;
  final String ru;
  final String ky;

  const PromptQuestion({required this.en, required this.ru, required this.ky});

  String forLang(String lang) {
    switch (lang) {
      case 'ru':
        return ru;
      case 'ky':
        return ky;
      default:
        return en;
    }
  }
}

class PromptLibrary {
  final List<String> ageBuckets;
  // personaServerId -> ageBucket -> questions
  final Map<String, Map<String, List<PromptQuestion>>> _byPersona;

  const PromptLibrary._({
    required this.ageBuckets,
    required Map<String, Map<String, List<PromptQuestion>>> byPersona,
  }) : _byPersona = byPersona;

  /// Returns the curated questions for this persona at this child age. Falls
  /// back to the closest bucket and then to Balam if anything is missing,
  /// so the UI never renders an empty carousel.
  List<PromptQuestion> questionsFor(PersonaId personaId, int? ageMonths) {
    final bucket = ageBucketFor(ageMonths) ?? ageBuckets.first;
    return _resolve(personaId.serverId, bucket) ??
        _resolve('balam', bucket) ??
        const [];
  }

  List<PromptQuestion>? _resolve(String personaServerId, String bucket) {
    final byBucket = _byPersona[personaServerId];
    if (byBucket == null) return null;
    final list = byBucket[bucket];
    if (list == null || list.isEmpty) return null;
    return list;
  }

  static Future<PromptLibrary> load() async {
    final raw = await rootBundle.loadString('assets/prompt_library/library.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final buckets =
        (json['ageBuckets'] as List<dynamic>).cast<String>();
    final personas = (json['personas'] as Map<String, dynamic>);

    final byPersona = <String, Map<String, List<PromptQuestion>>>{};
    personas.forEach((personaId, byBucketRaw) {
      final byBucket = <String, List<PromptQuestion>>{};
      (byBucketRaw as Map<String, dynamic>).forEach((bucket, questionsRaw) {
        final list = (questionsRaw as List<dynamic>)
            .map((q) => PromptQuestion(
                  en: (q as Map)['en'] as String,
                  ru: q['ru'] as String,
                  ky: q['ky'] as String,
                ))
            .toList(growable: false);
        byBucket[bucket] = list;
      });
      byPersona[personaId] = byBucket;
    });

    return PromptLibrary._(ageBuckets: buckets, byPersona: byPersona);
  }
}

/// Loaded once at app start; refreshed on hot-restart only.
final promptLibraryProvider = FutureProvider<PromptLibrary>((ref) async {
  return PromptLibrary.load();
});
