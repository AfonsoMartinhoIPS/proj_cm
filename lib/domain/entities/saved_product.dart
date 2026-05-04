import 'package:projeto/domain/entities/product.dart';

class SavedProduct {
  final Product product;
  final DateTime savedAt;
  final String? notes;

  const SavedProduct({
    required this.product,
    required this.savedAt,
    this.notes,
  });

  SavedProduct copyWith({String? notes}) {
    return SavedProduct(
      product: product,
      savedAt: savedAt,
      notes: notes ?? this.notes,
    );
  }
}
