import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/profile_controller.dart';

class ProfilePage extends StatelessWidget {
  final ProfileController profileController = Get.put(ProfileController());

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
                  onTap: profileController.pickImage,
                  child: Obx(() => CircleAvatar(
                        radius: 50,
                        backgroundImage: profileController.imageUrl.isNotEmpty
                            ? NetworkImage(profileController.imageUrl.value)
                            : null,
                        child: profileController.imageUrl.isEmpty
                            ? Icon(
                                Icons.camera_alt,
                                size: 50,
                                color: Colors.grey,
                              )
                            : null,
                      )),
                ),
                SizedBox(height: 10),
                Obx(() => Text(
                      'Hi there, ${profileController.username.value}!',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    )),
                TextButton(
                  onPressed: profileController.pickImage,
                  child: Text(
                    'Edit Profile',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
                SizedBox(height: 20),
                _buildTextField('Name', profileController.nameController),
                SizedBox(height: 10),
                _buildTextField(
                    'Password', profileController.passwordController,
                    isPassword: true),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: profileController.updateUserProfile,
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
          profileController.onItemTapped(
              4, context); // Navigate to the home page
        },
        backgroundColor: Colors.orange,
        child: Icon(Icons.home, size: 28, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Obx(() => BottomAppBar(
            shape: CircularNotchedRectangle(),
            notchMargin: 6.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.favorite,
                      color: profileController.selectedIndex.value == 0
                          ? Colors.orange
                          : Colors.grey),
                  onPressed: () {
                    profileController.onItemTapped(0, context);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.rate_review,
                      color: profileController.selectedIndex.value == 1
                          ? Colors.orange
                          : Colors.grey),
                  onPressed: () {
                    profileController.onItemTapped(1, context);
                  },
                ),
                SizedBox(width: 40), // The dummy child
                IconButton(
                  icon: Icon(Icons.person,
                      color: profileController.selectedIndex.value == 2
                          ? Colors.orange
                          : Colors.grey),
                  onPressed: () {
                    profileController.onItemTapped(2, context);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.more_vert,
                      color: profileController.selectedIndex.value == 3
                          ? Colors.orange
                          : Colors.grey),
                  onPressed: () {
                    profileController.onItemTapped(3, context);
                  },
                ),
              ],
            ),
          )),
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
