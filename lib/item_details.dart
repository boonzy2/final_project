import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'restaurant_details.dart'; // Import the RestaurantDetailsPage

class ItemDetailsPage extends StatefulWidget {
  final String itemId;
  final String restaurantId;

  ItemDetailsPage({required this.itemId, required this.restaurantId});

  @override
  _ItemDetailsPageState createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  Map<String, dynamic> selectedAddOns = {};

  Future<void> addToCart() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final cartRef = FirebaseFirestore.instance
        .collection('carts')
        .doc(currentUser!.uid)
        .collection('items');

    final cartSnapshot = await cartRef.get();

    // Check if the cart contains items from another restaurant
    if (cartSnapshot.docs.isNotEmpty) {
      var firstCartItem =
          cartSnapshot.docs.first.data() as Map<String, dynamic>;
      if (firstCartItem['restaurantId'] != widget.restaurantId) {
        // Show a message and return, do not add the item
        Fluttertoast.showToast(
          msg: "Your cart already contains items from another restaurant.",
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        return;
      }
    }

    final cartItemRef = cartRef.doc(widget.itemId);
    final cartItemSnapshot = await cartItemRef.get();
    final itemData = (await FirebaseFirestore.instance
            .collection('items')
            .doc(widget.itemId)
            .get())
        .data();

    List<Map<String, dynamic>> addOnsList = selectedAddOns.values
        .map((addOn) => addOn as Map<String, dynamic>)
        .toList();

    if (cartItemSnapshot.exists) {
      // Update the existing item in the cart
      cartItemRef.update({
        'quantity': FieldValue.increment(1),
        'addOns': FieldValue.arrayUnion(addOnsList)
      });
    } else {
      // Create a new item entry in the cart
      cartItemRef.set({
        'itemId': widget.itemId,
        'restaurantId': widget.restaurantId, // Add restaurantId to the cart
        'name': itemData!['name'],
        'imageUrl': itemData['imageUrl'],
        'price': itemData['price'],
        'quantity': 1,
        'addOns': addOnsList,
      });
    }

    Fluttertoast.showToast(
      msg: "Item added to cart.",
      gravity: ToastGravity.TOP,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );

    // Navigate to RestaurantDetailsPage after adding to cart
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            RestaurantDetailsPage(restaurantId: widget.restaurantId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Item Details'),
        backgroundColor: Colors.yellow.shade700,
      ),
      body: Container(
        color: Colors.yellow.shade200,
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('items')
              .doc(widget.itemId)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(child: Text('Item not found.'));
            }

            var itemData = snapshot.data!.data() as Map<String, dynamic>;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(itemData['imageUrl']),
                  SizedBox(height: 8.0),
                  Text(itemData['name'],
                      style: TextStyle(fontSize: 24, color: Colors.black)),
                  SizedBox(height: 8.0),
                  Text('\$${itemData['price']}',
                      style: TextStyle(fontSize: 20, color: Colors.black)),
                  SizedBox(height: 8.0),
                  Text(itemData['description'],
                      style: TextStyle(color: Colors.grey[800])),
                  SizedBox(height: 16.0),
                  Text('Add-ons',
                      style: TextStyle(fontSize: 18, color: Colors.black)),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('items')
                          .doc(widget.itemId)
                          .collection('addons')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Text('No add-ons available');
                        }

                        return ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            var addon = snapshot.data!.docs[index];
                            return CheckboxListTile(
                              title: Text(
                                  '${addon['name']} (\$${addon['price']})',
                                  style: TextStyle(color: Colors.black)),
                              value: selectedAddOns.containsKey(addon.id),
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    selectedAddOns[addon.id] = {
                                      'name': addon['name'],
                                      'price': addon['price']
                                    };
                                  } else {
                                    selectedAddOns.remove(addon.id);
                                  }
                                });
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      addToCart();
                    },
                    child: Text('Add to Cart',
                        style: TextStyle(fontSize: 20, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow.shade700,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
