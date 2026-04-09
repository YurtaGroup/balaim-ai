import 'package:cloud_firestore/cloud_firestore.dart';

class Moment {
  final String id;
  final String caption;
  final DateTime date;
  final String? photoUrl;
  final String? localPhotoPath;
  final MomentTag tag;
  final String? childId;

  Moment({
    required this.id,
    required this.caption,
    required this.date,
    this.photoUrl,
    this.localPhotoPath,
    this.tag = MomentTag.memory,
    this.childId,
  });

  String get displayPhoto => photoUrl ?? localPhotoPath ?? '';
  bool get hasPhoto => (photoUrl ?? localPhotoPath ?? '').isNotEmpty;

  Map<String, dynamic> toMap() => {
        'caption': caption,
        'date': Timestamp.fromDate(date),
        'photoUrl': photoUrl,
        'tag': tag.name,
        'childId': childId,
      };

  factory Moment.fromMap(String id, Map<String, dynamic> map) => Moment(
        id: id,
        caption: map['caption'] ?? '',
        date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
        photoUrl: map['photoUrl'],
        tag: MomentTag.values.firstWhere(
          (t) => t.name == map['tag'],
          orElse: () => MomentTag.memory,
        ),
        childId: map['childId'],
      );
}

enum MomentTag {
  firstSmile('First Smile', '😊'),
  firstLaugh('First Laugh', '😂'),
  firstWord('First Word', '💬'),
  firstStep('First Steps', '👣'),
  firstTooth('First Tooth', '🦷'),
  firstFood('First Food', '🥑'),
  rolledOver('Rolled Over', '🔄'),
  satUp('Sat Up', '🪑'),
  crawled('First Crawl', '🐛'),
  sleptThrough('Slept Through Night', '🌙'),
  firstBath('First Bath', '🛁'),
  firstHaircut('First Haircut', '✂️'),
  firstBirthday('First Birthday', '🎂'),
  memory('Memory', '📸');

  final String label;
  final String emoji;
  const MomentTag(this.label, this.emoji);
}
