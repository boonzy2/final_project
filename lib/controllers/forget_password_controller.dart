import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../firebase_auth_service.dart';

class ForgetPasswordController extends GetxController {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final emailController = TextEditingController();

  Future<void> sendPasswordResetEmail() async {
    String email = emailController.text.trim();
    if (email.isEmpty) {
      Fluttertoast.showToast(msg: "Please enter your email");
      return;
    }
    await _authService.sendPasswordResetEmail(email);
    Fluttertoast.showToast(
        msg: "Password reset email sent", gravity: ToastGravity.TOP);
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
