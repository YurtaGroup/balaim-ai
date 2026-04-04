import 'package:flutter/material.dart';

/// Evidence-based emergency quick-reference for new parents.
/// Designed to be scannable at 3am. Never replaces professional medical advice.
enum Urgency {
  emergency('Go to ER NOW', Color(0xFFD32F2F)),
  callDoctor('Call doctor today', Color(0xFFF57C00)),
  watchFor('Watch for this', Color(0xFF5BBCB4));

  const Urgency(this.label, this.color);
  final String label;
  final Color color;
}

class EmergencySign {
  final String title;
  final String description;
  final Urgency urgency;

  const EmergencySign({
    required this.title,
    required this.description,
    required this.urgency,
  });
}

class EmergencyCategory {
  final String title;
  final IconData icon;
  final List<EmergencySign> signs;

  const EmergencyCategory({
    required this.title,
    required this.icon,
    required this.signs,
  });
}

class EmergencyData {
  EmergencyData._();

  static const categories = <EmergencyCategory>[
    EmergencyCategory(
      title: 'Fever & Illness',
      icon: Icons.thermostat,
      signs: [
        EmergencySign(
          title: 'Fever in baby under 3 months',
          description:
              'Rectal temp 38°C (100.4°F) or higher. Call pediatrician or go to ER immediately — even if baby seems OK.',
          urgency: Urgency.emergency,
        ),
        EmergencySign(
          title: 'Fever 39°C+ (102°F+) at any age',
          description:
              'Call doctor. High fevers need medical assessment.',
          urgency: Urgency.callDoctor,
        ),
        EmergencySign(
          title: 'Persistent fever 3+ days',
          description:
              'Call doctor even if low-grade. Could indicate infection.',
          urgency: Urgency.callDoctor,
        ),
      ],
    ),
    EmergencyCategory(
      title: 'Breathing',
      icon: Icons.air,
      signs: [
        EmergencySign(
          title: 'Blue lips, face, or fingers',
          description: 'Call 911 / emergency services immediately.',
          urgency: Urgency.emergency,
        ),
        EmergencySign(
          title: 'Struggling to breathe',
          description:
              'Grunting, flaring nostrils, chest pulling in with each breath. Go to ER.',
          urgency: Urgency.emergency,
        ),
        EmergencySign(
          title: 'Breathing faster than 60 breaths/min',
          description:
              'Count breaths for a full minute when baby is calm. Go to ER if persistent.',
          urgency: Urgency.emergency,
        ),
        EmergencySign(
          title: 'Wheezing or barky cough',
          description:
              'Call doctor — could be croup, bronchiolitis, or asthma.',
          urgency: Urgency.callDoctor,
        ),
      ],
    ),
    EmergencyCategory(
      title: 'Feeding & Hydration',
      icon: Icons.local_drink,
      signs: [
        EmergencySign(
          title: 'Fewer than 6 wet diapers/day (after day 5)',
          description:
              'Baby is not getting enough milk. Call doctor same day.',
          urgency: Urgency.callDoctor,
        ),
        EmergencySign(
          title: 'No wet diaper in 8+ hours',
          description: 'Sign of dehydration. Go to ER.',
          urgency: Urgency.emergency,
        ),
        EmergencySign(
          title: 'Refusing to feed for several hours',
          description:
              'Out of character. Baby may be sick. Call doctor.',
          urgency: Urgency.callDoctor,
        ),
        EmergencySign(
          title: 'Vomiting after every feed',
          description:
              'Different from spit-up. Forceful, large volume. Call doctor.',
          urgency: Urgency.callDoctor,
        ),
        EmergencySign(
          title: 'Projectile vomiting',
          description:
              'Shoots out forcefully. Could be pyloric stenosis. Call doctor today.',
          urgency: Urgency.callDoctor,
        ),
      ],
    ),
    EmergencyCategory(
      title: 'Behavior & Alertness',
      icon: Icons.visibility,
      signs: [
        EmergencySign(
          title: 'Floppy, unresponsive baby',
          description:
              "Doesn't respond to voice, touch, or stimulation. Call 911.",
          urgency: Urgency.emergency,
        ),
        EmergencySign(
          title: 'Extreme lethargy',
          description:
              "Very hard to wake, even for feeding. Sleeping all day. Go to ER.",
          urgency: Urgency.emergency,
        ),
        EmergencySign(
          title: 'High-pitched continuous cry',
          description:
              "Unusual 'weak' or 'shrill' cry. Could indicate serious illness. Call doctor.",
          urgency: Urgency.callDoctor,
        ),
        EmergencySign(
          title: 'Inconsolable crying 3+ hours',
          description:
              "Non-stop screaming that nothing calms. Call doctor — could be colic or something more.",
          urgency: Urgency.callDoctor,
        ),
      ],
    ),
    EmergencyCategory(
      title: 'Color & Skin',
      icon: Icons.palette,
      signs: [
        EmergencySign(
          title: 'Yellow skin getting worse (jaundice)',
          description:
              'Especially in the first 2 weeks. Spreading to legs/feet. Call doctor today.',
          urgency: Urgency.callDoctor,
        ),
        EmergencySign(
          title: 'Rash that doesn\'t fade with glass test',
          description:
              'Press a clear glass on rash — if it doesn\'t fade, could be meningitis. Go to ER.',
          urgency: Urgency.emergency,
        ),
        EmergencySign(
          title: 'Pale, gray, or mottled skin',
          description: 'Call 911. Sign of poor circulation.',
          urgency: Urgency.emergency,
        ),
      ],
    ),
    EmergencyCategory(
      title: 'Injuries',
      icon: Icons.medical_services,
      signs: [
        EmergencySign(
          title: 'Any head injury with loss of consciousness',
          description: 'Go to ER, even briefly.',
          urgency: Urgency.emergency,
        ),
        EmergencySign(
          title: 'Fall from height',
          description:
              'Changing table, bed, couch — call doctor. Watch for vomiting, drowsiness, behavior changes.',
          urgency: Urgency.callDoctor,
        ),
        EmergencySign(
          title: 'Choking / gagging that doesn\'t clear',
          description:
              "Baby can't breathe, cry, or cough. Call 911. Start infant CPR.",
          urgency: Urgency.emergency,
        ),
      ],
    ),
    EmergencyCategory(
      title: 'Stool & Diapers',
      icon: Icons.baby_changing_station,
      signs: [
        EmergencySign(
          title: 'Bloody stool',
          description:
              'Any visible blood in diaper. Call doctor same day.',
          urgency: Urgency.callDoctor,
        ),
        EmergencySign(
          title: 'Black, tarry stool (after day 5)',
          description:
              'Meconium is normal first few days. After that, black stool could mean bleeding. Call doctor.',
          urgency: Urgency.callDoctor,
        ),
        EmergencySign(
          title: 'White/pale stool',
          description:
              'Could indicate liver issue. Call doctor today.',
          urgency: Urgency.callDoctor,
        ),
        EmergencySign(
          title: 'Watery diarrhea multiple times',
          description:
              'Risk of dehydration. Monitor wet diapers. Call if concerned.',
          urgency: Urgency.callDoctor,
        ),
      ],
    ),
  ];
}
