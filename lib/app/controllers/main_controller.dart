import 'package:get/get.dart';

class MainController extends GetxController {
  // Observable for current index
  final RxInt currentIndex = 0.obs;

  // Method to change tab
  void changeTab(int index) {
    currentIndex.value = index;
  }
}
