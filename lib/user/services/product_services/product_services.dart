import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../admin/models/products_model.dart';

class ProductServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add product to Firestore
  Future<void> addProduct(ProductModel product) async {
    await _firestore.collection('Products').add(product.toMap());
  }

  // Get all products
  Future<List<ProductModel>> getAllProducts() async {
    final snapshot = await _firestore.collection('Products').get();
    return snapshot.docs
        .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Get products filtered by category
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    final snapshot = await _firestore
        .collection('Products')
        .where('category', isEqualTo: category)
        .get();
    return snapshot.docs
        .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Get single product by ID
  Future<ProductModel?> getProductById(String productId) async {
    final doc = await _firestore.collection('Products').doc(productId).get();
    if (doc.exists) {
      return ProductModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  // Update product
  Future<void> updateProduct(ProductModel product) async {
    await _firestore
        .collection('Products')
        .doc(product.id)
        .update(product.toMap());
  }

  // Delete product
  Future<void> deleteProduct(String productId) async {
    await _firestore.collection('Products').doc(productId).delete();
  }

  Future<List<ProductModel>> getProducts() async {
    final snapshot = await _firestore.collection('Products').get();
    return snapshot.docs
        .map((snapshot) => ProductModel.fromMap(snapshot.data(), snapshot.id))
        .toList();
  }
}
