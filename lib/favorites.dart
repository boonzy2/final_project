import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/favorites_controller.dart';
import 'restaurant_details.dart';

class FavoritesPage extends StatelessWidget {
  final FavoritesController favoritesController =
      Get.put(FavoritesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow.shade700,
        title: Text(
          'Favorites',
          style: TextStyle(color: Colors.black),
        ),
        automaticallyImplyLeading: false, // Removed the back arrow
      ),
      body: Container(
        color: Colors.yellow
            .shade200, // Set the background color to match the login page
        child: Obx(() {
          if (favoritesController.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }

          if (favoritesController.favoriteRestaurants.isEmpty) {
            return Center(
              child: Text(
                'No favorites added.',
                style: TextStyle(color: Colors.black),
              ),
            );
          }

          return ListView.builder(
            itemCount: favoritesController.favoriteRestaurants.length,
            itemBuilder: (context, index) {
              var restaurantData =
                  favoritesController.favoriteRestaurants[index].data()
                      as Map<String, dynamic>;
              String restaurantId =
                  favoritesController.favoriteRestaurants[index].id;

              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  child: InkWell(
                    onTap: () {
                      Get.to(() => RestaurantDetailsPage(
                            restaurantId: restaurantId,
                          ));
                    },
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(
                            restaurantData['imageUrl'],
                            height: 80,
                            width: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  restaurantData['name'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  restaurantData['address'],
                                  style: TextStyle(color: Colors.grey[600]),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.grey,
                        ),
                        SizedBox(
                            width:
                                10), // Add some space between icon and the end
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed('/home');
        },
        backgroundColor: Colors.orange,
        child: Icon(Icons.home, size: 28, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.favorite,
                  color: Colors.orange), // Changed color to orange
              onPressed: () {
                Get.toNamed('/favorites');
              },
            ),
            IconButton(
              icon: Icon(Icons.rate_review, color: Colors.grey),
              onPressed: () {
                Get.toNamed('/location');
              },
            ),
            SizedBox(width: 40), // The dummy child
            IconButton(
              icon: Icon(Icons.person, color: Colors.grey),
              onPressed: () {
                Get.toNamed('/profile');
              },
            ),
            IconButton(
              icon: Icon(Icons.more_vert, color: Colors.grey),
              onPressed: () {
                Get.toNamed('/more');
              },
            ),
          ],
        ),
      ),
    );
  }
}
