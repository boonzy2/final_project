import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MorePage extends StatefulWidget {
  @override
  _MorePageState createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  int _selectedIndex = 3; // Default index for the "More" page

  final FirebaseAuth _auth = FirebaseAuth.instance;

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
      default:
        Navigator.pushReplacementNamed(context, '/home');
    }
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

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
              Navigator.pushNamed(context, '/cart');
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
                Navigator.pushNamed(context, '/payment_details');
              },
            ),
            SizedBox(height: 16),
            _buildListTile(
              context,
              icon: Icons.shopping_bag,
              title: 'My Orders',
              onTap: () {
                // Navigate to My Orders page
              },
            ),
            SizedBox(height: 16),
            _buildListTile(
              context,
              icon: Icons.feedback,
              title: 'Feedback',
              onTap: () {
                // Navigate to Feedback page
              },
            ),
            SizedBox(height: 16),
            _buildListTile(
              context,
              icon: Icons.mail,
              title: 'Inbox',
              onTap: () {
                // Navigate to Inbox page
              },
            ),
            SizedBox(height: 16),
            _buildListTile(
              context,
              icon: Icons.info,
              title: 'About Us',
              onTap: () {
                Navigator.pushNamed(context, '/about');
              },
            ),
            SizedBox(height: 16),
            _buildListTile(
              context,
              icon: Icons.description,
              title: 'Terms and Service',
              onTap: () {
                Navigator.pushNamed(context, '/terms');
              },
            ),
            SizedBox(height: 16),
            _buildListTile(
              context,
              icon: Icons.exit_to_app,
              title: 'Logout',
              onTap: _signOut,
            ),
          ],
        ),
      ),
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
