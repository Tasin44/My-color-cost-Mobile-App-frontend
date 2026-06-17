import 'package:color_os/app/controllers/new_mix_controller.dart';
import 'package:color_os/app/controllers/offline_mix_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:color_os/app/core/constant/app_textstyle.dart';
import 'package:color_os/app/core/constant/themes/app_colors.dart';
import 'package:color_os/app/models/inventory_product_model.dart';
import 'package:color_os/app/views/screens/main_base_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

// ─────────────────────────────────────────────────────────────
// Main Screen
// ─────────────────────────────────────────────────────────────
class OfflineMixCalculatorScreen extends StatelessWidget {
  const OfflineMixCalculatorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OfflineMixController());
    final inventoryCtrl = Get.isRegistered<NewMixController>()
        ? Get.find<NewMixController>()
        : Get.put(NewMixController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
        ),
        centerTitle: true,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Mix Calculator',
              style: AppTextStyle.titleLarge.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.w700,
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 2.h),
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                'OFFLINE  ·  No internet needed',
                style: TextStyle(
                  fontSize: 9.sp,
                  color: Colors.orange.shade800,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Obx(
            () => controller.items.isNotEmpty
                ? TextButton(
                    onPressed: () => _confirmClear(controller),
                    child: Text(
                      'Clear',
                      style: TextStyle(
                        color: Colors.red.shade400,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Gradient summary header
          Obx(
            () => _BowlSummaryCard(
              totalCost: controller.totalCost,
              itemCount: controller.items.length,
            ),
          ),
          // Item list / empty state
          Expanded(
            child: Obx(() {
              if (controller.items.isEmpty) {
                return _EmptyBowlState(
                  onAdd: () => _openAddSheet(controller, inventoryCtrl),
                );
              }
              return ListView.separated(
                padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 20.h),
                itemCount: controller.items.length,
                separatorBuilder: (_, __) => SizedBox(height: 10.h),
                itemBuilder: (_, i) {
                  final item = controller.items[i];
                  return _MixItemCard(
                    item: item,
                    onDelete: () => controller.removeItem(item.localId),
                    onEditGrams: (v) =>
                        controller.updateItemGrams(item.localId, v),
                  );
                },
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: Obx(
        () => _BottomBar(
          hasItems: controller.items.isNotEmpty,
          onAdd: () => _openAddSheet(controller, inventoryCtrl),
          onSave: () => _openSaveSheet(controller),
        ),
      ),
    );
  }

  void _confirmClear(OfflineMixController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Clear Bowl'),
        content: const Text('Remove all products from your mix?'),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.reset();
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _openAddSheet(
    OfflineMixController controller,
    NewMixController inventoryCtrl,
  ) {
    Get.bottomSheet(
      _AddProductSheet(
        offlineCtrl: controller,
        inventoryProducts: inventoryCtrl.inventoryProducts.toList(),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _openSaveSheet(OfflineMixController controller) {
    Get.bottomSheet(
      _SaveMixSheet(controller: controller),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Bowl summary header card
// ─────────────────────────────────────────────────────────────
class _BowlSummaryCard extends StatelessWidget {
  final double totalCost;
  final int itemCount;

  const _BowlSummaryCard({
    required this.totalCost,
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
      decoration: BoxDecoration(
        gradient: AppColors.buttonGradient,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.30),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.20),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.science_rounded,
              color: Colors.white,
              size: 28.sp,
            ),
          ),
          SizedBox(width: 16.w),
          // Text info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Mix Cost',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.80),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '\$${totalCost.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  itemCount == 0
                      ? 'No products yet'
                      : '$itemCount product${itemCount == 1 ? '' : 's'} in bowl',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          // Formula hint
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _formulaChip('Price ÷ Weight × Grams'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _formulaChip(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.90),
          fontSize: 9.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Individual mix item card
// ─────────────────────────────────────────────────────────────
class _MixItemCard extends StatelessWidget {
  final OfflineMixItem item;
  final VoidCallback onDelete;
  final ValueChanged<double> onEditGrams;

  const _MixItemCard({
    required this.item,
    required this.onDelete,
    required this.onEditGrams,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(item.localId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Icon(Icons.delete_outline, color: Colors.white, size: 26.sp),
      ),
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: () => _showEditGramsDialog(context),
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border(
              left: BorderSide(color: AppColors.primaryColor, width: 4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Product icon
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  item.canSaveToServer
                      ? Icons.inventory_2_outlined
                      : Icons.edit_note_outlined,
                  color: item.canSaveToServer
                      ? AppColors.primaryColor
                      : Colors.orange.shade600,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              // Product info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.productName,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14.sp,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!item.canSaveToServer)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              'Manual',
                              style: TextStyle(
                                fontSize: 9.sp,
                                color: Colors.orange.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        _pill(
                          '${item.usedGrams.toStringAsFixed(1)}g used',
                          Colors.blue,
                        ),
                        SizedBox(width: 6.w),
                        _pill(
                          '\$${item.pricePerGram.toStringAsFixed(3)}/g',
                          Colors.grey.shade600,
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.edit,
                          size: 12.sp,
                          color: Colors.grey.shade400,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              // Cost + delete
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${item.cost.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16.sp,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  GestureDetector(
                    onTap: onDelete,
                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.grey.shade400,
                      size: 20.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pill(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.sp,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _showEditGramsDialog(BuildContext context) {
    final tc = TextEditingController(
      text: item.usedGrams.toStringAsFixed(2),
    );
    Get.dialog(
      AlertDialog(
        title: Text(item.productName,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Update grams used',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13.sp),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: tc,
              autofocus: true,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                suffixText: 'g',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final v = double.tryParse(tc.text) ?? 0.0;
              if (v > 0) {
                onEditGrams(v);
                Get.back();
              } else {
                Get.snackbar('Error', 'Enter a valid amount');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
            ),
            child: const Text('Update', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────
class _EmptyBowlState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyBowlState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.science_outlined,
              size: 72.sp,
              color: Colors.grey.shade300,
            ),
            SizedBox(height: 16.h),
            Text(
              'Your bowl is empty',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Add products to start calculating your mix cost — no internet required.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey.shade500,
                height: 1.5,
              ),
            ),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                label: Text(
                  'Add Product to Bowl',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Bottom action bar
// ─────────────────────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  final bool hasItems;
  final VoidCallback onAdd;
  final VoidCallback onSave;

  const _BottomBar({
    required this.hasItems,
    required this.onAdd,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, bottomPad + 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onAdd,
              icon: Icon(Icons.add, size: 18.sp),
              label: Text(
                hasItems ? 'Add More' : 'Add Product',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                side: BorderSide(color: AppColors.primaryColor),
                foregroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
          if (hasItems) ...[
            SizedBox(width: 12.w),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: onSave,
                icon: Icon(
                  Icons.cloud_upload_outlined,
                  color: Colors.white,
                  size: 18.sp,
                ),
                label: Text(
                  'Save Mix',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Add Product bottom sheet
// ─────────────────────────────────────────────────────────────
enum _InventoryPhase { productList, gramsInput }

class _AddProductSheet extends StatefulWidget {
  final OfflineMixController offlineCtrl;
  final List<InventoryProduct> inventoryProducts;

  const _AddProductSheet({
    required this.offlineCtrl,
    required this.inventoryProducts,
  });

  @override
  State<_AddProductSheet> createState() => _AddProductSheetState();
}

class _AddProductSheetState extends State<_AddProductSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Inventory tab state
  _InventoryPhase _phase = _InventoryPhase.productList;
  InventoryProduct? _selectedProduct;
  String _searchQuery = '';
  final _invGramsCtrl = TextEditingController();
  final _invPriceCtrl = TextEditingController();
  final _invWeightCtrl = TextEditingController();
  // True while the async cache-check is in-flight for the selected product.
  // The "Add to Bowl" button is disabled until this is false.
  bool _invWeightLoading = false;

  // Manual tab state
  final _manNameCtrl = TextEditingController();
  final _manPriceCtrl = TextEditingController();
  final _manWeightCtrl = TextEditingController();
  final _manGramsCtrl = TextEditingController();

  double _previewCost = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _invGramsCtrl.dispose();
    _invPriceCtrl.dispose();
    _invWeightCtrl.dispose();
    _manNameCtrl.dispose();
    _manPriceCtrl.dispose();
    _manWeightCtrl.dispose();
    _manGramsCtrl.dispose();
    super.dispose();
  }

  void _updateInvPreview() {
    final price = double.tryParse(_invPriceCtrl.text) ?? 0.0;
    final weight = double.tryParse(_invWeightCtrl.text) ?? 0.0;
    final grams = double.tryParse(_invGramsCtrl.text) ?? 0.0;
    final ppg = weight > 0 ? price / weight : 0.0;
    setState(() => _previewCost = (ppg * grams * 100).roundToDouble() / 100);
  }

  void _updateManPreview() {
    final price = double.tryParse(_manPriceCtrl.text) ?? 0.0;
    final weight = double.tryParse(_manWeightCtrl.text) ?? 0.0;
    final grams = double.tryParse(_manGramsCtrl.text) ?? 0.0;
    final ppg = weight > 0 ? price / weight : 0.0;
    setState(() => _previewCost = (ppg * grams * 100).roundToDouble() / 100);
  }

  void _selectProduct(InventoryProduct p) {
    setState(() {
      _selectedProduct = p;
      _phase = _InventoryPhase.gramsInput;
      _invPriceCtrl.text = p.userPrice ?? p.marketPrice ?? '';
      // Start weight empty — the async cache load below will fill it in.
      // We must NOT seed from the API here because the API's
      // original_weight_grams may equal the current (reduced) stock,
      // which would corrupt the price-per-gram calculation.
      _invWeightCtrl.clear();
      _invGramsCtrl.clear();
      _previewCost = 0.0;
      _invWeightLoading = true; // block "Add to Bowl" until cache resolved
    });
    _loadCachedWeightForProduct(p);
  }

  /// Loads the cached original weight from SharedPreferences.
  ///
  /// * Cache hit  → use it (user-confirmed truth).
  /// * Cache miss → fall back to the API value (may still be null/empty).
  /// * Always sets [_invWeightLoading] = false when done.
  Future<void> _loadCachedWeightForProduct(InventoryProduct p) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString('$kOrigWeightPrefix${p.id}');
      if (!mounted) return;
      setState(() {
        if (stored != null) {
          _invWeightCtrl.text = stored;
        } else {
          // No cache yet — use the API field as a starting suggestion.
          _invWeightCtrl.text = p.originalWeightGrams ?? '';
        }
        _invWeightLoading = false;
      });
      _updateInvPreview();
    } catch (e) {
      debugPrint('OfflineCalc: _loadCachedWeightForProduct error: $e');
      if (mounted) setState(() => _invWeightLoading = false);
    }
  }

  void _addInventoryItem() {
    final p = _selectedProduct!;
    final price = double.tryParse(_invPriceCtrl.text) ?? 0.0;
    final weight = double.tryParse(_invWeightCtrl.text) ?? 0.0;
    final grams = double.tryParse(_invGramsCtrl.text) ?? 0.0;

    if (weight <= 0) {
      Get.snackbar('Error', 'Original weight must be greater than 0',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (grams <= 0) {
      Get.snackbar('Error', 'Please enter the grams to use',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    widget.offlineCtrl.addItem(OfflineMixItem(
      localId: DateTime.now().microsecondsSinceEpoch.toString(),
      productId: p.id,
      productName: p.productName,
      userPrice: price,
      marketPrice: double.tryParse(p.marketPrice ?? '0') ?? 0.0,
      originalWeight: weight,
      usedGrams: grams,
    ));
    Get.back();
  }

  void _addManualItem() {
    final name = _manNameCtrl.text.trim();
    final price = double.tryParse(_manPriceCtrl.text) ?? 0.0;
    final weight = double.tryParse(_manWeightCtrl.text) ?? 0.0;
    final grams = double.tryParse(_manGramsCtrl.text) ?? 0.0;

    if (name.isEmpty) {
      Get.snackbar('Error', 'Enter a product name',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (weight <= 0) {
      Get.snackbar('Error', 'Original weight must be greater than 0',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (grams <= 0) {
      Get.snackbar('Error', 'Please enter the grams to use',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    widget.offlineCtrl.addItem(OfflineMixItem(
      localId: DateTime.now().microsecondsSinceEpoch.toString(),
      productId: null,
      productName: name,
      userPrice: price,
      marketPrice: price,
      originalWeight: weight,
      usedGrams: grams,
    ));
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      height: MediaQuery.of(context).size.height * 0.88 -
          (keyboardHeight > 0 ? keyboardHeight * 0.5 : 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 10.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          // Title row
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
            child: Row(
              children: [
                if (_phase == _InventoryPhase.gramsInput) ...[
                  GestureDetector(
                    onTap: () => setState(() {
                      _phase = _InventoryPhase.productList;
                      _selectedProduct = null;
                      _previewCost = 0.0;
                    }),
                    child: Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: Icon(Icons.arrow_back,
                          color: Colors.black87, size: 22.sp),
                    ),
                  ),
                ],
                Expanded(
                  child: Text(
                    _phase == _InventoryPhase.gramsInput
                        ? _selectedProduct?.productName ?? 'Product'
                        : 'Add Product to Bowl',
                    style: AppTextStyle.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Tab bar
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primaryColor,
            unselectedLabelColor: Colors.grey.shade500,
            indicatorColor: AppColors.primaryColor,
            labelStyle: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
            tabs: const [
              Tab(text: 'From Inventory'),
              Tab(text: 'Manual Entry'),
            ],
          ),
          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildInventoryTab(),
                _buildManualTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Inventory Tab ──────────────────────────────────────────
  Widget _buildInventoryTab() {
    if (_phase == _InventoryPhase.gramsInput) {
      return _buildGramsInputView();
    }
    final filtered = widget.inventoryProducts.where((p) {
      if (_searchQuery.isEmpty) return true;
      return p.productName
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
    }).toList();

    return Column(
      children: [
        // Search
        Padding(
          padding: EdgeInsets.all(16.w),
          child: TextField(
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon:
                  const Icon(Icons.search, color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 12.h),
            ),
          ),
        ),
        if (filtered.isEmpty)
          Expanded(
            child: Center(
              child: Text(
                widget.inventoryProducts.isEmpty
                    ? 'No cached inventory.\nUse Manual Entry tab.'
                    : 'No products match.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14.sp,
                ),
              ),
            ),
          )
        else
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: filtered.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: Colors.grey.shade100),
              itemBuilder: (_, i) {
                final p = filtered[i];
                final avail =
                    double.tryParse(p.currentWeightGrams) ?? 0.0;
                final isAvail = avail > 0;
                return ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 4.h),
                  leading: CircleAvatar(
                    radius: 22.r,
                    backgroundColor:
                        AppColors.primaryColor.withOpacity(0.10),
                    backgroundImage: p.productImage != null
                        ? NetworkImage(p.productImage!)
                        : null,
                    child: p.productImage == null
                        ? Icon(Icons.inventory_2_outlined,
                            color: AppColors.primaryColor,
                            size: 20.sp)
                        : null,
                  ),
                  title: Text(
                    p.productName,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                      color:
                          isAvail ? Colors.black87 : Colors.grey,
                    ),
                  ),
                  subtitle: Text(
                    '${p.currentWeightGrams}g available  ·  \$${p.userPrice ?? p.marketPrice ?? '0'}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isAvail
                          ? Colors.grey.shade600
                          : Colors.red.shade300,
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: isAvail
                        ? AppColors.primaryColor
                        : Colors.grey.shade300,
                  ),
                  onTap: () => _selectProduct(p),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildGramsInputView() {
    final p = _selectedProduct!;
    final keyboardBottom = MediaQuery.of(context).viewInsets.bottom;
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: 16.w,
        bottom: keyboardBottom > 0 ? keyboardBottom + 16.h : 16.w,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Product info chip
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                  color: AppColors.primaryColor.withOpacity(0.20)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundColor:
                      AppColors.primaryColor.withOpacity(0.10),
                  backgroundImage: p.productImage != null
                      ? NetworkImage(p.productImage!)
                      : null,
                  child: p.productImage == null
                      ? Icon(Icons.inventory_2_outlined,
                          color: AppColors.primaryColor, size: 18.sp)
                      : null,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.productName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700)),
                      Text(
                        'Available: ${p.currentWeightGrams}g',
                        style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12.sp),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          _field(
            controller: _invPriceCtrl,
            label: 'Total Price',
            icon: Icons.attach_money,
            onChanged: (_) => _updateInvPreview(),
          ),
          SizedBox(height: 12.h),
          _field(
            controller: _invWeightCtrl,
            label: 'Original Full Bottle Weight',
            icon: Icons.scale,
            suffix: 'g',
            onChanged: (_) => _updateInvPreview(),
          ),
          SizedBox(height: 12.h),
          _field(
            controller: _invGramsCtrl,
            label: 'Grams to Use',
            icon: Icons.science_outlined,
            suffix: 'g',
            onChanged: (_) => _updateInvPreview(),
          ),
          SizedBox(height: 14.h),
          if (_invWeightLoading)
            Container(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 14.w,
                    height: 14.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Loading original weight…',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            )
          else
            _costPreview(_previewCost),
          SizedBox(height: 20.h),
          _addButton(_invWeightLoading ? null : _addInventoryItem),
        ],
      ),
    );
  }

  // ── Manual Tab ─────────────────────────────────────────────
  Widget _buildManualTab() {
    final keyboardBottom = MediaQuery.of(context).viewInsets.bottom;
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: 16.w,
        bottom: keyboardBottom > 0 ? keyboardBottom + 16.h : 16.w,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _field(
            controller: _manNameCtrl,
            label: 'Product Name',
            icon: Icons.label_outline,
          ),
          SizedBox(height: 12.h),
          _field(
            controller: _manPriceCtrl,
            label: 'Total Price',
            icon: Icons.attach_money,
            onChanged: (_) => _updateManPreview(),
          ),
          SizedBox(height: 12.h),
          _field(
            controller: _manWeightCtrl,
            label: 'Full Bottle Weight',
            icon: Icons.scale,
            suffix: 'g',
            onChanged: (_) => _updateManPreview(),
          ),
          SizedBox(height: 12.h),
          _field(
            controller: _manGramsCtrl,
            label: 'Grams to Use',
            icon: Icons.science_outlined,
            suffix: 'g',
            onChanged: (_) => _updateManPreview(),
          ),
          SizedBox(height: 14.h),
          _costPreview(_previewCost),
          SizedBox(height: 12.h),
          // Info banner
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: Colors.orange.shade100),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    color: Colors.orange.shade700, size: 16.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Manual items are for offline calculation only and cannot be saved to the server.',
                    style: TextStyle(
                        color: Colors.orange.shade800, fontSize: 11.sp),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          _addButton(_addManualItem),
        ],
      ),
    );
  }

  // ── Shared helpers ─────────────────────────────────────────
  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? suffix,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: label.contains('Name')
          ? TextInputType.text
          : const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: label.contains('Name')
          ? null
          : [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13.sp),
        prefixIcon: Icon(icon, color: AppColors.primaryColor, size: 20.sp),
        suffixText: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.primaryColor),
        ),
        contentPadding:
            EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      ),
    );
  }

  Widget _costPreview(double cost) {
    if (cost <= 0) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.green.shade100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Cost for this item',
              style: TextStyle(
                  color: Colors.grey.shade700, fontSize: 13.sp)),
          Text(
            '\$${cost.toStringAsFixed(2)}',
            style: TextStyle(
              color: Colors.green.shade700,
              fontWeight: FontWeight.w800,
              fontSize: 20.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _addButton(VoidCallback? onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon:
          const Icon(Icons.add_circle_outline, color: Colors.white),
      label: Text(
        'Add to Bowl',
        style: TextStyle(
            color: Colors.white,
            fontSize: 15.sp,
            fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        padding: EdgeInsets.symmetric(vertical: 15.h),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Save Mix bottom sheet
// ─────────────────────────────────────────────────────────────
class _SaveMixSheet extends StatefulWidget {
  final OfflineMixController controller;
  const _SaveMixSheet({required this.controller});

  @override
  State<_SaveMixSheet> createState() => _SaveMixSheetState();
}

class _SaveMixSheetState extends State<_SaveMixSheet> {
  final _nameCtrl = TextEditingController();
  final _serviceCtrl = TextEditingController();
  final _chargeCtrl = TextEditingController();

  double get _totalCost => widget.controller.totalCost;
  double get _charged => double.tryParse(_chargeCtrl.text) ?? 0.0;
  double get _profit => _charged - _totalCost;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _serviceCtrl.dispose();
    _chargeCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final name = _nameCtrl.text.trim();
    final service = _serviceCtrl.text.trim();
    if (name.isEmpty) {
      Get.snackbar('Required', 'Please enter a mix name',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (service.isEmpty) {
      Get.snackbar('Required', 'Please enter a service type',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    final ok = await widget.controller.saveToServer(
      mixName: name,
      serviceType: service,
      chargedAmount: _charged,
    );

    if (ok) {
      widget.controller.reset();
      Get.back();
      Get.snackbar(
        'Mix Saved!',
        'Your mix has been saved successfully.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
      Get.offAll(() => MainBaseScreen());
    } else {
      Get.snackbar(
        'Save Failed',
        'Could not save mix. Please check your connection and try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          top: 20.h,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
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
            // Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    gradient: AppColors.buttonGradient,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(Icons.cloud_upload_outlined,
                      color: Colors.white, size: 20.sp),
                ),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Save Mix to Server',
                      style: AppTextStyle.titleLarge.copyWith(
                          fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'Requires internet connection',
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 12.sp),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20.h),
            // Mix Name
            _sheetField(
              controller: _nameCtrl,
              label: 'Mix Name *',
              icon: Icons.science_outlined,
            ),
            SizedBox(height: 12.h),
            // Service Type
            _sheetField(
              controller: _serviceCtrl,
              label: 'Service Type *',
              icon: Icons.cut_outlined,
            ),
            SizedBox(height: 12.h),
            // Charged Amount
            _sheetField(
              controller: _chargeCtrl,
              label: 'Client Charge (optional)',
              icon: Icons.attach_money,
              isNumber: true,
              onChanged: (_) => setState(() {}),
            ),
            SizedBox(height: 16.h),
            // Cost summary card
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _summaryRow(
                    'Total Product Cost',
                    '\$${_totalCost.toStringAsFixed(2)}',
                    Colors.black87,
                  ),
                  if (_charged > 0) ...[
                    SizedBox(height: 8.h),
                    _summaryRow(
                      'Client Charge',
                      '\$${_charged.toStringAsFixed(2)}',
                      Colors.black87,
                    ),
                    Divider(height: 16.h, color: Colors.grey.shade200),
                    _summaryRow(
                      'Profit',
                      '\$${_profit.toStringAsFixed(2)}',
                      _profit >= 0
                          ? Colors.green.shade700
                          : Colors.red.shade600,
                    ),
                  ],
                ],
              ),
            ),
            // Warning for manual items
            if (widget.controller.hasManualItems) ...[
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: Colors.orange.shade700, size: 18.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Manual items will be skipped — only inventory products will be saved to the server.',
                        style: TextStyle(
                            color: Colors.orange.shade800,
                            fontSize: 11.sp),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: 20.h),
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: Get.back,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15.h),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.black87)),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  flex: 2,
                  child: Obx(
                    () => ElevatedButton(
                      onPressed:
                          widget.controller.isSaving.value ? null : _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        disabledBackgroundColor:
                            AppColors.primaryColor.withOpacity(0.5),
                        padding: EdgeInsets.symmetric(vertical: 15.h),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: widget.controller.isSaving.value
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.cloud_upload_outlined,
                                    color: Colors.white, size: 18.sp),
                                SizedBox(width: 6.w),
                                Text('Save Mix',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sheetField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isNumber = false,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      inputFormatters: isNumber
          ? [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))]
          : null,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon:
            Icon(icon, color: AppColors.primaryColor, size: 20.sp),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.primaryColor),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                color: Colors.grey.shade600, fontSize: 13.sp)),
        Text(value,
            style: TextStyle(
                color: valueColor,
                fontWeight: FontWeight.w700,
                fontSize: 14.sp)),
      ],
    );
  }
}
