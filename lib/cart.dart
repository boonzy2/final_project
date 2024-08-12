import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/cart_controller.dart';

class CartPage extends StatelessWidget {
  // Instantiate the CartController using GetX for state management
  final CartController controller = Get.put(CartController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // AppBar title
        title: Text(
          'Cart',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.yellow.shade700,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          // IconButton to clear the cart
          IconButton(
            icon: Icon(Icons.delete, color: Colors.black),
            onPressed: () {
              // Call the clearCart method in the CartController
              controller.clearCart();
            },
          ),
        ],
      ),
      // The body of the CartPage using Obx to reactively display changes
      body: Obx(() {
        // Check if the cart is empty and display a message if it is
        if (controller.cartItems.isEmpty) {
          return Center(child: Text('Your cart is empty.'));
        }

        return Container(
          color: Colors.yellow.shade200,
          child: Column(
            children: [
              // Expanded widget to allow the ListView to take up available space
              Expanded(
                child: ListView.builder(
                  itemCount: controller.cartItems.length,
                  itemBuilder: (context, index) {
                    // Get the current cart item data as a Map
                    var cartItem = controller.cartItems[index].data()
                        as Map<String, dynamic>;

                    // FutureBuilder to calculate the total price of each item
                    return FutureBuilder<double>(
                      future: controller.calculateItemTotal(cartItem),
                      builder: (context, itemSnapshot) {
                        // Display a loading indicator while calculating the total
                        if (!itemSnapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }

                        double itemTotal = itemSnapshot.data!;

                        // Card widget to display cart item details
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
                                // Row to display the item image and details
                                Row(
                                  children: [
                                    // Display the item image with rounded corners
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.network(
                                        cartItem['imageUrl'],
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    // Expanded widget to allow text to take available space
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Display the item name
                                          Text(
                                            cartItem['name'],
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          // Display the item price
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
                                    // Column to display quantity controls
                                    Column(
                                      children: [
                                        Row(
                                          children: [
                                            // Button to decrease quantity
                                            IconButton(
                                              icon: Icon(
                                                Icons.remove_circle_outline,
                                                color: Colors.black,
                                              ),
                                              onPressed: () {
                                                controller.decrementQuantity(
                                                    controller
                                                        .cartItems[index].id,
                                                    cartItem['quantity']);
                                              },
                                            ),
                                            // Display the current quantity
                                            Text(
                                              '${cartItem['quantity']}',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black,
                                              ),
                                            ),
                                            // Button to increase quantity
                                            IconButton(
                                              icon: Icon(
                                                Icons.add_circle_outline,
                                                color: Colors.black,
                                              ),
                                              onPressed: () {
                                                controller.incrementQuantity(
                                                    controller
                                                        .cartItems[index].id);
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                // Display the list of add-ons as Chips
                                Wrap(
                                  spacing: 8.0,
                                  children:
                                      (cartItem['addOns'] as List<dynamic>)
                                          .map<Widget>((addon) {
                                    if (addon is Map<String, dynamic>) {
                                      return Chip(
                                        label: Text(
                                          '${addon['name']} (\$${addon['price']})',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        backgroundColor: Colors.yellow.shade300,
                                      );
                                    } else {
                                      return SizedBox.shrink();
                                    }
                                  }).toList(),
                                ),
                                SizedBox(height: 10),
                                // Display the total price for the item
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
              // Checkout button at the bottom of the screen
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: Obx(() => ElevatedButton(
                        onPressed: controller.checkout,
                        // Display the total price in the checkout button
                        child: Text(
                          'Go to Checkout (\$${controller.totalPrice.value.toStringAsFixed(2)})',
                          style: TextStyle(color: Colors.black),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          backgroundColor: Colors.yellow.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      )),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
