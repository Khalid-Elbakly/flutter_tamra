import 'package:flutter/foundation.dart';
import '../models/cart.dart';
import '../models/cart_item.dart';

class CartProvider with ChangeNotifier {
  Cart _cart = Cart();

  Cart get cart => _cart;

  // إضافة منتج للسلة
  void addItem(CartItem item) {
    // التحقق من أن جميع المنتجات من نفس البائع
    if (!_cart.isEmpty && _cart.vendorId != item.vendorId) {
      // إذا كان المنتج من بائع مختلف، إفراغ السلة أولاً
      _cart.clear();
    }
    
    _cart.addItem(item);
    notifyListeners();
  }

  // إزالة منتج من السلة
  void removeItem(String productId) {
    _cart.removeItem(productId);
    notifyListeners();
  }

  // تحديث كمية منتج
  void updateQuantity(String productId, int quantity) {
    _cart.updateQuantity(productId, quantity);
    notifyListeners();
  }

  // تحديث عنوان التوصيل
  void setDeliveryAddress(String address, String addressName) {
    _cart.deliveryAddress = address;
    _cart.deliveryAddressName = addressName;
    notifyListeners();
  }

  // تحديث رسوم التوصيل
  void setDeliveryFee(double fee) {
    _cart.deliveryFee = fee;
    notifyListeners();
  }

  // مسح السلة
  void clear() {
    _cart.clear();
    notifyListeners();
  }

  // الحصول على إجمالي الكمية
  int get totalQuantity => _cart.totalQuantity;

  // الحصول على الإجمالي الفرعي
  double get subtotal => _cart.subtotal;

  // الحصول على الإجمالي النهائي
  double get total => _cart.total;
}





