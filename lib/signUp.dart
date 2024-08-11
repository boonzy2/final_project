import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'controllers/sign_up_controller.dart'; // Import the SignUpController

class SignUpPage extends StatelessWidget {
  final SignUpController signUpController = Get.put(SignUpController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.yellow.shade200, Colors.yellow.shade100],
                ),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 10), // Space for the logo
                            CircleAvatar(
                              radius: 50, // Adjusted size of the logo
                              backgroundColor: Colors.transparent,
                              backgroundImage: AssetImage(
                                  'images/logo.png'), // Provide your logo image path
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Sign Up',
                              style: TextStyle(
                                fontSize: 26, // Adjusted font size
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Create a Panda account now',
                              style: TextStyle(
                                fontSize: 14, // Adjusted font size
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: 20),
                            _buildTextField(
                                signUpController.nameController, 'Name', false),
                            SizedBox(height: 10),
                            _buildTextField(signUpController.emailController,
                                'Email', false),
                            SizedBox(height: 10),
                            _buildPasswordTextField(
                                signUpController.passwordController,
                                'Password'),
                            SizedBox(height: 20),
                            Text(
                              'or sign up using',
                              style: TextStyle(
                                fontSize: 14, // Adjusted font size
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: 10),
                            _buildSocialButton(
                                'connect with Facebook',
                                Colors.yellow.shade600,
                                FontAwesomeIcons.facebook),
                            SizedBox(height: 10),
                            _buildSocialButton(
                                'connect with Google',
                                Colors.yellow.shade700,
                                FontAwesomeIcons.google),
                            SizedBox(height: 20),
                            SizedBox(
                              width:
                                  250, // Adjusted width to match the width of the sign-up button
                              child: ElevatedButton(
                                onPressed: () async {
                                  await signUpController.signUp();
                                },
                                child: Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white, // Adjusted font size
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors
                                      .yellow.shade800, // Background color
                                  padding: EdgeInsets.symmetric(
                                      vertical: 12), // Adjusted padding
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'already have an account?',
                              style: TextStyle(
                                fontSize: 14, // Adjusted font size
                                color: Colors.grey[700],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/login');
                              },
                              child: Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 14, // Adjusted font size
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String hintText, bool isPassword) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hintText,
        fillColor: Colors.yellow.shade300,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(
            horizontal: 20, vertical: 10), // Adjusted padding
      ),
    );
  }

  Widget _buildPasswordTextField(
      TextEditingController controller, String hintText) {
    return Obx(() => TextField(
          controller: controller,
          obscureText: !signUpController.isPasswordVisible.value,
          decoration: InputDecoration(
            hintText: hintText,
            fillColor: Colors.yellow.shade300,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(
                horizontal: 20, vertical: 10), // Adjusted padding
            suffixIcon: IconButton(
              icon: Icon(
                signUpController.isPasswordVisible.value
                    ? Icons.visibility
                    : Icons.visibility_off,
              ),
              onPressed: () {
                signUpController.isPasswordVisible.value =
                    !signUpController.isPasswordVisible.value;
              },
            ),
          ),
        ));
  }

  Widget _buildSocialButton(String text, Color color, IconData icon) {
    return SizedBox(
      width: 250, // Adjusted width to match the width of the sign-up button
      child: ElevatedButton.icon(
        onPressed: () {
          // Handle social sign in
        },
        icon: Icon(icon, color: Colors.white),
        label: Text(
          text,
          style: TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.symmetric(vertical: 10), // Adjusted padding
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
