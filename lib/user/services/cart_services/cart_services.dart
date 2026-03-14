import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerceapp/user/models/cart_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  Future<void> addCart(CartItemModel cartItem) async {
    final currentUser = _auth.currentUser!.uid;
    final docRef = _fireStore
        .collection('Users')
        .doc(currentUser)
        .collection('Cart')
        .doc(cartItem.productId);
    final exDoc = await docRef.get();

    if (exDoc.exists) {
      // Update quantity and preserve discount
      docRef.update({
        'quantity': FieldValue.increment(1),
        // Ensure discount is preserved when updating
        'discount': cartItem.discount,
      });
    } else {
      // Save complete cart item with discount
      await docRef.set(cartItem.toMap());
    }
  }

  Future<void> removeCart(String? productId) async {
    final currentUser = _auth.currentUser!.uid;
    await _fireStore
        .collection('Users')
        .doc(currentUser)
        .collection('Cart')
        .doc(productId)
        .delete();
  }

  Stream<List<CartItemModel>> getCart() {
    final currentUser = _auth.currentUser!.uid;
    return _fireStore
        .collection('Users')
        .doc(currentUser)
        .collection('Cart')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            return CartItemModel.fromMap(doc.data());
          }).toList(),
        );
  }

  Future<void> clearCart() async {
    final currentUser = _auth.currentUser!.uid;
    final cartRef = _fireStore
        .collection('Users')
        .doc(currentUser)
        .collection('Cart');
    final snapshot = await cartRef.get();
    for (var item in snapshot.docs) {
      await item.reference.delete();
    }
  }

  Future<void> updateCart(CartItemModel cartItem) async {
    final currentUser = _auth.currentUser!.uid;
    final docRef = _fireStore
        .collection('Users')
        .doc(currentUser)
        .collection('Cart')
        .doc(cartItem.productId);

    if (cartItem.quantity > 0) {
      // Update with all fields including discount
      await docRef.update({
        'quantity': cartItem.quantity,
        'price': cartItem.price,
        'discount': cartItem.discount,
        'title': cartItem.title,
        'imageUrl': cartItem.imageUrl,
      });
    } else {
      await docRef.delete();
    }
  }

  // New method to update quantity only
  Future<void> updateQuantity(String productId, int newQuantity) async {
    final currentUser = _auth.currentUser!.uid;
    final docRef = _fireStore
        .collection('Users')
        .doc(currentUser)
        .collection('Cart')
        .doc(productId);

    if (newQuantity > 0) {
      await docRef.update({'quantity': newQuantity});
    } else {
      await docRef.delete();
    }
  }

  // Method to add product with proper discount handling
  Future<void> addProductToCart({
    required String productId,
    required String title,
    required String imageUrl,
    required double price,
    required double discount,
    int quantity = 1,
  }) async {
    final cartItem = CartItemModel(
      productId: productId,
      title: title,
      imageUrl: imageUrl,
      price: price,
      discount: discount,
      // Make sure discount is included
      quantity: quantity,
    );

    await addCart(cartItem);
  }

  Future<void> debugCartContents() async {
    final currentUser = _auth.currentUser!.uid;
    await _fireStore
        .collection('Users')
        .doc(currentUser)
        .collection('Cart')
        .get();
  }
}
