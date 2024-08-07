import 'package:flutter/material.dart';
import 'login.dart'; // Ensure this is the correct path to your login page file

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Spacer(flex: 3), // Increase spacing at the top
              Text(
                'Quick\nBites, Fast\nDelivery!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: Text(
                  'Get Started',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, // Background color
                  padding: EdgeInsets.symmetric(
                      horizontal: 30, vertical: 12), // Smaller button
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(10), // Less curved borders
                  ),
                ),
              ),
              Spacer(flex: 3), // Adjust spacing between button and image
              Align(
                alignment: Alignment.centerRight, // Move image to the right
                child: Image.asset(
                  'images/delivery_man.png',
                  height: 300, // Adjusted image size
                ),
              ),
              Spacer(flex: 3), // Add spacing at the bottom
            ],
          ),
        ),
      ),
    );
  }
}
