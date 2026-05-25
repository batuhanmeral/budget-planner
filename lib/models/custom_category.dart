import 'package:flutter/material.dart';

import '../app/app_constants.dart';
import '../utils/date_utils.dart';

/// Kullanıcının kendi tanımladığı kategori.
///
/// Sabit [AppCategories] listesine ek olarak `custom_categories`
/// tablosundan gelir. Çalışma anında her ikisi tek bir liste haline
/// getirilir (bkz. CategoryService).
///
/// [iconCode] Material Icons font'undaki bir codePoint olmalı
/// (örn. `Icons.coffee.codePoint`). [colorInt] ARGB tam sayısı.
class CustomCategory {
  final int? id;
  final int userId;
  final String name;
  final int iconCode;
  final int colorInt;
  final DateTime? createdAt;

  const CustomCategory({
    this.id,
    required this.userId,
    required this.name,
    required this.iconCode,
    required this.colorInt,
    this.createdAt,
  });

  /// [AppCategory]'ye dönüştürür — UI'da sabit kategorilerle aynı arayüze
  /// sahip olur.
  AppCategory toAppCategory() => AppCategory(
    name: name,
    icon: IconData(iconCode, fontFamily: 'MaterialIcons'),
    color: Color(colorInt),
  );

  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'user_id': userId,
    'name': name,
    'icon_code': iconCode,
    'color_int': colorInt,
    if (createdAt != null) 'created_at': createdAt!.toUtc().toIso8601String(),
  };

  factory CustomCategory.fromMap(Map<String, Object?> map) => CustomCategory(
    id: map['id'] as int?,
    userId: map['user_id'] as int,
    name: map['name'] as String,
    iconCode: map['icon_code'] as int,
    colorInt: map['color_int'] as int,
    createdAt: parseIsoOrNull(map['created_at'] as String?),
  );
}
