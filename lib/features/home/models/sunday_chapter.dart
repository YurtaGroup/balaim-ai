import 'package:cloud_firestore/cloud_firestore.dart';

enum ChapterState { generating, textReady, ready, playing, played, error }

/// One Sunday Chapter — the weekly narrated letter.
/// Stored at `users/{uid}/chapters/{weekId}` where weekId is the ISO week
/// string (e.g. "2026-W22"). Cloud Functions in jobs/sunday_chapter.ts
/// write everything; the client reads only.
class SundayChapter {
  final String weekId;            // "2026-W22"
  final int chapterNumber;        // 1-indexed
  final String childId;
  final String childName;
  final String? narrative;        // 150-word prose, null until status >= text_ready
  final String? audioUrl;         // null until status == ready and TTS is wired (Sprint 1 step 5)
  final Duration? duration;       // null until audioUrl is set
  final ChapterState state;
  final bool approximate;         // true if observations were empty
  final DateTime createdAt;

  const SundayChapter({
    required this.weekId,
    required this.chapterNumber,
    required this.childId,
    required this.childName,
    required this.narrative,
    required this.audioUrl,
    required this.duration,
    required this.state,
    required this.approximate,
    required this.createdAt,
  });

  /// First two sentences of the narrative, used as the card headline.
  /// Designer spec: "End the teaser mid-thought so the parent wants to
  /// hear the rest." For Sprint 1 we extract sentences 1-2 verbatim;
  /// the prompt's structure ensures sentence 1 opens with a specific
  /// observation.
  String get teaser {
    final text = narrative?.trim() ?? '';
    if (text.isEmpty) return '';
    final sentences = _splitSentences(text);
    if (sentences.isEmpty) return text;
    if (sentences.length == 1) return sentences.first;
    return '${sentences[0]} ${sentences[1]}'.trim();
  }

  static List<String> _splitSentences(String text) {
    final out = <String>[];
    final buffer = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ('.!?'.contains(text[i])) {
        final next = i + 1 < text.length ? text[i + 1] : ' ';
        if (next == ' ' || next == '\n') {
          out.add(buffer.toString().trim());
          buffer.clear();
        }
      }
    }
    if (buffer.isNotEmpty) out.add(buffer.toString().trim());
    return out.where((s) => s.isNotEmpty).toList();
  }

  factory SundayChapter.fromFirestore(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>? ?? {};
    final statusStr = (data['status'] as String?) ?? 'generating';
    final state = switch (statusStr) {
      'generating' => ChapterState.generating,
      'text_ready' => ChapterState.textReady,
      'ready' => ChapterState.ready,
      'error' => ChapterState.error,
      _ => ChapterState.generating,
    };

    final createdAtTs = data['createdAt'];
    final createdAt = createdAtTs is Timestamp
        ? createdAtTs.toDate()
        : DateTime.now();

    final durationSeconds = data['durationSeconds'];
    final duration = durationSeconds is num
        ? Duration(seconds: durationSeconds.toInt())
        : null;

    return SundayChapter(
      weekId: snap.id,
      chapterNumber: (data['chapterNumber'] as num?)?.toInt() ?? 1,
      childId: (data['childId'] as String?) ?? '',
      childName: (data['childName'] as String?) ?? '',
      narrative: data['narrative'] as String?,
      audioUrl: data['audioUrl'] as String?,
      duration: duration,
      state: state,
      approximate: (data['approximate'] as bool?) ?? false,
      createdAt: createdAt,
    );
  }
}

/// ISO 8601 week key for a given DateTime — matches the server-side
/// computation in functions/src/jobs/sunday_chapter.ts:isoWeekKey().
/// Example: 2026-06-01 (Monday of week 23) → "2026-W23".
String isoWeekKey(DateTime date) {
  final utc = DateTime.utc(date.year, date.month, date.day);
  final dayNum = utc.weekday; // 1 = Monday, 7 = Sunday (matches ISO)
  final thursday = utc.add(Duration(days: 4 - dayNum));
  final yearStart = DateTime.utc(thursday.year, 1, 1);
  final weekNo =
      ((thursday.difference(yearStart).inDays) / 7).ceil() + 1;
  return '${thursday.year}-W${weekNo.toString().padLeft(2, '0')}';
}

/// Designer spec — show from Sunday 7pm through the following Saturday
/// 11:59pm. Outside that window, render nothing (the card is not a
/// permanent fixture).
bool shouldShowChapterAt(DateTime now) {
  final weekday = now.weekday; // 1=Mon..7=Sun
  if (weekday == DateTime.sunday) return now.hour >= 19;
  return true; // any non-Sunday during the week the chapter exists
}
