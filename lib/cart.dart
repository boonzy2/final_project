import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/cart_controller.dart';

class CartPage extends StatelessWidget {
  final CartController controller = Get.put(CartController());

  @override
  Widget build(BuildContext context) {
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
              controller.clearCart();
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.cartItems.isEmpty) {
          return Center(child: Text('Your cart is empty.'));
        }

        return Container(
          color: Colors.yellow.shade200,
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: controller.cartItems.length,
                  itemBuilder: (context, index) {
                    var cartItem = controller.cartItems[index].data()
                        as Map<String, dynamic>;

                    return FutureBuilder<double>(
                      future: controller.calculateItemTotal(cartItem),
                      builder: (context, itemSnapshot) {
                        if (!itemSnapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }

                        double itemTotal = itemSnapshot.data!;

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
                                      borderRadius: BorderRadius.circular(8.0),
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
                                                controller.decrementQuantity(
                                                    controller
                                                        .cartItems[index].id,
                                                    cartItem['quantity']);
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
                  child: Obx(() => ElevatedButton(
                        onPressed: controller.checkout,
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
