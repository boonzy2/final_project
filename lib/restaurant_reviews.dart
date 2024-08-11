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
      body: StreamBuilder<QuerySnapshot>(
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
              return ListTile(
                title: Text(review['comment']),
                subtitle: Row(
                  children: [
                    Icon(Icons.star, color: Colors.orange, size: 16),
                    SizedBox(width: 4),
                    Text(review['rating'].toString()),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
