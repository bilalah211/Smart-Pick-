import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerceapp/admin/models/category_model.dart';
import 'package:ecommerceapp/user/services/product_services/product_services.dart';

class CategoriesServices {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  // Check if category already exists
  Future<bool> categoryExists(String categoryName) async {
    final snapshot = await _fireStore
        .collection('Categories')
        .where('name', isEqualTo: categoryName)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  Future<void> addCategory(CategoryModel category) async {
    // Check if category already exists before adding
    final exists = await categoryExists(category.name);
    if (exists) {
      throw Exception('Category "${category.name}" already exists!');
    }
    await _fireStore.collection('Categories').add(category.toMap());
  }

  Future<List<CategoryModel>> getCategory() async {
    final docRef = await _fireStore.collection('Categories').get();
    return docRef.docs
        .map((doc) => CategoryModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<int> getProductCountByCategory(String categoryName) async {
    try {
      final snapshot = await _fireStore
          .collection('Products')
          .where('category', isEqualTo: categoryName)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error getting product count for $categoryName: $e');
      return 0;
    }
  }

  Future<Map<String, dynamic>> getCategoriesWithProductCounts() async {
    final categories = await getCategory();
    Map<String, dynamic> result = {
      'categories': categories,
      'counts': <String, int>{},
    };

    for (var category in categories) {
      final count = await getProductCountByCategory(category.name);
      result['counts']![category.name] = count;
    }

    return result;
  }
}
