import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'firebase_auth_service.dart'; // Import your FirebaseAuthService class
import 'package:fluttertoast/fluttertoast.dart'; // Import fluttertoast for showing toast messages
import 'login.dart'; // Ensure this is the correct path to your login page file
import 'package:firebase_auth/firebase_auth.dart'; // Import User from firebase_auth package

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isPasswordVisible = false;

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
                            _buildTextField(_nameController, 'Name', false),
                            SizedBox(height: 10),
                            _buildTextField(_emailController, 'Email', false),
                            SizedBox(height: 10),
                            _buildPasswordTextField(
                                _passwordController, 'Password'),
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
                                  String email = _emailController.text.trim();
                                  String password =
                                      _passwordController.text.trim();
                                  String name = _nameController.text.trim();

                                  if (email.isEmpty ||
                                      password.isEmpty ||
                                      name.isEmpty) {
                                    Fluttertoast.showToast(
                                        msg: "All fields are required",
                                        gravity: ToastGravity.TOP);
                                    return;
                                  }

                                  User? user = await _authService.signUp(
                                    email: email,
                                    password: password,
                                    name: name,
                                  );

                                  if (user != null) {
                                    _emailController.clear();
                                    _passwordController.clear();
                                    _nameController.clear();
                                    Fluttertoast.showToast(
                                      msg: "Sign Up Successful",
                                      gravity: ToastGravity.TOP,
                                    );
                                  }
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
    return TextField(
      controller: controller,
      obscureText: !_isPasswordVisible,
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
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
      ),
    );
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
