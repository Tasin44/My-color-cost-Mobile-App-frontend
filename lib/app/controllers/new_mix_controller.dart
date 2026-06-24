import 'dart:io';
import 'package:color_os/app/views/screens/main_base_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:color_os/app/core/constant/api_endpoints.dart';
import 'package:color_os/app/core/services/api_services.dart';
import 'package:color_os/app/models/api_response.dart';
import 'package:color_os/app/views/screens/newmix/add_manual_product_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:color_os/app/models/mix_model.dart';
import 'package:color_os/app/models/client_model.dart';
import 'package:color_os/app/models/bowl_mix_item.dart';
import 'package:color_os/app/models/bowl_data_model.dart';
import 'package:color_os/app/models/service_type_model.dart';
import 'package:color_os/app/views/screens/newmix/barcode_scanner_screen.dart';
import 'package:color_os/app/models/inventory_product_model.dart';
import 'package:color_os/app/views/screens/newmix/steps/select_client_screen.dart';
import 'package:color_os/app/views/screens/newmix/steps/select_service_screen.dart';
import 'package:color_os/app/views/screens/newmix/steps/create_bowl_screen.dart';
import 'package:color_os/app/views/screens/newmix/product_list_screen.dart';
import 'package:color_os/app/views/screens/newmix/steps/mix_summary_screen.dart';
import 'package:color_os/app/views/screens/newmix/steps/all_bowls_review_screen.dart';
import 'package:color_os/app/core/constant/app_textstyle.dart';
import 'package:color_os/app/core/constant/themes/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:convert';
import 'package:color_os/app/core/helper/sharedpref_helper.dart';

/// SharedPreferences key prefix for persisted original weights.
/// Exported so other screens can read the cache directly when needed.
const String kOrigWeightPrefix = 'product_orig_weight_';

class NewMixController extends GetxController {
  // ═══════════════════════════════════════════════════════════════════════════
  // Observable variables
  // ═══════════════════════════════════════════════════════════════════════════
  final RxInt currentStep = 1.obs;
  final RxInt totalSteps = 5.obs;
  final RxList<MixProduct> selectedProducts = <MixProduct>[].obs;
  final searchController = TextEditingController();
  final RxString searchQuery = ''.obs;

  // Loading states
  final RxBool isCheckingStatus = false.obs;
  final RxBool isSubmitting = false.obs;

  // ═══════════════════════════════════════════════════════════════════════════
  // NEW FLOW: Multi-bowl mix creation state
  // ═══════════════════════════════════════════════════════════════════════════

  /// Selected client for the mix
  final Rx<ClientModel?> selectedClient = Rx<ClientModel?>(null);
  final RxString selectedClientId = ''.obs;

  /// Selected service type from dropdown
  final Rx<ServiceTypeModel?> selectedServiceType = Rx<ServiceTypeModel?>(null);

  /// Date for bleach_timer_start_time
  final Rx<DateTime?> serviceDate = Rx<DateTime?>(null);

  /// All bowls being created in this session
  final RxList<BowlData> bowls = <BowlData>[].obs;

  /// Index of the bowl currently being edited
  final RxInt currentBowlIndex = 0.obs;

  /// Progress message for dialogs
  final RxString progressMessage = ''.obs;

  // ═══════════════════════════════════════════════════════════════════════════
  // Legacy variables (kept for backward compatibility with existing screens)
  // ═══════════════════════════════════════════════════════════════════════════
  final Rx<BowlProduct?> currentBowl = Rx<BowlProduct?>(null);
  final RxDouble marketPrice = 0.0.obs;
  final RxDouble costPer100g = 0.0.obs;
  final RxDouble currentBowlGrams = 0.0.obs;
  final RxList<BowlMixItem> mixItems = <BowlMixItem>[].obs;
  final RxDouble totalMixCost = 0.0.obs;
  final RxDouble clientCharge = 20.0.obs;
  final RxDouble profit = 0.0.obs;
  final RxBool isAddingToExistingBowl = false.obs;

  // Recent Mixes
  final RxList<MixModel> recentMixes = <MixModel>[].obs;
  final RxBool isLoadingMixes = false.obs;

  // Inventory Flow
  final RxList<InventoryProduct> inventoryProducts = <InventoryProduct>[].obs;
  final RxBool isLoadingInventory = false.obs;

  // Add Bowl Form Controllers
  final TextEditingController mixTypeController = TextEditingController();
  final TextEditingController serviceTypeController = TextEditingController();

  // Selected Inventory Product for Bowl
  final Rx<InventoryProduct?> selectedInventoryProduct = Rx<InventoryProduct?>(
    null,
  );

  @override
  void onInit() {
    super.onInit();
    resetMix();
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });
    fetchRecentMixes();
    fetchInventory();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // NEW FLOW: Navigation methods
  // ═══════════════════════════════════════════════════════════════════════════

  /// Step 1: Start the service flow → navigate to client selection
  void startServiceFlow() {
    resetMix();
    Get.to(() => const SelectClientScreen());
  }

  /// Step 2: Client selected → navigate to service selection
  void onClientSelected(ClientModel client) {
    selectedClient.value = client;
    selectedClientId.value = client.id;
    Get.to(() => const SelectServiceScreen());
  }

  /// Step 3: Service + date selected → navigate to bowl creation
  void onServiceSelected(ServiceTypeModel service, DateTime date) {
    selectedServiceType.value = service;
    serviceDate.value = date;
    Get.to(() => const CreateBowlScreen());
  }

  /// Step 4: Bowl details entered → create bowl and navigate to product selection
  void createNewBowl(String serviceName, String mixName) {
    final dateStr = serviceDate.value?.toIso8601String() ??
        DateTime.now().toIso8601String();

    final newBowl = BowlData(
      serviceName: serviceName,
      mixName: mixName,
      bleachTimerStartTime: dateStr,
    );

    bowls.add(newBowl);
    currentBowlIndex.value = bowls.length - 1;

    // Navigate to product selection
    fetchInventory();
    Get.to(() => const ProductListScreen());
  }

  /// Get the current bowl being edited
  BowlData? get currentBowlData {
    if (currentBowlIndex.value >= 0 &&
        currentBowlIndex.value < bowls.length) {
      return bowls[currentBowlIndex.value];
    }
    return null;
  }

  /// Step 5: Add product to current bowl
  void addProductToCurrentBowl({
    required InventoryProduct product,
    required double usedWeight,
    required double userPrice,
    required double marketPriceValue,
  }) {
    if (currentBowlData == null) return;

    final bowlProduct = BowlProductData(
      userProductId: product.id,
      productName: product.productName,
      productImage: product.productImage,
      usedWeight: usedWeight,
      userPrice: userPrice,
      marketPrice: marketPriceValue,
    );

    bowls[currentBowlIndex.value].products.add(bowlProduct);
    bowls.refresh(); // Trigger reactive update

    Get.snackbar(
      'Product Added',
      '${product.productName} added to bowl',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade400,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  /// Remove product from current bowl
  void removeProductFromCurrentBowl(int productIndex) {
    if (currentBowlData == null) return;
    if (productIndex >= 0 &&
        productIndex < bowls[currentBowlIndex.value].products.length) {
      final removed =
          bowls[currentBowlIndex.value].products.removeAt(productIndex);
      bowls.refresh();
      Get.snackbar(
        'Removed',
        '${removed.productName} removed from bowl',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade400,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  /// Navigate to bowl review (after adding products)
  void reviewCurrentBowl() {
    if (currentBowlData == null || currentBowlData!.products.isEmpty) {
      Get.snackbar(
        'No Products',
        'Please add at least one product to the bowl',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    Get.to(() => const MixSummaryScreen());
  }

  /// Set charged amount for current bowl
  void setCurrentBowlChargedAmount(double amount) {
    if (currentBowlData != null) {
      bowls[currentBowlIndex.value].chargedAmount = amount;
      bowls.refresh();
    }
  }

  /// Bowl complete → go to all bowls review
  void finishCurrentBowl() {
    Get.to(() => const AllBowlsReviewScreen());
  }

  /// Add more bowls → go back to bowl creation
  void addMoreBowls() {
    Get.to(() => const CreateBowlScreen());
  }

  /// Delete a bowl by index
  void deleteBowl(int index) {
    if (index >= 0 && index < bowls.length) {
      final removed = bowls.removeAt(index);
      // Adjust current bowl index if needed
      if (currentBowlIndex.value >= bowls.length && bowls.isNotEmpty) {
        currentBowlIndex.value = bowls.length - 1;
      }
      Get.snackbar(
        'Bowl Deleted',
        '${removed.mixName} removed',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade400,
        colorText: Colors.white,
      );
    }
  }

  /// Calculate total cost across all bowls
  double get totalBowlsCost {
    double total = 0.0;
    for (final bowl in bowls) {
      for (final product in bowl.products) {
        total += product.marketPrice > 0
            ? (product.userPrice / product.marketPrice) * product.usedWeight
            : 0.0;
      }
    }
    return total;
  }

  /// Calculate total charged amount across all bowls
  double get totalChargedAmount {
    double total = 0.0;
    for (final bowl in bowls) {
      total += bowl.chargedAmount ?? 0.0;
    }
    return total;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // NEW FLOW: Submit Mix (POST /mix/mixes/new/)
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> submitNewMix() async {
    if (selectedClient.value == null) {
      Get.snackbar('Error', 'Please select a client',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (selectedServiceType.value == null) {
      Get.snackbar('Error', 'Please select a service type',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (bowls.isEmpty) {
      Get.snackbar('Error', 'Please add at least one bowl',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    // Check all bowls have products
    for (int i = 0; i < bowls.length; i++) {
      if (bowls[i].products.isEmpty) {
        Get.snackbar('Error', 'Bowl "${bowls[i].mixName}" has no products',
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }
    }

    isSubmitting.value = true;
    progressMessage.value = 'Creating mix...';

    // Show progress dialog
    Get.dialog(
      PopScope(
        canPop: false,
        child: AlertDialog(
          content: Obx(
            () => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                Text(
                  progressMessage.value,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      final body = {
        'client_id': int.tryParse(selectedClient.value!.id) ?? 0,
        'service_type': selectedServiceType.value!.id.toString(),
        'bowls': bowls.map((b) => b.toJson()).toList(),
      };

      debugPrint('--- [NewMixController] submitNewMix body: $body ---');

      final response = await ApiServices.postData(ApiEndpoints.newMixes, body);

      debugPrint(
          '--- [NewMixController] submitNewMix response: ${response?.data} ---');

      _closeBlockingProgressDialog();

      if (response != null &&
          (response.success ||
              ApiResponse.isSuccessfulHttpStatus(response.statusCode))) {
        progressMessage.value = 'Mix created successfully!';

        Get.snackbar(
          'Success',
          'Mix saved successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );

        // Navigate to home
        Get.offAll(() => MainBaseScreen());

        // Delay reset
        Future.delayed(const Duration(milliseconds: 300), () {
          resetMix();
          fetchRecentMixes();
        });
      } else {
        // Parse error
        String errorMessage = response?.message ?? 'Failed to create mix';

        // Try to extract bowl-level errors
        if (response?.data != null) {
          final data = response!.data;
          if (data is Map && data.containsKey('bowls')) {
            final bowlErrors = data['bowls'];
            if (bowlErrors is List && bowlErrors.isNotEmpty) {
              errorMessage = bowlErrors.first.toString();
            } else if (bowlErrors is String) {
              errorMessage = bowlErrors;
            }
          }
        }

        Get.dialog(
          AlertDialog(
            title: const Text('Failed to Create Mix'),
            content: Text(errorMessage),
            actions: [
              TextButton(
                  onPressed: () => Get.back(), child: const Text('OK')),
            ],
          ),
        );
      }
    } catch (e, stack) {
      _closeBlockingProgressDialog();
      debugPrint('Error submitting mix: $e');
      debugPrint('Stack trace: $stack');

      final errorMessage = e.toString().replaceAll('Exception: ', '');
      Get.dialog(
        AlertDialog(
          title: const Text('Failed to Create Mix'),
          content: Text(errorMessage),
          actions: [
            TextButton(
                onPressed: () => Get.back(), child: const Text('OK')),
          ],
        ),
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Delete a mix by ID
  Future<bool> deleteMixById(int mixId) async {
    try {
      final url = ApiEndpoints.deleteMix(mixId);
      debugPrint('--- [NewMixController] deleteMixById: $url ---');

      final response = await ApiServices.deleteData(url);

      if (response != null && response.success) {
        recentMixes.removeWhere((mix) => mix.id == mixId.toString());
        Get.snackbar(
          'Deleted',
          'Mix deleted successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          response?.message ?? 'Failed to delete mix',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      debugPrint('Error deleting mix: $e');
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // EXISTING METHODS (kept intact)
  // ═══════════════════════════════════════════════════════════════════════════

  // Fetch Recent Mixes
  Future<void> fetchRecentMixes() async {
    try {
      isLoadingMixes.value = true;
      final response = await ApiServices.getData(ApiEndpoints.newMixes);
      if (response != null && response.success && response.data != null) {
        debugPrint("DEBUG: fetchRecentMixes response.data: ${response.data}");
        final List<dynamic> mixesJson = (response.data['mixes'] != null)
            ? response.data['mixes']
            : [];
        recentMixes.value = mixesJson
            .map((json) => MixModel.fromJson(json))
            .toList();
        debugPrint(
          "DEBUG: fetchRecentMixes loaded ${recentMixes.length} mixes",
        );
      }
    } catch (e) {
      debugPrint("Error fetching recent mixes: $e");
      if (e is NoSuchMethodError && e.toString().contains("[]")) {
        debugPrint(
          "DEBUG: Parsing failure in fetchRecentMixes. Response data might not have expected structure.",
        );
      }
    } finally {
      isLoadingMixes.value = false;
    }
  }

  // Fetch All Mixes
  Future<List<MixModel>> getAllMixes() async {
    try {
      final response = await ApiServices.getData(ApiEndpoints.newMixes);
      if (response != null && response.success && response.data != null) {
        final List<dynamic> mixesJson = (response.data['mixes'] != null)
            ? response.data['mixes']
            : [];
        return mixesJson.map((json) => MixModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Error fetching all mixes: $e");
      return [];
    }
  }

  // Fetch Mix Details
  Future<MixModel?> fetchMixDetails(String mixId) async {
    try {
      final response = await ApiServices.getData(ApiEndpoints.mixDetails(mixId));
      if (response != null && response.success && response.data != null) {
        return MixModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint("Error fetching mix details: $e");
      return null;
    }
  }

  // Check if user can create a mix
  Future<bool> checkMixCreation() async {
    return true; // Temporary bypass
  }

  @override
  void onClose() {
    super.onClose();
  }

  // Fetch Inventory Products
  Future<void> fetchInventory() async {
    try {
      isLoadingInventory.value = true;
      final response = await ApiServices.getData(ApiEndpoints.inventory);
      if (response != null && response.success && response.data != null) {
        final List<dynamic> productsJson = response.data['products'] ?? [];
        inventoryProducts.value = productsJson
            .map((json) => InventoryProduct.fromJson(json))
            .toList();
      }
    } catch (e) {
      debugPrint("Error fetching inventory: $e");
    } finally {
      isLoadingInventory.value = false;
    }
  }

  // Get progress percentage
  double get progressPercentage => currentStep.value / totalSteps.value;

  /// Closes loading dialogs used elsewhere (e.g. save mix). Snackbars first.
  void _closeBlockingProgressDialog() {
    if (Get.isSnackbarOpen == true) {
      Get.closeAllSnackbars();
    }
    if (Get.isDialogOpen != false) {
      Get.back();
    }
  }

  /// Dismisses the barcode "Searching…" dialog and waits until the route is fully removed.
  Future<void> _closeSearchDialogAndWait(Future<dynamic>? dialogFuture) async {
    if (dialogFuture == null) return;
    if (Get.isSnackbarOpen == true) {
      Get.closeAllSnackbars();
    }
    final nav = Get.key.currentState;
    if (nav != null && nav.canPop()) {
      nav.pop();
    } else {
      Get.back();
    }
    try {
      await dialogFuture;
    } catch (_) {
      // Already dismissed
    }
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }

  /// Pops every open Get dialog (guarded)
  void _closeAllDialogs() {
    var guard = 0;
    while (Get.isDialogOpen == true && guard < 8) {
      Get.back();
      guard++;
    }
  }

  // Scan barcode
  Future<void> scanBarcode() async {
    debugPrint('--- [NewMixController] Session Start: Scan Barcode Flow ---');
    try {
      final result = await Get.to(() => const BarcodeScannerScreen());

      if (result != null && result is String) {
        debugPrint('--- [NewMixController] Barcode Captured: $result ---');
        searchQuery.value = result;

        final RxString statusMessage = 'Searching products...'.obs;
        final RxBool isError = false.obs;

        final Future<dynamic> searchDialogFuture = Get.dialog<dynamic>(
          AlertDialog(
            content: Obx(
              () => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isError.value &&
                      !statusMessage.value.toLowerCase().contains('found'))
                    const CircularProgressIndicator(),
                  if (!isError.value &&
                      statusMessage.value.toLowerCase().contains('found'))
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 40,
                    ),
                  const SizedBox(height: 20),
                  Text(
                    statusMessage.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isError.value ? Colors.red : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
          barrierDismissible: false,
        );

        try {
          final response = await ApiServices.postData(
            ApiEndpoints.scanBarcode,
            {'barcode': result},
          );

          if (response != null && response.success && response.data != null) {
            final data = response.data;
            if (data['found_in_db'] == true || data['product'] != null) {
              final productData = data['product'];
              if (productData != null && productData['name'] != null) {
                statusMessage.value = 'Product found!';
                await Future.delayed(const Duration(seconds: 1));
                await _closeSearchDialogAndWait(searchDialogFuture);

                final mappedProductData = {
                  'id': productData['id'],
                  'product_id': productData['id'],
                  'product_name': productData['name'],
                  'product_image': productData['image_url'],
                  'market_price': productData['market_price']?.toString(),
                  'user_price': productData['user_price']?.toString(),
                  'current_weight_grams':
                      productData['current_weight_grams']?.toString() ?? '0',
                  'is_available': true,
                  'scanned_at': DateTime.now().toIso8601String(),
                  'api_data': productData['api_data'],
                };

                final scannedProduct =
                    InventoryProduct.fromJson(mappedProductData);

                final existingIndex = inventoryProducts.indexWhere(
                  (p) => p.id == scannedProduct.id,
                );
                if (existingIndex == -1) {
                  inventoryProducts.insert(0, scannedProduct);
                }

                Get.snackbar(
                  'Product Found',
                  '${scannedProduct.productName} added to inventory',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green.shade400,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 2),
                );
              } else {
                await _closeSearchDialogAndWait(searchDialogFuture);
                await _showScanFailedDialog();
              }
            } else {
              await _closeSearchDialogAndWait(searchDialogFuture);
              await _showScanFailedDialog();
            }
          } else {
            await _closeSearchDialogAndWait(searchDialogFuture);
            await _showScanFailedDialog();
          }
        } catch (e) {
          debugPrint('--- [NewMixController] Error scanning barcode API: $e ---');
          await _closeSearchDialogAndWait(searchDialogFuture);
          await _showScanFailedDialog();
        }
      }
    } catch (e) {
      debugPrint('--- [NewMixController] Error opening scanner: $e ---');
      Get.snackbar(
        'Error',
        'Failed to open scanner: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
    }
  }

  /// Shared UX for barcode scan issues
  Future<void> _showBarcodeResultDialog({
    required String title,
    required String message,
    IconData icon = Icons.qr_code_scanner_rounded,
    Color? iconAccent,
  }) async {
    final accent = iconAccent ?? Colors.orange.shade800;
    final result = await Get.dialog<String>(
      Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(22.w, 24.h, 22.w, 18.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 36.sp, color: accent),
              ),
              SizedBox(height: 18.h),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  height: 1.45,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: 22.h),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Get.back(result: 'manual'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Add manually',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Get.back(result: 'retry'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryColor,
                    side: BorderSide(
                      color: AppColors.primaryColor.withValues(alpha: 0.45),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 13.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Scan again',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              TextButton(
                onPressed: () => Get.back(),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade600,
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                ),
                child: Text(
                  'Not now',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.45),
    );

    if (result == 'manual') {
      _closeAllDialogs();
      await Future<void>.delayed(Duration.zero);
      await Get.to(() => const AddManualProductScreen());
    } else if (result == 'retry') {
      _closeAllDialogs();
      await Future<void>.delayed(Duration.zero);
      await scanBarcode();
    }
  }

  Future<void> _showInvalidProductDialog() async {
    await _showBarcodeResultDialog(
      title: 'Incomplete product',
      message:
          'We couldn\'t use this product\'s details. Add it yourself or try scanning again.',
      icon: Icons.warning_amber_rounded,
      iconAccent: Colors.amber.shade800,
    );
  }

  Future<void> _showScanFailedDialog() async {
    await _showBarcodeResultDialog(
      title: 'Product not found',
      message:
          'This barcode isn\'t in your inventory yet. Add the product manually or try another scan.',
    );
  }

  // Add Manual Product
  Future<void> addManualProduct(Map<String, dynamic> data, File image) async {
    debugPrint(
      '--- [NewMixController] Session Start: Manual Product Entry ---',
    );
    debugPrint('--- [NewMixController] Data: $data ---');
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final Map<String, String> fields = data.map(
        (key, value) => MapEntry(key, value.toString()),
      );

      final List<http.MultipartFile> files = [];
      files.add(await http.MultipartFile.fromPath('image', image.path));

      final response = await ApiServices.postMultipartData(
        ApiEndpoints.manualProductEntry,
        fields,
        files,
      );

      Get.back(); // Close loading dialog

      if (response != null &&
          (response.success ||
              ApiResponse.isSuccessfulHttpStatus(response.statusCode))) {
        Get.back(); // Close manual add screen
        Get.snackbar(
          'Success',
          'Product added to inventory',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        await fetchInventory();
      } else {
        Get.snackbar(
          'Error',
          response?.message ?? 'Failed to add product',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('--- [NewMixController] Error adding manual product: $e ---');
      Get.back();
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Update Product
  Future<InventoryProduct?> updateScannedProduct(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final response = await ApiServices.updateData(
        '${ApiEndpoints.updateScannedProduct}$id/',
        data,
      );

      Get.back(); // Close loading dialog

      if (response != null && response.success) {
        await fetchInventory();
        Get.snackbar(
          'Success',
          'Product updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return inventoryProducts.firstWhereOrNull((p) => p.id.toString() == id);
      } else {
        Get.snackbar(
          'Error',
          response?.message ?? 'Failed to update product',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return null;
      }
    } catch (e) {
      debugPrint('--- [NewMixController] Error updating product: $e ---');
      Get.back();
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }
  }

  // Search products
  void searchProducts(String query) {
    searchQuery.value = query;
  }

  // Assign to client
  void assignToClient(ClientModel client) {
    selectedClientId.value = client.id;
    selectedClient.value = client;
    Get.snackbar(
      'Assigned',
      'Mix assigned to ${client.name}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade400,
      colorText: Colors.white,
    );
  }

  // Delete Mix — returns true on success, false otherwise.
  Future<bool> deleteMix(int mixId) async {
    return deleteMixById(mixId);
  }

  // Assign Client API
  Future<bool> assignClientToMix(int mixId, int clientId) async {
    try {
      final url = '${ApiEndpoints.mixes}$mixId/assign-client/';
      final body = {"client_id": clientId};

      final token = await SharedprefHelper.getString(SharedprefHelper().token);
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      debugPrint('Making POST request to: $url');
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      debugPrint(
        'Assign Client Response: ${response.statusCode} ${response.body}',
      );

      if (ApiResponse.isSuccessfulHttpStatus(response.statusCode)) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error assignClient: $e');
      return false;
    }
  }

  // ── Original-weight cache ───────────────────────────────────────────────

  /// Persist [weight] as the original weight for [productId].
  static Future<void> saveOriginalWeight(int productId, double weight) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          '$kOrigWeightPrefix$productId', weight.toStringAsFixed(4));
    } catch (e) {
      debugPrint('[NewMixController] saveOriginalWeight error: $e');
    }
  }

  /// Return the cached original weight for [productId], or null if unknown.
  static Future<double?> loadOriginalWeight(int productId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString('$kOrigWeightPrefix$productId');
      return stored != null ? double.tryParse(stored) : null;
    } catch (e) {
      debugPrint('[NewMixController] loadOriginalWeight error: $e');
      return null;
    }
  }

  // Reset mix
  void resetMix() {
    currentStep.value = 1;
    currentBowl.value = null;
    marketPrice.value = 0.0;
    costPer100g.value = 0.0;
    currentBowlGrams.value = 0;
    mixItems.clear();
    totalMixCost.value = 0.0;
    clientCharge.value = 20.0;
    profit.value = 0.0;
    selectedClientId.value = '';
    selectedClient.value = null;
    isAddingToExistingBowl.value = false;

    // New flow state reset
    selectedServiceType.value = null;
    serviceDate.value = null;
    bowls.clear();
    currentBowlIndex.value = 0;
    isSubmitting.value = false;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LEGACY DUMMY METHODS (To fix compilation errors in old obsolete screens)
  // ═══════════════════════════════════════════════════════════════════════════
  double calculateUsageCost(double grams) => 0.0;
  void addGramsToCurrentBowl(double grams) {}
  void addAnotherBowl() {}
  void continueToSummary() {}
  void updateClientCharge(double charge) {}
  void saveMix() {}
  void setQuickCharge(double amount) {}
  void showBowlDetailsSheet() {}
  void openAddToBowlSheet(dynamic product) {}
  void continueToPricing() {}

  void confirmAddToBowl(
    InventoryProduct product,
    String name,
    double price,
    double weight,
  ) {}
}

// Bowl product model for recent bowls (legacy - kept for backward compat)
class BowlProduct {
  final String name;
  final double pricePerGram;
  final double? originalWeight;

  BowlProduct({
    required this.name,
    required this.pricePerGram,
    this.originalWeight,
  });

  BowlProduct copyWith({
    String? name,
    double? pricePerGram,
    double? originalWeight,
  }) {
    return BowlProduct(
      name: name ?? this.name,
      pricePerGram: pricePerGram ?? this.pricePerGram,
      originalWeight: originalWeight ?? this.originalWeight,
    );
  }
}
