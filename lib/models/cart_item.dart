class CartItem {
  final String productId;
  final String nameAr;
  final String nameEn;
  final double price;
  final String packagingWeight;
  final String imageUrl;
  final String vendorId;
  int quantity;

  CartItem({
    required this.productId,
    required this.nameAr,
    required this.nameEn,
    required this.price,
    required this.packagingWeight,
    required this.imageUrl,
    required this.vendorId,
    this.quantity = 1,
  });

  // تحويل إلى Map للاستخدام مع OrdersService
  Map<String, dynamic> toOrderItemMap() {
    return {
      'productId': productId,
      'nameAr': nameAr,
      'nameEn': nameEn,
      'quantity': quantity,
      'price': price,
      'packagingWeight': packagingWeight,
    };
  }

  // حساب السعر الإجمالي لهذا المنتج
  double get totalPrice => price * quantity;

  // نسخ CartItem مع تحديث الكمية
  CartItem copyWith({int? quantity}) {
    return CartItem(
      productId: productId,
      nameAr: nameAr,
      nameEn: nameEn,
      price: price,
      packagingWeight: packagingWeight,
      imageUrl: imageUrl,
      vendorId: vendorId,
      quantity: quantity ?? this.quantity,
    );
  }
}





