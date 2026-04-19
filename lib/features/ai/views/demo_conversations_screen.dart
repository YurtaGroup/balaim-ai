import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../data/demo_conversations.dart';
import '../services/ai_service.dart';

/// Read-only showcase of example Balam AI conversations.
///
/// Why: during beta it's important testers see the product work even
/// when they (a) run out of their daily rate-limit quota, or (b) the
/// Anthropic account is out of credit. These exchanges are bundled with
/// the app in all 3 languages so there's zero Claude cost to browse.
class DemoConversationsScreen extends StatelessWidget {
  const DemoConversationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(L.of(context).exampleConversations),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: demoConversations.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) => _ConversationTile(
          convo: demoConversations[i],
        ),
      ),
    );
  }
}

class _ConversationTile extends StatefulWidget {
  final DemoConversation convo;
  const _ConversationTile({required this.convo});

  @override
  State<_ConversationTile> createState() => _ConversationTileState();
}

class _ConversationTileState extends State<_ConversationTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.convo;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: _expanded
                ? const BorderRadius.vertical(top: Radius.circular(18))
                : BorderRadius.circular(18),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(c.icon, color: AppColors.secondary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.title.of(context),
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          c.question.of(context),
                          style: TextStyle(fontSize: 12, color: AppColors.textHint, height: 1.3),
                          maxLines: _expanded ? null : 2,
                          overflow: _expanded ? null : TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.textHint,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    L.of(context).balamResponds,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: AppColors.textHint,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    c.answer.of(context),
                    style: const TextStyle(fontSize: 14, height: 1.55),
                  ),
                  if (c.triage != null && c.triage!.isRedFlag) ...[
                    const SizedBox(height: 14),
                    _MiniTriageBanner(triage: c.triage!),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniTriageBanner extends StatelessWidget {
  final Triage triage;
  const _MiniTriageBanner({required this.triage});

  @override
  Widget build(BuildContext context) {
    final isEmergency = triage.urgency == TriageUrgency.emergency;
    final color = isEmergency ? AppColors.error : AppColors.accentDark;
    final label = isEmergency
        ? L.of(context).triageEmergencyTitle
        : L.of(context).triageHighTitle;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(
            isEmergency ? Icons.emergency : Icons.medical_services,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
