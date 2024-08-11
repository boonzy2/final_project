import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart'; // Import Fluttertoast

class FeedbackPage extends StatefulWidget {
  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _commentsController = TextEditingController();
  double _rating = 0.0;

  @override
  void dispose() {
    // Dispose of the controllers when the widget is removed from the widget tree
    _nameController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Submit Feedback'),
        backgroundColor: Colors.yellow.shade700,
      ),
      body: Container(
        width: double.infinity,
        color: Colors.yellow.shade200, // Set background color
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Your Name',
                fillColor: Colors.yellow.shade300, // Match text field color
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _commentsController,
              decoration: InputDecoration(
                labelText: 'Your Comments',
                fillColor: Colors.yellow.shade300, // Match text field color
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text('Rating:'),
                Expanded(
                  child: Slider(
                    value: _rating,
                    onChanged: (value) {
                      setState(() {
                        _rating = value;
                      });
                    },
                    divisions: 10,
                    label: _rating.toString(),
                    min: 0.0,
                    max: 5.0,
                  ),
                ),
                Text(_rating.toStringAsFixed(1)),
              ],
            ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (_nameController.text.isNotEmpty &&
                      _commentsController.text.isNotEmpty &&
                      _rating > 0) {
                    User? user = _auth.currentUser;
                    if (user != null) {
                      await _firestore.collection('feedback').add({
                        'name': _nameController.text,
                        'email': user.email,
                        'comments': _commentsController.text,
                        'rating': _rating,
                      });

                      Fluttertoast.showToast(
                        msg: "Feedback submitted successfully",
                        gravity: ToastGravity.TOP,
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                      );

                      // Clear the form after submission
                      setState(() {
                        _nameController.clear();
                        _commentsController.clear();
                        _rating = 0.0;
                      });
                    }
                  } else {
                    Fluttertoast.showToast(
                      msg: "Please fill all fields",
                      gravity: ToastGravity.TOP,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                    );
                  }
                },
                child: Text('Submit Feedback'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow[700], // Match button color
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
