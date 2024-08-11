import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart'; // Import GetX
import 'firebase_options.dart';
import 'login.dart';
import 'home.dart';
import 'landing_page.dart';
import 'more.dart';
import 'profile.dart';
import 'payment_details.dart';
import 'about.dart';
import 'restaurant_details.dart';
import 'item_details.dart';
import 'cart.dart';
import 'favorites.dart';
import 'terms.dart';
import 'restaurant_reviews.dart';
import 'review.dart';
import 'feedback.dart';

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
    return GetMaterialApp(
      // Use GetMaterialApp instead of MaterialApp
      title: 'Food Delivery App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/', // Set the initial route
      getPages: [
        GetPage(name: '/', page: () => LandingPage()),
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(name: '/home', page: () => HomePage()),
        GetPage(name: '/more', page: () => MorePage()),
        GetPage(name: '/profile', page: () => ProfilePage()),
        GetPage(name: '/payment_details', page: () => PaymentDetailsPage()),
        GetPage(
            name: '/about',
            page: () => AboutPage()), // Add the route for About page
        GetPage(name: '/cart', page: () => CartPage()),
        // Dynamic routes for restaurant and item details
        GetPage(
            name: '/restaurantDetails',
            page: () => RestaurantDetailsPage(restaurantId: '')),
        GetPage(
            name: '/itemDetails',
            page: () => ItemDetailsPage(itemId: '', restaurantId: '')),
        GetPage(name: '/favorites', page: () => FavoritesPage()),
        GetPage(name: '/terms', page: () => TermsPage()),
        GetPage(name: '/location', page: () => ReviewPage()),
        GetPage(name: '/feedback', page: () => FeedbackPage()),
        GetPage(
            name: '/restaurant_reviews',
            page: () => RestaurantReviewsPage(restaurantId: '')),
      ],
    );
  }
}
