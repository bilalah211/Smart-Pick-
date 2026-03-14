// services/wishlist_service.dart
import 'package:ecommerceapp/admin/models/products_model.dart';

class WishlistService {
  static final WishlistService _instance = WishlistService._internal();
  factory WishlistService() => _instance;
  WishlistService._internal();

  final List<ProductModel> _wishlistItems = [];
  List<ProductModel> get wishlistItems => _wishlistItems;

  void addToWishlist(ProductModel product) {
    if (!_wishlistItems.any((item) => item.id == product.id)) {
      _wishlistItems.add(product);
    }
  }

  void removeFromWishlist(String productId) {
    _wishlistItems.removeWhere((item) => item.id == productId);
  }

  bool isInWishlist(String productId) {
    return _wishlistItems.any((item) => item.id == productId);
  }

  void clearWishlist() {
    _wishlistItems.clear();
  }

  int get itemCount => _wishlistItems.length;
}
