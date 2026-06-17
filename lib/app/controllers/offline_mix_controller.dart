import 'package:color_os/app/core/constant/api_endpoints.dart';
import 'package:color_os/app/core/services/api_services.dart';
import 'package:color_os/app/models/api_response.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OfflineMixItem {
  final String localId;
  final int? productId; // null for manually-entered items
  final String productName;
  final double userPrice;
  final double marketPrice;
  final double originalWeight;
  final double usedGrams;

  OfflineMixItem({
    required this.localId,
    this.productId,
    required this.productName,
    this.userPrice = 0.0,
    this.marketPrice = 0.0,
    required this.originalWeight,
    required this.usedGrams,
  });

  double get effectivePrice => userPrice > 0 ? userPrice : marketPrice;

  double get pricePerGram =>
      originalWeight > 0 ? effectivePrice / originalWeight : 0.0;

  double get cost {
    final raw = pricePerGram * usedGrams;
    return (raw * 100).roundToDouble() / 100;
  }

  bool get canSaveToServer => productId != null;

  OfflineMixItem copyWith({double? usedGrams}) {
    return OfflineMixItem(
      localId: localId,
      productId: productId,
      productName: productName,
      userPrice: userPrice,
      marketPrice: marketPrice,
      originalWeight: originalWeight,
      usedGrams: usedGrams ?? this.usedGrams,
    );
  }
}

class OfflineMixController extends GetxController {
  final RxList<OfflineMixItem> items = <OfflineMixItem>[].obs;
  final RxBool isSaving = false.obs;

  // Computed getters — reactive because they read from items (RxList)
  double get totalCost => items.fold(0.0, (sum, item) => sum + item.cost);
  bool get hasManualItems => items.any((i) => !i.canSaveToServer);
  bool get hasSavableItems => items.any((i) => i.canSaveToServer);

  void addItem(OfflineMixItem item) {
    items.add(item);
  }

  void removeItem(String localId) {
    items.removeWhere((i) => i.localId == localId);
  }

  void updateItemGrams(String localId, double newGrams) {
    final idx = items.indexWhere((i) => i.localId == localId);
    if (idx != -1) {
      items[idx] = items[idx].copyWith(usedGrams: newGrams);
    }
  }

  void reset() {
    items.clear();
  }

  Future<bool> saveToServer({
    required String mixName,
    required String serviceType,
    required double chargedAmount,
  }) async {
    if (!hasSavableItems) return false;
    isSaving.value = true;
    try {
      final productsList = items
          .where((item) => item.canSaveToServer)
          .map((item) => {
                "user_product_id": item.productId,
                "used_weight": item.usedGrams.toDouble(),
                "user_price": item.userPrice,
                "market_price": item.marketPrice,
              })
          .toList();

      final body = {
        "mix_name": mixName,
        "service_type": serviceType,
        "charged_amount": chargedAmount,
        "products": productsList,
      };

      final response = await ApiServices.postData(ApiEndpoints.mixes, body);
      return response != null &&
          (response.success ||
              ApiResponse.isSuccessfulHttpStatus(response.statusCode));
    } catch (e) {
      debugPrint('OfflineMixController saveToServer error: $e');
      return false;
    } finally {
      isSaving.value = false;
    }
  }
}
