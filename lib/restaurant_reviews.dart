import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantReviewsPage extends StatelessWidget {
  final String restaurantId;

  RestaurantReviewsPage({required this.restaurantId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reviews'),
        backgroundColor: Colors.yellow.shade700,
      ),
      body: Container(
        width: double.infinity,
        color: Colors.yellow.shade200, // Set background color
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('restaurants')
              .doc(restaurantId)
              .collection('reviews')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            final reviews = snapshot.data!.docs;
            if (reviews.isEmpty) {
              return Center(child: Text('No reviews yet.'));
            }

            return ListView.builder(
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                var review = reviews[index].data() as Map<String, dynamic>;
                return Card(
                  color: Colors.yellow.shade300, // Set card background color
                  child: ListTile(
                    title: Text(
                      review['comment'],
                      style: TextStyle(
                        color: Colors.black, // Set text color
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Row(
                      children: [
                        Icon(Icons.star, color: Colors.orange, size: 16),
                        SizedBox(width: 4),
                        Text(
                          review['rating'].toString(),
                          style:
                              TextStyle(color: Colors.black), // Set text color
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
