import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart'; // Import Fluttertoast package

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
        .collection('items')
        .doc(widget.itemId);

    final cartDoc = await cartRef.get();
    final itemData = (await FirebaseFirestore.instance
            .collection('items')
            .doc(widget.itemId)
            .get())
        .data();

    List<Map<String, dynamic>> addOnsList = selectedAddOns.values
        .map((addOn) => addOn as Map<String, dynamic>)
        .toList();

    if (cartDoc.exists) {
      // Update the existing item in the cart
      cartRef.update({
        'quantity': FieldValue.increment(1),
        'addOns': FieldValue.arrayUnion(addOnsList)
      });
    } else {
      // Create a new item entry in the cart
      cartRef.set({
        'itemId': widget.itemId,
        'name': itemData!['name'], // Make sure to pass the name of the item
        'imageUrl': itemData['imageUrl'], // Make sure to pass the image URL
        'price': itemData['price'], // Make sure to pass the price of the item
        'quantity': 1,
        'addOns': addOnsList,
      });
    }

    // Show a toast message after successfully adding the item to the cart
    Fluttertoast.showToast(
      msg: "Item successfully added to cart",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Item Details',
          style: TextStyle(color: Colors.black), // Updated text color
        ),
        backgroundColor: Colors.yellow.shade700, // Updated background color
        iconTheme: IconThemeData(color: Colors.black), // Update icon color
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.pushNamed(
                  context, '/cart'); // Navigate to the cart page
            },
            color: Colors.black, // Set the icon color to black
          ),
        ],
      ),
      body: Container(
        color: Colors.yellow.shade200, // Set background color
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
                      style: TextStyle(
                          fontSize: 24,
                          color: Colors.black)), // Updated text color
                  SizedBox(height: 8.0),
                  Text('\$${itemData['price']}',
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.black)), // Updated text color
                  SizedBox(height: 8.0),
                  Text(itemData['description'],
                      style: TextStyle(color: Colors.grey[800])),
                  SizedBox(height: 16.0),
                  Text('Add-ons',
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.black)), // Updated text color
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
                                  style: TextStyle(
                                      color:
                                          Colors.black)), // Updated text color
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
                      Navigator.pop(context);
                    },
                    child: Text('Add to Cart',
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.white)), // Updated button text color
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors
                          .yellow.shade700, // Updated button background color
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
