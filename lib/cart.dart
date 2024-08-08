import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final List<Map<String, dynamic>> _cartItems = [
    {
      'name': 'Classic Cheeseburger',
      'price': 8.99,
      'quantity': 1,
      'imageUrl':
          'https://firebasestorage.googleapis.com/v0/b/food-delivery-app-b02ed.appspot.com/o/item_pictures%2Fclassic_cheeseburger.png?alt=media&token=cad2b31b-2b17-446c-a396-48f808fe4ccb',
      'addOns': [
        {'name': 'Extra Cheese', 'price': 0.99}
      ]
    },
    {
      'name': 'Veggie Burger',
      'price': 9.49,
      'quantity': 6,
      'imageUrl':
          'https://firebasestorage.googleapis.com/v0/b/food-delivery-app-b02ed.appspot.com/o/item_pictures%2Fveggie_burger.png?alt=media&token=cad2b31b-2b17-446c-a396-48f808fe4ccb',
      'addOns': [
        {'name': 'Vegan Cheese', 'price': 0.99},
        {'name': 'Grilled Mushrooms', 'price': 1.49}
      ]
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: ListView.builder(
        itemCount: _cartItems.length,
        itemBuilder: (context, index) {
          final item = _cartItems[index];
          return Card(
            margin: EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      CachedNetworkImage(
                        imageUrl: item['imageUrl'],
                        height: 60,
                        width: 60,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'],
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 5),
                            Text(
                              '\$${item['price']}',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              setState(() {
                                item['quantity']++;
                              });
                            },
                          ),
                          Text('${item['quantity']}'),
                          IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: () {
                              setState(() {
                                if (item['quantity'] > 1) {
                                  item['quantity']--;
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  if (item['addOns'] != null && item['addOns'].isNotEmpty)
                    ...item['addOns'].map<Widget>((addOn) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            SizedBox(width: 70),
                            Text(
                              addOn['name'],
                              style: TextStyle(fontSize: 16),
                            ),
                            Spacer(),
                            Text(
                              '\$${addOn['price']}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
