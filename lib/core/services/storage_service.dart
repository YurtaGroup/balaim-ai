import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../main.dart' show isFirebaseInitialized;

/// Firebase Storage service for uploading images and files.
/// Returns download URLs on success, null on failure.
/// In demo mode: returns a fake URL so the flow works without Firebase.
class StorageService {
  static final StorageService _instance = StorageService._();
  factory StorageService() => _instance;
  StorageService._();

  final _picker = ImagePicker();

  FirebaseStorage? get _storage =>
      isFirebaseInitialized ? FirebaseStorage.instance : null;

  // ── Pick image ──

  Future<File?> pickFromCamera() async {
    final xFile = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 80,
    );
    if (xFile == null) return null;
    return File(xFile.path);
  }

  Future<File?> pickFromGallery() async {
    final xFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 80,
    );
    if (xFile == null) return null;
    return File(xFile.path);
  }

  Future<List<File>> pickMultipleFromGallery() async {
    final xFiles = await _picker.pickMultiImage(
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 80,
    );
    return xFiles.map((xf) => File(xf.path)).toList();
  }

  // ── Upload ──

  /// Upload a file to Firebase Storage. Returns the download URL.
  /// [path] is the storage path, e.g. 'consultations/{id}/lab_0.jpg'
  Future<String?> uploadFile({
    required File file,
    required String path,
    ValueChanged<double>? onProgress,
  }) async {
    if (_storage == null) {
      // Demo mode — return a placeholder URL
      debugPrint('[Storage] Demo mode — returning placeholder URL for $path');
      await Future.delayed(const Duration(milliseconds: 500));
      return 'https://storage.demo.balam.ai/$path';
    }

    try {
      final ref = _storage!.ref(path);
      final uploadTask = ref.putFile(
        file,
        SettableMetadata(contentType: _contentType(file.path)),
      );

      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((snap) {
          final progress = snap.bytesTransferred / snap.totalBytes;
          onProgress(progress);
        });
      }

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      debugPrint('[Storage] Uploaded: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('[Storage] Upload error: $e');
      return null;
    }
  }

  /// Upload for consultation: lab results or photos.
  Future<String?> uploadConsultationFile({
    required File file,
    required String consultationId,
    required String type, // 'labs' or 'photos'
    required int index,
  }) {
    final ext = file.path.split('.').last;
    final path = 'consultations/$consultationId/$type/${type}_$index.$ext';
    return uploadFile(file: file, path: path);
  }

  /// Upload profile photo.
  Future<String?> uploadProfilePhoto({
    required File file,
    required String userId,
  }) {
    final ext = file.path.split('.').last;
    final path = 'profiles/$userId/avatar.$ext';
    return uploadFile(file: file, path: path);
  }

  // ── Delete ──

  Future<void> deleteFile(String url) async {
    if (_storage == null) return;
    try {
      await _storage!.refFromURL(url).delete();
    } catch (e) {
      debugPrint('[Storage] Delete error: $e');
    }
  }

  // ── Helpers ──

  String _contentType(String filePath) {
    final ext = filePath.split('.').last.toLowerCase();
    switch (ext) {
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

  /// Show picker bottom sheet: Camera or Gallery.
  Future<File?> showPickerSheet(BuildContext context) async {
    File? result;
    await showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a photo'),
              onTap: () async {
                result = await pickFromCamera();
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () async {
                result = await pickFromGallery();
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      ),
    );
    return result;
  }
}
