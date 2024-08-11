import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'restaurant_details.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  String _username = '';
  String _profilePictureUrl = '';
  String selectedCategory = 'All';
  String searchText = '';

  final TextEditingController _searchController = TextEditingController();

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

  Future<void> _toggleFavorite(String restaurantId) async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentReference favoriteRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(restaurantId);

      DocumentSnapshot doc = await favoriteRef.get();
      if (doc.exists) {
        await favoriteRef.delete();
      } else {
        await favoriteRef.set({'favorite': true});
      }

      setState(() {});
    }
  }

  Future<bool> _isFavorite(String restaurantId) async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(restaurantId)
          .get();
      return doc.exists;
    }
    return false;
  }

  Stream<QuerySnapshot> _getRestaurants() {
    Query query = _firestore.collection('restaurants');

    if (selectedCategory != 'All') {
      query = query.where('category', isEqualTo: selectedCategory);
    }

    if (searchText.isNotEmpty) {
      query = query
          .where('name', isGreaterThanOrEqualTo: searchText)
          .where('name', isLessThanOrEqualTo: searchText + '\uf8ff');
    }

    return query.snapshots();
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
                      controller: _searchController,
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
                      onChanged: (value) {
                        setState(() {
                          searchText = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: 16.0), // Padding at the start of the row
                  _buildCategoryChip('All'),
                  SizedBox(width: 8.0),
                  _buildCategoryChip('Fast Food'),
                  SizedBox(width: 8.0),
                  _buildCategoryChip('Pizza'),
                ],
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _getRestaurants(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }
                    final restaurants = snapshot.data!.docs;
                    if (restaurants.isEmpty) {
                      return Center(
                          child: Text('No restaurants match your search.'));
                    }
                    List<Widget> restaurantWidgets = [];
                    for (var restaurant in restaurants) {
                      try {
                        var data = restaurant.data() as Map<String, dynamic>;
                        var name = data['name'];
                        var price = '\$' * data['price'];
                        var address = data['address'];
                        var imageUrl = data['imageUrl'];
                        var reviews = data['reviews'] as List<dynamic>? ?? [];
                        var rating = reviews.isEmpty
                            ? 0.0
                            : reviews
                                    .map((e) => e['rating'])
                                    .reduce((a, b) => a + b) /
                                reviews.length;
                        var deliveryTime = '20 mins';

                        restaurantWidgets.add(
                          FutureBuilder<bool>(
                            future: _isFavorite(restaurant.id),
                            builder: (context, favoriteSnapshot) {
                              bool isFavorite = favoriteSnapshot.data ?? false;
                              return GestureDetector(
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
                                  isFavorite,
                                  () => _toggleFavorite(restaurant.id),
                                ),
                              );
                            },
                          ),
                        );
                      } catch (e) {
                        print('Error processing restaurant data: $e');
                      }
                    }
                    return ListView(
                      children: restaurantWidgets,
                    );
                  },
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
            SizedBox(width: 40),
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
    return ChoiceChip(
      label: Text(label),
      selected: selectedCategory == label,
      onSelected: (bool selected) {
        setState(() {
          selectedCategory = label;
        });
      },
      selectedColor: Colors.orange,
      backgroundColor: Colors.yellow.shade300,
      labelStyle: TextStyle(
          color: selectedCategory == label ? Colors.white : Colors.black),
    );
  }

  Widget _buildFoodCard(
    String title,
    String price,
    String restaurant,
    String rating,
    String deliveryTime,
    String imagePath,
    bool isFavorite,
    VoidCallback onFavoriteToggle,
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
        trailing: IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : Colors.grey,
          ),
          onPressed: onFavoriteToggle,
        ),
      ),
    );
  }
}
