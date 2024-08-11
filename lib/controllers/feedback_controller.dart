import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FeedbackController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var nameController = TextEditingController();
  var commentsController = TextEditingController();
  var rating = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    print("FeedbackController initialized");
  }

  @override
  void onClose() {
    nameController.dispose();
    commentsController.dispose();
    print("FeedbackController disposed");
    super.onClose();
  }

  void submitFeedback() async {
    print("Submit feedback called");
    if (nameController.text.isNotEmpty &&
        commentsController.text.isNotEmpty &&
        rating.value > 0) {
      User? user = _auth.currentUser;
      if (user != null) {
        try {
          await _firestore.collection('feedback').add({
            'name': nameController.text,
            'email': user.email,
            'comments': commentsController.text,
            'rating': rating.value,
          });

          Fluttertoast.showToast(
            msg: "Feedback submitted successfully",
            gravity: ToastGravity.TOP,
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );

          clearForm();
        } catch (e) {
          print("Error submitting feedback: $e");
          Fluttertoast.showToast(
            msg: "Failed to submit feedback",
            gravity: ToastGravity.TOP,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      }
    } else {
      Fluttertoast.showToast(
        msg: "Please fill all fields",
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  void clearForm() {
    print("Clearing form");
    nameController.clear();
    commentsController.clear();
    rating.value = 0.0;
  }
}
