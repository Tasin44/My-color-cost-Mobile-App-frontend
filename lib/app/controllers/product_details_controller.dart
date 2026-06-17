import 'package:color_os/app/models/product_review_model.dart'
    show ProductReview;
import 'package:color_os/app/views/screens/tabs/shop/my_cart_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:color_os/app/controllers/shop_controller.dart';
import 'package:color_os/app/models/product_model.dart';
import 'package:color_os/app/core/constant/api_endpoints.dart';
import 'package:color_os/app/core/services/api_services.dart';

class ProductDetailsController extends GetxController {
  // Observable product that will be loaded from API
  final Rx<Product?> _product = Rx<Product?>(null);
  final RxBool isLoadingProduct = false.obs;

  Product get product {
    // Return loaded product or fallback to arguments
    if (_product.value != null) {
      return _product.value!;
    }

    if (Get.arguments != null && Get.arguments is Product) {
      return Get.arguments as Product;
    }

    // Fallback product if arguments are null
    return Product(
      id: '0',
      name: 'Unknown Product',
      retailer: 'Unknown',
      rating: 0.0,
      price: 0.0,
      imageUrl: '',
    );
  }

  // Observable variables
  final RxInt quantity = 1.obs;
  final RxBool isFavorite = false.obs;
  final RxBool isDescriptionExpanded = false.obs;
  final RxBool isAddedToCart = false.obs;

  // Reviews data
  final RxList<ProductReview> reviews = <ProductReview>[].obs;
  final RxDouble averageRating = 0.0.obs;
  final RxInt totalRatings = 0.obs;
  final RxBool isLoadingReviews = false.obs;

  // Rating breakdown
  final RxMap<int, int> ratingBreakdown = <int, int>{
    5: 0,
    4: 0,
    3: 0,
    2: 0,
    1: 0,
  }.obs;

  @override
  void onInit() {
    super.onInit();
    _loadProductDetails();
    _loadReviews();
  }

  // Load product details from API
  Future<void> _loadProductDetails() async {
    final initialProduct = product;
    if (initialProduct.id == '0') return;

    isLoadingProduct.value = true;
    try {
      final endpoint = ApiEndpoints.productDetails(
        int.parse(initialProduct.id),
      );
      debugPrint('Fetching product details from: $endpoint');
      final response = await ApiServices.getData(endpoint);

      if (response != null && response.success && response.data != null) {
        final productData = response.data['product'];
        if (productData != null) {
          // Map the API response to Product model using the updated factory
          _product.value = Product.fromJson(productData);

          // Update ratings from product details
          averageRating.value = product.rating;
          totalRatings.value = product.totalReviews;
        }

        // Also parse reviews if available in the same response
        if (response.data['reviews'] != null) {
          final List<dynamic> reviewsJson = response.data['reviews'];
          reviews.value =
              reviewsJson.map((json) => ProductReview.fromJson(json)).toList();
          _calculateRatingBreakdown();
        }

        if (response.data['review_count'] != null) {
          totalRatings.value = response.data['review_count'];
        }
      }
    } catch (e) {
      debugPrint('Error loading product details: $e');
    } finally {
      isLoadingProduct.value = false;
    }
  }

  // Load reviews from API
  Future<void> _loadReviews() async {
    final currentProduct = product;
    if (currentProduct.id == '0') return;

    isLoadingReviews.value = true;
    try {
      final endpoint = ApiEndpoints.productReviews(
        int.parse(currentProduct.id),
      );
      debugPrint('Fetching reviews from: $endpoint');
      final response = await ApiServices.getData(endpoint);

      if (response != null && response.success && response.data != null) {
        // Parse reviews
        final List<dynamic> reviewsJson = response.data['reviews'] ?? [];
        reviews.value = reviewsJson
            .map((json) => ProductReview.fromJson(json))
            .toList();

        // Parse aggregate data
        totalRatings.value = response.data['total_reviews'] ?? 0;
        averageRating.value =
            double.tryParse(
              response.data['average_rating']?.toString() ?? '0',
            ) ??
            0.0;

        // Calculate breakdown
        _calculateRatingBreakdown();
      }
    } catch (e) {
      debugPrint('Error loading reviews: $e');
    } finally {
      isLoadingReviews.value = false;
    }
  }

  void _calculateRatingBreakdown() {
    final Map<int, int> breakdown = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};

    if (reviews.isNotEmpty) {
      for (var review in reviews) {
        if (review.rating >= 1 && review.rating <= 5) {
          breakdown[review.rating] = (breakdown[review.rating] ?? 0) + 1;
        }
      }
    } else {
      // If no reviews, reset breakdown logic or keep empty
      // Resetting to 0s is already done by initialization above
    }

    ratingBreakdown.value = breakdown;
  }

  // Increment quantity
  void incrementQuantity() {
    quantity.value++;
  }

  // Decrement quantity
  void decrementQuantity() {
    if (quantity.value > 1) {
      quantity.value--;
    }
  }

  // Toggle favorite
  void toggleFavorite() {
    isFavorite.value = !isFavorite.value;
  }

  // Toggle description
  void toggleDescription() {
    isDescriptionExpanded.value = !isDescriptionExpanded.value;
  }

  // Add to cart
  void addToCart() {
    isAddedToCart.value = true;

    // Add to cart via ShopController
    try {
      final shopController = Get.find<ShopController>();
      shopController.addToCart(product, quantity: quantity.value);
    } catch (e) {
      debugPrint('ShopController not found: $e');
    }

    // Navigate to cart screen
    Get.to(() => const MyCartView());
  }

  // View cart
  void viewCart() {
    Get.to(() => const MyCartView());
  }

  // Open write review
  void writeReview() {
    Get.snackbar(
      'Write a Review',
      'Review feature coming soon',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFFF6B9D),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  // Get rating percentage
  double getRatingPercentage(int stars) {
    final total = ratingBreakdown.values.reduce((a, b) => a + b);
    if (total == 0) return 0;
    return (ratingBreakdown[stars] ?? 0) / total;
  }
}
