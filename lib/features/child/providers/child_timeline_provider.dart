import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/moment.dart';
import '../../vault/vault_provider.dart';
import 'moments_provider.dart';

/// One entry in the unified child timeline — either a medical record
/// from the vault, or a milestone memory. The Child tab shows both in
/// a single chronological feed: "one timeline of your kid's life".
sealed class TimelineEntry {
  DateTime get date;
}

class RecordEntry extends TimelineEntry {
  final VaultItem item;
  RecordEntry(this.item);
  @override
  DateTime get date => item.dateOfService ?? item.uploadedAt;
}

class MomentEntry extends TimelineEntry {
  final Moment moment;
  MomentEntry(this.moment);
  @override
  DateTime get date => moment.date;
}

/// The merged, date-sorted timeline for one child: vault records +
/// milestone moments, newest first.
final childTimelineProvider =
    Provider.autoDispose.family<List<TimelineEntry>, String>((ref, childId) {
  final records = ref.watch(vaultItemsForMemberProvider(childId));
  final moments = ref.watch(momentsProvider);

  final entries = <TimelineEntry>[
    ...records.map(RecordEntry.new),
    // childId-tagged moments, plus legacy untagged ones.
    ...moments
        .where((m) => m.childId == childId || m.childId == null)
        .map(MomentEntry.new),
  ];
  entries.sort((a, b) => b.date.compareTo(a.date));
  return entries;
});
