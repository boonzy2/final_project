import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/feedback_controller.dart';

class FeedbackPage extends StatelessWidget {
  final FeedbackController feedbackController = Get.put(FeedbackController());

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
              controller: feedbackController.nameController,
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
              controller: feedbackController.commentsController,
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
                  child: Obx(() => Slider(
                        value: feedbackController.rating.value,
                        onChanged: (value) {
                          feedbackController.rating.value = value;
                        },
                        divisions: 10,
                        label: feedbackController.rating.value.toString(),
                        min: 0.0,
                        max: 5.0,
                      )),
                ),
                Obx(() =>
                    Text(feedbackController.rating.value.toStringAsFixed(1))),
              ],
            ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  feedbackController.submitFeedback();
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
