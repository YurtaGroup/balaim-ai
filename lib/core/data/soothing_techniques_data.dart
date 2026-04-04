import 'package:flutter/material.dart';

/// Evidence-based soothing techniques for crying newborns.
/// Content aligned with Dr. Harvey Karp's Happiest Baby methodology,
/// AAP safe sleep guidelines, and common pediatric advice.
class SoothingTechnique {
  final String id;
  final String title;
  final String shortDescription;
  final IconData icon;
  final Color color;
  final List<SoothingStep> steps;
  final List<String> whenToUse;
  final List<String> safetyNotes;

  const SoothingTechnique({
    required this.id,
    required this.title,
    required this.shortDescription,
    required this.icon,
    required this.color,
    required this.steps,
    required this.whenToUse,
    this.safetyNotes = const [],
  });
}

class SoothingStep {
  final String title;
  final String description;

  const SoothingStep({required this.title, required this.description});
}

class SoothingTechniquesData {
  SoothingTechniquesData._();

  static const techniques = <SoothingTechnique>[
    // The 5 S's — core method
    SoothingTechnique(
      id: 'five-s',
      title: "The 5 S's",
      shortDescription:
          'Dr. Harvey Karp\'s proven method — the fourth trimester survival guide',
      icon: Icons.auto_awesome,
      color: Color(0xFFE8787A),
      steps: [
        SoothingStep(
          title: '1. Swaddle',
          description:
              'Wrap baby snugly with arms down. This mimics the womb. Use a blanket or purpose-made swaddle. Arms snug, hips LOOSE (hip dysplasia risk if tight).',
        ),
        SoothingStep(
          title: '2. Side or Stomach position',
          description:
              'Hold baby on their side or stomach in your arms — NEVER to sleep. This position calms them because gravity isn\'t triggering their startle reflex.',
        ),
        SoothingStep(
          title: '3. Shush',
          description:
              'Make a loud "shhhhh" sound right in baby\'s ear, as loud as their crying. The womb is LOUD — about 85 decibels. Gentle shushing won\'t break through crying.',
        ),
        SoothingStep(
          title: '4. Swing',
          description:
              'Tiny, jiggly motions — small head movements, about 1 inch back and forth, 2-3 per second. NOT shaking. Think: jello jiggling.',
        ),
        SoothingStep(
          title: '5. Suck',
          description:
              'Offer a pacifier, clean finger, or breast. Sucking releases calming chemicals in baby\'s brain.',
        ),
      ],
      whenToUse: [
        'Crying that won\'t stop',
        'Colicky baby (crying >3 hours/day)',
        'Before naps and bedtime',
        '0-3 months (fourth trimester)',
      ],
      safetyNotes: [
        'Do all 5 S\'s TOGETHER, not one at a time',
        'Always place baby on their BACK to sleep',
        'Side/stomach position is only while holding awake baby',
        'Most babies calm within 60 seconds when done correctly',
      ],
    ),

    // Hunger check
    SoothingTechnique(
      id: 'hunger',
      title: 'Hunger Check',
      shortDescription: 'Is baby hungry? Offer the breast or bottle first.',
      icon: Icons.restaurant,
      color: Color(0xFFF5C15A),
      steps: [
        SoothingStep(
          title: 'Look for hunger cues',
          description:
              'Rooting (turning head toward touch), hand-to-mouth, lip smacking, sucking on hands. Crying is a LATE hunger cue.',
        ),
        SoothingStep(
          title: 'Offer feeding',
          description:
              'Breast: offer both sides. Bottle: start with half the usual amount. Newborns eat every 2-3 hours.',
        ),
        SoothingStep(
          title: 'Burp halfway',
          description:
              'Burp when baby pauses or after the first breast. Gas can cause fussiness.',
        ),
      ],
      whenToUse: [
        'Baby cried within last 2-3 hours of eating',
        'Shows hunger cues',
        'Last feeding was small',
      ],
    ),

    // Diaper check
    SoothingTechnique(
      id: 'diaper',
      title: 'Diaper Check',
      shortDescription: 'Quick, obvious, but easy to forget.',
      icon: Icons.baby_changing_station,
      color: Color(0xFF5BBCB4),
      steps: [
        SoothingStep(
          title: 'Check and change',
          description:
              'Newborns need 8-12 diaper changes a day. Wet or dirty diapers cause discomfort.',
        ),
        SoothingStep(
          title: 'Check for rash',
          description:
              'Red skin in the diaper area? Apply barrier cream. Let baby air out for a few minutes if possible.',
        ),
      ],
      whenToUse: [
        'Every 2-3 hours',
        'Before feeds',
        'When baby fusses for no obvious reason',
      ],
    ),

    // Too hot/cold
    SoothingTechnique(
      id: 'temperature',
      title: 'Temperature Check',
      shortDescription: 'Babies can\'t regulate their own temperature well.',
      icon: Icons.thermostat,
      color: Color(0xFF4FC3F7),
      steps: [
        SoothingStep(
          title: 'Check baby\'s neck/chest',
          description:
              'Feel baby\'s neck or chest (NOT hands/feet). Hands and feet are naturally cooler. Neck should feel warm, not sweaty or cold.',
        ),
        SoothingStep(
          title: 'Room temperature',
          description:
              'Ideal: 20-22°C (68-72°F). Baby should wear one more layer than you feel comfortable in.',
        ),
        SoothingStep(
          title: 'Adjust clothing',
          description:
              'Too hot = remove a layer. Too cold = add a layer. Never overdress for sleep (SIDS risk).',
        ),
      ],
      whenToUse: [
        'Baby seems fussy without obvious cause',
        'Sweating or red-faced',
        'Cold to the touch on neck',
      ],
    ),

    // Burping
    SoothingTechnique(
      id: 'burping',
      title: 'Burping Positions',
      shortDescription: 'Trapped gas is a top cause of baby fussiness.',
      icon: Icons.air,
      color: Color(0xFFFF7043),
      steps: [
        SoothingStep(
          title: 'Over-the-shoulder',
          description:
              'Hold baby upright, their chin on your shoulder. Support their bottom. Pat firmly between shoulder blades.',
        ),
        SoothingStep(
          title: 'Sitting on lap',
          description:
              'Sit baby upright on your lap. Support their chest and chin with one hand. Pat or rub their back with the other.',
        ),
        SoothingStep(
          title: 'Face-down on lap',
          description:
              'Lay baby face-down across your knees. Support their head (turned to side). Pat gently. Works great for stubborn gas.',
        ),
      ],
      whenToUse: [
        'After every feeding',
        'If baby cries shortly after eating',
        'If baby pulls legs up to belly (gas pain sign)',
      ],
    ),

    // Overstimulation
    SoothingTechnique(
      id: 'overstimulation',
      title: 'Reduce Stimulation',
      shortDescription: 'Too much world can overwhelm a newborn brain.',
      icon: Icons.visibility_off,
      color: Color(0xFF9575CD),
      steps: [
        SoothingStep(
          title: 'Go to a quiet room',
          description:
              'Dim the lights, close curtains, turn off TV/phones. Low sensory input.',
        ),
        SoothingStep(
          title: 'Reduce handling',
          description:
              'Stop passing baby around. One person holds baby quietly, close to their chest.',
        ),
        SoothingStep(
          title: 'White noise',
          description:
              'Turn on steady white noise. Mimics the womb. Use the Sounds tab in this app.',
        ),
      ],
      whenToUse: [
        'End of the day (witching hour)',
        'After visitors left',
        'Baby is arching back, turning away, closing eyes',
        'After stimulating activities',
      ],
    ),

    // Bicycle legs
    SoothingTechnique(
      id: 'bicycle',
      title: 'Bicycle Legs',
      shortDescription: 'Gentle massage for gas and constipation relief.',
      icon: Icons.directions_bike,
      color: Color(0xFF66BB6A),
      steps: [
        SoothingStep(
          title: 'Lay baby on back',
          description:
              'On a firm, flat surface. Make eye contact and smile.',
        ),
        SoothingStep(
          title: 'Gentle cycling motion',
          description:
              'Hold their ankles. Gently bend and straighten their legs in a cycling motion, one at a time. 10-20 cycles.',
        ),
        SoothingStep(
          title: 'Knees to chest',
          description:
              'Bring both knees up to their chest and hold for 10 seconds. Release. Repeat 3-5 times.',
        ),
        SoothingStep(
          title: 'Tummy massage',
          description:
              'Gently massage baby\'s belly in clockwise circles. This follows the natural direction of the intestines.',
        ),
      ],
      whenToUse: [
        'Baby is gassy or constipated',
        'Pulling legs up',
        'Straining without passing gas/stool',
        'Between feedings (not right after)',
      ],
    ),

    // Movement
    SoothingTechnique(
      id: 'movement',
      title: 'Movement & Motion',
      shortDescription: 'Babies spent 9 months being rocked. They need it.',
      icon: Icons.directions_walk,
      color: Color(0xFF26A69A),
      steps: [
        SoothingStep(
          title: 'Walking',
          description:
              'Carry baby while walking. Pace around the room, up and down stairs, around the block.',
        ),
        SoothingStep(
          title: 'Rocking chair',
          description:
              'Steady back-and-forth rocking. Rhythmic and predictable.',
        ),
        SoothingStep(
          title: 'Baby carrier',
          description:
              'Wearing baby close keeps them calm and frees your hands. Wrap, sling, or structured carrier.',
        ),
        SoothingStep(
          title: 'Car ride',
          description:
              'Last resort but effective. The rhythm of driving calms most babies within minutes.',
        ),
      ],
      whenToUse: [
        'Baby is fussy but not hungry/tired',
        'Evening fussiness',
        'Need to free your hands',
        'Before sleep',
      ],
    ),

    // Singing
    SoothingTechnique(
      id: 'singing',
      title: 'Singing & Talking',
      shortDescription: 'Your voice is your baby\'s favorite sound.',
      icon: Icons.music_note,
      color: Color(0xFFEC407A),
      steps: [
        SoothingStep(
          title: 'Sing anything',
          description:
              'Baby doesn\'t care if you\'re in tune. They recognized your voice from the womb — it\'s comforting.',
        ),
        SoothingStep(
          title: 'Narrate what you\'re doing',
          description:
              '"We\'re going to change your diaper now, sweet girl." This builds language and connection.',
        ),
        SoothingStep(
          title: 'Low hum',
          description:
              'A low, steady hum right next to baby\'s ear. Creates vibration similar to being in the womb.',
        ),
      ],
      whenToUse: [
        'Bonding time',
        'During feeds and diaper changes',
        'To distract before a meltdown',
        'Bath time',
      ],
    ),

    // Warm bath
    SoothingTechnique(
      id: 'bath',
      title: 'Warm Bath',
      shortDescription: 'The ultimate reset button.',
      icon: Icons.bathtub,
      color: Color(0xFF4DB6AC),
      steps: [
        SoothingStep(
          title: 'Fill to 2 inches',
          description:
              'Water temperature: 37°C / 98°F. Test with your wrist or a thermometer.',
        ),
        SoothingStep(
          title: 'Support head & neck',
          description:
              'Keep baby\'s head and neck above water at all times. Use one hand to support under their arm and shoulder.',
        ),
        SoothingStep(
          title: 'Cup water over belly',
          description:
              'Keep them warm by continuously pouring water over their body with your free hand.',
        ),
        SoothingStep(
          title: 'Wrap immediately after',
          description:
              'Babies get cold fast. Wrap in a warm towel as soon as you lift them out.',
        ),
      ],
      whenToUse: [
        'Evening fussiness',
        'Before bedtime routine',
        'When nothing else works',
      ],
      safetyNotes: [
        'NEVER leave baby alone in water — not even for a second',
        'Water should be no deeper than 2 inches',
        'Until cord stump falls off (~2 weeks), sponge bath only',
      ],
    ),
  ];

  static SoothingTechnique? byId(String id) {
    try {
      return techniques.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }
}
