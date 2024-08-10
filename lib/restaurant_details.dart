import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'item_details.dart';

class RestaurantDetailsPage extends StatelessWidget {
  final String restaurantId;

  RestaurantDetailsPage({required this.restaurantId});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Number of tabs (burgers, salads, etc.)
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Restaurant Details',
            style: TextStyle(color: Colors.black), // Updated text color
          ),
          backgroundColor: Colors.yellow.shade700, // Updated background color
          iconTheme: IconThemeData(color: Colors.black), // Update icon color
          actions: [
            IconButton(
              icon: Icon(Icons.shopping_cart, color: Colors.black),
              onPressed: () {
                Navigator.pushNamed(context, '/cart');
              },
            ),
          ],
        ),
        body: Container(
          color: Colors.yellow.shade200, // Set background color
          child: FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('restaurants')
                .doc(restaurantId)
                .get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              var restaurantData =
                  snapshot.data!.data() as Map<String, dynamic>;

              return Column(
                children: [
                  // Restaurant Image
                  Image.network(
                    restaurantData['imageUrl'],
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(height: 8),
                  // Tabs for categories
                  TabBar(
                    isScrollable: true,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey.shade600,
                    indicatorColor: Colors.yellow.shade700,
                    tabs: [
                      Tab(text: 'Mains'),
                      Tab(text: 'Sides'),
                      Tab(text: 'Dessert'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        buildMenuList('Mains'),
                        buildMenuList('Sides'),
                        buildMenuList('Dessert'),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildMenuList(String category) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('items')
          .where('restaurantId', isEqualTo: restaurantId)
          .where('category', isEqualTo: category)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final items = snapshot.data!.docs;

        if (items.isEmpty) {
          return Center(child: Text('No menu items available.'));
        }

        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            var itemData = items[index].data() as Map<String, dynamic>;
            return MenuItemCard(
              itemId: items[index].id,
              name: itemData['name'],
              description: itemData['description'],
              price: itemData['price'],
              imageUrl: itemData['imageUrl'],
              restaurantId: restaurantId,
            );
          },
        );
      },
    );
  }
}

class MenuItemCard extends StatelessWidget {
  final String itemId;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String restaurantId;

  MenuItemCard({
    required this.itemId,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.restaurantId,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
        color: Colors.yellow.shade300, // Updated card background color
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ItemDetailsPage(
                  itemId: itemId,
                  restaurantId: restaurantId,
                ),
              ),
            );
          },
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  imageUrl,
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black), // Updated text color
                      ),
                      SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(color: Colors.grey[800]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      Text(
                        '\$$price',
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
