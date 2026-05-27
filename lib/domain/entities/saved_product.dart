class SavedProductNote {
  final String text;
  final DateTime createdAt;

  const SavedProductNote({
    required this.text,
    required this.createdAt,
  });
}

/// Snapshot of a product the user has saved.
/// Full product data lives in `products/{barcode}` - this only holds enough
/// to render the saved list without a second read per item.
class SavedProduct {
  final String barcode;
  final DateTime savedAt;

  // snapshot for list rendering
  final String name;
  final String? brand;
  final String? imageUrl;
  final double? caloriesPer100g;

  // user-specific notes
  final List<SavedProductNote> notes;

  const SavedProduct({
    required this.barcode,
    required this.savedAt,
    required this.name,
    this.brand,
    this.imageUrl,
    this.caloriesPer100g,
    this.notes = const [],
  });

  SavedProduct copyWith({
    String? name,
    String? brand,
    String? imageUrl,
    double? caloriesPer100g,
    List<SavedProductNote>? notes,
  }) {
    return SavedProduct(
      barcode: barcode,
      savedAt: savedAt,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      imageUrl: imageUrl ?? this.imageUrl,
      caloriesPer100g: caloriesPer100g ?? this.caloriesPer100g,
      notes: notes ?? this.notes,
    );
  }
}
