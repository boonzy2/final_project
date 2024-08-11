import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../firebase_auth_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpController extends GetxController {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  var isPasswordVisible = false.obs;

  Future<void> signUp() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String name = nameController.text.trim();

    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      Fluttertoast.showToast(
          msg: "All fields are required", gravity: ToastGravity.TOP);
      return;
    }

    User? user = await _authService.signUp(
      email: email,
      password: password,
      name: name,
    );

    if (user != null) {
      emailController.clear();
      passwordController.clear();
      nameController.clear();
      Fluttertoast.showToast(
        msg: "Sign Up Successful",
        gravity: ToastGravity.TOP,
      );
    }
  }
}
