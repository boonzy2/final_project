import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/login_controller.dart';
import 'forget_password.dart';
import 'signUp.dart';

class LoginPage extends StatelessWidget {
  final LoginController loginController = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          color: Colors.yellow.shade200, // Set background color
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 30.0,
                        vertical: 30.0), // Adjusted vertical padding
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 30), // Reduced height
                        CircleAvatar(
                          radius: 60, // Adjusted size of the logo
                          backgroundColor: Colors.transparent,
                          backgroundImage: AssetImage(
                              'images/logo.png'), // Provide your logo image path
                        ),
                        SizedBox(height: 20),
                        Text(
                          'QuickBites',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Food Delivery App',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 30), // Reduced height
                        _buildTextField('Email Address', false,
                            loginController.emailController),
                        SizedBox(height: 20),
                        _buildPasswordTextField(
                            'Password', loginController.passwordController),
                        SizedBox(height: 20), // Reduced height
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Get.to(() => ForgetPasswordPage());
                              },
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        SizedBox(
                          width:
                              250, // Adjusted width to match the width of the sign-up button
                          child: ElevatedButton(
                            onPressed: () async {
                              await loginController.login();
                            },
                            child: Text(
                              'Login',
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.yellow[700], // Background color
                              padding: EdgeInsets.symmetric(
                                  vertical: 15), // Adjusted padding
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Don\'t Have Account?',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(width: 5),
                            GestureDetector(
                              onTap: () {
                                Get.to(() => SignUpPage());
                              },
                              child: Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String hintText, bool isPassword, TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: hintText,
        fillColor: Colors.yellow.shade300, // Set background color
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none, // Remove border side
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
    );
  }

  Widget _buildPasswordTextField(
      String hintText, TextEditingController controller) {
    return Obx(() => TextField(
          controller: controller,
          obscureText: !loginController.isPasswordVisible.value,
          decoration: InputDecoration(
            labelText: hintText,
            fillColor: Colors.yellow.shade300, // Set background color
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none, // Remove border side
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            suffixIcon: IconButton(
              icon: Icon(
                loginController.isPasswordVisible.value
                    ? Icons.visibility
                    : Icons.visibility_off,
              ),
              onPressed: () {
                loginController.isPasswordVisible.value =
                    !loginController.isPasswordVisible.value;
              },
            ),
          ),
        ));
  }
}
