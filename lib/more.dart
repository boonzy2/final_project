import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/more_controller.dart';

class MorePage extends StatelessWidget {
  final MoreController moreController = Get.put(MoreController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove the back arrow
        backgroundColor: Colors.yellow.shade700,
        title: Text('More'),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Get.toNamed('/cart');
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.yellow.shade200,
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildListTile(
              context,
              icon: Icons.payment,
              title: 'Payment Details',
              onTap: () {
                Get.toNamed('/payment_details');
              },
            ),
            SizedBox(height: 16),
            _buildListTile(
              context,
              icon: Icons.feedback,
              title: 'Feedback',
              onTap: () {
                Get.toNamed('/feedback');
              },
            ),
            SizedBox(height: 16),
            _buildListTile(
              context,
              icon: Icons.info,
              title: 'About Us',
              onTap: () {
                Get.toNamed('/about');
              },
            ),
            SizedBox(height: 16),
            _buildListTile(
              context,
              icon: Icons.description,
              title: 'Terms and Service',
              onTap: () {
                Get.toNamed('/terms');
              },
            ),
            SizedBox(height: 16),
            _buildListTile(
              context,
              icon: Icons.exit_to_app,
              title: 'Logout',
              onTap: moreController.signOut,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          moreController.onItemTapped(4); // Navigate to the home page
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
                      color: moreController.selectedIndex.value == 0
                          ? Colors.orange
                          : Colors.grey),
                  onPressed: () {
                    moreController.onItemTapped(0);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.rate_review,
                      color: moreController.selectedIndex.value == 1
                          ? Colors.orange
                          : Colors.grey),
                  onPressed: () {
                    moreController.onItemTapped(1);
                  },
                ),
                SizedBox(width: 40), // The dummy child
                IconButton(
                  icon: Icon(Icons.person,
                      color: moreController.selectedIndex.value == 2
                          ? Colors.orange
                          : Colors.grey),
                  onPressed: () {
                    moreController.onItemTapped(2);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.more_vert,
                      color: moreController.selectedIndex.value == 3
                          ? Colors.orange
                          : Colors.grey),
                  onPressed: () {
                    moreController.onItemTapped(3);
                  },
                ),
              ],
            ),
          )),
    );
  }

  Widget _buildListTile(BuildContext context,
      {required IconData icon,
      required String title,
      Widget? trailing,
      required Function onTap}) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.yellow.shade300,
        child: Icon(icon, color: Colors.grey),
      ),
      title: Text(title),
      trailing: trailing ?? Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => onTap(),
    );
  }
}
