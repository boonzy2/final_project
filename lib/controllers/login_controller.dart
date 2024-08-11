import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../firebase_auth_service.dart';

class LoginController extends GetxController {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  var isPasswordVisible = false.obs;

  Future<void> login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Fluttertoast.showToast(
        msg: "All fields are required",
        gravity: ToastGravity.TOP,
      );
      return;
    }

    dynamic user = await _authService.login(email: email, password: password);

    if (user != null) {
      emailController.clear();
      passwordController.clear();
      Get.offNamed('/home');
    } else {
      Fluttertoast.showToast(
        msg: "Invalid login",
        gravity: ToastGravity.TOP,
      );
    }
  }
}
