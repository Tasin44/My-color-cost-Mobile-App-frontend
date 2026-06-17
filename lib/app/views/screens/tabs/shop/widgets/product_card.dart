import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:color_os/app/core/constant/app_textstyle.dart';
import 'package:color_os/app/models/product_model.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  const ProductCard({
    Key? key,
    required this.product,
    required this.onTap,
    required this.onAddToCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with Stock Badge Overlay
            Expanded(
              flex: 7,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                child: Stack(
                  children: [
                    // Product Image
                    SizedBox.expand(
                      child: product.imageUrl.isNotEmpty
                          ? Image.network(
                              product.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey.shade200,
                                  child: Icon(
                                    Icons.inventory_2_outlined,
                                    size: 50.sp,
                                    color: Colors.grey.shade400,
                                  ),
                                );
                              },
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value:
                                            loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                            : null,
                                        color: const Color(0xFFFF6B9D),
                                      ),
                                    );
                                  },
                            )
                          : Container(
                              color: Colors.grey.shade200,
                              child: Icon(
                                Icons.inventory_2_outlined,
                                size: 50.sp,
                                color: Colors.grey.shade400,
                              ),
                            ),
                    ),

                    // Stock Status Badge Overlay
                    Positioned(
                      top: 6.h,
                      right: 6.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: product.isInStock
                              ? Colors.green.withOpacity(0.9)
                              : Colors.red.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          product.isInStock ? 'In Stock' : 'Out of Stock',
                          style: TextStyle(
                            fontSize: 8.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    // Quantity Badge Overlay
                    if (product.quantity > 0)
                      Positioned(
                        top: 6.h,
                        left: 6.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            'Qty: ${product.quantity}',
                            style: TextStyle(
                              fontSize: 8.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                    // Promo Badge Overlay
                    if (product.promoIsActive && product.promoText != null)
                      Positioned(
                        bottom: 6.h,
                        left: 6.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF6B9D), Color(0xFFFE4C82)],
                            ),
                            borderRadius: BorderRadius.circular(6.r),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF6B9D).withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            product.promoText!,
                            style: TextStyle(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Product Details
            Expanded(
              flex: 6,
              child: Padding(
                padding: EdgeInsets.all(6.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Product Name
                    Text(
                      product.name,
                      style: AppTextStyle.bodyMedium.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 11.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 2.h),

                    // Retailer
                    Text(
                      product.retailer,
                      style: AppTextStyle.bodySmall.copyWith(
                        color: Colors.grey.shade600,
                        fontSize: 8.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 2.h),

                    // Rating and Reviews
                    Row(
                      children: [
                        Icon(Icons.star, size: 10.sp, color: Colors.amber),
                        SizedBox(width: 1.w),
                        Text(
                          product.rating.toStringAsFixed(1),
                          style: AppTextStyle.bodySmall.copyWith(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                            fontSize: 8.sp,
                          ),
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          '(${product.totalReviews})',
                          style: AppTextStyle.bodySmall.copyWith(
                            color: Colors.grey.shade500,
                            fontSize: 7.sp,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Price and Cart Button Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (product.discountedPrice < product.price)
                                Text(
                                  '£${product.price.toStringAsFixed(2)}',
                                  style: AppTextStyle.bodySmall.copyWith(
                                    color: Colors.grey.shade500,
                                    fontSize: 10.sp,
                                    decoration: TextDecoration.lineThrough,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              Text(
                                '£${product.discountedPrice.toStringAsFixed(2)}',
                                style: AppTextStyle.titleMedium.copyWith(
                                  color: product.discountedPrice < product.price
                                      ? const Color(0xFFFE4C82)
                                      : Colors.black87,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: product.isInStock ? onAddToCart : null,
                          child: Container(
                            padding: EdgeInsets.all(7.w),
                            decoration: BoxDecoration(
                              gradient: product.isInStock
                                  ? const LinearGradient(
                                      colors: [Color(0xFFFF6B9D), Color(0xFFFE4C82)],
                                    )
                                  : null,
                              color: product.isInStock
                                  ? null
                                  : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(10.r),
                              boxShadow: product.isInStock
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFFFF6B9D).withOpacity(0.3),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Icon(
                              Icons.add_shopping_cart_rounded,
                              size: 16.sp,
                              color: product.isInStock
                                  ? Colors.white
                                  : Colors.grey.shade500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
