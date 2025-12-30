import 'cart_item.dart';

class Cart {
  final Map<String, CartItem> _items = {};
  String? deliveryAddress;
  String? deliveryAddressName;
  double deliveryFee = 0.0;

  // إضافة منتج للسلة
  void addItem(CartItem item) {
    if (_items.containsKey(item.productId)) {
      // إذا المنتج موجود، زيادة الكمية
      final existingItem = _items[item.productId]!;
      _items[item.productId] = existingItem.copyWith(
        quantity: existingItem.quantity + item.quantity,
      );
    } else {
      _items[item.productId] = item;
    }
  }

  // إزالة منتج من السلة
  void removeItem(String productId) {
    _items.remove(productId);
  }

  // تحديث كمية منتج
  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }
    if (_items.containsKey(productId)) {
      _items[productId] = _items[productId]!.copyWith(quantity: quantity);
    }
  }

  // الحصول على منتج
  CartItem? getItem(String productId) {
    return _items[productId];
  }

  // الحصول على جميع المنتجات
  List<CartItem> get items => _items.values.toList();

  // التحقق من أن السلة فارغة
  bool get isEmpty => _items.isEmpty;

  // عدد المنتجات
  int get itemCount => _items.length;

  // إجمالي الكميات
  int get totalQuantity {
    return _items.values.fold(0, (sum, item) => sum + item.quantity);
  }

  // حساب الإجمالي الفرعي (بدون رسوم التوصيل)
  double get subtotal {
    return _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  // حساب الإجمالي النهائي (مع رسوم التوصيل)
  double get total => subtotal + deliveryFee;

  // التحقق من أن جميع المنتجات من نفس البائع
  String? get vendorId {
    if (_items.isEmpty) return null;
    return _items.values.first.vendorId;
  }

  bool get isAllFromSameVendor {
    if (_items.isEmpty) return true;
    final firstVendorId = _items.values.first.vendorId;
    return _items.values.every((item) => item.vendorId == firstVendorId);
  }

  // مسح السلة
  void clear() {
    _items.clear();
    deliveryAddress = null;
    deliveryAddressName = null;
    deliveryFee = 0.0;
  }

  // تحويل إلى List<Map> للاستخدام مع OrdersService
  List<Map<String, dynamic>> toOrderItemsList() {
    return _items.values.map((item) => item.toOrderItemMap()).toList();
  }
}





