import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';

class ProfileController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var imageFile = Rx<File?>(null);
  var imageUrl = ''.obs;
  var username = ''.obs;
  var selectedIndex = 2.obs;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;
      username.value = userData?['name'] ?? 'User';
      imageUrl.value =
          userData != null && userData.containsKey('profilePicture')
              ? userData['profilePicture']
              : '';
      nameController.text = username.value;
    }
  }

  Future<void> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      imageFile.value = File(pickedFile.path);
      _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    if (imageFile.value == null) return;

    User? user = _auth.currentUser;
    if (user != null) {
      try {
        Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_pictures/${user.uid}');
        UploadTask uploadTask = storageRef.putFile(imageFile.value!);
        TaskSnapshot taskSnapshot = await uploadTask;
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();

        await _firestore.collection('users').doc(user.uid).update({
          'profilePicture': downloadUrl,
        });

        imageUrl.value = downloadUrl;
      } catch (e) {
        print('Error occurred: $e');
        Fluttertoast.showToast(
          msg: "Error uploading image: $e",
          gravity: ToastGravity.TOP,
        );
      }
    }
  }

  Future<void> updateUserProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await user.updateDisplayName(nameController.text);
        await _firestore.collection('users').doc(user.uid).update({
          'name': nameController.text,
        });

        if (passwordController.text.isNotEmpty) {
          await user.updatePassword(passwordController.text);
        }

        Fluttertoast.showToast(
          msg: "Profile updated successfully",
          gravity: ToastGravity.TOP,
        );
      } catch (e) {
        print('Error occurred: $e');
        Fluttertoast.showToast(
          msg: "Error updating profile: $e",
          gravity: ToastGravity.TOP,
        );
      }
    }
  }

  void onItemTapped(int index, BuildContext context) {
    selectedIndex.value = index;

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/favorites');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/location');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/more');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/home');
        break;
    }
  }
}
