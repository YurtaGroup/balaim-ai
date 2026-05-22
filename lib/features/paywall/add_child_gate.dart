import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/models/child_model.dart';
import '../journey/providers/journey_provider.dart';
import 'providers/premium_provider.dart';

/// Free tier = 1 child; Balam Premium = unlimited.
///
/// Returns true if the caller may proceed to add a child. Returns false
/// (and pushes the paywall) when a free user already has one child.
bool ensureCanAddChild(BuildContext context, WidgetRef ref) {
  final premium = ref.read(isPremiumProvider);
  final childCount = ref
      .read(userProfileProvider)
      .members
      .where((m) => m.role == MemberRole.child)
      .length;
  if (!premium && childCount >= 1) {
    context.push('/paywall');
    return false;
  }
  return true;
}
