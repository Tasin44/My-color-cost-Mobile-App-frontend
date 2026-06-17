import 'dart:convert';

import 'package:color_os/app/core/constant/api_endpoints.dart';
import 'package:color_os/app/core/services/api_services.dart';
import 'package:color_os/app/models/api_response.dart';
import 'package:color_os/app/models/client_model.dart';
import 'package:color_os/app/models/client_image_model.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class ClientController extends GetxController {
  // Observable list of clients
  final RxList<ClientModel> clients = <ClientModel>[].obs;

  // Loading state
  final RxBool isLoading = false.obs;

  // Observable for search query
  final RxString searchQuery = ''.obs;

  // Observable for selected service type filter
  final RxString selectedServiceType = 'All'.obs;

  // Observable for selected sort option
  final RxString selectedSortOption = 'Name (A-Z)'.obs;

  @override
  void onInit() {
    super.onInit();
    getClients();
  }

  // Fetch clients from API
  Future<void> getClients() async {
    try {
      isLoading.value = true;
      final response = await ApiServices.getData(ApiEndpoints.clients);

      if (response != null && response.success && response.data != null) {
        if (response.data['clients'] != null) {
          final List<dynamic> clientsList = response.data['clients'];
          clients.value = clientsList
              .map((json) => ClientModel.fromJson(json))
              .toList();
        } else {
          clients.clear();
        }
      } else {
        debugPrint('Failed to load clients: ${response?.message}');
        // Optional: Show error snackbar
      }
    } catch (e) {
      debugPrint('Error loading clients: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Get filtered and sorted clients
  List<ClientModel> get filteredClients {
    var filtered = clients.where((client) {
      // Filter by search query
      final matchesSearch =
          searchQuery.value.isEmpty ||
          client.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          client.serviceType.toLowerCase().contains(
            searchQuery.value.toLowerCase(),
          );

      // Filter by service type
      final matchesServiceType =
          selectedServiceType.value == 'All' ||
          client.serviceType == selectedServiceType.value;

      return matchesSearch && matchesServiceType;
    }).toList();

    // Sort the filtered list
    switch (selectedSortOption.value) {
      case 'Name (A-Z)':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'Name (Z-A)':
        filtered.sort((a, b) => b.name.compareTo(a.name));
        break;
      case 'Recent':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'Oldest':
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
    }

    return filtered;
  }

  // Update search query
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  // Update service type filter
  void updateServiceTypeFilter(String serviceType) {
    selectedServiceType.value = serviceType;
  }

  // Update sort option
  void updateSortOption(String sortOption) {
    selectedSortOption.value = sortOption;
  }

  // Add new client
  void addClient(ClientModel client) {
    clients.add(client);
  }

  // Update existing client
  void updateClient(String id, ClientModel updatedClient) {
    final index = clients.indexWhere((client) => client.id == id);
    if (index != -1) {
      clients[index] = updatedClient;
    }
  }

  // Delete client
  void deleteClient(String id) {
    clients.removeWhere((client) => client.id == id);
  }

  // Get client by id
  ClientModel? getClientById(String id) {
    try {
      return clients.firstWhere((client) => client.id == id);
    } catch (e) {
      return null;
    }
  }

  // Clear all filters
  void clearFilters() {
    searchQuery.value = '';
    selectedServiceType.value = 'All';
    selectedSortOption.value = 'Name (A-Z)';
  }

  // Get statistics
  int get totalClients => clients.length;

  int getClientCountByServiceType(String serviceType) {
    return clients.where((client) => client.serviceType == serviceType).length;
  }

  // Get available service types dynamically
  List<String> get availableServiceTypes {
    final types = clients
        .map((client) => client.serviceType)
        .where((type) => type.isNotEmpty)
        .toSet()
        .toList();
    types.sort();
    return ['All', ...types];
  }

  // Get client details by ID
  Future<ClientModel?> getClientDetails(String clientId) async {
    try {
      isLoading.value = true;
      final response = await ApiServices.getData(
        '${ApiEndpoints.clients}$clientId/',
      );

      debugPrint('--- [ClientController] Fetching Client Details ---');
      debugPrint('URL: ${ApiEndpoints.clients}$clientId/');
      debugPrint('Full Response Data: ${response?.data}');

      if (response != null && response.success && response.data != null) {
        // If the data is nested under a 'client' key, unwrap it.
        final json = (response.data is Map && response.data.containsKey('client'))
            ? response.data['client']
            : response.data;
        
        debugPrint('Parsing Client JSON: $json');
        return ClientModel.fromJson(json);
      } else {
        debugPrint('Failed to load client details: ${response?.message}');
        return null;
      }
    } catch (e) {
      debugPrint('Error loading client details: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Get client images
  Future<ClientImagesData?> getClientImages(String clientId) async {
    try {
      final response = await ApiServices.getData(
        '${ApiEndpoints.clients}$clientId/images/',
      );

      if (response != null && response.success && response.data != null) {
        return ClientImagesData.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint('Error loading client images: $e');
      return null;
    }
  }

  // Delete client image
  Future<bool> deleteClientImage(String clientId, int imageId) async {
    try {
      final response = await ApiServices.deleteData(
        '${ApiEndpoints.clients}$clientId/images/$imageId/',
      );

      if (response != null && response.success) {
        return true;
      } else {
        Get.snackbar('Error', response?.message ?? 'Failed to delete image');
        return false;
      }
    } catch (e) {
      debugPrint('Error deleting image: $e');
      Get.snackbar('Error', 'An unexpected error occurred');
      return false;
    }
  }

  // Create new client
  Future<String?> createClient(
    Map<String, dynamic> data, {
    XFile? profileImage,
  }) async {
    try {
      isLoading.value = true;
      final url = ApiEndpoints.clients;

      final Map<String, String> fields = {};
      data.forEach((key, value) {
        if (value != null) {
          fields[key] = value.toString();
        }
      });

      // Add created_by field as generic json string if backend implies complex structure,
      // or just assume backend handles it.
      // User requirement was: "created_by": {"type": "owner"}
      // In multipart form data, nested objects are often sent as dot notation or bracket notation
      // OR as a JSON string in a field. given Flutter/Django/Node context, JSON string is safest default
      // if not specified.
      fields['created_by'] = '{"type": "owner"}';

      List<http.MultipartFile> files = [];

      if (profileImage != null) {
        final bytes = await profileImage.readAsBytes();
        final mimeType = lookupMimeType(profileImage.path) ?? 'image/jpeg';
        final type = mimeType.split('/')[0];
        final subtype = mimeType.split('/')[1];

        final file = http.MultipartFile.fromBytes(
          'profile_image', // Assuming backend field for profile image is 'profile_image' or 'image'
          // If request fails on image field name, we might need to ask/debug.
          // Earlier upload used 'body', but that was a bulk upload endpoint.
          // For creation, 'profile_image' or 'image' is standard. I'll use 'image' as a common guess
          // or 'profile_image' given the context. Let's try 'image' or ask?
          // User didn't specify. I will use 'profile_image' to be specific, or 'image' if generic.
          // Let's stick with 'image' as it's common in Django (Avatar/ImageField).
          // actually, in uploadClientImages I used 'body'.
          // Let's use 'profile_image' to differentiate.
          bytes,
          filename: profileImage.name,
          contentType: MediaType(type, subtype),
        );
        files.add(file);
      }

      final response = await ApiServices.postMultipartData(url, fields, files);

      if (response != null && response.success) {
        Get.snackbar(
          'Success',
          'Client created successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        // Refresh client list
        getClients();
        // Return client ID if available
        if (response.data != null) {
          if (response.data['id'] != null) {
            return response.data['id'].toString();
          } else if (response.data['client'] != null &&
              response.data['client']['id'] != null) {
            return response.data['client']['id'].toString();
          }
        }
        return null; // Success but no ID?
      } else {
        Get.snackbar('Error', response?.message ?? 'Failed to create client');
        return null;
      }
    } catch (e) {
      debugPrint('Error creating client: $e');
      Get.snackbar('Error', 'An unexpected error occurred');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// True when the API reports success or HTTP 2xx (wire status on [ApiResponse]).
  bool _isClientUpdateSuccess(ApiResponse response) {
    return response.success ||
        ApiResponse.isSuccessfulHttpStatus(response.statusCode);
  }

  static const Set<String> _updateErrorDataSkipKeys = {
    'success',
    'statusCode',
    'status_code',
  };

  /// Logs full update response for debugging; use when the snackbar shows a generic message.
  void _debugLogClientUpdateResponse(String context, ApiResponse? response) {
    if (response == null) {
      debugPrint('[ClientController] $context: response is null');
      return;
    }
    debugPrint(
      '[ClientController] $context: HTTP ${response.statusCode} '
      'success=${response.success} message="${response.message}"',
    );
    try {
      debugPrint(
        '[ClientController] $context: data=${jsonEncode(response.data)}',
      );
    } catch (_) {
      debugPrint('[ClientController] $context: data=${response.data}');
    }
  }

  /// Backend often returns DRF-style bodies without `message`; ApiServices then uses "Request completed".
  String _clientUpdateErrorMessage(ApiResponse response) {
    final m = response.message.trim();
    final isGeneric = m.isEmpty ||
        m == 'Request completed' ||
        m == 'Request completed successfully' ||
        m == 'Request failed';
    if (!isGeneric) return m;

    final data = response.data;
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);

      final detail = map['detail'];
      if (detail != null) {
        if (detail is List) {
          return detail.map((e) => e.toString()).join(', ');
        }
        return detail.toString();
      }

      final err = map['error'];
      if (err != null) return err.toString();

      final nonField = map['non_field_errors'];
      if (nonField is List) {
        return nonField.map((e) => e.toString()).join(', ');
      }

      final parts = <String>[];
      for (final e in map.entries) {
        if (_updateErrorDataSkipKeys.contains(e.key)) continue;
        final v = e.value;
        if (v == null) continue;
        if (v is List) {
          parts.add('${e.key}: ${v.map((x) => x.toString()).join(", ")}');
        } else if (v is Map) {
          parts.add('${e.key}: ${jsonEncode(v)}');
        } else {
          parts.add('${e.key}: $v');
        }
      }
      if (parts.isNotEmpty) return parts.join('; ');
    }

    return 'Failed to update client (HTTP ${response.statusCode})';
  }

  // Update client details
  Future<bool> updateClientDetails(
    String clientId,
    Map<String, dynamic> data, {
    XFile? profileImage,
  }) async {
    try {
      isLoading.value = true;
      final url = '${ApiEndpoints.clients}$clientId/';

      final Map<String, String> fields = {};
      data.forEach((key, value) {
        if (value != null) {
          fields[key] = value.toString();
        }
      });

      final List<http.MultipartFile> files = [];
      if (profileImage != null) {
        final bytes = await profileImage.readAsBytes();
        final mimeType = lookupMimeType(profileImage.path) ?? 'image/jpeg';
        final segments = mimeType.split('/');
        final type = segments.length >= 2 ? segments[0] : 'image';
        final subtype = segments.length >= 2 ? segments[1] : 'jpeg';

        files.add(
          http.MultipartFile.fromBytes(
            'profile_image',
            bytes,
            filename: profileImage.name,
            contentType: MediaType(type, subtype),
          ),
        );
      }

      // This endpoint returns 415 for application/json; it expects multipart.
      final response = await ApiServices.patchMultipartData(
        url,
        fields,
        files,
      );

      final updateOk = response != null && _isClientUpdateSuccess(response);

      if (updateOk) {
        getClients();
        return true;
      }

      if (response != null) {
        _debugLogClientUpdateResponse('updateClientDetails', response);
        Get.snackbar(
          'Error',
          _clientUpdateErrorMessage(response),
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        debugPrint(
          '[ClientController] updateClientDetails: '
          'null response (network/parse failure)',
        );
        Get.snackbar(
          'Error',
          'Network error occurred while updating client',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return false;
    } catch (e, stackTrace) {
      debugPrint('Error updating client: $e');
      debugPrint('Error updating client stack: $stackTrace');
      Get.snackbar('Error', 'An unexpected error occurred');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Upload client images
  Future<bool> uploadClientImages(
    String clientId,
    List<XFile> images,
    String imageType,
  ) async {
    try {
      isLoading.value = true;
      final url = '${ApiEndpoints.clients}$clientId/images/upload/';

      final fields = {'image_type': imageType};

      List<http.MultipartFile> files = [];
      for (var image in images) {
        final bytes = await image.readAsBytes();
        final mimeType = lookupMimeType(image.path) ?? 'image/jpeg';
        final type = mimeType.split('/')[0];
        final subtype = mimeType.split('/')[1];

        final file = http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: image.name,
          contentType: MediaType(type, subtype),
        );
        files.add(file);
      }

      final response = await ApiServices.postMultipartData(url, fields, files);

      if (response != null && response.success) {
        Get.snackbar(
          'Success',
          'Images uploaded successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      } else {
        Get.snackbar('Error', response?.message ?? 'Failed to upload images');
        return false;
      }
    } catch (e) {
      debugPrint('Error uploading images: $e');
      Get.snackbar('Error', 'Failed to upload images');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
