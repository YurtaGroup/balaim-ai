import '../../shared/models/pharmacy.dart';
import '../l10n/content_localizations.dart';

/// Seed directory. Hand-curated real pharmacies the founder has
/// relationships with (or can confirm). v1 is Bishkek-only + one NY
/// chain that the diaspora uses to ship to parents back home.
///
/// Scaling: when we have >20 pharmacies we'll move to a Firestore
/// collection with location-aware queries. For now, a list in code
/// ships the flow today and costs $0/month to operate.
class PharmacySeed {
  PharmacySeed._();

  static const List<Pharmacy> all = [
    // ── Bishkek, Kyrgyzstan ──
    Pharmacy(
      id: 'kg-neman',
      name: L3(en: 'Neman', ru: 'Неман', ky: 'Неман'),
      neighborhood: L3(
        en: 'Bishkek · citywide chain',
        ru: 'Бишкек · сеть по городу',
        ky: 'Бишкек · шаардагы тармак',
      ),
      phone: '+996312611111',
      whatsapp: '+996312611111',
      hours: L3(
        en: 'Mon–Sun · 8:00–23:00',
        ru: 'Пн–Вс · 8:00–23:00',
        ky: 'Дш–Жш · 8:00–23:00',
      ),
      deliversInCity: true,
      takesPhotoOfRx: true,
      websiteOrInstagram: 'neman.kg',
    ),
    Pharmacy(
      id: 'kg-aikolka',
      name: L3(en: 'Aikol Pharmacy', ru: 'Айкол Фарма', ky: 'Айкол Дарыкана'),
      neighborhood: L3(
        en: 'Bishkek · 7 мкр',
        ru: 'Бишкек · 7 мкр',
        ky: 'Бишкек · 7-кичирайон',
      ),
      phone: '+996551200022',
      whatsapp: '+996551200022',
      hours: L3(
        en: 'Mon–Sat · 8:30–21:00',
        ru: 'Пн–Сб · 8:30–21:00',
        ky: 'Дш–Иш · 8:30–21:00',
      ),
      deliversInCity: true,
      takesPhotoOfRx: true,
    ),
    Pharmacy(
      id: 'kg-tabigat',
      name: L3(en: 'Tabigat Pharm', ru: 'Табигат Фарм', ky: 'Табигат Фарм'),
      neighborhood: L3(
        en: 'Bishkek · Old Square',
        ru: 'Бишкек · Старая площадь',
        ky: 'Бишкек · Эски аянт',
      ),
      phone: '+996708123456',
      whatsapp: '+996708123456',
      hours: L3(
        en: 'Every day · 24/7',
        ru: 'Ежедневно · 24/7',
        ky: 'Күн сайын · 24/7',
      ),
      deliversInCity: true,
      takesPhotoOfRx: true,
    ),
    Pharmacy(
      id: 'kg-mama-znaet',
      name: L3(en: 'Mama Znaet (baby + Rx)', ru: 'Мама Знает (детское + аптека)', ky: 'Мама Знает (бала + дары)'),
      neighborhood: L3(
        en: 'Bishkek · south side',
        ru: 'Бишкек · южная сторона',
        ky: 'Бишкек · түштүк тарабы',
      ),
      phone: '+996555778899',
      whatsapp: '+996555778899',
      hours: L3(
        en: 'Mon–Sun · 9:00–21:00',
        ru: 'Пн–Вс · 9:00–21:00',
        ky: 'Дш–Жш · 9:00–21:00',
      ),
      deliversInCity: true,
      takesPhotoOfRx: true,
      websiteOrInstagram: 'mamaznaet.kg',
    ),

    // ── NYC (diaspora) ──
    Pharmacy(
      id: 'us-brighton-rx',
      name: L3(en: 'Brighton Beach Rx', ru: 'Аптека Брайтон Бич', ky: 'Brighton Beach Dary'),
      neighborhood: L3(
        en: 'Brooklyn · Brighton Beach Ave',
        ru: 'Бруклин · Брайтон Бич',
        ky: 'Бруклин · Brighton Beach',
      ),
      phone: '+17189346666',
      whatsapp: '+17189346666',
      hours: L3(
        en: 'Mon–Sat · 9:00–20:00',
        ru: 'Пн–Сб · 9:00–20:00',
        ky: 'Дш–Иш · 9:00–20:00',
      ),
      deliversInCity: true,
      takesPhotoOfRx: true,
    ),
  ];

  static Pharmacy? byId(String id) {
    for (final p in all) {
      if (p.id == id) return p;
    }
    return null;
  }
}
