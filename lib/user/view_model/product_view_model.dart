import '../../admin/models/products_model.dart';
import '../services/product_services/product_services.dart';

class ProductViewModel {
  final ProductServices _productServices = ProductServices();

  List<ProductModel> products = [];

  // Fetch all products
  Future<List<ProductModel>> fetchAllProducts() async {
    products = await _productServices.getAllProducts();
    return products;
  }

  // Fetch products by category (or all if category = All)
  Future<List<ProductModel>> fetchCategoryProducts({String? category}) async {
    if (category == null || category.isEmpty || category == "All") {
      return await fetchAllProducts();
    }
    return await _productServices.getProductsByCategory(category);
  }
}
