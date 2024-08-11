import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeedbackPage extends StatefulWidget {
  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _name = '';
  double _rating = 0.0;
  String _comments = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Submit Feedback'),
        backgroundColor: Colors.yellow.shade700,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Your Name',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _name = value;
                });
              },
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Your Comments',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) {
                setState(() {
                  _comments = value;
                });
              },
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
            ElevatedButton(
              onPressed: () async {
                if (_name.isNotEmpty && _comments.isNotEmpty && _rating > 0) {
                  User? user = _auth.currentUser;
                  if (user != null) {
                    await _firestore.collection('feedback').add({
                      'name': _name,
                      'email': user.email,
                      'comments': _comments,
                      'rating': _rating,
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Feedback submitted successfully')),
                    );

                    // Clear the form after submission
                    setState(() {
                      _name = '';
                      _rating = 0.0;
                      _comments = '';
                    });
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill all fields')),
                  );
                }
              },
              child: Text('Submit Feedback'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
