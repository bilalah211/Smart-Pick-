import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerceapp/admin/models/category_model.dart';
import 'package:ecommerceapp/admin/screens/categories_screen.dart';
import 'package:ecommerceapp/admin/viewModel/category_viewmodel.dart';
import 'package:ecommerceapp/user/screens/all_categories.dart';
import 'package:ecommerceapp/user/screens/description_screen.dart';
import 'package:ecommerceapp/user/screens/profile_screen.dart';
import 'package:ecommerceapp/user/screens/search_screen.dart';
import 'package:ecommerceapp/user/screens/wishlist_screen.dart';
import 'package:ecommerceapp/user/services/firestore_services/firestore_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../admin/models/products_model.dart';
import '../constants/app_strings.dart';
import '../constants/images_url.dart';
import '../models/auth_user_model.dart';
import '../models/banner_moderl.dart';
import '../services/wishlist_services.dart';
import '../view_model/product_view_model.dart';
import '../widgets/custom_textfield.dart';
import 'cart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;
  TextEditingController searchController = TextEditingController();
  final CategoryViewModel _categoryViewModel = CategoryViewModel();
  late TabController _tabController;
  int _selectedIndex = 0;
  int _selectedTabIndex = 0;
  int _currentBannerIndex = 0;
  List<ProductModel> productCategory = [];
  List<CategoryModel> _categories = [];
  final id = FirebaseAuth.instance.currentUser!.uid;
  late final UserModel? userModel;
  final FirestoreServices _firestoreServices = FirestoreServices();
  String? username;

  final ProductViewModel _productVM = ProductViewModel();
  final WishlistService _wishlistService = WishlistService();

  // Stream for real-time cart count
  Stream<int> get _cartItemCountStream {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('Cart')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Future<void> _fetchUsername() async {
    try {
      final uid = id;
      if (uid.isNotEmpty) {
        final user = await _firestoreServices.getCurrentUser(uid);
        setState(() {
          username = user?.name ?? "Guest";
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching user name: $e");
      }
    }
  }

  // banners list
  final List<BannerItem> banners = [
    BannerItem(
      imageUrl: 'assets/banners/banner1.jpg',
      title: 'Summer Sale',
      description: 'Up to 50% off on all items',
    ),
    BannerItem(
      imageUrl: 'assets/banners/banner2.jpg',
      title: 'New Arrivals',
      description: 'Check out the latest collection',
    ),
    BannerItem(
      imageUrl: 'assets/banners/banner3.jpg',
      title: 'Free Shipping',
      description: 'On orders over \$50',
    ),
    BannerItem(
      imageUrl: 'assets/banners/banner4.jpg',
      title: 'Winter Collection',
      description: 'Stay warm in style',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _fetchUsername();
  }

  void _loadCategories() async {
    final fetchedCategories = await _categoryViewModel.fetchCategory();
    setState(() {
      _categories = fetchedCategories;
      _tabController = TabController(
        length: _categories.length + 1,
        vsync: this,
      );
      _tabController.addListener(_handleTabSelection);
    });
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    }
  }

  Future<List<ProductModel>> _fetchProductsForCurrentTab() async {
    if (_selectedTabIndex == 0) {
      return await _productVM.fetchAllProducts();
    } else {
      final categoryName = _categories[_selectedTabIndex - 1].name;
      return await _productVM.fetchCategoryProducts(category: categoryName);
    }
  }

  // Add to Wishlist Function
  void _addToWishlist(ProductModel product) {
    setState(() {
      _wishlistService.addToWishlist(product);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.title} added to wishlist'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Remove from Wishlist Function
  void _removeFromWishlist(ProductModel product) {
    setState(() {
      _wishlistService.removeFromWishlist(product.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.title} removed from wishlist'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Toggle Wishlist Function
  void _toggleWishlist(ProductModel product) {
    if (_wishlistService.isInWishlist(product.id)) {
      _removeFromWishlist(product);
    } else {
      _addToWishlist(product);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildHomeBody(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Column(
      children: [
        // Header Section
        _buildHeaderSection(context, width),

        // Categories Section
        _buildCategoriesSection(),

        // Products Section
        Expanded(child: _buildProductsSection(height, width)),
      ],
    );
  }

  Widget _buildHeaderSection(BuildContext context, double width) {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 40, bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 5,
            offset: Offset(-0, 1),
            color: Colors.black26,
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade200, Color(0xFFEFF5FF)],
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello! 👋',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    username != null ? username! : '',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  // Wishlist Icon
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WishlistScreen(),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 25),
                      child: Container(
                        height: 50,
                        width: 50,
                        margin: EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: Color(0xfff5f6fb),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.black12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Icon(
                                Icons.favorite_outline,
                                color: Colors.blue[700],
                                size: 24,
                              ),
                            ),
                            if (_wishlistService.wishlistItems.isNotEmpty)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${_wishlistService.wishlistItems.length}',
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
                      ),
                    ),
                  ),
                  // Cart Icon with StreamBuilder
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CartScreen()),
                      );
                    },
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Color(0xfff5f6fb),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.black12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Image.asset(
                              ImageUrls.bag,
                              width: 24,
                              color: Colors.blue[700],
                            ),
                          ),
                          // Cart count badge - only show when count > 0
                          StreamBuilder<int>(
                            stream: _cartItemCountStream,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return SizedBox.shrink(); // Hide when loading
                              }
                              if (snapshot.hasError) {
                                if (kDebugMode) {
                                  print("Cart stream error: ${snapshot.error}");
                                }
                                return SizedBox.shrink(); // Hide on error
                              }
                              final cartCount = snapshot.data ?? 0;

                              // Only show badge if count is greater than 0
                              if (cartCount > 0) {
                                return Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      cartCount > 9 ? '9+' : '$cartCount',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                return SizedBox.shrink(); // Hide when count is 0
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 0),
          CustomTextField(
            hintText: 'Search products...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.black26),
            ),
          ),
          SizedBox(height: 16),
          // Banner Section
          _buildBannerSection(),
        ],
      ),
    );
  }

  Widget _buildBannerSection() {
    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          children: [
            CarouselSlider(
              options: CarouselOptions(
                height: 180,
                aspectRatio: 16 / 10,
                viewportFraction: 0.8,
                enableInfiniteScroll: true,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 4),
                autoPlayAnimationDuration: Duration(milliseconds: 1000),
                enlargeCenterPage: true,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentBannerIndex = index;
                  });
                },
              ),
              items: banners.map((banner) {
                return Container(
                  margin: EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(
                      image: AssetImage(banner.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 8),
            // Dots indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: banners.asMap().entries.map((entry) {
                return Container(
                  width: 9.0,
                  height: 8.0,
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentBannerIndex == entry.key
                        ? Colors.blue
                        : Colors.grey,
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.categories,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserCategoriesScreen(),
                    ),
                  );
                },
                child: Text(
                  'See All',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        _categories.isEmpty
            ? Center(
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 60,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              )
            : SizedBox(
                height: 35,

                child: TabBar(
                  labelPadding: EdgeInsets.only(left: 20),
                  controller: _tabController,
                  indicatorPadding: EdgeInsetsGeometry.zero,
                  isScrollable: true,
                  labelColor: Colors.blue[700],
                  indicatorColor: Colors.blue[700],
                  unselectedLabelColor: Colors.grey[600],
                  labelStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                  tabs: [
                    Tab(text: "All"),
                    ..._categories.map((cat) => Tab(text: cat.name)),
                  ],
                ),
              ),
      ],
    );
  }

  Widget _buildProductsSection(double height, double width) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: FutureBuilder<List<ProductModel>>(
        future: _fetchProductsForCurrentTab(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerGrid();
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 50, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Something went wrong',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 50,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No Products Found',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }
          final products = snapshot.data!;

          return GridView.builder(
            padding: EdgeInsets.only(top: 20),
            itemCount: products.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemBuilder: (context, index) {
              return _buildProductCard(products[index], height, width);
            },
          );
        },
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      padding: EdgeInsets.only(top: 20),

      itemCount: 6,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) {
        return _buildShimmerCard();
      },
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stack for image and favorite icon
          Stack(
            children: [
              // Main product image shimmer
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: 120,
                  width: double.infinity,
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              // Favorite icon shimmer
              Positioned(
                top: 12,
                right: 12,
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Product details section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product title shimmer
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(height: 4),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.3,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                // Price shimmer
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 60,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                // Rating and badge row shimmer
                Row(
                  children: [
                    // Rating section shimmer
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          SizedBox(width: 4),
                          Container(
                            width: 25,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    // Popular badge shimmer
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: 50,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
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
    );
  }

  Widget _buildProductCard(ProductModel product, double height, double width) {
    final isInWishlist = _wishlistService.isInWishlist(product.id);
    final hasDiscount = product.discount != null && product.discount > 0;
    final discountedPrice = hasDiscount
        ? product.price - (product.price * product.discount / 100)
        : product.price;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DescriptionScreen(products: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: height * 0.15,
                  width: double.infinity,
                  margin: EdgeInsets.all(8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[100],
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Discount Badge - Only show if product has discount
                if (hasDiscount)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${product.discount.toStringAsFixed(0)}% OFF',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () => _toggleWishlist(product),
                    child: Container(
                      height: 36,
                      width: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          isInWishlist ? Icons.favorite : Icons.favorite_border,
                          size: 20,
                          color: isInWishlist ? Colors.red : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title.length > 20
                        ? '${product.title.substring(0, 20)}...'
                        : product.title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),

                  // Price Section - Show original and discounted price
                  if (hasDiscount)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '\$${discountedPrice.toStringAsFixed(2)}',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.blue[700],
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
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
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.blue[700],
                      ),
                    ),

                  SizedBox(height: 4),
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating: 4.2,
                        itemBuilder: (context, index) =>
                            Icon(Icons.star, color: Colors.amber),
                        itemCount: 1,
                        itemSize: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '4.2',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(6),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _selectedIndex == 0
          ? _buildHomeBody(context)
          : _selectedIndex == 1
          ? SearchScreen()
          : _selectedIndex == 2
          ? WishlistScreen()
          : ProfileScreen(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    final wishlistCount = _wishlistService.wishlistItems.length;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blue[700],
          unselectedItemColor: Colors.grey[500],
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: _selectedIndex == 0
                    ? BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                      )
                    : null,
                child: Image.asset(
                  ImageUrls.home,
                  height: 24,
                  color: _selectedIndex == 0
                      ? Colors.blue[700]
                      : Colors.grey[500],
                ),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: _selectedIndex == 1
                    ? BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                      )
                    : null,
                child: Image.asset(
                  ImageUrls.searchN,
                  height: 24,
                  color: _selectedIndex == 1
                      ? Colors.blue[700]
                      : Colors.grey[500],
                ),
              ),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: _selectedIndex == 2
                        ? BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(12),
                          )
                        : null,
                    child: Image.asset(
                      ImageUrls.wishlist,
                      height: 24,
                      color: _selectedIndex == 2
                          ? Colors.blue[700]
                          : Colors.grey[500],
                    ),
                  ),
                  // Only show wishlist badge when count > 0
                  if (wishlistCount > 0)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          wishlistCount > 9 ? '9+' : '$wishlistCount',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              label: 'Wishlist',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: _selectedIndex == 3
                    ? BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                      )
                    : null,
                child: Image.asset(
                  ImageUrls.profile,
                  height: 24,
                  color: _selectedIndex == 3
                      ? Colors.blue[700]
                      : Colors.grey[500],
                ),
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
