import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/content_localizations.dart';
import '../../main.dart' show isFirebaseInitialized, localeProvider;
import '../auth/providers/auth_provider.dart';
import '../journey/providers/journey_provider.dart';

/// A single proactive notice written by the Cloud Function notices engine.
class Notice {
  final String id;
  final String memberId;
  final String memberName;
  final String milestoneId;
  final String type; // 'schedule' | 'trend'
  final String urgency; // 'low' | 'medium' | 'high'
  final L3 title;
  final L3 body;
  final String actionRoute;
  final L3 actionLabel;
  final DateTime createdAt;
  final DateTime? dismissedAt;
  final DateTime? actedAt;

  const Notice({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.milestoneId,
    required this.type,
    required this.urgency,
    required this.title,
    required this.body,
    required this.actionRoute,
    required this.actionLabel,
    required this.createdAt,
    this.dismissedAt,
    this.actedAt,
  });

  bool get isDismissed => dismissedAt != null;

  /// Rank for sorting. Higher = more prominent. Emergency banners are
  /// Claude-driven in AI chat; notices cap at `high`.
  int get urgencySortKey {
    switch (urgency) {
      case 'high':
        return 3;
      case 'medium':
        return 2;
      default:
        return 1;
    }
  }

  static L3 _parseL3(Object? raw) {
    if (raw is Map) {
      return L3(
        en: (raw['en'] as String?) ?? '',
        ru: (raw['ru'] as String?) ?? '',
        ky: (raw['ky'] as String?) ?? '',
      );
    }
    return const L3(en: '', ru: '', ky: '');
  }

  static DateTime _parseDate(Object? raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is String) return DateTime.tryParse(raw) ?? DateTime.now();
    return DateTime.now();
  }

  factory Notice.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    final action = (d['action'] as Map<String, dynamic>?) ?? const {};
    return Notice(
      id: doc.id,
      memberId: (d['memberId'] as String?) ?? '',
      memberName: (d['memberName'] as String?) ?? '',
      milestoneId: (d['milestoneId'] as String?) ?? '',
      type: (d['type'] as String?) ?? 'schedule',
      urgency: (d['urgency'] as String?) ?? 'low',
      title: _parseL3(d['title']),
      body: _parseL3(d['body']),
      actionRoute: (action['route'] as String?) ?? '/',
      actionLabel: _parseL3(action['label']),
      createdAt: _parseDate(d['createdAt']),
      dismissedAt: d['dismissedAt'] == null ? null : _parseDate(d['dismissedAt']),
      actedAt: d['actedAt'] == null ? null : _parseDate(d['actedAt']),
    );
  }
}

/// All notices for the signed-in user, sorted urgency desc then createdAt
/// desc. Dismissed notices are filtered out of the live stream but stay
/// in Firestore for analytics.
final noticesProvider = StreamProvider.autoDispose<List<Notice>>((ref) {
  ref.watch(localeProvider); // rebuild strings when locale changes
  if (!isFirebaseInitialized) return Stream.value(const []);

  final info = ref.watch(currentUserInfoProvider);
  final uid = info.uid;
  if (uid == null) return Stream.value(const []);

  final col = FirebaseFirestore.instance
      .collection('notices')
      .doc(uid)
      .collection('items')
      .orderBy('createdAt', descending: true);

  return col.snapshots().map((snap) {
    final list = snap.docs
        .map(Notice.fromFirestore)
        .where((n) => !n.isDismissed)
        .toList();
    list.sort((a, b) {
      final byUrgency = b.urgencySortKey.compareTo(a.urgencySortKey);
      if (byUrgency != 0) return byUrgency;
      return b.createdAt.compareTo(a.createdAt);
    });
    return list;
  });
});

/// The one notice that should render at the top of Today for the currently
/// active household member. Returns null if none exist (card hides itself).
final topNoticeForSelectedMemberProvider = Provider.autoDispose<Notice?>((ref) {
  final async = ref.watch(noticesProvider);
  final list = async.asData?.value ?? const <Notice>[];
  if (list.isEmpty) return null;

  final profile = ref.watch(userProfileProvider);
  final selectedId = profile.selectedMember?.id;
  if (selectedId == null) return list.first;

  // Prefer the highest-urgency notice for the selected member; if none,
  // fall back to the top overall notice.
  for (final n in list) {
    if (n.memberId == selectedId) return n;
  }
  return list.first;
});

/// Mark a notice dismissed. Firestore rules only allow updating
/// dismissedAt / actedAt from the client.
Future<void> dismissNotice(String uid, String noticeId) async {
  if (!isFirebaseInitialized) return;
  await FirebaseFirestore.instance
      .collection('notices')
      .doc(uid)
      .collection('items')
      .doc(noticeId)
      .update({'dismissedAt': FieldValue.serverTimestamp()});
}

/// Mark a notice acted-on (user tapped the action CTA).
Future<void> markNoticeActed(String uid, String noticeId) async {
  if (!isFirebaseInitialized) return;
  await FirebaseFirestore.instance
      .collection('notices')
      .doc(uid)
      .collection('items')
      .doc(noticeId)
      .update({'actedAt': FieldValue.serverTimestamp()});
}

/// Convenience for UI: picks the right-language field from an [L3] using
/// the provided [BuildContext]'s locale. Respects the existing pattern
/// in content_localizations.dart without duplicating it.
extension L3X on L3 {
  String forContext(BuildContext context) => of(context);
}
