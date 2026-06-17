import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:color_os/app/models/cart_item_model.dart';
import 'package:color_os/app/core/constant/themes/app_colors.dart';

class CartItemWidget extends StatelessWidget {
  final CartItem cartItem;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const CartItemWidget({
    Key? key,
    required this.cartItem,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: cartItem.product.imageUrl.isNotEmpty
                ? Image.network(
                    cartItem.product.imageUrl,
                    width: 70.w,
                    height: 70.h,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 70.w,
                        height: 70.h,
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey[400],
                          size: 28.sp,
                        ),
                      );
                    },
                  )
                : Container(
                    width: 70.w,
                    height: 70.h,
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.grey[400],
                      size: 28.sp,
                    ),
                  ),
          ),
          SizedBox(width: 10.w),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cartItem.product.name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 3.h),
                Text(
                  cartItem.product.retailer,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Price
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '£${(cartItem.product.discountedPrice + cartItem.product.vat).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        if (cartItem.product.vat > 0)
                          Text(
                            'Inc. £${cartItem.product.vat.toStringAsFixed(2)} VAT',
                            style: TextStyle(
                              fontSize: 9.sp,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),

                    // Quantity Controls
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Decrement Button
                          InkWell(
                            onTap: onDecrement,
                            borderRadius: BorderRadius.circular(6.r),
                            child: Container(
                              padding: EdgeInsets.all(4.w),
                              child: Icon(
                                Icons.remove,
                                size: 16.sp,
                                color: Colors.black87,
                              ),
                            ),
                          ),

                          // Quantity
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w),
                            child: Text(
                              '${cartItem.quantity}',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),

                          // Increment Button
                          InkWell(
                            onTap: onIncrement,
                            borderRadius: BorderRadius.circular(6.r),
                            child: Container(
                              padding: EdgeInsets.all(4.w),
                              child: Icon(
                                Icons.add,
                                size: 16.sp,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Remove Button
          SizedBox(width: 6.w),
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(6.r),
            child: Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Icon(
                Icons.delete_outline,
                size: 18.sp,
                color: Colors.red.shade400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
