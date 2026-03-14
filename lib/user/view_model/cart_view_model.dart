import 'package:ecommerceapp/user/models/cart_model.dart';
import 'package:ecommerceapp/user/services/cart_services/cart_services.dart';
import 'package:flutter/cupertino.dart';

class CartViewModel {
  final CartServices _cartServices = CartServices();

  Future<void> addCart(CartItemModel cartItem) async {
    try {
      await _cartServices.addCart(cartItem);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Stream<List<CartItemModel>> getCart() {
    try {
      return _cartServices.getCart();
    } catch (e) {
      debugPrint(e.toString());
      throw e.toString();
    }
  }

  Future<void> removeCart(String productId) async {
    try {
      await _cartServices.removeCart(productId);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> clearCart() async {
    try {
      await _cartServices.clearCart();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // FIXED: Update method signature to match what you're calling
  Future<void> updateCart(
    CartItemModel cartItem,
    String uid,
    String productId,
  ) async {
    try {
      // Call the service with just the cartItem
      await _cartServices.updateCart(cartItem);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // Calculate subtotal (original prices without discount)
  double subTotal(List<CartItemModel> cartItems) =>
      cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));

  // Calculate total discount amount
  double discount(List<CartItemModel> cartItems) =>
      cartItems.fold(0, (sum, item) => sum + item.discountAmount);

  // Calculate final total price after discount
  double totalPrice(List<CartItemModel> cartItems) =>
      subTotal(cartItems) - discount(cartItems);

  // Calculate total items count
  int totalItems(List<CartItemModel> cartItems) =>
      cartItems.fold(0, (sum, item) => sum + item.quantity);

  // Calculate total savings
  double totalSavings(List<CartItemModel> cartItems) =>
      cartItems.fold(0, (sum, item) {
        double originalTotal = item.price * item.quantity;
        double discountedTotal = item.itemTotal;
        return sum + (originalTotal - discountedTotal);
      });
}
