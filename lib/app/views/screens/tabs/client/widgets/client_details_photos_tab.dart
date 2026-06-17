import 'package:color_os/app/controllers/client_controller.dart';
import 'package:color_os/app/models/client_image_model.dart';
import 'package:color_os/app/models/client_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ClientDetailsPhotosTab extends StatefulWidget {
  final ClientModel client;

  const ClientDetailsPhotosTab({super.key, required this.client});

  @override
  State<ClientDetailsPhotosTab> createState() => _ClientDetailsPhotosTabState();
}

class _ClientDetailsPhotosTabState extends State<ClientDetailsPhotosTab> {
  final ClientController _clientController = Get.find<ClientController>();
  ClientImagesData? _imagesData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchImages();
    });
  }

  Future<void> _fetchImages() async {
    final data = await _clientController.getClientImages(widget.client.id);
    if (mounted) {
      setState(() {
        _imagesData = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Upload Image Button
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24.r),
                      topRight: Radius.circular(24.r),
                    ),
                  ),
                  builder: (context) => Container(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Upload Image',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Row(
                          children: [
                            Expanded(
                              child: _buildUploadOption(
                                context,
                                'Before Image',
                                Icons.history,
                                Colors.purple,
                                'before',
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: _buildUploadOption(
                                context,
                                'After Image',
                                Icons.update,
                                Colors.teal,
                                'after',
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                      ],
                    ),
                  ),
                );
              },
              icon: Icon(Icons.upload_file, size: 20.sp),
              label: Text(
                'Upload Image',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[50],
                foregroundColor: Colors.green[700],
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),

          SizedBox(height: 24.h),

          // Before Images Section
          Text(
            'Before Image',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 16.h),

          if (_imagesData?.beforeImages.isNotEmpty ?? false)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: 0.8,
              ),
              itemCount: _imagesData!.beforeImages.length,
              itemBuilder: (context, index) {
                return _buildImageCard(
                  _imagesData!.beforeImages[index],
                  'Before',
                  Colors.purple,
                );
              },
            )
          else
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32.h),
                child: Text(
                  'No before images',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
                ),
              ),
            ),

          SizedBox(height: 32.h),

          // After Images Section
          Text(
            'After Image',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 16.h),

          if (_imagesData?.afterImages.isNotEmpty ?? false)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: 0.8,
              ),
              itemCount: _imagesData!.afterImages.length,
              itemBuilder: (context, index) {
                return _buildImageCard(
                  _imagesData!.afterImages[index],
                  'After',
                  Colors.teal,
                );
              },
            )
          else
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32.h),
                child: Text(
                  'No after images',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
                ),
              ),
            ),

          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildImageCard(ClientImage image, String label, Color badgeColor) {
    return Stack(
      children: [
        // Image Container
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey[200]!),
            image: DecorationImage(
              image: NetworkImage(image.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),

        // Badge (Before/After)
        Positioned(
          top: 8.h,
          left: 8.w,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),

        // Delete Button
        Positioned(
          top: 8.h,
          right: 8.w,
          child: GestureDetector(
            onTap: () async {
              // Handle delete
              final confirm = await Get.dialog<bool>(
                AlertDialog(
                  title: const Text('Delete Image'),
                  content: const Text(
                    'Are you sure you want to delete this image?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(result: false),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.back(result: true),
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                final success = await _clientController.deleteClientImage(
                  widget.client.id,
                  image.id,
                );
                if (success) {
                  _fetchImages(); // Refresh list
                  Get.snackbar(
                    'Success',
                    'Image deleted successfully',
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                }
              }
            },
            child: Container(
              width: 28.w,
              height: 28.w,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, color: Colors.white, size: 16.sp),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadOption(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    String type,
  ) {
    return GestureDetector(
      onTap: () async {
        Navigator.pop(context);
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: ImageSource.gallery,
        );
        if (image != null) {
          final success = await _clientController.uploadClientImages(
            widget.client.id,
            [image],
            type,
          );
          if (success) {
            _fetchImages();
          }
        }
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32.sp),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
