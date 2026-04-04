import 'package:flutter/material.dart';
import '../../shared/models/marketplace_models.dart';
import '../constants/app_constants.dart';
import '../theme/app_colors.dart';

/// Seed data for the marketplace — loaded from here in demo mode,
/// replaced by Firestore in production.
class SeedData {
  SeedData._();

  // ==========================================================
  // CATEGORIES
  // ==========================================================
  static const categories = <ProductCategory>[
    ProductCategory(id: 'diapers', name: 'Diapers', icon: Icons.baby_changing_station, color: AppColors.primary, productCount: 18),
    ProductCategory(id: 'feeding', name: 'Feeding', icon: Icons.restaurant, color: AppColors.secondary, productCount: 24),
    ProductCategory(id: 'clothing', name: 'Clothing', icon: Icons.checkroom, color: AppColors.accent, productCount: 32),
    ProductCategory(id: 'health', name: 'Health', icon: Icons.health_and_safety, color: AppColors.success, productCount: 20),
    ProductCategory(id: 'gear', name: 'Gear', icon: Icons.stroller, color: AppColors.stagePrePregnancy, productCount: 15),
    ProductCategory(id: 'toys', name: 'Toys', icon: Icons.smart_toy, color: AppColors.stageToddler, productCount: 28),
    ProductCategory(id: 'maternity', name: 'Maternity', icon: Icons.pregnant_woman, color: AppColors.stagePregnancy, productCount: 16),
    ProductCategory(id: 'photography', name: 'Photos', icon: Icons.camera_alt, color: Color(0xFF7C4DFF), productCount: 8),
    ProductCategory(id: 'services', name: 'Services', icon: Icons.medical_services, color: AppColors.secondaryDark, productCount: 12),
    ProductCategory(id: 'food', name: 'Meals', icon: Icons.lunch_dining, color: Color(0xFFFF7043), productCount: 6),
  ];

  // ==========================================================
  // VENDORS
  // ==========================================================
  static const vendors = <Vendor>[
    Vendor(
      id: 'mama-znaet',
      name: 'Мама Знает',
      description: 'Первый бренд подгузников, созданный мамами для мам. Японская технология, бесплатная доставка.',
      icon: Icons.baby_changing_station,
      iconColor: AppColors.primary,
      website: 'https://mamaznaet.kg',
      rating: 4.8,
      reviewCount: 342,
      isVerified: true,
      isFeatured: true,
      category: 'Diapers',
      location: 'Bishkek, KG',
    ),
    Vendor(
      id: 'tiny-steps',
      name: 'TinySteps Photography',
      description: 'Professional maternity, newborn, and family photography.',
      icon: Icons.camera_alt,
      iconColor: Color(0xFF7C4DFF),
      rating: 4.9,
      reviewCount: 127,
      isVerified: true,
      isFeatured: true,
      category: 'Photography',
      location: 'Bishkek, KG',
    ),
    Vendor(
      id: 'bamboo-nest',
      name: 'BambooNest',
      description: 'Eco-friendly baby products — organic clothing, bamboo, natural skincare.',
      icon: Icons.eco,
      iconColor: AppColors.success,
      rating: 4.7,
      reviewCount: 89,
      isVerified: true,
      isFeatured: false,
      category: 'Clothing',
      location: 'Bishkek, KG',
    ),
    Vendor(
      id: 'mama-fuel',
      name: 'MamaFuel Meals',
      description: 'Nutritious meal delivery for pregnant and postpartum moms.',
      icon: Icons.lunch_dining,
      iconColor: Color(0xFFFF7043),
      rating: 4.6,
      reviewCount: 64,
      isVerified: true,
      isFeatured: false,
      category: 'Meal Prep',
      location: 'Bishkek, KG',
    ),
    Vendor(
      id: 'little-joy',
      name: 'Little Joy Toys',
      description: 'Educational and developmental toys. Montessori-inspired.',
      icon: Icons.smart_toy,
      iconColor: AppColors.stageToddler,
      rating: 4.8,
      reviewCount: 156,
      isVerified: true,
      isFeatured: false,
      category: 'Toys & Books',
      location: 'Bishkek, KG',
    ),
    Vendor(
      id: 'comfy-mom',
      name: 'ComfyMom',
      description: 'Maternity and nursing wear. From bump to breastfeeding.',
      icon: Icons.checkroom,
      iconColor: AppColors.stagePregnancy,
      rating: 4.5,
      reviewCount: 98,
      isVerified: true,
      isFeatured: false,
      category: 'Maternity',
      location: 'Bishkek, KG',
    ),
    Vendor(
      id: 'safe-watch',
      name: 'SafeWatch Baby',
      description: 'Smart baby monitors, thermometers, and safety products.',
      icon: Icons.videocam,
      iconColor: AppColors.secondaryDark,
      rating: 4.7,
      reviewCount: 73,
      isVerified: true,
      isFeatured: false,
      category: 'Baby Gear',
      location: 'Bishkek, KG',
    ),
    Vendor(
      id: 'pure-mama',
      name: 'PureMama',
      description: 'Organic skincare for moms and babies. No parabens, no sulfates.',
      icon: Icons.spa,
      iconColor: AppColors.stagePrePregnancy,
      rating: 4.8,
      reviewCount: 112,
      isVerified: true,
      isFeatured: false,
      category: 'Health & Care',
      location: 'Bishkek, KG',
    ),
  ];

  // ==========================================================
  // PRODUCTS
  // ==========================================================
  static const products = <Product>[
    // --- MAMA ZNAET DIAPERS ---
    Product(
      id: 'mz-diaper-s', vendorId: 'mama-znaet',
      name: 'Мама Знает подгузники S',
      description: 'Японская технология, ультра-мягкие, дышащие, индикатор влаги. 3-6 кг.',
      price: 650, icon: Icons.baby_changing_station, iconColor: AppColors.primary,
      category: 'Diapers', subcategory: 'Disposable', rating: 4.8, reviewCount: 89,
      inStock: true, isFeatured: true,
      variants: {'S 42шт': '650', 'S 84шт': '1200'},
      tags: ['newborn', 'japanese-tech', 'mama-znaet'],
      relevantStages: [ParentingStage.pregnant, ParentingStage.newborn],
      minAgeMonths: 0, maxAgeMonths: 3,
    ),
    Product(
      id: 'mz-diaper-m', vendorId: 'mama-znaet',
      name: 'Мама Знает подгузники M',
      description: 'Для активных малышей. Эластичные боковинки, защита 12 часов. 6-11 кг.',
      price: 700, icon: Icons.baby_changing_station, iconColor: AppColors.primary,
      category: 'Diapers', subcategory: 'Disposable', rating: 4.9, reviewCount: 156,
      inStock: true, isFeatured: true,
      variants: {'M 38шт': '700', 'M 76шт': '1300'},
      tags: ['baby', 'japanese-tech', 'mama-znaet', 'bestseller'],
      relevantStages: [ParentingStage.newborn], minAgeMonths: 3, maxAgeMonths: 9,
    ),
    Product(
      id: 'mz-diaper-l', vendorId: 'mama-znaet',
      name: 'Мама Знает подгузники L',
      description: 'Максимальная впитываемость, мягкие резинки. 9-14 кг.',
      price: 750, icon: Icons.baby_changing_station, iconColor: AppColors.primary,
      category: 'Diapers', subcategory: 'Disposable', rating: 4.8, reviewCount: 134,
      inStock: true, isFeatured: false,
      variants: {'L 34шт': '750', 'L 68шт': '1400'},
      tags: ['baby', 'japanese-tech', 'mama-znaet'],
      relevantStages: [ParentingStage.newborn, ParentingStage.toddler],
      minAgeMonths: 6, maxAgeMonths: 18,
    ),
    Product(
      id: 'mz-diaper-xl', vendorId: 'mama-znaet',
      name: 'Мама Знает подгузники XL',
      description: 'Тонкие, супер-впитывающие, для активных детей. 12-17 кг.',
      price: 800, icon: Icons.baby_changing_station, iconColor: AppColors.primary,
      category: 'Diapers', subcategory: 'Disposable', rating: 4.7, reviewCount: 98,
      inStock: true, isFeatured: false,
      variants: {'XL 30шт': '800', 'XL 60шт': '1500'},
      tags: ['toddler', 'japanese-tech', 'mama-znaet'],
      relevantStages: [ParentingStage.toddler], minAgeMonths: 12, maxAgeMonths: 24,
    ),
    Product(
      id: 'mz-pants-m', vendorId: 'mama-znaet',
      name: 'Мама Знает трусики M',
      description: 'Подгузники-трусики для ползающих. Легко надевать и снимать. 6-11 кг.',
      price: 750, icon: Icons.child_care, iconColor: AppColors.secondary,
      category: 'Diapers', subcategory: 'Pull-ups', rating: 4.8, reviewCount: 112,
      inStock: true, isFeatured: true,
      variants: {'M 36шт': '750', 'M 72шт': '1400'},
      tags: ['crawling', 'pull-ups', 'mama-znaet'],
      relevantStages: [ParentingStage.newborn], minAgeMonths: 4, maxAgeMonths: 9,
    ),
    Product(
      id: 'mz-pants-l', vendorId: 'mama-znaet',
      name: 'Мама Знает трусики L',
      description: '360° эластичный пояс, легко снимаются. 9-14 кг.',
      price: 800, icon: Icons.child_care, iconColor: AppColors.secondary,
      category: 'Diapers', subcategory: 'Pull-ups', rating: 4.9, reviewCount: 145,
      inStock: true, isFeatured: false,
      variants: {'L 32шт': '800', 'L 64шт': '1500'},
      tags: ['walking', 'pull-ups', 'mama-znaet', 'bestseller'],
      relevantStages: [ParentingStage.newborn, ParentingStage.toddler],
      minAgeMonths: 8, maxAgeMonths: 18,
    ),
    Product(
      id: 'mz-pants-xl', vendorId: 'mama-znaet',
      name: 'Мама Знает трусики XL',
      description: 'Для приучения к горшку. 12-17 кг.',
      price: 850, icon: Icons.child_care, iconColor: AppColors.secondary,
      category: 'Diapers', subcategory: 'Pull-ups', rating: 4.7, reviewCount: 87,
      inStock: true, isFeatured: false,
      variants: {'XL 28шт': '850', 'XL 56шт': '1600'},
      tags: ['potty-training', 'pull-ups', 'mama-znaet'],
      relevantStages: [ParentingStage.toddler], minAgeMonths: 12, maxAgeMonths: 24,
    ),
    Product(
      id: 'mz-wipes', vendorId: 'mama-znaet',
      name: 'Мама Знает салфетки',
      description: 'Нежные влажные салфетки. Без спирта, гипоаллергенные. 80 шт.',
      price: 250, icon: Icons.clean_hands, iconColor: AppColors.stageNewborn,
      category: 'Health & Care', subcategory: 'Wipes', rating: 4.6, reviewCount: 203,
      inStock: true, isFeatured: false,
      variants: {'80шт': '250', '3x80шт': '650'},
      tags: ['wipes', 'hypoallergenic', 'mama-znaet'],
      relevantStages: [ParentingStage.newborn, ParentingStage.toddler],
      minAgeMonths: 0, maxAgeMonths: 24,
    ),

    // --- FEEDING ---
    Product(
      id: 'bottle-anti-colic', vendorId: 'bamboo-nest',
      name: 'Anti-Colic Bottle Set',
      description: 'BPA-free anti-colic bottles, slow-flow nipple. Set of 3.',
      price: 1800, icon: Icons.local_drink, iconColor: AppColors.secondary,
      category: 'Feeding', subcategory: 'Bottles', rating: 4.8, reviewCount: 67,
      inStock: true, isFeatured: true,
      tags: ['anti-colic', 'bpa-free', 'newborn'],
      relevantStages: [ParentingStage.pregnant, ParentingStage.newborn],
      minAgeMonths: 0, maxAgeMonths: 12,
    ),
    Product(
      id: 'breast-pump', vendorId: 'comfy-mom',
      name: 'Electric Breast Pump',
      description: 'Quiet, portable, hospital-grade suction. USB rechargeable.',
      price: 4500, icon: Icons.favorite, iconColor: AppColors.primary,
      category: 'Feeding', subcategory: 'Breast Pumps', rating: 4.7, reviewCount: 45,
      inStock: true, isFeatured: true,
      tags: ['breast-pump', 'portable', 'electric'],
      relevantStages: [ParentingStage.pregnant, ParentingStage.newborn],
      minAgeMonths: 0, maxAgeMonths: 12,
    ),
    Product(
      id: 'silicone-bibs', vendorId: 'bamboo-nest',
      name: 'Silicone Bib Set (3 pack)',
      description: 'Waterproof, food catcher pocket. Easy to clean. BPA-free.',
      price: 900, icon: Icons.restaurant_menu, iconColor: AppColors.accent,
      category: 'Feeding', subcategory: 'Bibs', rating: 4.9, reviewCount: 82,
      inStock: true, isFeatured: false,
      tags: ['bibs', 'silicone', 'solid-foods'],
      relevantStages: [ParentingStage.newborn, ParentingStage.toddler],
      minAgeMonths: 4, maxAgeMonths: 24,
    ),
    Product(
      id: 'suction-plate', vendorId: 'bamboo-nest',
      name: 'Bamboo Suction Plate',
      description: 'Eco-friendly bamboo plate with silicone suction base + spoon.',
      price: 1200, icon: Icons.set_meal, iconColor: AppColors.success,
      category: 'Feeding', subcategory: 'Utensils', rating: 4.6, reviewCount: 54,
      inStock: true, isFeatured: false,
      tags: ['bamboo', 'eco', 'blw', 'suction'],
      relevantStages: [ParentingStage.newborn, ParentingStage.toddler],
      minAgeMonths: 6, maxAgeMonths: 24,
    ),

    // --- HEALTH & CARE ---
    Product(
      id: 'baby-lotion', vendorId: 'pure-mama',
      name: 'Organic Baby Lotion',
      description: 'Shea butter, chamomile, calendula. No parabens. 250ml.',
      price: 850, icon: Icons.spa, iconColor: AppColors.stagePrePregnancy,
      category: 'Health & Care', subcategory: 'Skincare', rating: 4.9, reviewCount: 134,
      inStock: true, isFeatured: true,
      tags: ['organic', 'gentle', 'moisturizer'],
      relevantStages: [ParentingStage.newborn, ParentingStage.toddler],
      minAgeMonths: 0, maxAgeMonths: 24,
    ),
    Product(
      id: 'stretch-oil', vendorId: 'pure-mama',
      name: 'Stretch Mark Oil',
      description: 'Rosehip, jojoba, vitamin E. Apply daily from first trimester. 100ml.',
      price: 1200, icon: Icons.water_drop, iconColor: AppColors.stagePrePregnancy,
      category: 'Health & Care', subcategory: 'Mama Care', rating: 4.8, reviewCount: 89,
      inStock: true, isFeatured: true,
      tags: ['stretch-marks', 'pregnancy', 'organic'],
      relevantStages: [ParentingStage.pregnant],
    ),
    Product(
      id: 'thermometer', vendorId: 'safe-watch',
      name: 'Infrared Thermometer',
      description: 'Instant 1-second reading. No-contact. Memory 20 readings.',
      price: 2200, icon: Icons.thermostat, iconColor: AppColors.error,
      category: 'Health & Care', subcategory: 'Devices', rating: 4.7, reviewCount: 56,
      inStock: true, isFeatured: false,
      tags: ['thermometer', 'instant', 'no-contact'],
      relevantStages: [ParentingStage.pregnant, ParentingStage.newborn, ParentingStage.toddler],
      minAgeMonths: 0, maxAgeMonths: 24,
    ),

    // --- GEAR ---
    Product(
      id: 'baby-monitor', vendorId: 'safe-watch',
      name: 'Smart Baby Monitor Pro',
      description: 'HD video, night vision, 2-way audio, temp sensor, lullabies.',
      price: 8500, icon: Icons.videocam, iconColor: AppColors.secondaryDark,
      category: 'Baby Gear', subcategory: 'Monitors', rating: 4.9, reviewCount: 78,
      inStock: true, isFeatured: true,
      tags: ['monitor', 'smart', 'video'],
      relevantStages: [ParentingStage.pregnant, ParentingStage.newborn, ParentingStage.toddler],
      minAgeMonths: 0, maxAgeMonths: 24,
    ),
    Product(
      id: 'pregnancy-pillow', vendorId: 'comfy-mom',
      name: 'Pregnancy Pillow',
      description: 'U-shaped full body support. Belly, back, hips, knees. Washable.',
      price: 3500, icon: Icons.airline_seat_flat, iconColor: AppColors.accent,
      category: 'Maternity', subcategory: 'Comfort', rating: 4.8, reviewCount: 112,
      inStock: true, isFeatured: true,
      tags: ['pillow', 'pregnancy', 'sleep'],
      relevantStages: [ParentingStage.pregnant],
    ),
    Product(
      id: 'nursing-bra', vendorId: 'comfy-mom',
      name: 'Nursing Bra (2 pack)',
      description: 'Ultra-soft, clip-down cups. No underwire. S-XXL.',
      price: 1800, icon: Icons.checkroom, iconColor: AppColors.stagePregnancy,
      category: 'Maternity', subcategory: 'Nursing', rating: 4.6, reviewCount: 67,
      inStock: true, isFeatured: false,
      tags: ['nursing', 'bra', 'breastfeeding'],
      relevantStages: [ParentingStage.pregnant, ParentingStage.newborn],
    ),

    // --- TOYS ---
    Product(
      id: 'montessori-set', vendorId: 'little-joy',
      name: 'Montessori Baby Box 0-6m',
      description: 'B&W cards, wooden rattle, teether, crinkle cloth, mirror toy.',
      price: 2800, icon: Icons.redeem, iconColor: AppColors.stageToddler,
      category: 'Toys & Books', subcategory: 'Developmental', rating: 4.9, reviewCount: 89,
      inStock: true, isFeatured: true,
      tags: ['montessori', 'newborn', 'gift-set'],
      relevantStages: [ParentingStage.pregnant, ParentingStage.newborn],
      minAgeMonths: 0, maxAgeMonths: 6,
    ),
    Product(
      id: 'stacking-rings', vendorId: 'little-joy',
      name: 'Wooden Stacking Rings',
      description: 'Natural wood rainbow rings. Fine motor + color recognition.',
      price: 1100, icon: Icons.toys, iconColor: AppColors.accent,
      category: 'Toys & Books', subcategory: 'Developmental', rating: 4.8, reviewCount: 67,
      inStock: true, isFeatured: false,
      tags: ['wooden', 'stacking', 'motor-skills'],
      relevantStages: [ParentingStage.newborn, ParentingStage.toddler],
      minAgeMonths: 6, maxAgeMonths: 18,
    ),
    Product(
      id: 'board-books', vendorId: 'little-joy',
      name: 'My First Library (10 books)',
      description: 'Touch-and-feel board books: animals, colors, shapes, family.',
      price: 1500, icon: Icons.menu_book, iconColor: AppColors.secondary,
      category: 'Toys & Books', subcategory: 'Books', rating: 4.9, reviewCount: 134,
      inStock: true, isFeatured: true,
      tags: ['books', 'board-books', 'reading'],
      relevantStages: [ParentingStage.newborn, ParentingStage.toddler],
      minAgeMonths: 3, maxAgeMonths: 24,
    ),
    Product(
      id: 'play-dough', vendorId: 'little-joy',
      name: 'Natural Play Dough (6 colors)',
      description: 'Non-toxic, wheat-free, safe if eaten. With tools.',
      price: 950, icon: Icons.palette, iconColor: Color(0xFFFF7043),
      category: 'Toys & Books', subcategory: 'Creative', rating: 4.7, reviewCount: 45,
      inStock: true, isFeatured: false,
      tags: ['play-dough', 'creative', 'non-toxic'],
      relevantStages: [ParentingStage.toddler], minAgeMonths: 12, maxAgeMonths: 24,
    ),

    // --- PHOTOGRAPHY ---
    Product(
      id: 'newborn-photo', vendorId: 'tiny-steps',
      name: 'Newborn Photoshoot',
      description: '2hr studio, 20 edited photos, props included. Within 14 days of birth.',
      price: 15000, icon: Icons.camera_alt, iconColor: Color(0xFF7C4DFF),
      category: 'Photography', subcategory: 'Studio', rating: 5.0, reviewCount: 67,
      inStock: true, isFeatured: true,
      tags: ['newborn', 'photography', 'studio'],
      relevantStages: [ParentingStage.pregnant, ParentingStage.newborn],
      minAgeMonths: 0, maxAgeMonths: 1,
    ),
    Product(
      id: 'maternity-photo', vendorId: 'tiny-steps',
      name: 'Maternity Photoshoot',
      description: '1.5hr session, 15 edited photos. Dresses provided. Best at 30-36 weeks.',
      price: 12000, icon: Icons.photo_camera, iconColor: Color(0xFF7C4DFF),
      category: 'Photography', subcategory: 'Studio', rating: 4.9, reviewCount: 45,
      inStock: true, isFeatured: true,
      tags: ['maternity', 'photography', 'pregnancy'],
      relevantStages: [ParentingStage.pregnant],
    ),
    Product(
      id: 'milestone-photos', vendorId: 'tiny-steps',
      name: 'First Year Package',
      description: '4 sessions (3mo, 6mo, 9mo, 1yr). 40 edited photos total.',
      price: 35000, icon: Icons.photo_library, iconColor: Color(0xFF7C4DFF),
      category: 'Photography', subcategory: 'Packages', rating: 5.0, reviewCount: 23,
      inStock: true, isFeatured: false,
      tags: ['milestone', 'first-year', 'package'],
      relevantStages: [ParentingStage.newborn], minAgeMonths: 0, maxAgeMonths: 12,
    ),

    // --- MEALS ---
    Product(
      id: 'postpartum-meals', vendorId: 'mama-fuel',
      name: 'Postpartum Meals (1 week)',
      description: '21 meals: iron-rich, lactation-boosting. Delivered fresh daily.',
      price: 8500, icon: Icons.lunch_dining, iconColor: Color(0xFFFF7043),
      category: 'Meal Prep', subcategory: 'Plans', rating: 4.7, reviewCount: 34,
      inStock: true, isFeatured: true,
      tags: ['postpartum', 'meal-delivery', 'lactation'],
      relevantStages: [ParentingStage.newborn], minAgeMonths: 0, maxAgeMonths: 3,
    ),
    Product(
      id: 'pregnancy-meals', vendorId: 'mama-fuel',
      name: 'Pregnancy Meals (1 week)',
      description: '14 meals: folate-rich, balanced macros. GD-friendly options.',
      price: 6500, icon: Icons.restaurant, iconColor: Color(0xFFFF7043),
      category: 'Meal Prep', subcategory: 'Plans', rating: 4.6, reviewCount: 28,
      inStock: true, isFeatured: false,
      tags: ['pregnancy', 'nutrition', 'meal-delivery'],
      relevantStages: [ParentingStage.pregnant],
    ),
  ];

  // ==========================================================
  // HELPERS
  // ==========================================================
  static List<Product> getProductsForStage(ParentingStage stage) {
    return products.where((p) => p.relevantStages.contains(stage)).toList();
  }

  static List<Product> getProductsForAge(int ageMonths) {
    return products.where((p) {
      if (p.minAgeMonths == null && p.maxAgeMonths == null) return true;
      final min = p.minAgeMonths ?? 0;
      final max = p.maxAgeMonths ?? 99;
      return ageMonths >= min && ageMonths <= max;
    }).toList();
  }

  static List<Product> getProductsByCategory(String category) {
    return products.where((p) => p.category == category).toList();
  }

  static List<Product> getFeaturedProducts() {
    return products.where((p) => p.isFeatured).toList();
  }

  static Vendor? getVendor(String id) {
    try { return vendors.firstWhere((v) => v.id == id); } catch (_) { return null; }
  }

  static List<Product> getProductsByVendor(String vendorId) {
    return products.where((p) => p.vendorId == vendorId).toList();
  }

  static List<Product> getMamaZnaetProducts() => getProductsByVendor('mama-znaet');
}
