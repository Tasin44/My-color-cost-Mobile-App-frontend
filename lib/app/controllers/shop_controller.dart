import 'package:color_os/app/views/screens/tabs/shop/product_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:color_os/app/models/product_model.dart';
import 'package:color_os/app/models/cart_item_model.dart';
import 'package:color_os/app/models/retailer_model.dart';
import 'package:color_os/app/core/services/api_services.dart';
import 'package:color_os/app/models/api_response.dart';
import 'package:color_os/app/core/constant/api_endpoints.dart';
import 'dart:async';
import 'package:color_os/app/views/screens/tabs/shop/widgets/shop_filter_bottom_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

class ShopController extends GetxController {
  // Observable variables
  final RxList<Product> products = <Product>[].obs;
  final RxList<Product> filteredProducts = <Product>[].obs;
  final RxList<CartItem> cartItems = <CartItem>[].obs;
  final RxList<Retailer> retailers = <Retailer>[].obs;
  final RxList<Retailer> filteredRetailers = <Retailer>[].obs;
  final RxBool isLoadingRetailers = false.obs;
  final searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isAvailableOnly = false.obs;
  final RxString selectedSort = 'rating'.obs;
  final RxInt totalProducts = 0.obs;

  // Debounce timer
  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_onSearchChanged);
    _loadProducts();
    _loadRetailers();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    searchController.dispose();
    super.onClose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (searchQuery.value != searchController.text) {
        searchQuery.value = searchController.text;
        _filterRetailers();
        _loadProducts();
      }
    });
  }

  void _filterRetailers() {
    if (searchQuery.value.isEmpty) {
      filteredRetailers.assignAll(retailers);
    } else {
      final query = searchQuery.value.toLowerCase();
      filteredRetailers.assignAll(
        retailers.where((retailer) {
          return retailer.businessName.toLowerCase().contains(query) ||
              retailer.deliveryAreas.any(
                (area) => area.toLowerCase().contains(query),
              );
        }).toList(),
      );
    }
  }

  // Load products from API
  Future<void> _loadProducts() async {
    isLoading.value = true;
    try {
      String url;
      if (isAvailableOnly.value) {
        url = "${ApiEndpoints.inventory}?available_only=true";
      } else {
        url = "${ApiEndpoints.shopProducts}?";
      }

      // Append search param
      if (searchQuery.value.isNotEmpty) {
        if (url.endsWith('?')) {
          url += "search=${Uri.encodeComponent(searchQuery.value)}";
        } else {
          url += "&search=${Uri.encodeComponent(searchQuery.value)}";
        }
      }

      // Append sort param
      if (selectedSort.value.isNotEmpty) {
        if (url.endsWith('?')) {
          url += "ordering=${selectedSort.value}";
        } else {
          url += "&ordering=${selectedSort.value}";
        }
      }

      debugPrint('Fetching products from: $url');
      final response = await ApiServices.getData(url);

      if (response != null && response.success && response.data != null) {
        List<Product> fetchedProducts = [];

        if (isAvailableOnly.value) {
          // Parse InventoryProduct and map to Product
          final List<dynamic> productsData = response.data['products'] ?? [];
          fetchedProducts = productsData.map((e) {
            return Product(
              id: e['id'].toString(),
              name: e['product_name'] ?? 'Unknown',
              retailer: 'Unknown',
              rating: 0.0,
              price: double.tryParse(e['market_price']?.toString() ?? '0') ?? 0.0,
              discountedPrice: double.tryParse(e['discounted_market_price']?.toString() ??
                      e['market_price']?.toString() ??
                      '0') ??
                  0.0,
              imageUrl: e['product_image'] ?? '',
              promoIsActive: e['promo_is_active'] ?? false,
              promoBuyQuantity: e['promo_buy_quantity'],
              promoFreeQuantity: e['promo_free_quantity'],
              description: e['description'],
            );
          }).toList();
        } else {
          // Parse standard Shop Product
          final List<dynamic> productsData = response.data['products'] ?? [];
          fetchedProducts = productsData
              .map((e) => Product.fromJson(e))
              .toList();
        }

        products.value = fetchedProducts;
        totalProducts.value = response.data['total_count'] ?? fetchedProducts.length;
        filteredProducts.value = products.toList(); // No local filtering needed
      } else {
        // Only show error if strictly needed, or just clear list
        products.clear();
        filteredProducts.clear();
      }
    } catch (e) {
      debugPrint('Error loading products: $e');
      Get.snackbar(
        'Error',
        'An error occurred while loading products',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Load retailers from API
  Future<void> _loadRetailers() async {
    isLoadingRetailers.value = true;
    try {
      debugPrint('Fetching retailers from: ${ApiEndpoints.retailers}');
      final response = await ApiServices.getData(ApiEndpoints.retailers);

      if (response != null && response.success && response.data != null) {
        final List<dynamic> retailersData = response.data['retailers'] ?? [];
        retailers.value = retailersData
            .map((e) => Retailer.fromJson(e))
            .toList();
        _filterRetailers();
        debugPrint('Loaded ${retailers.length} retailers');
      } else {
        retailers.clear();
      }
    } catch (e) {
      debugPrint('Error loading retailers: $e');
      retailers.clear();
    } finally {
      isLoadingRetailers.value = false;
    }
  }

  // Get retailer details with products
  Future<RetailerDetails?> getRetailerDetails(int retailerId) async {
    try {
      debugPrint(
        'Fetching retailer details: ${ApiEndpoints.retailerDetails(retailerId)}',
      );
      final response = await ApiServices.getData(
        ApiEndpoints.retailerDetails(retailerId),
      );

      if (response != null && response.success && response.data != null) {
        return RetailerDetails.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint('Error loading retailer details: $e');
      Get.snackbar(
        'Error',
        'Failed to load retailer details',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
      return null;
    }
  }

  // Apply filters from bottom sheet
  void applyFilters() {
    _loadProducts();
  }

  // Open filter options
  void openFilters() {
    Get.bottomSheet(
      ShopFilterBottomSheet(controller: this),
      isScrollControlled: true,
    );
  }

  // View product details
  void viewProductDetails(Product product) {
    Get.to(() => const ProductDetailsScreen(), arguments: product);
  }

  // Add product to cart
  void addToCart(Product product, {int quantity = 1}) {
    // Check if product already exists in cart
    final existingIndex = cartItems.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex != -1) {
      // Update quantity if product exists
      final existingItem = cartItems[existingIndex];
      cartItems[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + quantity,
      );
    } else {
      // Add new item to cart
      cartItems.add(CartItem(product: product, quantity: quantity));
    }

    Get.snackbar(
      'Added to Cart',
      '${product.name} has been added to your cart',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade400,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  // Remove product from cart
  void removeFromCart(String productId) {
    cartItems.removeWhere((item) => item.product.id == productId);
    Get.snackbar(
      'Removed from Cart',
      'Item has been removed from your cart',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade400,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  // Update quantity of cart item
  void updateCartItemQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }

    final index = cartItems.indexWhere((item) => item.product.id == productId);

    if (index != -1) {
      cartItems[index] = cartItems[index].copyWith(quantity: quantity);
    }
  }

  // Increment cart item quantity
  void incrementCartItem(String productId) {
    final index = cartItems.indexWhere((item) => item.product.id == productId);

    if (index != -1) {
      final currentQuantity = cartItems[index].quantity;
      cartItems[index] = cartItems[index].copyWith(
        quantity: currentQuantity + 1,
      );
    }
  }

  // Decrement cart item quantity
  void decrementCartItem(String productId) {
    final index = cartItems.indexWhere((item) => item.product.id == productId);

    if (index != -1) {
      final currentQuantity = cartItems[index].quantity;
      if (currentQuantity > 1) {
        cartItems[index] = cartItems[index].copyWith(
          quantity: currentQuantity - 1,
        );
      } else {
        removeFromCart(productId);
      }
    }
  }

  // Get total cart value
  double get cartTotal {
    return cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  // Get total items count in cart
  int get cartItemsCount {
    return cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  // Clear cart
  void clearCart() {
    cartItems.clear();
    Get.snackbar(
      'Cart Cleared',
      'All items have been removed from your cart',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange.shade400,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  // Missing Product Request
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  Future<void> submitMissingProductRequest() async {
    if (productNameController.text.trim().isEmpty ||
        categoryController.text.trim().isEmpty ||
        brandController.text.trim().isEmpty ||
        notesController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'All fields are required',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final body = {
        "product_name": productNameController.text.trim(),
        "category": categoryController.text.trim(),
        "brand": brandController.text.trim(),
        "additional_notes": notesController.text.trim(),
      };

      final response = await ApiServices.postData(
        ApiEndpoints.missingProducts,
        body,
      );

      Get.back(); // Close loading

      if (response != null &&
          (response.success ||
              ApiResponse.isSuccessfulHttpStatus(response.statusCode))) {
        Get.back(); // Close bottom sheet
        Get.snackbar(
          'Success',
          'Request submitted successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        // Clear fields
        productNameController.clear();
        categoryController.clear();
        brandController.clear();
        notesController.clear();
      } else {
        Get.snackbar(
          'Error',
          response?.message ?? 'Failed to submit request',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back(); // Close loading
      debugPrint('Error submitting missing product: $e');
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> createCheckoutSession({
    required String addressLabel,
    required String fullAddress,
    required String area,
    required String postalCode,
    required String phoneNumber,
    bool isDefault = true,
  }) async {
    if (cartItems.isEmpty) {
      Get.snackbar(
        'Error',
        'Your cart is empty',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final products = cartItems
          .map(
            (item) => {
              'shop_product_id': int.parse(item.product.id),
              'quantity': item.quantity,
            },
          )
          .toList();

      final body = {
        "products": products,
        "address_label": addressLabel,
        "full_address": fullAddress,
        "area": area,
        "postal_code": postalCode,
        "phone_number": phoneNumber,
        "is_default": isDefault,
      };

      final response = await ApiServices.postData(
        ApiEndpoints.createCheckout,
        body,
      );

      Get.back(); // Close loading dialog

      if (response != null &&
          (response.success ||
              ApiResponse.isSuccessfulHttpStatus(response.statusCode)) &&
          response.data != null) {
        final data = response.data;
        if (data is Map && data.containsKey('checkout_url')) {
          final checkoutUrl = data['checkout_url'];
          await _launchCheckoutUrl(checkoutUrl);
        } else {
          Get.snackbar(
            'Error',
            'Checkout URL not found in response',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar(
          'Error',
          response?.message ?? 'Failed to create checkout session',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      debugPrint('Error creating checkout session: $e');
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _launchCheckoutUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Error launching checkout URL: $e');
      Get.snackbar(
        'Error',
        'Could not launch checkout URL',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
