import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'restaurant_details.dart'; // Ensure this import is correct

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  String _username = '';
  String _profilePictureUrl = '';

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
        _profilePictureUrl = userData?['profilePicture'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow.shade700,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
              child: CircleAvatar(
                radius: 20,
                backgroundImage: _profilePictureUrl.isNotEmpty
                    ? NetworkImage(_profilePictureUrl)
                    : AssetImage('images/default_profile.png') as ImageProvider,
              ),
            ),
            Text(
              'QuickBites',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            IconButton(
              icon: Icon(Icons.shopping_cart, color: Colors.black),
              onPressed: () {
                Navigator.pushNamed(context, '/cart');
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          color: Colors.yellow.shade200,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8.0),
                    Text(
                      'Hello, $_username!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'What would you like to eat?',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        fillColor: Colors.yellow.shade300,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Categories',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildCategoryChip('All'),
                                _buildCategoryChip('Burger'),
                                _buildCategoryChip('Doughnut'),
                              ],
                            ),
                            SizedBox(height: 16.0),
                            StreamBuilder<QuerySnapshot>(
                              stream: _firestore
                                  .collection('restaurants')
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return Center(
                                      child: Text('Error: ${snapshot.error}'));
                                }
                                if (!snapshot.hasData) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                }
                                final restaurants = snapshot.data!.docs;
                                List<Widget> restaurantWidgets = [];
                                for (var restaurant in restaurants) {
                                  try {
                                    var data = restaurant.data()
                                        as Map<String, dynamic>;
                                    var name = data['name'];
                                    var price = '\$' * data['price'];
                                    var address = data['address'];
                                    var imageUrl = data['imageUrl'];
                                    var reviews =
                                        data['reviews'] as List<dynamic>? ?? [];
                                    var rating = reviews.isEmpty
                                        ? 0.0
                                        : reviews
                                                .map((e) => e['rating'])
                                                .reduce((a, b) => a + b) /
                                            reviews.length;
                                    var deliveryTime =
                                        '20 mins'; // This would typically be calculated or stored in the database

                                    restaurantWidgets.add(
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  RestaurantDetailsPage(
                                                restaurantId: restaurant.id,
                                              ),
                                            ),
                                          );
                                        },
                                        child: _buildFoodCard(
                                          name,
                                          price,
                                          address,
                                          rating.toStringAsFixed(1),
                                          deliveryTime,
                                          imageUrl,
                                        ),
                                      ),
                                    );
                                  } catch (e) {
                                    print(
                                        'Error processing restaurant data: $e');
                                  }
                                }
                                return Column(
                                  children: restaurantWidgets,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/home');
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
              icon: Icon(Icons.favorite, color: Colors.grey),
              onPressed: () {
                Navigator.pushNamed(context, '/favorites');
              },
            ),
            IconButton(
              icon: Icon(Icons.location_on, color: Colors.grey),
              onPressed: () {
                Navigator.pushNamed(context, '/location');
              },
            ),
            SizedBox(width: 40), // The dummy child
            IconButton(
              icon: Icon(Icons.person, color: Colors.grey),
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
            IconButton(
              icon: Icon(Icons.more_vert, color: Colors.grey),
              onPressed: () {
                Navigator.pushNamed(context, '/more');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: Colors.yellow.shade300,
    );
  }

  Widget _buildFoodCard(
    String title,
    String price,
    String restaurant,
    String rating,
    String deliveryTime,
    String imagePath,
  ) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(imagePath),
        ),
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$price • $restaurant'),
            Row(
              children: [
                Icon(Icons.star, size: 16, color: Colors.orange),
                Text('$rating • $deliveryTime'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
