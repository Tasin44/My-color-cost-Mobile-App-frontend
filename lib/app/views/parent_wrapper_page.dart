import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget ParentWrapper({required Widget child}) {
  return Scaffold(
    body: SafeArea(
      child: Padding(
        padding: EdgeInsets.only(left: 16.w, top: 16.h, right: 16.w),
        child: child,
      ),
    ),
  );
}
