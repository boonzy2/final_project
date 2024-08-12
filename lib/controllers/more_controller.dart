import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MoreController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var selectedIndex = 3.obs;
  var isLoading = false.obs; // Observable to track loading state

  void onItemTapped(int index) {
    selectedIndex.value = index;

    switch (index) {
      case 0:
        Get.offNamed('/favorites');
        break;
      case 1:
        Get.offNamed('/location');
        break;
      case 2:
        Get.offNamed('/profile');
        break;
      case 3:
        Get.offNamed('/more');
        break;
      case 4:
        Get.offNamed('/home');
        break;
      default:
        Get.offNamed('/home');
    }
  }

  Future<void> signOut() async {
    try {
      isLoading.value = true; // Set loading state to true
      // Show loading dialog
      Get.dialog(
        Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      // Perform sign out
      await _auth.signOut();

      // Navigate to the login page
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to log out: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false; // Reset loading state
      Get.back(); // Ensure the dialog is dismissed
    }
  }
}
