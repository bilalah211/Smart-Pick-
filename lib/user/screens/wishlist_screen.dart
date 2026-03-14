import 'package:ecommerceapp/user/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../admin/models/products_model.dart';

import '../services/wishlist_services.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final WishlistService _wishlistService = WishlistService();
  bool _isSelectAll = false;
  final List<String> _selectedItems = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<ProductModel> _filteredWishlistItems = [];

  @override
  void initState() {
    super.initState();
    _filteredWishlistItems = _wishlistService.wishlistItems;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredWishlistItems = _wishlistService.wishlistItems;
        _isSearching = false;
      } else {
        _filteredWishlistItems = _wishlistService.wishlistItems.where((
          product,
        ) {
          return product.title.toLowerCase().contains(query) ||
              product.category.toLowerCase().contains(query) ||
              product.description.toLowerCase().contains(query);
        }).toList();
        _isSearching = true;
      }
      // Clear selection when search changes
      _selectedItems.clear();
      _isSelectAll = false;
    });
  }

  void _toggleSelectAll(bool? value) {
    setState(() {
      _isSelectAll = value ?? false;
      if (_isSelectAll) {
        _selectedItems.clear();
        _selectedItems.addAll(_filteredWishlistItems.map((item) => item.id));
      } else {
        _selectedItems.clear();
      }
    });
  }

  void _toggleItemSelection(String itemId) {
    setState(() {
      if (_selectedItems.contains(itemId)) {
        _selectedItems.remove(itemId);
      } else {
        _selectedItems.add(itemId);
      }
      _isSelectAll = _selectedItems.length == _filteredWishlistItems.length;
    });
  }

  void _removeSelectedItems() {
    setState(() {
      for (String itemId in _selectedItems) {
        _wishlistService.removeFromWishlist(itemId);
      }
      _selectedItems.clear();
      _isSelectAll = false;
      // Update filtered list after removal
      _filteredWishlistItems = _wishlistService.wishlistItems;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Items removed from wishlist'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _removeItem(String itemId) {
    setState(() {
      _wishlistService.removeFromWishlist(itemId);
      // Update filtered list after removal
      _filteredWishlistItems = _wishlistService.wishlistItems;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Item removed from wishlist'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _moveToCart(ProductModel product) {
    // Implement your cart functionality here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.title} moved to cart'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _moveAllToCart() {
    for (String itemId in _selectedItems) {
      final product = _wishlistService.wishlistItems.firstWhere(
        (item) => item.id == itemId,
      );
      _moveToCart(product);
    }
    _removeSelectedItems();
  }

  double _calculateTotalPrice() {
    return _filteredWishlistItems.fold(
      0,
      (total, item) => total + double.parse(item.price.toString()),
    );
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _filteredWishlistItems = _wishlistService.wishlistItems;
      _isSearching = false;
    });
  }

  void _toggleSearch() {
    setState(() {
      if (_isSearching) {
        _clearSearch();
      } else {
        _isSearching = true;
        // Optionally focus on search field
        // FocusScope.of(context).requestFocus(_searchFocusNode);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Color(0xfff6f7fb),
      body: Column(
        children: [
          // Header
          _buildHeader(context, isDark),

          // Search Bar (when searching)
          if (_isSearching) _buildSearchBar(isDark),

          // Selection Bar
          if (_selectedItems.isNotEmpty) _buildSelectionBar(isDark),

          // Wishlist Items
          Expanded(
            child: _filteredWishlistItems.isEmpty
                ? _buildEmptyWishlist(isDark)
                : _buildWishlistItems(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.only(left: 5, right: 5, top: 50, bottom: 10),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            blurRadius: 5,
            offset: Offset(0, 1),
            color: Colors.black.withValues(alpha: 0.1),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade200, Color(0xFFEFF5FF)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  size: 20,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            SizedBox(width: 80),
            Text(
              'My Wishlist',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            Spacer(),
            // Search Icon Button
            GestureDetector(
              onTap: _toggleSearch,
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  _isSearching ? Iconsax.close_circle : Iconsax.search_normal,
                  size: 20,
                  color: _isSearching
                      ? Colors.red
                      : (isDark ? Colors.white : Colors.black87),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: TextField(
                controller: _searchController,

                decoration: InputDecoration(
                  hintText: 'Search in wishlist...',
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Iconsax.search_normal,
                    size: 20,
                    color: Colors.grey[500],
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.grey[500],
                          ),
                          onPressed: _clearSearch,
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                ),
                style: GoogleFonts.poppins(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          // Filter button (optional)
          GestureDetector(
            onTap: () {
              // Add filter functionality if needed
              _showFilterOptions(isDark);
            },
            child: Container(
              height: 45,
              width: 45,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Iconsax.filter, size: 20, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterOptions(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Wishlist',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(height: 20),
            // Add filter options here (price range, category, etc.)
            ListTile(
              leading: Icon(Iconsax.sort, color: Colors.blue),
              title: Text('Sort by Name A-Z'),
              onTap: () {
                Navigator.pop(context);
                _sortWishlist('name_asc');
              },
            ),
            ListTile(
              leading: Icon(Iconsax.sort, color: Colors.blue),
              title: Text('Sort by Name Z-A'),
              onTap: () {
                Navigator.pop(context);
                _sortWishlist('name_desc');
              },
            ),
            ListTile(
              leading: Icon(Iconsax.arrow_up, color: Colors.blue),
              title: Text('Price: Low to High'),
              onTap: () {
                Navigator.pop(context);
                _sortWishlist('price_asc');
              },
            ),
            ListTile(
              leading: Icon(Iconsax.arrow_down, color: Colors.blue),
              title: Text('Price: High to Low'),
              onTap: () {
                Navigator.pop(context);
                _sortWishlist('price_desc');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _sortWishlist(String sortBy) {
    setState(() {
      switch (sortBy) {
        case 'name_asc':
          _filteredWishlistItems.sort((a, b) => a.title.compareTo(b.title));
          break;
        case 'name_desc':
          _filteredWishlistItems.sort((a, b) => b.title.compareTo(a.title));
          break;
        case 'price_asc':
          _filteredWishlistItems.sort((a, b) => a.price.compareTo(b.price));
          break;
        case 'price_desc':
          _filteredWishlistItems.sort((a, b) => b.price.compareTo(a.price));
          break;
      }
    });
  }

  Widget _buildSelectionBar(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Checkbox(
            value: _isSelectAll,
            onChanged: _toggleSelectAll,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Text(
            'Select All (${_selectedItems.length})',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          Spacer(),
          IconButton(
            onPressed: _removeSelectedItems,
            icon: Icon(Icons.delete_outline, color: Colors.red),
            tooltip: 'Remove Selected',
          ),
          SizedBox(width: 8),
          GestureDetector(
            onTap: _moveAllToCart,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue[700],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Add to Cart',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWishlist(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              _isSearching ? Iconsax.search_normal : Iconsax.heart,
              size: 50,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: 24),
          Text(
            _isSearching ? 'No Items Found' : 'Your Wishlist is Empty',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 12),
          Text(
            _isSearching
                ? 'No items match your search criteria'
                : 'Start adding items you love to your wishlist',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          if (_isSearching) ...[
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _clearSearch,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text('Clear Search'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWishlistItems(bool isDark) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Wishlist count and total
          Row(
            children: [
              Text(
                '${_filteredWishlistItems.length} ${_filteredWishlistItems.length == 1 ? 'Item' : 'Items'}${_isSearching ? ' found' : ''}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              Spacer(),
              Text(
                'Total: \$${_calculateTotalPrice().toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Wishlist items grid
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.7,
            ),
            itemCount: _filteredWishlistItems.length,
            itemBuilder: (context, index) {
              final item = _filteredWishlistItems[index];
              final isSelected = _selectedItems.contains(item.id);

              return _buildWishlistItemCard(item, isSelected, isDark);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistItemCard(
    ProductModel product,
    bool isSelected,
    bool isDark,
  ) {
    final hasDiscount = product.discount != null && product.discount > 0;
    final discountedPrice = hasDiscount
        ? product.price - (product.price * product.discount / 100)
        : product.price;

    return Stack(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
            border: isSelected
                ? Border.all(color: Colors.blue[700]!, width: 2)
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Stack(
                children: [
                  Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey[100],
                            child: Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: Colors.grey[400],
                              size: 40,
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Discount Badge (if applicable)
                  if (hasDiscount)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${product.discount.round()}% OFF',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              // Product Details
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title.length > 20
                          ? '${product.title.substring(0, 20)}...'
                          : product.title,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),

                    // Price with discount
                    if (hasDiscount)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '\$${discountedPrice.toStringAsFixed(2)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    else
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    SizedBox(height: 4),

                    // Category
                    Text(
                      product.category,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),

                    // Rating
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        SizedBox(width: 4),
                        Text(
                          '4.5',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Popular',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Selection Checkbox
        Positioned(
          bottom: 4,
          right: hasDiscount ? 10 : 8,
          child: GestureDetector(
            onTap: () => _toggleItemSelection(product.id),
            child: Container(
              height: 24,
              width: 24,
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue[700] : Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isSelected ? Colors.blue[700]! : Colors.grey[300]!,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 2,
                  ),
                ],
              ),
              child: isSelected
                  ? Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),
        ),

        // Remove Button
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () => _removeItem(product.id),
            child: Container(
              height: 24,
              width: 24,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Icon(Icons.close, size: 16, color: Colors.grey[600]),
            ),
          ),
        ),
      ],
    );
  }
}
