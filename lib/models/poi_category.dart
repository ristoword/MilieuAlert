import 'package:flutter/material.dart';

class PoiCategory {
  const PoiCategory({
    required this.id,
    required this.label,
    required this.icon,
  });

  final String id;
  final String label;
  final IconData icon;
}

const kPoiCategories = <PoiCategory>[
  PoiCategory(
    id: 'restaurants',
    label: 'Ristoranti',
    icon: Icons.restaurant_rounded,
  ),
  PoiCategory(
    id: 'fuel',
    label: 'Pompe di benzina',
    icon: Icons.local_gas_station_rounded,
  ),
  PoiCategory(
    id: 'tobacco',
    label: 'Tabacchi',
    icon: Icons.storefront_rounded,
  ),
  PoiCategory(
    id: 'parking',
    label: 'Parcheggi',
    icon: Icons.local_parking_rounded,
  ),
  PoiCategory(
    id: 'supermarket',
    label: 'Supermercati',
    icon: Icons.local_grocery_store_rounded,
  ),
  PoiCategory(
    id: 'cafe',
    label: 'Caffè',
    icon: Icons.local_cafe_rounded,
  ),
  PoiCategory(
    id: 'pharmacy',
    label: 'Farmacie',
    icon: Icons.local_pharmacy_rounded,
  ),
];

PoiCategory? poiCategoryById(String? id) {
  if (id == null) return null;
  for (final c in kPoiCategories) {
    if (c.id == id) return c;
  }
  return null;
}
