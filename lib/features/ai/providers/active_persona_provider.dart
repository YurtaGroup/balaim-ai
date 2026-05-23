import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/persona.dart';

/// The currently-active AI persona. Persisted in SharedPreferences so the
/// choice survives app restarts. Default is Balam (the free Montessori
/// coach). Premium personas are gated by the paywall on selection — server
/// also enforces the gate so a stale or forged selection silently falls
/// back to Balam.
final activePersonaProvider =
    StateNotifierProvider<ActivePersonaNotifier, PersonaId>((ref) {
  return ActivePersonaNotifier();
});

class ActivePersonaNotifier extends StateNotifier<PersonaId> {
  static const _key = 'ai.activePersonaId';

  ActivePersonaNotifier() : super(PersonaId.balam) {
    _hydrate();
  }

  Future<void> _hydrate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) return;
      state = PersonaId.fromServerId(raw);
    } catch (_) {
      // ignore — defaults to balam
    }
  }

  Future<void> set(PersonaId next) async {
    state = next;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, next.serverId);
    } catch (_) {
      // best-effort
    }
  }
}
