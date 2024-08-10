import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'checkout.dart';
import 'payment_details.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cart',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.yellow.shade700,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.black),
            onPressed: () {
              FirebaseFirestore.instance
                  .collection('carts')
                  .doc(currentUser!.uid)
                  .collection('items')
                  .get()
                  .then((snapshot) {
                for (DocumentSnapshot ds in snapshot.docs) {
                  ds.reference.delete();
                }
              });
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.yellow.shade200, // Set background color
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('carts')
              .doc(currentUser!.uid)
              .collection('items')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('Your cart is empty.'));
            }

            double totalPrice = 0.0;

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var cartItem = snapshot.data!.docs[index].data()
                          as Map<String, dynamic>;

                      return FutureBuilder<double>(
                        future: _calculateItemTotal(cartItem),
                        builder: (context, itemSnapshot) {
                          if (!itemSnapshot.hasData) {
                            return Center(child: CircularProgressIndicator());
                          }

                          double itemTotal = itemSnapshot.data!;
                          totalPrice += itemTotal;

                          return Card(
                            margin: EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            elevation: 5,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: Image.network(
                                          cartItem['imageUrl'],
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              cartItem['name'],
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              '\$${cartItem['price']}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                  Icons.remove_circle_outline,
                                                  color: Colors.black,
                                                ),
                                                onPressed: () {
                                                  if (cartItem['quantity'] >
                                                      1) {
                                                    FirebaseFirestore.instance
                                                        .collection('carts')
                                                        .doc(currentUser!.uid)
                                                        .collection('items')
                                                        .doc(snapshot.data!
                                                            .docs[index].id)
                                                        .update({
                                                      'quantity':
                                                          FieldValue.increment(
                                                              -1)
                                                    });
                                                  } else {
                                                    FirebaseFirestore.instance
                                                        .collection('carts')
                                                        .doc(currentUser!.uid)
                                                        .collection('items')
                                                        .doc(snapshot.data!
                                                            .docs[index].id)
                                                        .delete();
                                                  }
                                                },
                                              ),
                                              Text(
                                                '${cartItem['quantity']}',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  Icons.add_circle_outline,
                                                  color: Colors.black,
                                                ),
                                                onPressed: () {
                                                  FirebaseFirestore.instance
                                                      .collection('carts')
                                                      .doc(currentUser.uid)
                                                      .collection('items')
                                                      .doc(snapshot
                                                          .data!.docs[index].id)
                                                      .update({
                                                    'quantity':
                                                        FieldValue.increment(1)
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Wrap(
                                    spacing: 8.0,
                                    children:
                                        (cartItem['addOns'] as List<dynamic>)
                                            .map<Widget>((addon) {
                                      if (addon is Map<String, dynamic>) {
                                        return Chip(
                                          label: Text(
                                            '${addon['name']} (\$${addon['price']})',
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                          backgroundColor:
                                              Colors.yellow.shade300,
                                        );
                                      } else if (addon is String) {
                                        return FutureBuilder<DocumentSnapshot>(
                                          future: FirebaseFirestore.instance
                                              .collection('items')
                                              .doc(cartItem['itemId'])
                                              .collection('addons')
                                              .doc(addon)
                                              .get(),
                                          builder: (context, snapshot) {
                                            if (!snapshot.hasData ||
                                                !snapshot.data!.exists) {
                                              return Chip(
                                                label: Text(
                                                  'Unknown Addon',
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                                backgroundColor:
                                                    Colors.yellow.shade300,
                                              );
                                            }
                                            var addonData = snapshot.data!
                                                .data() as Map<String, dynamic>;
                                            return Chip(
                                              label: Text(
                                                '${addonData['name']} (\$${addonData['price']})',
                                                style: TextStyle(
                                                    color: Colors.black),
                                              ),
                                              backgroundColor:
                                                  Colors.yellow.shade300,
                                            );
                                          },
                                        );
                                      } else {
                                        return SizedBox.shrink();
                                      }
                                    }).toList(),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Item Total: \$${itemTotal.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Check if the user has saved cards
                        bool hasSavedCard = await _checkUserHasSavedCard();

                        if (hasSavedCard) {
                          bool canProceedToCheckout =
                              await _checkCardValue(totalPrice);

                          if (canProceedToCheckout) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CheckoutPage()),
                            );
                            // Optional: Clear the cart here if needed
                          } else {
                            Fluttertoast.showToast(
                              msg:
                                  "Card does not have enough value. Please add a card with more value.",
                              gravity: ToastGravity.TOP,
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PaymentDetailsPage()),
                            );
                          }
                        } else {
                          Fluttertoast.showToast(
                            msg: "Please add a payment card before proceeding.",
                            gravity: ToastGravity.TOP,
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PaymentDetailsPage()),
                          );
                        }
                      },
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('carts')
                            .doc(currentUser!.uid)
                            .collection('items')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return Text('Go to Checkout (\$0.00)',
                                style: TextStyle(color: Colors.black));
                          }

                          double totalPrice = 0.0;

                          for (var doc in snapshot.data!.docs) {
                            var cartItem = doc.data() as Map<String, dynamic>;
                            double itemTotal = (cartItem['price'] ?? 0.0) *
                                (cartItem['quantity'] ?? 1);

                            for (var addOn in cartItem['addOns']) {
                              if (addOn is Map<String, dynamic>) {
                                itemTotal += (addOn['price'] ?? 0.0) *
                                    (cartItem['quantity'] ?? 1);
                              } else if (addOn is String) {
                                var addOnSnapshot = FirebaseFirestore.instance
                                    .collection('items')
                                    .doc(cartItem['itemId'])
                                    .collection('addons')
                                    .doc(addOn)
                                    .get();
                                addOnSnapshot.then((addOnData) {
                                  if (addOnData.exists) {
                                    var addOnDetails = addOnData.data()
                                        as Map<String, dynamic>;
                                    totalPrice +=
                                        (addOnDetails['price'] ?? 0.0) *
                                            (cartItem['quantity'] ?? 1);
                                  }
                                });
                              }
                            }

                            totalPrice += itemTotal;
                          }

                          return Text(
                            'Go to Checkout (\$${totalPrice.toStringAsFixed(2)})',
                            style: TextStyle(color: Colors.black),
                          );
                        },
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        backgroundColor: Colors.yellow.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<bool> _checkUserHasSavedCard() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return false;
    }

    final cardCollection = await FirebaseFirestore.instance
        .collection('cards')
        .doc(currentUser.email)
        .collection('userCards')
        .get();

    return cardCollection.docs.isNotEmpty;
  }

  Future<bool> _checkCardValue(double totalPrice) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return false;
    }

    final cardCollection = await FirebaseFirestore.instance
        .collection('cards')
        .doc(currentUser.email)
        .collection('userCards')
        .get();

    if (cardCollection.docs.isEmpty) {
      return false;
    }

    for (var doc in cardCollection.docs) {
      double cardValue = doc['cardValue'] ?? 0.0;

      if (cardValue >= totalPrice) {
        // Subtract the total price from the card value and update the document
        await FirebaseFirestore.instance
            .collection('cards')
            .doc(currentUser.email)
            .collection('userCards')
            .doc(doc.id)
            .update({'cardValue': cardValue - totalPrice});

        return true; // Can proceed to checkout
      }
    }

    return false; // Card value is not sufficient
  }

  Future<double> _calculateItemTotal(Map<String, dynamic> cartItem) async {
    double itemPrice = cartItem['price'] ?? 0.0;
    int quantity = cartItem['quantity'] ?? 1;

    double addOnsTotal = 0.0;
    for (var addOn in cartItem['addOns']) {
      if (addOn is Map<String, dynamic>) {
        addOnsTotal += (addOn['price'] ?? 0.0) * quantity;
      } else if (addOn is String) {
        var addOnSnapshot = await FirebaseFirestore.instance
            .collection('items')
            .doc(cartItem['itemId'])
            .collection('addons')
            .doc(addOn)
            .get();
        if (addOnSnapshot.exists) {
          var addOnData = addOnSnapshot.data() as Map<String, dynamic>;
          addOnsTotal += (addOnData['price'] ?? 0.0) * quantity;
        }
      }
    }

    return (itemPrice * quantity) + addOnsTotal;
  }
}
