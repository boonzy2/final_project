import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/review_controller.dart';

class ReviewPage extends StatelessWidget {
  final ReviewController reviewController = Get.put(ReviewController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Write a Review'),
        backgroundColor: Colors.yellow.shade700,
        automaticallyImplyLeading: false, // Removes the back arrow
      ),
      body: Container(
        width: double.infinity,
        color: Colors.yellow.shade200, // Set background color
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() {
                if (reviewController.restaurants.isEmpty) {
                  return CircularProgressIndicator();
                }

                return DropdownButton<String>(
                  value: reviewController.selectedRestaurantId.isEmpty
                      ? null
                      : reviewController.selectedRestaurantId.value,
                  hint: Text('Choose a Restaurant'),
                  items: reviewController.restaurants,
                  onChanged: (value) {
                    reviewController.selectedRestaurantId.value = value!;
                  },
                  isExpanded: true,
                  dropdownColor: Colors.yellow.shade300,
                );
              }),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Write your review',
                  fillColor: Colors.yellow.shade300, // Set background color
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                maxLines: 3,
                onChanged: (value) {
                  reviewController.reviewText.value = value;
                },
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Text('Rating:'),
                  Expanded(
                    child: Obx(() => Slider(
                          value: reviewController.rating.value,
                          onChanged: (value) {
                            reviewController.rating.value = value;
                          },
                          divisions: 10,
                          label: reviewController.rating.toString(),
                          min: 0.0,
                          max: 5.0,
                        )),
                  ),
                  Obx(() =>
                      Text(reviewController.rating.value.toStringAsFixed(1))),
                ],
              ),
              SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    await reviewController.submitReview();
                  },
                  child: Text('Submit Review'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors
                        .yellow[700], // Follow the Login page button color
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed('/home');
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
                Get.toNamed('/favorites');
              },
            ),
            IconButton(
              icon: Icon(Icons.rate_review,
                  color: Colors.orange), // Highlight review icon
              onPressed: () {
                Get.toNamed('/location');
              },
            ),
            SizedBox(width: 40), // The dummy child
            IconButton(
              icon: Icon(Icons.person, color: Colors.grey),
              onPressed: () {
                Get.toNamed('/profile');
              },
            ),
            IconButton(
              icon: Icon(Icons.more_vert, color: Colors.grey),
              onPressed: () {
                Get.toNamed('/more');
              },
            ),
          ],
        ),
      ),
    );
  }
}
