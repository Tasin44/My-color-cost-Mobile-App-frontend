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
import 'package:color_os/app/views/screens/newmix/barcode_scanner_screen.dart';
import 'package:color_os/app/models/inventory_product_model.dart';
import 'package:color_os/app/views/screens/newmix/steps/mix_summary_screen.dart';
import 'package:color_os/app/views/screens/newmix/steps/step5_pricing_screen.dart';
import 'package:color_os/app/views/screens/newmix/widgets/add_to_bowl_sheet.dart';
import 'package:color_os/app/views/screens/newmix/steps/step2_bowl_details_screen.dart';
import 'package:color_os/app/views/screens/newmix/product_list_screen.dart';
import 'package:color_os/app/core/constant/app_textstyle.dart';
import 'package:color_os/app/core/constant/themes/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:convert';
import 'package:color_os/app/core/helper/sharedpref_helper.dart';

/// SharedPreferences key prefix for persisted original weights.
/// Exported so other screens can read the cache directly when needed.
const String kOrigWeightPrefix = 'product_orig_weight_';

class NewMixController extends GetxController {
  // Observable variables
  final RxInt currentStep = 1.obs;
  final RxInt totalSteps = 5.obs;
  final RxList<MixProduct> selectedProducts = <MixProduct>[].obs;
  final searchController = TextEditingController();
  final RxString searchQuery = ''.obs;

  // Loading state for mix creation check
  final RxBool isCheckingStatus = false.obs;

  // New Mix Flow Variables
  final Rx<BowlProduct?> currentBowl = Rx<BowlProduct?>(null);
  final RxDouble marketPrice = 0.0.obs;
  final RxDouble costPer100g = 0.0.obs;
  final RxDouble currentBowlGrams = 0.0.obs;
  final RxList<BowlMixItem> mixItems = <BowlMixItem>[].obs;
  final RxDouble totalMixCost = 0.0.obs;
  final RxDouble clientCharge = 20.0.obs;
  final RxDouble profit = 0.0.obs;
  final RxString selectedClientId = ''.obs;
  final Rx<ClientModel?> selectedClient = Rx<ClientModel?>(null);

  // True when the user is adding a 2nd+ product from MixSummaryScreen.
  // Tells addGramsToCurrentBowl to pop back instead of pushing a new summary.
  final RxBool isAddingToExistingBowl = false.obs;

  // Progress Message
  final RxString progressMessage = ''.obs;

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
    resetMix(); // Always start clean
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });
    // Check immediately
    // checkMixCreation(); // Disabled to prevent auto-check on HomeTab load. Handled by AddMixCard on tap.
    fetchRecentMixes();
    fetchInventory();
  }

  // Fetch Recent Mixes
  Future<void> fetchRecentMixes() async {
    try {
      isLoadingMixes.value = true;
      final response = await ApiServices.getData(ApiEndpoints.mixes);
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
      final response = await ApiServices.getData(ApiEndpoints.mixes);
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
    /*
    debugPrint(
      '--- [NewMixController] Session Start: Checking Mix Creation ---',
    );
    isCheckingStatus.value = true;
    try {
      debugPrint(
        '--- [NewMixController] API Request: ${ApiEndpoints.checkMixCreation} ---',
      );
      final response = await ApiServices.getData(ApiEndpoints.checkMixCreation);
      debugPrint('--- [NewMixController] API Response: ${response?.data} ---');

      if (response != null && response.success && response.data != null) {
        final data = response.data;
        final bool canCreateMix = data['can_create_mix'] ?? false;
        final bool hasProducts = data['has_products'] ?? false;
        final bool hasClients = data['has_clients'] ?? false;
        final List<dynamic> rawMessages = data['messages'] ?? [];
        final List<String> messages = rawMessages
            .map((e) => e.toString())
            .toList();

        debugPrint(
          '--- [NewMixController] Check Results: CanCreate=$canCreateMix, HasProducts=$hasProducts, HasClients=$hasClients ---',
        );

        if (canCreateMix) {
          debugPrint(
            '--- [NewMixController] Status: User CAN create mix. Proceeding. ---',
          );
          isCheckingStatus.value = false;
          return true; // Allow flow to proceed
        }

        if (!hasClients) {
          debugPrint(
            '--- [NewMixController] Status: Missing Clients. Showing Dialog. ---',
          );

          final String clientMessage = messages.firstWhere(
            (m) => m.toLowerCase().contains('client'),
            orElse: () => 'You need to add a client before creating a mix.',
          );

          Get.dialog(
            AlertDialog(
              title: const Text('No Clients Found'),
              content: Text(clientMessage),
              actions: [
                TextButton(
                  onPressed: () {
                    Get.back();
                    Get.back(); // Close dialog and go back from new mix screen
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    Get.back(); // Close dialog
                    // Navigate to add new client screen
                    await Get.to(() => const AddNewClientScreen());
                    // Check again when user returns
                    checkMixCreation();
                  },
                  child: const Text(
                    'Add Client',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
            barrierDismissible: false,
          );
        } else if (!hasProducts) {
          debugPrint(
            '--- [NewMixController] Status: Missing Products. Showing Dialog. ---',
          );

          final String productMessage = messages.firstWhere(
            (m) => m.toLowerCase().contains('product'),
            orElse: () => 'You need to add products before creating a mix.',
          );

          Get.dialog(
            AlertDialog(
              title: const Text('No Products Found'),
              content: Text(productMessage),
              actions: [
                TextButton(
                  onPressed: () {
                    Get.back();
                    Get.back(); // Close dialog and go back from new mix screen
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    Get.back(); // Close dialog
                    // Call scanBarcode which handles navigation and API calls
                    await scanBarcode();
                    // Check again when user returns
                    checkMixCreation();
                  },
                  child: const Text(
                    'Add Product',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
            barrierDismissible: false,
          );
        }
      } else {
        debugPrint(
          '--- [NewMixController] Check Failed: Invalid Response or Success=False ---',
        );
      }
    } catch (e) {
      debugPrint('--- [NewMixController] Error checking mix creation: $e ---');
    } finally {
      // If we are showing a dialog, we might want to keep loading true or handle it?
      // Actually, if we show dialog, isCheckingStatus should probably be false so UI renders behind it?
      // Or if we want to block UI, keep it true?
      // User wants "instant" check.
      // Let's set it to false so the UI builds (and dialog shows over it),
      // or if we block UI completely, we need a Loading View in the UI.
      // Let's assume we block UI until check is done.
      isCheckingStatus.value = false;
      debugPrint(
        '--- [NewMixController] Session End: Checking Mix Creation ---',
      );
    }
    return false;
    */
  }

  @override
  void onClose() {
    // We avoid disposing these if they might be reused by shared widgets like AddMixCard in HomeTab
    // searchController.dispose();
    // mixTypeController.dispose();
    // serviceTypeController.dispose();
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

  // Submit Bowl Details and Navigate to Product List
  void submitBowlDetails() {
    if (mixTypeController.text.isNotEmpty &&
        serviceTypeController.text.isNotEmpty) {
      Get.back(); // Close BottomSheet

      if (selectedInventoryProduct.value != null) {
        // If a product was already selected from Recent Products, open AddToBowlSheet
        openAddToBowlSheet(selectedInventoryProduct.value!);
      } else {
        // Normal flow: Fetch inventory and go to Product List
        fetchInventory();
        currentStep.value = 1; // Explicitly set to 1
        Get.to(() => const ProductListScreen());
      }
    } else {
      Get.snackbar(
        'Error',
        'Please fill all fields',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Show Bowl Details Bottom Sheet (Centralized)
  void showBowlDetailsSheet() {
    resetMix(); // Ensure fresh start
    Get.bottomSheet(
      Builder(
        builder: (context) {
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.92,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 20.w,
                right: 20.w,
                top: 16.h,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Add Bowl',
                    style: AppTextStyle.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20.h),
                  // Mix Type
                  TextField(
                    controller: mixTypeController,
                    decoration: InputDecoration(
                      labelText: 'Mix Type (Bowl Name)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      prefixIcon: const Icon(Icons.science),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // Service Type
                  TextField(
                    controller: serviceTypeController,
                    decoration: InputDecoration(
                      labelText: 'Service Type',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      prefixIcon: const Icon(Icons.cut),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  // Submit Button
                  ElevatedButton(
                    onPressed: submitBowlDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Continue',
                      style: TextStyle(color: Colors.white, fontSize: 16.sp),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  // Get progress percentage
  double get progressPercentage => currentStep.value / totalSteps.value;

  // Open Add To Bowl Sheet
  void openAddToBowlSheet(InventoryProduct product) {
    Get.bottomSheet(
      AddToBowlSheet(product: product, controller: this),
      isScrollControlled: true,
    );
  }

  // Confirm Add To Bowl (Step 1 -> Step 2)
  void confirmAddToBowl(
    InventoryProduct product,
    String name,
    double price,
    double totalWeight,
  ) {
    Get.back(); // Close sheet

    // Set current bowl data
    currentBowl.value = BowlProduct(
      name: name,
      pricePerGram: totalWeight > 0 ? price / totalWeight : 0.0,
    );

    // Calculate normalized cost per 100g based on total weight of the pack
    // Logic: user enters total price (e.g. 10.00) for a specific total weight (e.g. 500g).
    // So costPer100g = (price / totalWeight) * 100.
    if (totalWeight <= 0) totalWeight = 100.0; // Fallback
    costPer100g.value = (price / totalWeight) * 100;
    
    // Store original weight for precise recalculation if needed
    currentBowl.value = currentBowl.value?.copyWith(originalWeight: totalWeight);

    // Persist the confirmed original weight so future mix sessions for this
    // product always pre-fill the correct value, regardless of what the API
    // returns for current_weight_grams.
    saveOriginalWeight(product.id, totalWeight);

    // Sync name controllers so saveMix() validation always passes.
    if (mixTypeController.text.isEmpty) mixTypeController.text = name;
    if (serviceTypeController.text.isEmpty) serviceTypeController.text = 'Service';

    // Store selected product
    selectedInventoryProduct.value = product;

    // Navigate to Step 2
    currentStep.value = 2;
    Get.to(() => const Step2BowlDetailsScreen());
  }

  // Navigate to next step
  void nextStep() {
    if (currentStep.value < totalSteps.value) {
      currentStep.value++;
    }
  }

  // Navigate to previous step
  void previousStep() {
    if (currentStep.value > 1) {
      currentStep.value--;
    }
  }

  // Add product to mix
  void addProduct(MixProduct product) {
    selectedProducts.add(product);
  }

  // Remove product from mix
  void removeProduct(int index) {
    selectedProducts.removeAt(index);
  }

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
  /// [Get.dialog] returns a [Future] that completes when the dialog is popped — we must await
  /// it; [Get.isDialogOpen] / [Get.back] alone often leave the overlay visible in GetX 4.
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

  /// Pops every open Get dialog (guarded) — use before pushing a full screen so
  /// no overlay blocks the next route (e.g. manual add after “not found”).
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
      // Navigate to barcode scanner screen using Get.to for better compatibility
      final result = await Get.to(() => const BarcodeScannerScreen());

      if (result != null && result is String) {
        debugPrint('--- [NewMixController] Barcode Captured: $result ---');
        searchQuery.value = result;

        // Reactive status for the dialog
        final RxString statusMessage = 'Searching products...'.obs;
        final RxBool isError = false.obs;

        // Show progress dialog — keep the Future from [Get.dialog] so we can await
        // full dismissal (Get.isDialogOpen is unreliable).
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

        // Hit server to check barcode
        try {
          debugPrint(
            '--- [NewMixController] API Request: ${ApiEndpoints.scanBarcode} with barcode=$result ---',
          );
          final response = await ApiServices.postData(
            ApiEndpoints.scanBarcode,
            {'barcode': result},
          );

          debugPrint(
            '--- [NewMixController] API Response: ${response?.data} ---',
          );

          if (response != null && response.success && response.data != null) {
            final data = response.data;
            // Check if product found or we have product data
            if (data['found_in_db'] == true || data['product'] != null) {
              final productData = data['product'];
              if (productData != null) {
                debugPrint(
                  '--- [NewMixController] Product Parsed: ${productData['name']} (ID: ${productData['id']}) ---',
                );

                if (productData['name'] == null) {
                  // Product found but incomplete — close search dialog first, then prompt
                  await _closeSearchDialogAndWait(searchDialogFuture);
                  debugPrint(
                    '--- [NewMixController] Status: Product Name is NULL. Showing Invalid Product Dialog. ---',
                  );
                  await _showInvalidProductDialog();
                } else {
                  // Product found and valid
                  statusMessage.value = 'Product found!';
                  await Future.delayed(const Duration(seconds: 1)); // UX delay
                  await _closeSearchDialogAndWait(searchDialogFuture);

                  debugPrint('--- [NewMixController] Status: Valid Product. ---');

                  // Always map the scanned product to InventoryProduct
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

                  final scannedProduct = InventoryProduct.fromJson(mappedProductData);

                  // Add to inventory list if not already present
                  final existingIndex = inventoryProducts.indexWhere(
                    (p) => p.id == scannedProduct.id,
                  );
                  if (existingIndex == -1) {
                    inventoryProducts.insert(0, scannedProduct);
                  }

                  // Check if we're already in a mix (has items OR bowl name set)
                  final bool isInMixCreation =
                      mixItems.isNotEmpty ||
                      (mixTypeController.text.isNotEmpty &&
                          serviceTypeController.text.isNotEmpty);

                  debugPrint(
                    '--- [NewMixController] isInMixCreation=$isInMixCreation '
                    '(mixItems=${mixItems.length}) ---',
                  );

                  if (isInMixCreation) {
                    // Already in a bowl — add this product directly
                    Get.snackbar(
                      'Product Found',
                      '${scannedProduct.productName} ready to add to bowl',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green.shade400,
                      colorText: Colors.white,
                      duration: const Duration(seconds: 2),
                    );
                    openAddToBowlSheet(scannedProduct);
                  } else {
                    // Fresh start — pre-select the product and show bowl setup sheet.
                    // submitBowlDetails() will open AddToBowlSheet automatically
                    // once the user sets the bowl name.
                    selectedInventoryProduct.value = scannedProduct;
                    showBowlDetailsSheet();
                  }
                }
              } else {
                // Edge case: productData is null despite checks
                debugPrint(
                  '--- [NewMixController] Status: productData null. Not-found flow. ---',
                );
                await _closeSearchDialogAndWait(searchDialogFuture);
                await _showScanFailedDialog();
              }
            } else {
              // Not found in DB — never reuse the search dialog for “not found” text
              // (it has no buttons and stacks under the real prompt).
              debugPrint(
                '--- [NewMixController] Status: Product Not Found in DB. Showing Failed Dialog. ---',
              );
              await _closeSearchDialogAndWait(searchDialogFuture);
              await _showScanFailedDialog();
            }
          } else {
            // API returned failure
            debugPrint(
              '--- [NewMixController] Status: API Success=False or No Data. Showing Failed Dialog. ---',
            );
            await _closeSearchDialogAndWait(searchDialogFuture);
            await _showScanFailedDialog();
          }
        } catch (e) {
          debugPrint(
            '--- [NewMixController] Error scanning barcode API: $e ---',
          );
          await _closeSearchDialogAndWait(searchDialogFuture);
          await _showScanFailedDialog();
        }
      } else {
        debugPrint('--- [NewMixController] Scan Cancelled or No Result ---');
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

  /// Shared UX for barcode scan issues: dismissible (tap outside / back), clear CTAs.
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
      // Ensure no stacked dialogs (e.g. stray search overlay) block the form.
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

      debugPrint(
        '--- [NewMixController] API Request: ${ApiEndpoints.manualProductEntry} (Multipart) ---',
      );
      final response = await ApiServices.postMultipartData(
        ApiEndpoints.manualProductEntry,
        fields,
        files,
      );
      debugPrint('--- [NewMixController] API Response: ${response?.data} ---');

      Get.back(); // Close loading dialog

      if (response != null &&
          (response.success ||
              ApiResponse.isSuccessfulHttpStatus(response.statusCode))) {
        debugPrint(
          '--- [NewMixController] Status: Product Added Successfully ---',
        );
        Get.back(); // Close manual add screen
        Get.snackbar(
          'Success',
          'Product added — now add it to your bowl',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        // Refresh inventory so the new product appears in the list immediately
        await fetchInventory();

        // Always continue to the bowl flow — this screen is only reached from a mix session.
        if (inventoryProducts.isNotEmpty) {
          // Find the product by barcode or fall back to most recently added
          final barcode = data['barcode']?.toString();
          InventoryProduct? newProduct;

          if (barcode != null && barcode.isNotEmpty) {
            newProduct = inventoryProducts.firstWhereOrNull(
              (p) => p.barcode == barcode,
            );
          }

          // Fallback: use the most recently added product
          newProduct ??= inventoryProducts.first;

          openAddToBowlSheet(newProduct);
        }
      } else {
        debugPrint(
          '--- [NewMixController] Status: Failed to Add Product. Message: ${response?.message} ---',
        );
        Get.snackbar(
          'Error',
          response?.message ?? 'Failed to add product',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('--- [NewMixController] Error adding manual product: $e ---');
      Get.back(); // Close loading dialog
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      debugPrint(
        '--- [NewMixController] Session End: Manual Product Entry ---',
      );
    }
  }

  // Update Product
  Future<InventoryProduct?> updateScannedProduct(
    String id,
    Map<String, dynamic> data,
  ) async {
    debugPrint(
      '--- [NewMixController] Session Start: Update Product (ID: $id) ---',
    );
    debugPrint('--- [NewMixController] Update Data: $data ---');
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      debugPrint(
        '--- [NewMixController] API Request: ${ApiEndpoints.updateScannedProduct}$id/ ---',
      );
      final response = await ApiServices.updateData(
        '${ApiEndpoints.updateScannedProduct}$id/',
        data,
      );
      debugPrint('--- [NewMixController] API Response: ${response?.data} ---');

      Get.back(); // Close loading dialog

      if (response != null && response.success) {
        debugPrint(
          '--- [NewMixController] Status: Product Updated Successfully ---',
        );

        // Refresh inventory to include the updated product
        await fetchInventory();

        Get.snackbar(
          'Success',
          'Product updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return inventoryProducts.firstWhereOrNull((p) => p.id.toString() == id);
      } else {
        debugPrint(
          '--- [NewMixController] Status: Failed to Update Product. Message: ${response?.message} ---',
        );
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
      Get.back(); // Close loading dialog
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    } finally {
      debugPrint('--- [NewMixController] Session End: Update Product ---');
    }
  }

  // Select bowl from recent list
  void selectBowl(MixModel mix) {
    // Navigate to bowl details or add to mix
    Get.snackbar(
      'Selected',
      '${mix.mixName} selected',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade400,
      colorText: Colors.white,
    );
  }

  // Search products
  void searchProducts(String query) {
    searchQuery.value = query;
    // In real app, this would search database
  }

  // Start new mix flow
  void startNewMix(BowlProduct bowl, double market, double cost) {
    currentBowl.value = bowl;
    marketPrice.value = market;
    costPer100g.value = cost;
    currentStep.value = 2;
    // Use Future.delayed to ensure navigation happens after bottom sheet closes
    Future.delayed(const Duration(milliseconds: 100), () {
      Get.toNamed('/add-grams');
    });
  }

  // Calculate usage cost based on grams
  double calculateUsageCost(double grams) {
    if (grams == 0) return 0.0;
    
    // Backend Logic Alignment:
    // price_per_gram = user_price / original_weight_grams
    // each_item_cost = (price_per_gram * used_weight).rounded_to_2_decimal_places()
    
    // We get costPer100g which is (price/weight)*100
    // So pricePerGram = costPer100g / 100
    double pricePerGram = costPer100g.value / 100;
    double cost = pricePerGram * grams;
    
    // Round to 2 decimal places (quantize Decimal('0.01'))
    return (cost * 100).roundToDouble() / 100;
  }

  // Add grams to current bowl and move to step 3
  void addGramsToCurrentBowl(double grams) {
    final bowl = currentBowl.value;
    if (bowl == null) {
      Get.snackbar(
        'Error',
        'No bowl selected',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final usageCost = calculateUsageCost(grams);
    final item = BowlMixItem(
      bowlName: bowl.name,
      grams: grams,
      cost: usageCost,
      productId: selectedInventoryProduct.value?.id,
      originalWeight: bowl.originalWeight,
      userPrice: selectedInventoryProduct.value?.userPrice != null
          ? double.tryParse(selectedInventoryProduct.value!.userPrice!)
          : null,
      marketPrice: selectedInventoryProduct.value?.marketPrice != null
          ? double.tryParse(selectedInventoryProduct.value!.marketPrice!)
          : null,
    );

    mixItems.add(item);
    calculateTotalCost(); // CRITICAL: Update total cost before summary
    currentBowlGrams.value = grams;
    currentStep.value = 3;

    if (isAddingToExistingBowl.value) {
      // Pop ProductListScreen + Step2BowlDetailsScreen in one call,
      // landing cleanly back on the existing MixSummaryScreen.
      isAddingToExistingBowl.value = false;
      Get.close(2);
    } else {
      Get.to(() => const MixSummaryScreen());
    }
  }

  // Add another bowl (go back to step 1)
  void addAnotherBowl() {
    currentBowl.value = null;
    currentBowlGrams.value = 0;
    // Navigate to bowl selection instead of just going back
    Get.toNamed('/all-recent-bowls');
  }

  // Continue to summary
  void continueToSummary() {
    currentStep.value = 4;
    calculateTotalCost();
    Get.to(() => const MixSummaryScreen());
  }

  // Continue to pricing (Step 4 -> Step 5)
  void continueToPricing() {
    currentStep.value = 5;
    calculateProfit(); // Ensure profit is calculated initially
    Get.to(() => const Step5PricingScreen());
  }

  // Calculate total mix cost
  void calculateTotalCost() {
    totalMixCost.value = mixItems.fold(0.0, (sum, item) => sum + item.cost);
    calculateProfit();
  }

  // Calculate profit
  void calculateProfit() {
    profit.value = clientCharge.value - totalMixCost.value;
  }

  // Update client charge
  void updateClientCharge(double charge) {
    clientCharge.value = charge;
    calculateProfit();
  }

  // Save Mix (Final)
  Future<void> saveMix() async {
    // Validate inputs
    if (mixTypeController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Bowl name is missing',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    if (serviceTypeController.text.isEmpty) serviceTypeController.text = 'Service';

    if (mixItems.isEmpty) {
      Get.snackbar(
        'Error',
        'No products in the mix',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isCheckingStatus.value = true;
    progressMessage.value = 'Creating mix...';

    // Custom Progress Dialog
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
      debugPrint('--- [NewMixController] saveMix: Calling createMix ---');
      // 1. Create Mix
      final mixId = await createMix();
      debugPrint('--- [NewMixController] saveMix: mixId=$mixId ---');

      if (mixId != null) {
        // 2. Assign Client if selected
        debugPrint(
          '--- [NewMixController] saveMix: selectedClientId=${selectedClientId.value} ---',
        );
        if (selectedClientId.value.isNotEmpty) {
          progressMessage.value = 'Assigning to client...';
          debugPrint(
            '--- [NewMixController] saveMix: Calling assignClientToMix ---',
          );
          final clientIdInt = int.tryParse(selectedClientId.value);
          if (clientIdInt == null) {
            debugPrint(
              '--- [NewMixController] saveMix: Client ID "${selectedClientId.value}" is not a valid integer, skipping assignment ---',
            );
            _closeBlockingProgressDialog();
            Get.snackbar(
              'Mix Saved',
              'Mix created but client could not be assigned (invalid client ID).',
              backgroundColor: Colors.orange,
              colorText: Colors.white,
            );
            Get.offAll(() => MainBaseScreen());
            return;
          }
          final assigned = await assignClientToMix(mixId, clientIdInt);
          debugPrint(
            '--- [NewMixController] saveMix: assignClientToMix result=$assigned ---',
          );
          if (!assigned) {
            debugPrint('--- [NewMixController] saveMix: Assignment failed ---');
            _closeBlockingProgressDialog();
            // Use snackbar to warn but still success on mix
            Get.snackbar(
              'Warning',
              'Mix created but client assignment failed',
              backgroundColor: Colors.orange,
              colorText: Colors.white,
            );
            Get.offAll(() => MainBaseScreen());
            return;
          }
        }

        progressMessage.value = 'Finalizing...';
        await Future.delayed(
          const Duration(milliseconds: 500),
        ); // Good UX pause

        debugPrint(
          '--- [NewMixController] saveMix: Success! Resetting and Navigating... ---',
        );
        // 1. Close loading dialog
        _closeBlockingProgressDialog();

        // 2. Show Success Snackbar
        Get.snackbar(
          'Success',
          'Mix saved successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );

        // 3. Navigate to Dashboard (offAll)
        Get.offAll(() => MainBaseScreen());

        // 4. Delay reset slightly to allow current build cycle/navigation to settle
        // This prevents "Null check operator" crashes in Obx widgets still watching the controller
        Future.delayed(const Duration(milliseconds: 300), () {
          debugPrint('--- [NewMixController] saveMix: Resetting state ---');
          resetMix();
        });

        debugPrint('--- [NewMixController] saveMix: Done ---');
      } else {
        debugPrint('--- [NewMixController] saveMix: mixId is null ---');
        _closeBlockingProgressDialog();
        // Error snackbar already shown in createMix
      }
    } catch (e, stack) {
      _closeBlockingProgressDialog();
      debugPrint('Error saving mix: $e');
      debugPrint('Stack trace: $stack');

      // Show Error Dialog as requested
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      Get.dialog(
        AlertDialog(
          title: const Text('Failed to Create Mix'),
          content: Text(errorMessage),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('OK')),
          ],
        ),
      );
    } finally {
      isCheckingStatus.value = false;
    }
  }

  // Create Mix API
  Future<int?> createMix() async {
    try {
      final productsList = mixItems.map((item) {
        return {
          "user_product_id": item.productId,
          "used_weight": item.grams.toDouble(),
          "user_price": item.userPrice ?? 0.0,
          "market_price": item.marketPrice ?? 0.0,
        };
      }).toList();

      final body = {
        "mix_name": mixTypeController.text,
        "service_type": serviceTypeController.text,
        "charged_amount": clientCharge.value,
        "is_bleach_timer_on": false,
        "bleach_timer_start_time": DateTime.now().toIso8601String(),
        "bleach_timer_duration": "0 sec",
        "products": productsList,
      };

      final response = await ApiServices.postData(ApiEndpoints.mixes, body);

      if (response != null &&
          (response.success ||
              ApiResponse.isSuccessfulHttpStatus(response.statusCode))) {
        // Handle response structure provided by user
        // {"success": true, "data": {"id": 20, ...}}
        // ApiResponse puts the outer "data" field into response.data
        if (response.data != null) {
          if (response.data is Map) {
            final dataMap = response.data as Map;
            // Check for direct ID access (common in ApiResponse unwrapping)
            if (dataMap.containsKey('id')) {
              return dataMap['id'];
            }
            // Check for nested data object (just in case)
            if (dataMap.containsKey('data') && dataMap['data'] is Map) {
              final innerData = dataMap['data'] as Map;
              if (innerData.containsKey('id')) {
                return innerData['id'];
              }
            }
          }
        }

        // Fallback for ID if structure was different
        if (response.data != null && response.data['id'] != null) {
          return response.data['id'];
        }

        // If ID not found but success is true
        return null;
      } else {
        // Parse error message (logic retained)
        String errorMessage = response?.message ?? 'Failed to create mix';
        if (response?.data != null && response!.data['data'] != null) {
          final errorData = response.data['data'];
          if (errorData is Map && errorData.containsKey('products')) {
            try {
              final products = errorData['products'];
              if (products is List) {
                for (var p in products) {
                  if (p is Map) {
                    for (var val in p.values) {
                      if (val is List && val.isNotEmpty) {
                        errorMessage = val.first.toString();
                        break;
                      }
                    }
                  }
                  if (errorMessage != response.message) break;
                }
              }
            } catch (_) {}
          }
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      debugPrint('Error createMix: $e');
      rethrow;
    }
  }

  // Assign Client API
  // Assign Client API
  Future<bool> assignClientToMix(int mixId, int clientId) async {
    try {
      final url = '${ApiEndpoints.mixes}$mixId/assign-client/';
      final body = {"client_id": clientId};

      // Use direct http call to avoid ApiResponse parsing issues since this endpoint
      // returns a different structure: {"message": "...", "mix_id": ..., "client_id": ...}
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

  // Set quick charge amount
  void setQuickCharge(double amount) {
    clientCharge.value = amount;
    calculateProfit();
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
    try {
      final url = '${ApiEndpoints.mixes}$mixId/';
      debugPrint('--- [NewMixController] deleteMix: API Request $url ---');

      final response = await ApiServices.deleteData(url);
      debugPrint(
        '--- [NewMixController] deleteMix: API Response ${response?.data} ---',
      );

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

  // ── Original-weight cache ───────────────────────────────────────────────
  // The original (full-bottle) weight for a product is stored once in
  // SharedPreferences so that price-per-gram stays constant even after stock
  // has been partially consumed.  It is written on every successful bowl
  // confirmation so that edits by the user are always respected.

  /// Persist [weight] as the original weight for [productId].
  static Future<void> saveOriginalWeight(int productId, double weight) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$kOrigWeightPrefix$productId', weight.toStringAsFixed(4));
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
  }
}

// Bowl product model for recent bowls
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
