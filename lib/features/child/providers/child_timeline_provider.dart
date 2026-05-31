import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/diaper_entry.dart';
import '../../../shared/models/feeding_entry.dart';
import '../../../shared/models/moment.dart';
import '../../care_log/care_log_provider.dart';
import '../../montessori/observation_models.dart';
import '../../montessori/observations_provider.dart';
import '../../vault/vault_provider.dart';
import 'moments_provider.dart';

/// One entry in the unified child timeline. Five flavours coexist in
/// one chronological feed: a medical record (vault), a milestone memory
/// (moment), a Mom-logged Montessori observation, a feeding, or a
/// diaper change. The Child tab is the single story of the child's
/// life — survival data and milestones live side by side.
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

class ObservationEntry extends TimelineEntry {
  final Observation observation;
  ObservationEntry(this.observation);
  @override
  DateTime get date => observation.createdAt;
}

class FeedingEntryItem extends TimelineEntry {
  final FeedingEntry feeding;
  FeedingEntryItem(this.feeding);
  @override
  DateTime get date => feeding.startTime;
}

class DiaperEntryItem extends TimelineEntry {
  final DiaperEntry diaper;
  DiaperEntryItem(this.diaper);
  @override
  DateTime get date => diaper.timestamp;
}

/// The merged, date-sorted timeline for one child, newest first.
final childTimelineProvider =
    Provider.autoDispose.family<List<TimelineEntry>, String>((ref, childId) {
  final records = ref.watch(vaultItemsForMemberProvider(childId));
  final moments = ref.watch(momentsProvider);
  final observations = ref.watch(observationsProvider).asData?.value ?? const [];
  final feedings = ref.watch(feedingsProvider).asData?.value ?? const [];
  final diapers = ref.watch(diapersProvider).asData?.value ?? const [];

  final entries = <TimelineEntry>[
    ...records.map(RecordEntry.new),
    // childId-tagged moments, plus legacy untagged ones.
    ...moments
        .where((m) => m.childId == childId || m.childId == null)
        .map(MomentEntry.new),
    ...observations
        .where((o) => o.childId == null || o.childId == childId)
        .map(ObservationEntry.new),
    ...feedings
        .where((f) => f.childId == null || f.childId == childId)
        .map(FeedingEntryItem.new),
    ...diapers
        .where((d) => d.childId == null || d.childId == childId)
        .map(DiaperEntryItem.new),
  ];
  entries.sort((a, b) => b.date.compareTo(a.date));
  return entries;
});
