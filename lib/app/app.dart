import 'package:color_os/app/bindings/initial_binding.dart';
import 'package:color_os/app/core/constant/themes/app_colors.dart';
import 'package:color_os/app/routes/app_pages.dart';
import 'package:color_os/app/views/screens/initial/initial_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

Widget MyApp() {
  return ScreenUtilInit(
    builder: (context, child) {
      return GetMaterialApp(
        home: InitialScreen(),
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
          useMaterial3: true,
        ),
        title: 'My Colour Cost',
        initialBinding: InitialBinding(),
        getPages: AppPages.pages,
      );
    },
  );
}
