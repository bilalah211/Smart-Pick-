import 'package:ecommerceapp/admin/models/category_model.dart';
import 'package:ecommerceapp/admin/screens/widgets/custom_drawer.dart';
import 'package:ecommerceapp/admin/viewModel/category_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  bool _isLoading = false;
  final CategoryViewModel _categoryVM = CategoryViewModel();
  List<CategoryModel> _categories = [];
  Map<String, int> _productCounts = {};

  final List<String> _availableCategories = [
    "Mobile",
    "Headphones",
    "Xbox",
    "Smart Watch",
    "Laptop",
    "Chargers",
  ];
  String? _selectedItem;

  @override
  void initState() {
    super.initState();
    _loadCategoriesWithCounts();
  }

  Future<void> _loadCategoriesWithCounts() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final result = await _categoryVM.fetchCategoriesWithCounts();
      if (mounted) {
        setState(() {
          _categories = result['categories'] as List<CategoryModel>;
          _productCounts = result['counts'] as Map<String, int>;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading categories: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _addCategories() async {
    if (_selectedItem == null || _selectedItem!.isEmpty) {
      _showSnackBar('Please select a category first!', Colors.orange);
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      // Check if category already exists
      final exists = await _categoryVM.checkCategoryExists(_selectedItem!);

      if (exists) {
        _showSnackBar(
          'Category "$_selectedItem" already exists!',
          Colors.orange,
        );
        return;
      }

      // If category doesn't exist, add it
      String id = const Uuid().v4();
      await _categoryVM.addCategory(id, _selectedItem!);

      // Refresh the data
      await _loadCategoriesWithCounts();

      // Clear selection
      if (mounted) {
        setState(() {
          _selectedItem = null;
        });
      }

      _showSnackBar(
        'Category "$_selectedItem" Added Successfully!',
        Colors.green,
      );
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}', Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  int _getProductCount(String categoryName) {
    return _productCounts[categoryName] ?? 0;
  }

  // Get existing category names for validation
  List<String> get _existingCategoryNames {
    return _categories.map((cat) => cat.name).toList();
  }

  // Get available categories (not yet added)
  List<String> get _availableCategoryOptions {
    return _availableCategories
        .where((cat) => !_existingCategoryNames.contains(cat))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: Column(
        children: [
          // Header with gradient
          _buildHeader(context),

          // Main content
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 5, right: 5, top: 60, bottom: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue, Color(0xFFEFF5FF)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          children: [
            _buildBackButton(context),
            SizedBox(width: 60),
            Text(
              'Product Categories',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(-2, 0),
            ),
          ],
        ),
        child: Icon(Icons.arrow_back_ios_new, size: 18),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleSection(),
          const SizedBox(height: 30),
          _buildAddCategoryCard(),
          const SizedBox(height: 30),
          _buildCategoriesListSection(),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Manage your product categories and view product counts',
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildAddCategoryCard() {
    final bool categoryExists =
        _selectedItem != null && _existingCategoryNames.contains(_selectedItem);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add New Category',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // Warning if category exists
            if (categoryExists) _buildCategoryExistsWarning(),

            // Dropdown
            _buildCategoryDropdown(),
            const SizedBox(height: 20),

            // Available categories info
            _buildAvailableCategoriesInfo(),
            const SizedBox(height: 20),

            // Add button
            _buildAddButton(categoryExists),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryExistsWarning() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: Colors.orange, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'This category already exists!',
              style: GoogleFonts.poppins(
                color: Colors.orange[800],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        labelText: 'Select Category Type',
        hintText: 'Choose a category',
      ),
      value: _selectedItem,
      items: _availableCategories.map((cat) {
        final exists = _existingCategoryNames.contains(cat);
        return DropdownMenuItem<String>(
          value: cat,
          enabled: !exists,
          child: Text(
            cat,
            style: GoogleFonts.poppins(
              color: exists ? Colors.grey : Colors.black,
            ),
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedItem = value;
        });
      },
    );
  }

  Widget _buildAvailableCategoriesInfo() {
    final available = _availableCategoryOptions;
    if (available.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available categories to add:',
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: available.map((cat) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Text(
                cat,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: Colors.green[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAddButton(bool categoryExists) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: categoryExists || _isLoading ? null : _addCategories,
        style: ElevatedButton.styleFrom(
          backgroundColor: categoryExists ? Colors.grey : Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: _isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: SpinKitFadingCircle(size: 25, color: Colors.white),
              )
            : Text(
                categoryExists ? 'Category Exists' : 'Add Category',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
      ),
    );
  }

  Widget _buildCategoriesListSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Existing Categories',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              'Total: ${_categories.length}',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),

        _buildCategoriesList(),
      ],
    );
  }

  Widget _buildCategoriesList() {
    if (_isLoading) {
      return _buildLoadingIndicator();
    }

    if (_categories.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _categories.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final category = _categories[index];
        return _buildCategoryItem(category);
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.only(left: 40.0, right: 40),
      child: Column(
        children: [
          SpinKitFadingCircle(size: 40, color: Colors.blue),
          SizedBox(height: 16),
          Text('Loading categories...'),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.all(40.0),
      child: Column(
        children: [
          Icon(Icons.category_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No categories found',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Add your first category using the form above',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(CategoryModel category) {
    final productCount = _getProductCount(category.name);

    return Card(
      elevation: 2,
      color: Color(0xfff5f6fb),
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getCategoryColor(category.name),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            _getCategoryIcon(category.name),
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Text(
          category.name,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Text(
          '$productCount ${productCount == 1 ? 'Product' : 'Products'}',
          style: GoogleFonts.poppins(color: Colors.grey[600]),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: productCount > 0 ? Colors.green[50] : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: productCount > 0 ? Colors.green : Colors.grey,
            ),
          ),
          child: Text(
            '$productCount',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: productCount > 0 ? Colors.green[800] : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  // category icons and colors
  Color _getCategoryColor(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'mobile':
        return Colors.blue.shade300;
      case 'headphones':
        return Colors.purple.shade300;
      case 'xbox':
        return Colors.green.shade300;
      case 'smart watch':
        return Colors.orange.shade300;
      case 'laptop':
        return Colors.red.shade300;
      case 'chargers':
        return Colors.teal.shade300;
      default:
        return Colors.grey.shade300;
    }
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'mobile':
        return Icons.phone_iphone;
      case 'headphones':
        return Icons.headphones;
      case 'xbox':
        return Icons.sports_esports;
      case 'smart watch':
        return Icons.watch;
      case 'laptop':
        return Icons.laptop;
      case 'chargers':
        return Icons.charging_station;
      default:
        return Icons.category;
    }
  }
}
