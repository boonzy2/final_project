import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/forget_password_controller.dart'; // Import the controller

class ForgetPasswordPage extends StatelessWidget {
  final ForgetPasswordController controller =
      Get.put(ForgetPasswordController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          color: Colors.yellow.shade200, // Set background color
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 16, left: 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back,
                          size: 32), // Increase icon size
                      onPressed: () {
                        Navigator.pop(
                            context); // Navigate back to the previous page
                      },
                    ),
                  ],
                ),
              ),
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
                        _buildTextField(
                            'Email Address', controller.emailController),
                        SizedBox(height: 20), // Reduced height
                        SizedBox(
                          width:
                              250, // Adjusted width to match the width of the sign-up button
                          child: ElevatedButton(
                            onPressed: controller.sendPasswordResetEmail,
                            child: Text(
                              'Reset Password',
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

  Widget _buildTextField(String hintText, TextEditingController controller) {
    return TextField(
      controller: controller,
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
}
