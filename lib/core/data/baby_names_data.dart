/// Baby names seed data.
/// Multi-origin curated list — Kyrgyz, Russian, Western, Arabic, Turkish.
enum NameGender { boy, girl, unisex }

enum NameOrigin {
  kyrgyz('Kyrgyz'),
  russian('Russian'),
  western('Western'),
  arabic('Arabic'),
  turkish('Turkish'),
  persian('Persian');

  const NameOrigin(this.label);
  final String label;
}

class BabyName {
  final String name;
  final NameGender gender;
  final NameOrigin origin;
  final String meaning;

  const BabyName({
    required this.name,
    required this.gender,
    required this.origin,
    required this.meaning,
  });

  String get id => '${name.toLowerCase()}_${gender.name}';
}

class BabyNamesData {
  BabyNamesData._();

  static const names = <BabyName>[
    // KYRGYZ — BOYS
    BabyName(name: 'Айбек', gender: NameGender.boy, origin: NameOrigin.kyrgyz, meaning: 'Moon prince'),
    BabyName(name: 'Балбек', gender: NameGender.boy, origin: NameOrigin.kyrgyz, meaning: 'Honey prince'),
    BabyName(name: 'Чынгыз', gender: NameGender.boy, origin: NameOrigin.kyrgyz, meaning: 'Great, oceanic'),
    BabyName(name: 'Эрлан', gender: NameGender.boy, origin: NameOrigin.kyrgyz, meaning: 'Brave young man'),
    BabyName(name: 'Темир', gender: NameGender.boy, origin: NameOrigin.kyrgyz, meaning: 'Iron, strong'),
    BabyName(name: 'Нурлан', gender: NameGender.boy, origin: NameOrigin.kyrgyz, meaning: 'Light, radiant'),
    BabyName(name: 'Бакыт', gender: NameGender.boy, origin: NameOrigin.kyrgyz, meaning: 'Happiness'),
    BabyName(name: 'Данияр', gender: NameGender.boy, origin: NameOrigin.kyrgyz, meaning: 'Close friend, wise'),
    BabyName(name: 'Азамат', gender: NameGender.boy, origin: NameOrigin.kyrgyz, meaning: 'Honorable, brave'),
    BabyName(name: 'Манас', gender: NameGender.boy, origin: NameOrigin.kyrgyz, meaning: 'Legendary hero'),

    // KYRGYZ — GIRLS
    BabyName(name: 'Айгуль', gender: NameGender.girl, origin: NameOrigin.kyrgyz, meaning: 'Moon flower'),
    BabyName(name: 'Гульнара', gender: NameGender.girl, origin: NameOrigin.kyrgyz, meaning: 'Pomegranate flower'),
    BabyName(name: 'Нурия', gender: NameGender.girl, origin: NameOrigin.kyrgyz, meaning: 'Light'),
    BabyName(name: 'Алтынай', gender: NameGender.girl, origin: NameOrigin.kyrgyz, meaning: 'Golden moon'),
    BabyName(name: 'Бермет', gender: NameGender.girl, origin: NameOrigin.kyrgyz, meaning: 'Pearl'),
    BabyName(name: 'Чолпон', gender: NameGender.girl, origin: NameOrigin.kyrgyz, meaning: 'Morning star (Venus)'),
    BabyName(name: 'Жылдыз', gender: NameGender.girl, origin: NameOrigin.kyrgyz, meaning: 'Star'),
    BabyName(name: 'Сезим', gender: NameGender.girl, origin: NameOrigin.kyrgyz, meaning: 'Feeling, emotion'),
    BabyName(name: 'Айсулуу', gender: NameGender.girl, origin: NameOrigin.kyrgyz, meaning: 'Moon beauty'),
    BabyName(name: 'Меерим', gender: NameGender.girl, origin: NameOrigin.kyrgyz, meaning: 'Kindness, mercy'),

    // RUSSIAN — BOYS
    BabyName(name: 'Александр', gender: NameGender.boy, origin: NameOrigin.russian, meaning: 'Defender of the people'),
    BabyName(name: 'Михаил', gender: NameGender.boy, origin: NameOrigin.russian, meaning: 'Who is like God'),
    BabyName(name: 'Артём', gender: NameGender.boy, origin: NameOrigin.russian, meaning: 'Unharmed, healthy'),
    BabyName(name: 'Даниил', gender: NameGender.boy, origin: NameOrigin.russian, meaning: 'God is my judge'),
    BabyName(name: 'Максим', gender: NameGender.boy, origin: NameOrigin.russian, meaning: 'Greatest'),
    BabyName(name: 'Иван', gender: NameGender.boy, origin: NameOrigin.russian, meaning: 'God is gracious'),
    BabyName(name: 'Тимур', gender: NameGender.boy, origin: NameOrigin.russian, meaning: 'Iron'),

    // RUSSIAN — GIRLS
    BabyName(name: 'Анна', gender: NameGender.girl, origin: NameOrigin.russian, meaning: 'Grace'),
    BabyName(name: 'Мария', gender: NameGender.girl, origin: NameOrigin.russian, meaning: 'Beloved, bitter'),
    BabyName(name: 'София', gender: NameGender.girl, origin: NameOrigin.russian, meaning: 'Wisdom'),
    BabyName(name: 'Елена', gender: NameGender.girl, origin: NameOrigin.russian, meaning: 'Light, bright'),
    BabyName(name: 'Екатерина', gender: NameGender.girl, origin: NameOrigin.russian, meaning: 'Pure'),
    BabyName(name: 'Виктория', gender: NameGender.girl, origin: NameOrigin.russian, meaning: 'Victory'),

    // WESTERN — BOYS
    BabyName(name: 'Liam', gender: NameGender.boy, origin: NameOrigin.western, meaning: 'Strong-willed warrior'),
    BabyName(name: 'Noah', gender: NameGender.boy, origin: NameOrigin.western, meaning: 'Rest, comfort'),
    BabyName(name: 'Oliver', gender: NameGender.boy, origin: NameOrigin.western, meaning: 'Olive tree'),
    BabyName(name: 'Elijah', gender: NameGender.boy, origin: NameOrigin.western, meaning: 'My God is Yahweh'),
    BabyName(name: 'James', gender: NameGender.boy, origin: NameOrigin.western, meaning: 'Supplanter'),
    BabyName(name: 'Lucas', gender: NameGender.boy, origin: NameOrigin.western, meaning: 'Light'),
    BabyName(name: 'Henry', gender: NameGender.boy, origin: NameOrigin.western, meaning: 'Ruler of the home'),
    BabyName(name: 'Theodore', gender: NameGender.boy, origin: NameOrigin.western, meaning: "God's gift"),

    // WESTERN — GIRLS
    BabyName(name: 'Olivia', gender: NameGender.girl, origin: NameOrigin.western, meaning: 'Olive tree'),
    BabyName(name: 'Emma', gender: NameGender.girl, origin: NameOrigin.western, meaning: 'Universal, whole'),
    BabyName(name: 'Charlotte', gender: NameGender.girl, origin: NameOrigin.western, meaning: 'Free woman'),
    BabyName(name: 'Amelia', gender: NameGender.girl, origin: NameOrigin.western, meaning: 'Work, industrious'),
    BabyName(name: 'Sophia', gender: NameGender.girl, origin: NameOrigin.western, meaning: 'Wisdom'),
    BabyName(name: 'Isabella', gender: NameGender.girl, origin: NameOrigin.western, meaning: 'Devoted to God'),
    BabyName(name: 'Ava', gender: NameGender.girl, origin: NameOrigin.western, meaning: 'Life, bird'),
    BabyName(name: 'Mia', gender: NameGender.girl, origin: NameOrigin.western, meaning: 'Mine, beloved'),
    BabyName(name: 'Luna', gender: NameGender.girl, origin: NameOrigin.western, meaning: 'Moon'),
    BabyName(name: 'Harper', gender: NameGender.girl, origin: NameOrigin.western, meaning: 'Harp player'),

    // ARABIC — BOYS
    BabyName(name: 'Омар', gender: NameGender.boy, origin: NameOrigin.arabic, meaning: 'Flourishing, long-lived'),
    BabyName(name: 'Ибрагим', gender: NameGender.boy, origin: NameOrigin.arabic, meaning: 'Father of many'),
    BabyName(name: 'Юсуф', gender: NameGender.boy, origin: NameOrigin.arabic, meaning: 'God will increase'),
    BabyName(name: 'Али', gender: NameGender.boy, origin: NameOrigin.arabic, meaning: 'Exalted, noble'),
    BabyName(name: 'Мухаммед', gender: NameGender.boy, origin: NameOrigin.arabic, meaning: 'Praised'),
    BabyName(name: 'Амир', gender: NameGender.boy, origin: NameOrigin.arabic, meaning: 'Prince, leader'),

    // ARABIC — GIRLS
    BabyName(name: 'Амира', gender: NameGender.girl, origin: NameOrigin.arabic, meaning: 'Princess'),
    BabyName(name: 'Лейла', gender: NameGender.girl, origin: NameOrigin.arabic, meaning: 'Night'),
    BabyName(name: 'Зайнаб', gender: NameGender.girl, origin: NameOrigin.arabic, meaning: 'Beautiful, fragrant'),
    BabyName(name: 'Нура', gender: NameGender.girl, origin: NameOrigin.arabic, meaning: 'Light'),
    BabyName(name: 'Ясмина', gender: NameGender.girl, origin: NameOrigin.arabic, meaning: 'Jasmine flower'),

    // TURKISH
    BabyName(name: 'Эмре', gender: NameGender.boy, origin: NameOrigin.turkish, meaning: 'Friend, brother'),
    BabyName(name: 'Бурак', gender: NameGender.boy, origin: NameOrigin.turkish, meaning: 'Lightning'),
    BabyName(name: 'Дениз', gender: NameGender.unisex, origin: NameOrigin.turkish, meaning: 'Sea'),
    BabyName(name: 'Зейнеп', gender: NameGender.girl, origin: NameOrigin.turkish, meaning: 'Precious stone'),
    BabyName(name: 'Айла', gender: NameGender.girl, origin: NameOrigin.turkish, meaning: 'Halo around the moon'),

    // PERSIAN
    BabyName(name: 'Фарид', gender: NameGender.boy, origin: NameOrigin.persian, meaning: 'Unique, precious'),
    BabyName(name: 'Сами', gender: NameGender.boy, origin: NameOrigin.persian, meaning: 'Exalted'),
    BabyName(name: 'Дария', gender: NameGender.girl, origin: NameOrigin.persian, meaning: 'Sea, ocean'),
    BabyName(name: 'Рокшана', gender: NameGender.girl, origin: NameOrigin.persian, meaning: 'Bright, dawn'),
  ];

  static List<BabyName> filter({
    NameGender? gender,
    NameOrigin? origin,
    String? search,
  }) {
    return names.where((n) {
      if (gender != null && n.gender != gender && n.gender != NameGender.unisex) {
        return false;
      }
      if (origin != null && n.origin != origin) return false;
      if (search != null && search.isNotEmpty) {
        final q = search.toLowerCase();
        return n.name.toLowerCase().contains(q) ||
            n.meaning.toLowerCase().contains(q);
      }
      return true;
    }).toList();
  }
}
