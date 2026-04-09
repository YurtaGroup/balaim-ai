import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/consultation_service.dart';
import '../../auth/providers/auth_provider.dart';

/// Unread notification count — streams from Firestore
final unreadCountProvider = StreamProvider<int>((ref) {
  final userInfo = ref.watch(currentUserInfoProvider);
  final uid = userInfo.uid;
  if (uid == null) return Stream.value(0);
  return ConsultationService().watchUnreadCount(uid);
});
