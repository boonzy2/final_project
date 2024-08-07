import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'login.dart';
import 'home.dart';
import 'landing_page.dart';
import 'more.dart';
import 'profile.dart';
import 'payment_details.dart';
import 'about.dart'; // Add this line

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Delivery App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LandingPage(),
      routes: {
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
        '/more': (context) => MorePage(),
        '/profile': (context) => ProfilePage(),
        '/payment_details': (context) => PaymentDetailsPage(),
        '/about': (context) => AboutPage(), // Add the route for About page
      },
    );
  }
}
