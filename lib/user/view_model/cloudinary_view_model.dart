import 'dart:io';
import '../../admin/models/products_model.dart';
import '../services/cloudinary_services/cloudinary_services.dart';
import '../services/product_services/product_services.dart';

class CloudinaryViewModel {
  String? selectedItems;
  final ProductServices _productServices = ProductServices();
  final CloudinaryServices _cloudinaryServices = CloudinaryServices();
  final List<String?> item = [
    "Mobile",
    "Headphones",
    "Xbox",
    "Smart Watch",
    "Laptop",
    "Chargers",
  ];

  File? _selectedImage;
  File? get selectedImage => _selectedImage;

  Future<void> pickImage() async {
    _selectedImage = await _cloudinaryServices.pickImage();
  }

  void clearImage() {
    _selectedImage = null;
  }

  Future<void> addProducts(
    String title,
    String description,
    dynamic price,
    dynamic category,
    dynamic discount,
  ) async {
    if (_selectedImage == null) return;

    final String? imageUrl = await _cloudinaryServices.uploadImageToCloudinary(
      _selectedImage!,
    );

    final double parsedPrice = _parseDouble(price);
    final double parsedDiscount = _parseDouble(discount);
    if (imageUrl != null) {
      await _productServices.addProduct(
        ProductModel(
          id: '',
          title: title,
          description: description,
          price: parsedPrice,
          imageUrl: imageUrl,
          category: category,
          discount: parsedDiscount,
        ),
      );
      _selectedImage = null;
    }
  }

  // Updated method for updating product - accepts currentImageUrl as parameter
  Future<void> updateProduct(
    String productId,
    String title,
    String description,
    dynamic price,
    dynamic category,
    dynamic discount,
    String currentImageUrl, // Add this parameter
  ) async {
    String? imageUrl = currentImageUrl; // Use the passed current image URL

    // Upload new image if selected
    if (_selectedImage != null) {
      imageUrl = await _cloudinaryServices.uploadImageToCloudinary(
        _selectedImage!,
      );
    }

    final double parsedPrice = _parseDouble(price);
    final double parsedDiscount = _parseDouble(discount);

    if (imageUrl != null) {
      await _productServices.updateProduct(
        ProductModel(
          id: productId,
          title: title,
          description: description,
          price: parsedPrice,
          imageUrl: imageUrl,
          category: category,
          discount: parsedDiscount,
        ),
      );
      _selectedImage = null;
    }
  }

  void debugProductData(
    String title,
    dynamic price,
    dynamic discount,
    String category,
  ) {}

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
