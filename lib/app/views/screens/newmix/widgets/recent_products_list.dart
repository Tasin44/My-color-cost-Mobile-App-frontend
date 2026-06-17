import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:color_os/app/core/constant/app_textstyle.dart';
import 'package:color_os/app/core/constant/themes/app_colors.dart';
import 'package:color_os/app/models/inventory_product_model.dart';

class RecentProductsList extends StatelessWidget {
  final List<InventoryProduct> products;
  final Function(InventoryProduct) onProductTap;

  const RecentProductsList({
    Key? key,
    required this.products,
    required this.onProductTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: 12.h),
          _buildEmptyState(),
        ],
      );
    }

    // Limit to top 4 products for "Recent" view
    final displayProducts = products.length > 4
        ? products.sublist(0, 4)
        : products;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        SizedBox(height: 12.h),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displayProducts.length,
          separatorBuilder: (context, index) => SizedBox(height: 10.h),
          itemBuilder: (context, index) {
            return _buildProductListItem(displayProducts[index]);
          },
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Recent Products',
          style: AppTextStyle.titleMedium.copyWith(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 20.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 40.sp,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 8.h),
          Text(
            'No recent products found',
            style: AppTextStyle.bodyMedium.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductListItem(InventoryProduct product) {
    final bool isAvailable = product.isAvailable;

    return GestureDetector(
      onTap: isAvailable ? () => onProductTap(product) : null,
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isAvailable ? Colors.grey.shade200 : Colors.grey.shade100,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Product Image with Availability Badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Container(
                    width: 65.w,
                    height: 65.w,
                    color: Colors.grey.shade50,
                    child: product.productImage != null
                        ? Image.network(
                            product.productImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.image_not_supported_outlined,
                              color: Colors.grey.shade400,
                              size: 24.sp,
                            ),
                          )
                        : Icon(
                            Icons.inventory_2_outlined,
                            color: Colors.grey.shade400,
                            size: 24.sp,
                          ),
                  ),
                ),
                if (!isAvailable)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 12.w),

            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.productName,
                          style: AppTextStyle.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isAvailable ? Colors.black87 : Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: isAvailable
                              ? Colors.green.shade50
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          isAvailable ? 'Available' : 'Out of Stock',
                          style: TextStyle(
                            color: isAvailable
                                ? Colors.green.shade700
                                : Colors.grey.shade600,
                            fontSize: 8.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${double.tryParse(product.currentWeightGrams)?.toInt() ?? 0}g left',
                    style: AppTextStyle.labelSmall.copyWith(
                      color: isAvailable
                          ? Colors.grey.shade600
                          : Colors.grey.shade400,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '£${product.userPrice ?? product.marketPrice ?? '0.00'}',
                        style: AppTextStyle.bodySmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isAvailable
                              ? AppColors.primaryColor
                              : Colors.grey,
                        ),
                      ),
                      Icon(
                        Icons.add_circle,
                        color: isAvailable
                            ? AppColors.primaryColor
                            : Colors.grey.shade300,
                        size: 20.sp,
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
}
