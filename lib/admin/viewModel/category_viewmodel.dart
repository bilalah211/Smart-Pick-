import 'package:ecommerceapp/admin/models/category_model.dart';
import 'package:ecommerceapp/admin/services/cartegories_services.dart';

class CategoryViewModel {
  final CategoriesServices _categoriesServices = CategoriesServices();

  Future<List<CategoryModel>> fetchCategory() async {
    return await _categoriesServices.getCategory();
  }

  Future<void> addCategory(String id, String name) async {
    final category = CategoryModel(id: id, name: name);
    await _categoriesServices.addCategory(category);
  }

  // Check if category exists
  Future<bool> checkCategoryExists(String categoryName) async {
    return await _categoriesServices.categoryExists(categoryName);
  }

  Future<Map<String, dynamic>> fetchCategoriesWithCounts() async {
    return await _categoriesServices.getCategoriesWithProductCounts();
  }

  Future<int> getProductCountForCategory(String categoryName) async {
    return await _categoriesServices.getProductCountByCategory(categoryName);
  }
}
