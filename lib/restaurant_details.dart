import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RestaurantDetailsPage extends StatelessWidget {
  final String restaurantId;

  RestaurantDetailsPage({required this.restaurantId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Restaurant Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('restaurants')
            .doc(restaurantId)
            .get(),
        builder: (context, restaurantSnapshot) {
          if (restaurantSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!restaurantSnapshot.hasData || !restaurantSnapshot.data!.exists) {
            return Center(child: Text('Restaurant Data Not Found'));
          }

          var restaurantData =
              restaurantSnapshot.data!.data() as Map<String, dynamic>;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display Restaurant Image
              CachedNetworkImage(
                imageUrl: restaurantData['imageUrl'],
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) =>
                    Icon(Icons.error, size: 50),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Restaurant Name
                    Text(
                      restaurantData['name'],
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    // Restaurant Address
                    Text(
                      restaurantData['address'],
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Menu',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                  ],
                ),
              ),
              // Display Menu Items
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('items')
                      .where('restaurantId', isEqualTo: restaurantId)
                      .snapshots(),
                  builder: (context, itemSnapshot) {
                    if (itemSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (!itemSnapshot.hasData ||
                        itemSnapshot.data!.docs.isEmpty) {
                      return Center(child: Text('No menu items available.'));
                    }

                    return ListView.builder(
                      itemCount: itemSnapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var itemData = itemSnapshot.data!.docs[index].data()
                            as Map<String, dynamic>;

                        return ListTile(
                          leading: CachedNetworkImage(
                            imageUrl: itemData['imageUrl'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                          title: Text(itemData['name']),
                          subtitle: Text(itemData['description']),
                          trailing: Text('\$${itemData['price']}'),
                          onTap: () {
                            // Handle item tap if needed
                            print('Tapped on ${itemData['name']}');
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
