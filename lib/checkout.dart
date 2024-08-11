import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/standalone.dart' as tz;

class CheckoutPage extends StatelessWidget {
  CheckoutPage() {
    // Initialize the timezone database
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Singapore'));
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Delivery in progress..'),
        backgroundColor: Colors.yellow.shade700,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('carts')
            .doc(currentUser!.uid)
            .collection('items')
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'Your cart is empty.',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
            );
          }

          double totalPrice = 0.0;
          int totalItems = 0;

          // Iterating through the cart items before building the widget
          snapshot.data!.docs.forEach((doc) {
            var cartItem = doc.data() as Map<String, dynamic>;
            double itemTotal = cartItem['price'] ?? 0.0;
            int quantity = cartItem['quantity'] ?? 1;
            double addOnsTotal = 0.0;

            for (var addOn in cartItem['addOns']) {
              if (addOn is Map<String, dynamic>) {
                addOnsTotal += addOn['price'] ?? 0.0;
              }
            }

            itemTotal = (itemTotal + addOnsTotal) * quantity;
            totalPrice += itemTotal;
            totalItems += quantity;
          });

          // Get the current time in Singapore
          final singaporeTime =
              tz.TZDateTime.now(tz.getLocation('Asia/Singapore'));

          return Container(
            color: Colors.yellow.shade200, // Set background color
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Thank you for your order!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Here's your receipt:",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  DateFormat('yyyy-MM-dd HH:mm:ss').format(singaporeTime),
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
                Divider(thickness: 1, color: Colors.black),
                Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var cartItem = snapshot.data!.docs[index].data()
                          as Map<String, dynamic>;

                      double itemTotal = cartItem['price'] ?? 0.0;
                      int quantity = cartItem['quantity'] ?? 1;
                      double addOnsTotal = 0.0;

                      List<String> addOns = [];
                      for (var addOn in cartItem['addOns']) {
                        if (addOn is Map<String, dynamic>) {
                          addOnsTotal += addOn['price'] ?? 0.0;
                          addOns.add(
                              "${addOn['name']} (\$${addOn['price'].toStringAsFixed(2)})");
                        }
                      }

                      itemTotal = (itemTotal + addOnsTotal) * quantity;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "$quantity x ${cartItem['name']} - \$${itemTotal.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          if (addOns.isNotEmpty) ...[
                            SizedBox(height: 5),
                            Text(
                              'Add-ons: ${addOns.join(', ')}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                          Divider(thickness: 1, color: Colors.black),
                        ],
                      );
                    },
                  ),
                ),
                Text(
                  "Total Items: $totalItems",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Total Price: \$${totalPrice.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Estimated delivery time is: ${DateFormat.jm().format(singaporeTime.add(Duration(minutes: 30)))}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
