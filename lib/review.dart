import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'restaurant_reviews.dart';

class ReviewPage extends StatefulWidget {
  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String selectedRestaurantId = '';
  String reviewText = '';
  double rating = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Write a Review'),
        backgroundColor: Colors.yellow.shade700,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('restaurants').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }

                List<DropdownMenuItem<String>> restaurantItems = [];
                for (var doc in snapshot.data!.docs) {
                  var restaurantData = doc.data() as Map<String, dynamic>;
                  restaurantItems.add(
                    DropdownMenuItem(
                      child: Text(restaurantData['name']),
                      value: doc.id,
                    ),
                  );
                }

                return DropdownButton<String>(
                  value: selectedRestaurantId.isEmpty
                      ? null
                      : selectedRestaurantId,
                  hint: Text('Choose a Restaurant'),
                  items: restaurantItems,
                  onChanged: (value) {
                    setState(() {
                      selectedRestaurantId = value!;
                    });
                  },
                  isExpanded: true,
                );
              },
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Write your review',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) {
                setState(() {
                  reviewText = value;
                });
              },
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text('Rating:'),
                Expanded(
                  child: Slider(
                    value: rating,
                    onChanged: (value) {
                      setState(() {
                        rating = value;
                      });
                    },
                    divisions: 10,
                    label: rating.toString(),
                    min: 0.0,
                    max: 5.0,
                  ),
                ),
                Text(rating.toStringAsFixed(1)),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (selectedRestaurantId.isNotEmpty &&
                    reviewText.isNotEmpty &&
                    rating > 0) {
                  await _firestore
                      .collection('restaurants')
                      .doc(selectedRestaurantId)
                      .collection('reviews')
                      .add({
                    'comment': reviewText,
                    'rating': rating,
                    'userId': _auth.currentUser!.uid,
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Review submitted successfully')),
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RestaurantReviewsPage(
                        restaurantId: selectedRestaurantId,
                      ),
                    ),
                  );
                }
              },
              child: Text('Submit Review'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.orange, // Use backgroundColor instead of primary
              ),
            )
          ],
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
              icon: Icon(Icons.rate_review, color: Colors.orange),
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
}
