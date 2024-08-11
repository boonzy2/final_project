import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../restaurant_reviews.dart';

class ReviewController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var selectedRestaurantId = ''.obs;
  var reviewText = ''.obs;
  var rating = 0.0.obs;
  var restaurants = <DropdownMenuItem<String>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _fetchRestaurants();
  }

  void _fetchRestaurants() async {
    QuerySnapshot snapshot = await _firestore.collection('restaurants').get();

    var restaurantItems = snapshot.docs.map((doc) {
      var restaurantData = doc.data() as Map<String, dynamic>;
      return DropdownMenuItem<String>(
        child: Text(restaurantData['name']),
        value: doc.id,
      );
    }).toList();

    restaurants.value = restaurantItems;
  }

  Future<void> submitReview() async {
    if (selectedRestaurantId.isNotEmpty &&
        reviewText.isNotEmpty &&
        rating.value > 0) {
      await _firestore
          .collection('restaurants')
          .doc(selectedRestaurantId.value)
          .collection('reviews')
          .add({
        'comment': reviewText.value,
        'rating': rating.value,
        'userId': _auth.currentUser!.uid,
      });

      Fluttertoast.showToast(
        msg: "Review submitted successfully",
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      // Navigate to the RestaurantReviewsPage with the selectedRestaurantId
      Get.to(() =>
          RestaurantReviewsPage(restaurantId: selectedRestaurantId.value));
    } else {
      Fluttertoast.showToast(
        msg: "Please fill all fields",
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }
}
