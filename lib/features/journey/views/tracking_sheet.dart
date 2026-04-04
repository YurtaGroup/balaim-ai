import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/tracking_entry.dart';
import '../providers/journey_provider.dart';

class TrackingSheet extends ConsumerStatefulWidget {
  final TrackingType type;

  const TrackingSheet({super.key, required this.type});

  @override
  ConsumerState<TrackingSheet> createState() => _TrackingSheetState();
}

class _TrackingSheetState extends ConsumerState<TrackingSheet> {
  double _value = 0;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _value = _defaultValue;
  }

  double get _defaultValue {
    switch (widget.type) {
      case TrackingType.weight:
        return 68.0;
      case TrackingType.water:
        return 4;
      case TrackingType.sleep:
        return 7;
      case TrackingType.mood:
        return 3;
      default:
        return 0;
    }
  }

  String get _title {
    switch (widget.type) {
      case TrackingType.weight:
        return 'Log Weight';
      case TrackingType.water:
        return 'Log Water';
      case TrackingType.sleep:
        return 'Log Sleep';
      case TrackingType.mood:
        return 'Log Mood';
      default:
        return 'Log';
    }
  }

  String get _unit {
    switch (widget.type) {
      case TrackingType.weight:
        return 'kg';
      case TrackingType.water:
        return 'glasses';
      case TrackingType.sleep:
        return 'hours';
      case TrackingType.mood:
        return 'rating';
      default:
        return '';
    }
  }

  IconData get _icon {
    switch (widget.type) {
      case TrackingType.weight:
        return Icons.monitor_weight_outlined;
      case TrackingType.water:
        return Icons.water_drop_outlined;
      case TrackingType.sleep:
        return Icons.bedtime_outlined;
      case TrackingType.mood:
        return Icons.mood;
      default:
        return Icons.edit;
    }
  }

  Color get _color {
    switch (widget.type) {
      case TrackingType.weight:
        return AppColors.primary;
      case TrackingType.water:
        return AppColors.secondary;
      case TrackingType.sleep:
        return AppColors.accent;
      case TrackingType.mood:
        return AppColors.stagePrePregnancy;
      default:
        return AppColors.primary;
    }
  }

  double get _min {
    switch (widget.type) {
      case TrackingType.weight:
        return 40;
      case TrackingType.water:
        return 0;
      case TrackingType.sleep:
        return 0;
      case TrackingType.mood:
        return 1;
      default:
        return 0;
    }
  }

  double get _max {
    switch (widget.type) {
      case TrackingType.weight:
        return 150;
      case TrackingType.water:
        return 20;
      case TrackingType.sleep:
        return 16;
      case TrackingType.mood:
        return 5;
      default:
        return 100;
    }
  }

  String get _moodEmoji {
    if (widget.type != TrackingType.mood) return '';
    final moods = ['😢', '😟', '😐', '😊', '😄'];
    return moods[(_value - 1).round().clamp(0, 4)];
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    final profile = ref.read(userProfileProvider);
    final entry = TrackingEntry(
      id: const Uuid().v4(),
      userId: profile.uid,
      type: widget.type,
      value: _value,
      unit: _unit,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      timestamp: DateTime.now(),
      createdAt: DateTime.now(),
    );
    ref.read(trackingEntriesProvider.notifier).addEntry(entry);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Row(
            children: [
              Icon(_icon, color: _color, size: 24),
              const SizedBox(width: 10),
              Text(_title, style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 24),

          // Value display
          if (widget.type == TrackingType.mood)
            Text(_moodEmoji, style: const TextStyle(fontSize: 56))
          else
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: widget.type == TrackingType.weight
                        ? _value.toStringAsFixed(1)
                        : _value.round().toString(),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                      color: _color,
                    ),
                  ),
                  TextSpan(
                    text: ' $_unit',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),

          // Slider
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: _color,
              thumbColor: _color,
              inactiveTrackColor: _color.withValues(alpha: 0.15),
              overlayColor: _color.withValues(alpha: 0.1),
            ),
            child: Slider(
              value: _value,
              min: _min,
              max: _max,
              divisions: widget.type == TrackingType.weight
                  ? ((_max - _min) * 2).round()
                  : (_max - _min).round(),
              onChanged: (v) => setState(() => _value = v),
            ),
          ),
          const SizedBox(height: 16),

          // Notes
          TextField(
            controller: _notesController,
            decoration: InputDecoration(
              hintText: 'Add a note (optional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 24),

          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(backgroundColor: _color),
              child: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}
