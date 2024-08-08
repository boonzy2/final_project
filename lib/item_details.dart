import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ItemDetailsPage extends StatefulWidget {
  final String itemId;

  ItemDetailsPage({required this.itemId});

  @override
  _ItemDetailsPageState createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  final Map<String, bool> _selectedAddOns = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Item Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              // Handle cart icon press
              Navigator.pushNamed(context,
                  '/cart'); // Assuming you have a cart page route defined
            },
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('items')
            .doc(widget.itemId)
            .get(),
        builder: (context, itemSnapshot) {
          if (itemSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!itemSnapshot.hasData || !itemSnapshot.data!.exists) {
            return Center(child: Text('Item Data Not Found'));
          }

          var itemData = itemSnapshot.data!.data() as Map<String, dynamic>;

          return ListView(
            children: [
              // Display Item Image
              CachedNetworkImage(
                imageUrl: itemData['imageUrl'],
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) =>
                    Icon(Icons.error, size: 50),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Item Name
                    Text(
                      itemData['name'],
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    // Item Price
                    Text(
                      '\$${itemData['price']}',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 16),
                    // Item Description
                    Text(
                      itemData['description'],
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 16),
                    // Add-ons Title
                    Text(
                      'Add-ons',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    // Display Add-ons
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('items')
                          .doc(widget.itemId)
                          .collection('addons')
                          .snapshots(),
                      builder: (context, addonSnapshot) {
                        if (addonSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (!addonSnapshot.hasData ||
                            addonSnapshot.data!.docs.isEmpty) {
                          return Center(child: Text('No add-ons available.'));
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: addonSnapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            var addonData = addonSnapshot.data!.docs[index]
                                .data() as Map<String, dynamic>;
                            var addonId = addonSnapshot.data!.docs[index].id;

                            return ListTile(
                              title: Text(addonData['name']),
                              trailing: Text(
                                '\$${addonData['price']}',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              leading: StatefulBuilder(
                                builder: (context, setState) {
                                  return Checkbox(
                                    value: _selectedAddOns[addonId] ?? false,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        _selectedAddOns[addonId] = value!;
                                      });
                                    },
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                    SizedBox(height: 16),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle add to cart
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                          textStyle: TextStyle(fontSize: 20),
                        ),
                        child: Text('Add to Cart'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
