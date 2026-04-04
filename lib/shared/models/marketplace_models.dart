import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

/// Vendor (seller) on the marketplace
class Vendor {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color iconColor;
  final String? logoUrl;
  final String? website;
  final double rating;
  final int reviewCount;
  final bool isVerified;
  final bool isFeatured;
  final String category;
  final String location;

  const Vendor({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.iconColor,
    this.logoUrl,
    this.website,
    required this.rating,
    required this.reviewCount,
    required this.isVerified,
    required this.isFeatured,
    required this.category,
    required this.location,
  });
}

/// Product listing
class Product {
  final String id;
  final String vendorId;
  final String name;
  final String description;
  final double price;
  final String currency;
  final String? imageUrl;
  final IconData icon;
  final Color iconColor;
  final String category;
  final String subcategory;
  final double rating;
  final int reviewCount;
  final bool inStock;
  final bool isFeatured;
  final Map<String, String>? variants;
  final List<String> tags;
  final List<ParentingStage> relevantStages;
  final int? minAgeMonths;
  final int? maxAgeMonths;

  const Product({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.description,
    required this.price,
    this.currency = 'сом',
    this.imageUrl,
    required this.icon,
    required this.iconColor,
    required this.category,
    required this.subcategory,
    required this.rating,
    required this.reviewCount,
    required this.inStock,
    required this.isFeatured,
    this.variants,
    required this.tags,
    required this.relevantStages,
    this.minAgeMonths,
    this.maxAgeMonths,
  });

  String get priceFormatted => '${price.toStringAsFixed(0)} $currency';
}

/// Product categories
class ProductCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final int productCount;

  const ProductCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.productCount,
  });
}
