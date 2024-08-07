import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart'; // Import Fluttertoast
import 'dart:io';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _imageFile;
  String _imageUrl = '';
  String _username = '';
  String _password = '';
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  int _selectedIndex =
      2; // Set the default selected index to 2 for profile page

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;
      setState(() {
        _username = userData?['name'] ?? 'User';
        _imageUrl = userData != null && userData.containsKey('profilePicture')
            ? userData['profilePicture']
            : '';
        _nameController.text = _username;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    User? user = _auth.currentUser;
    if (user != null) {
      try {
        Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_pictures/${user.uid}');
        UploadTask uploadTask = storageRef.putFile(_imageFile!);
        TaskSnapshot taskSnapshot = await uploadTask;
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();

        await _firestore.collection('users').doc(user.uid).update({
          'profilePicture': downloadUrl,
        });

        setState(() {
          _imageUrl = downloadUrl;
        });
      } catch (e) {
        print('Error occurred: $e');
        // Handle errors here, e.g., show a dialog or toast
      }
    }
  }

  Future<void> _updateUserProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await user.updateDisplayName(_nameController.text);
        await _firestore.collection('users').doc(user.uid).update({
          'name': _nameController.text,
        });

        if (_passwordController.text.isNotEmpty) {
          await user.updatePassword(_passwordController.text);
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove the back arrow
        backgroundColor: Colors.yellow.shade700,
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.yellow.shade200,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        _imageUrl.isNotEmpty ? NetworkImage(_imageUrl) : null,
                    child: _imageUrl.isEmpty
                        ? Icon(
                            Icons.camera_alt,
                            size: 50,
                            color: Colors.grey,
                          )
                        : null,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Hi there, $_username!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: _pickImage,
                  child: Text(
                    'Edit Profile',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
                SizedBox(height: 20),
                _buildTextField('Name', _nameController),
                SizedBox(height: 10),
                _buildTextField('Password', _passwordController,
                    isPassword: true),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _updateUserProfile,
                  child: Text('Save'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.yellow.shade200,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _onItemTapped(4); // Ensure the home button navigates to the home page
        },
        backgroundColor: Colors.orange,
        child: Icon(Icons.home, size: 28, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.favorite,
                  color: _selectedIndex == 0 ? Colors.orange : Colors.grey),
              onPressed: () {
                _onItemTapped(0);
              },
            ),
            IconButton(
              icon: Icon(Icons.location_on,
                  color: _selectedIndex == 1 ? Colors.orange : Colors.grey),
              onPressed: () {
                _onItemTapped(1);
              },
            ),
            SizedBox(width: 40), // The dummy child
            IconButton(
              icon: Icon(Icons.person,
                  color: _selectedIndex == 2 ? Colors.orange : Colors.grey),
              onPressed: () {
                _onItemTapped(2);
              },
            ),
            IconButton(
              icon: Icon(Icons.more_vert,
                  color: _selectedIndex == 3 ? Colors.orange : Colors.grey),
              onPressed: () {
                _onItemTapped(3);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hintText, TextEditingController controller,
      {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: hintText,
        fillColor: Colors.yellow.shade300,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
    );
  }
}
