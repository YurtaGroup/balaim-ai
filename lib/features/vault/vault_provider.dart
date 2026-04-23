import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/storage_service.dart';
import '../../main.dart' show isFirebaseInitialized;

/// A single medical document stored in the family vault.
/// Starts in status 'pending' when the client creates it; the
/// onVaultItemCreated Cloud Function fills in the extraction fields
/// and flips status to 'processed' (or 'failed').
class VaultItem {
  final String id;
  final String memberId;
  final String fileUrl;
  final String contentType;
  final String fileName;
  final DateTime uploadedAt;
  final String status; // 'pending' | 'processed' | 'failed'

  // Extraction fields (populated by Cloud Function)
  final String? docType;
  final String? providerName;
  final DateTime? dateOfService;
  final String summary;
  final List<String> diagnoses;
  final List<String> medications; // flattened for display: "Metformin 500mg BID"
  final DateTime? followUpDate;
  final List<String> flagsForReview;
  final String? detectedLanguage;

  // User-editable
  final String? userNote;
  final List<String> userTags;

  const VaultItem({
    required this.id,
    required this.memberId,
    required this.fileUrl,
    required this.contentType,
    required this.fileName,
    required this.uploadedAt,
    required this.status,
    this.docType,
    this.providerName,
    this.dateOfService,
    this.summary = '',
    this.diagnoses = const [],
    this.medications = const [],
    this.followUpDate,
    this.flagsForReview = const [],
    this.detectedLanguage,
    this.userNote,
    this.userTags = const [],
  });

  bool get isProcessed => status == 'processed';
  bool get isPending => status == 'pending';
  bool get isFailed => status == 'failed';

  factory VaultItem.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    final medsRaw = (d['medications'] as List?) ?? const [];
    final medsFlat = medsRaw
        .whereType<Map>()
        .map((m) {
          final name = (m['name'] as String?) ?? '';
          final dose = (m['dose'] as String?) ?? '';
          final freq = (m['frequency'] as String?) ?? '';
          return [name, dose, freq].where((s) => s.isNotEmpty).join(' ');
        })
        .where((s) => s.isNotEmpty)
        .toList();

    return VaultItem(
      id: doc.id,
      memberId: (d['memberId'] as String?) ?? '',
      fileUrl: (d['fileUrl'] as String?) ?? '',
      contentType: (d['contentType'] as String?) ?? '',
      fileName: (d['fileName'] as String?) ?? '',
      uploadedAt: _parseDate(d['uploadedAt']) ?? DateTime.now(),
      status: (d['status'] as String?) ?? 'pending',
      docType: d['docType'] as String?,
      providerName: d['providerName'] as String?,
      dateOfService: _parseDate(d['dateOfService']),
      summary: (d['summary'] as String?) ?? '',
      diagnoses: ((d['diagnoses'] as List?) ?? const []).whereType<String>().toList(),
      medications: medsFlat,
      followUpDate: _parseDate(d['followUpDate']),
      flagsForReview:
          ((d['flagsForReview'] as List?) ?? const []).whereType<String>().toList(),
      detectedLanguage: d['detectedLanguage'] as String?,
      userNote: d['userNote'] as String?,
      userTags: ((d['userTags'] as List?) ?? const []).whereType<String>().toList(),
    );
  }

  static DateTime? _parseDate(Object? raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is String) return DateTime.tryParse(raw);
    return null;
  }
}

/// All vault items for the signed-in user, newest first.
/// The client listens to this stream; the Cloud Function fills
/// extraction fields asynchronously and the UI updates live.
final vaultItemsProvider = StreamProvider.autoDispose<List<VaultItem>>((ref) {
  if (!isFirebaseInitialized) return Stream.value(const []);
  final uid = AuthService().currentUid;
  if (uid == null) return Stream.value(const []);

  return FirebaseFirestore.instance
      .collection('vault')
      .doc(uid)
      .collection('items')
      .orderBy('uploadedAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map(VaultItem.fromFirestore).toList());
});

/// Vault items scoped to a specific household member.
final vaultItemsForMemberProvider =
    Provider.autoDispose.family<List<VaultItem>, String>((ref, memberId) {
  final all = ref.watch(vaultItemsProvider).asData?.value ?? const [];
  return all.where((v) => v.memberId == memberId).toList();
});

final vaultServiceProvider = Provider<VaultService>((ref) => VaultService());

class VaultService {
  /// Upload a file to Firebase Storage and create the Firestore doc.
  /// The ingest Cloud Function picks it up from there and fills in
  /// the extraction fields asynchronously.
  /// Returns the new doc id, or null on failure.
  Future<String?> uploadFile({
    required File file,
    required String memberId,
  }) async {
    if (!isFirebaseInitialized) return null;
    final uid = AuthService().currentUid;
    if (uid == null) return null;

    final ext = file.path.split('.').last;
    final fileName = file.path.split('/').last;
    final itemId = DateTime.now().millisecondsSinceEpoch.toString();
    final path = 'vault/$uid/$itemId.$ext';

    // 1. Upload to Firebase Storage
    final url = await StorageService().uploadFile(file: file, path: path);
    if (url == null) return null;

    // 2. Write the pending Firestore doc — the trigger picks it up
    final contentType = _contentType(ext);
    final docRef = FirebaseFirestore.instance
        .collection('vault')
        .doc(uid)
        .collection('items')
        .doc(itemId);
    await docRef.set({
      'memberId': memberId,
      'fileUrl': url,
      'contentType': contentType,
      'fileName': fileName,
      'uploadedAt': FieldValue.serverTimestamp(),
      'status': 'pending',
    });
    return itemId;
  }

  /// Delete a vault item (both storage + Firestore).
  Future<void> deleteItem(VaultItem item) async {
    if (!isFirebaseInitialized) return;
    final uid = AuthService().currentUid;
    if (uid == null) return;

    await StorageService().deleteFile(item.fileUrl);
    await FirebaseFirestore.instance
        .collection('vault')
        .doc(uid)
        .collection('items')
        .doc(item.id)
        .delete();
  }

  /// Re-tag a vault item to a different member.
  Future<void> retagMember(VaultItem item, String newMemberId) async {
    if (!isFirebaseInitialized) return;
    final uid = AuthService().currentUid;
    if (uid == null) return;
    await FirebaseFirestore.instance
        .collection('vault')
        .doc(uid)
        .collection('items')
        .doc(item.id)
        .update({'memberId': newMemberId});
  }

  String _contentType(String ext) {
    switch (ext.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'heic':
        return 'image/heic';
      case 'pdf':
        return 'application/pdf';
      default:
        return 'application/octet-stream';
    }
  }
}
