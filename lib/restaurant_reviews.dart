import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/restaurant_reviews_controller.dart';

class RestaurantReviewsPage extends StatelessWidget {
  final String restaurantId;

  RestaurantReviewsPage({required this.restaurantId});

  @override
  Widget build(BuildContext context) {
    final RestaurantReviewsController reviewsController =
        Get.put(RestaurantReviewsController(restaurantId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Reviews'),
        backgroundColor: Colors.yellow.shade700,
      ),
      body: Container(
        width: double.infinity,
        color: Colors.yellow.shade200, // Set background color
        child: Obx(() {
          if (reviewsController.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }

          if (reviewsController.reviews.isEmpty) {
            return Center(child: Text('No reviews yet.'));
          }

          return ListView.builder(
            itemCount: reviewsController.reviews.length,
            itemBuilder: (context, index) {
              var review = reviewsController.reviews[index].data()
                  as Map<String, dynamic>;
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
                        style: TextStyle(color: Colors.black), // Set text color
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
