/// Hospital bag checklist seed data.
/// Curated from common labor & delivery recommendations.
enum BagCategory {
  mom('For Mom'),
  baby('For Baby'),
  partner('For Partner'),
  documents('Documents');

  const BagCategory(this.label);
  final String label;
}

class HospitalBagItem {
  final String id;
  final BagCategory category;
  final String name;
  final String? note;
  final bool essential;

  const HospitalBagItem({
    required this.id,
    required this.category,
    required this.name,
    this.note,
    this.essential = false,
  });
}

class HospitalBagData {
  HospitalBagData._();

  static const items = <HospitalBagItem>[
    // DOCUMENTS
    HospitalBagItem(
      id: 'doc-id',
      category: BagCategory.documents,
      name: 'ID / passport',
      essential: true,
    ),
    HospitalBagItem(
      id: 'doc-insurance',
      category: BagCategory.documents,
      name: 'Insurance card',
      essential: true,
    ),
    HospitalBagItem(
      id: 'doc-hospital-paperwork',
      category: BagCategory.documents,
      name: 'Hospital pre-registration papers',
      essential: true,
    ),
    HospitalBagItem(
      id: 'doc-birth-plan',
      category: BagCategory.documents,
      name: 'Birth plan (printed copies)',
      note: '3 copies: nurse, doctor, chart',
    ),
    HospitalBagItem(
      id: 'doc-prenatal-records',
      category: BagCategory.documents,
      name: 'Prenatal medical records',
    ),

    // FOR MOM
    HospitalBagItem(
      id: 'mom-robe',
      category: BagCategory.mom,
      name: 'Comfortable robe',
      note: 'Dark colors hide stains',
      essential: true,
    ),
    HospitalBagItem(
      id: 'mom-slippers',
      category: BagCategory.mom,
      name: 'Non-slip slippers or socks',
      essential: true,
    ),
    HospitalBagItem(
      id: 'mom-nursing-bras',
      category: BagCategory.mom,
      name: 'Nursing bras (2-3)',
      essential: true,
    ),
    HospitalBagItem(
      id: 'mom-nursing-pads',
      category: BagCategory.mom,
      name: 'Nursing pads',
    ),
    HospitalBagItem(
      id: 'mom-underwear',
      category: BagCategory.mom,
      name: 'Disposable or old underwear (5+)',
      note: 'You will bleed. Don\'t bring your nice ones.',
      essential: true,
    ),
    HospitalBagItem(
      id: 'mom-pads',
      category: BagCategory.mom,
      name: 'Heavy-flow maxi pads',
      note: 'Hospital provides some, but bring extras',
    ),
    HospitalBagItem(
      id: 'mom-toiletries',
      category: BagCategory.mom,
      name: 'Toiletries (shampoo, toothbrush, lip balm)',
      essential: true,
    ),
    HospitalBagItem(
      id: 'mom-hair-ties',
      category: BagCategory.mom,
      name: 'Hair ties and clips',
    ),
    HospitalBagItem(
      id: 'mom-phone-charger',
      category: BagCategory.mom,
      name: 'Phone charger (extra long cord)',
      essential: true,
    ),
    HospitalBagItem(
      id: 'mom-snacks',
      category: BagCategory.mom,
      name: 'Snacks for labor and after',
      note: 'Granola bars, dried fruit, crackers',
    ),
    HospitalBagItem(
      id: 'mom-water-bottle',
      category: BagCategory.mom,
      name: 'Water bottle with straw',
    ),
    HospitalBagItem(
      id: 'mom-going-home-outfit',
      category: BagCategory.mom,
      name: 'Loose going-home outfit',
      note: 'You\'ll still look pregnant for weeks',
      essential: true,
    ),
    HospitalBagItem(
      id: 'mom-pillow',
      category: BagCategory.mom,
      name: 'Your own pillow',
      note: 'Hospital pillows are flat',
    ),
    HospitalBagItem(
      id: 'mom-eye-mask',
      category: BagCategory.mom,
      name: 'Eye mask and earplugs',
      note: 'Hospital rooms are bright and noisy',
    ),

    // FOR BABY
    HospitalBagItem(
      id: 'baby-going-home',
      category: BagCategory.baby,
      name: 'Going-home outfit (2 sizes: newborn + 0-3mo)',
      essential: true,
    ),
    HospitalBagItem(
      id: 'baby-onesies',
      category: BagCategory.baby,
      name: 'Onesies or sleepers (2-3)',
    ),
    HospitalBagItem(
      id: 'baby-socks-hat',
      category: BagCategory.baby,
      name: 'Socks, mittens, hat',
      essential: true,
    ),
    HospitalBagItem(
      id: 'baby-swaddle',
      category: BagCategory.baby,
      name: 'Swaddle blankets (2)',
    ),
    HospitalBagItem(
      id: 'baby-car-seat',
      category: BagCategory.baby,
      name: 'Car seat (installed!)',
      note: 'Hospital will not let you leave without one',
      essential: true,
    ),
    HospitalBagItem(
      id: 'baby-weather-gear',
      category: BagCategory.baby,
      name: 'Weather-appropriate outerwear',
      note: 'Thin blanket for car seat (NOT under straps)',
    ),

    // FOR PARTNER
    HospitalBagItem(
      id: 'partner-clothes',
      category: BagCategory.partner,
      name: 'Change of clothes (2 days)',
      essential: true,
    ),
    HospitalBagItem(
      id: 'partner-toiletries',
      category: BagCategory.partner,
      name: 'Toiletries',
    ),
    HospitalBagItem(
      id: 'partner-snacks',
      category: BagCategory.partner,
      name: 'Snacks and drinks',
      note: 'Labor takes hours. Hospital food is expensive.',
    ),
    HospitalBagItem(
      id: 'partner-charger',
      category: BagCategory.partner,
      name: 'Phone charger',
      essential: true,
    ),
    HospitalBagItem(
      id: 'partner-camera',
      category: BagCategory.partner,
      name: 'Camera (or good phone camera)',
    ),
    HospitalBagItem(
      id: 'partner-pillow-blanket',
      category: BagCategory.partner,
      name: 'Pillow and light blanket',
      note: 'Hospital chairs are terrible',
    ),
  ];

  static List<HospitalBagItem> byCategory(BagCategory category) {
    return items.where((i) => i.category == category).toList();
  }

  static List<HospitalBagItem> essentials() {
    return items.where((i) => i.essential).toList();
  }
}
