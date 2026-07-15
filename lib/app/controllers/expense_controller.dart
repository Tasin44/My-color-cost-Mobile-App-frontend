import 'dart:io';
import 'package:color_os/app/core/constant/api_endpoints.dart';
import 'package:color_os/app/core/helper/sharedpref_helper.dart';
import 'package:color_os/app/core/services/api_services.dart';
import 'package:color_os/app/models/api_response.dart';
import 'package:color_os/app/models/expense_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ExpenseController extends GetxController {
  final RxList<ExpenseModel> expenses = <ExpenseModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchExpenses();
  }

  // GET /mix/expenses/
  // Response: { "data": { "expenses": [...], "total_count": N } }
  Future<void> fetchExpenses() async {
    try {
      isLoading.value = true;
      final response = await ApiServices.getData(ApiEndpoints.expenses);

      if (response != null &&
          ApiResponse.isSuccessfulHttpStatus(response.statusCode) &&
          response.data != null) {
        // Backend wraps the list under data.expenses (not data.results)
        final results = response.data['expenses'] as List? ?? [];
        expenses.value = results
            .map((e) => ExpenseModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        expenses.clear();
      }
    } catch (e) {
      debugPrint('Error fetching expenses: $e');
      expenses.clear();
    } finally {
      isLoading.value = false;
    }
  }

  // POST /mix/expenses/  (multipart/form-data)
  Future<bool> addExpense({
    required String name,
    required String amount,
    required String category,
    required String description,
    File? image,
  }) async {
    try {
      isSubmitting.value = true;

      final token = await SharedprefHelper.getString(SharedprefHelper().token);
      final uri = Uri.parse(ApiEndpoints.expenses);
      final request = http.MultipartRequest('POST', uri);

      request.headers.addAll({'Authorization': 'Bearer $token'});

      request.fields['expense_name'] = name;
      request.fields['amount'] = amount;
      request.fields['category'] = category;
      request.fields['description'] = description;
      // NOTE: frequency field removed — no longer part of the Expense API

      if (image != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            image.path,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (ApiResponse.isSuccessfulHttpStatus(response.statusCode)) {
        fetchExpenses(); // Refresh list
        return true;
      } else {
        debugPrint('Failed to add expense: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error adding expense: $e');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  // PATCH /mix/expenses/{id}/  (multipart/form-data)
  Future<bool> updateExpense({
    required int id,
    required String name,
    required String amount,
    required String category,
    required String description,
    File? image,
  }) async {
    try {
      isSubmitting.value = true;

      final token = await SharedprefHelper.getString(SharedprefHelper().token);
      final uri = Uri.parse('${ApiEndpoints.expenses}$id/');
      final request = http.MultipartRequest('PATCH', uri);

      request.headers.addAll({'Authorization': 'Bearer $token'});

      request.fields['expense_name'] = name;
      request.fields['amount'] = amount;
      request.fields['category'] = category;
      request.fields['description'] = description;
      // NOTE: frequency field removed — no longer part of the Expense API

      if (image != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            image.path,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (ApiResponse.isSuccessfulHttpStatus(response.statusCode)) {
        fetchExpenses(); // Refresh list
        return true;
      } else {
        debugPrint('Failed to update expense: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error updating expense: $e');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  // DELETE /mix/expenses/{id}/
  Future<bool> deleteExpense(int id) async {
    try {
      isSubmitting.value = true;
      final response =
          await ApiServices.deleteData('${ApiEndpoints.expenses}$id/');

      if (response != null && response.success) {
        expenses.removeWhere((e) => e.id == id);
        Get.snackbar(
          'Deleted',
          'Expense deleted successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          response?.message ?? 'Failed to delete expense',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      debugPrint('Error deleting expense: $e');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
}
