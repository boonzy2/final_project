import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoritesController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var favoriteRestaurants = <DocumentSnapshot>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _fetchFavorites();
  }

  void _fetchFavorites() async {
    isLoading.value = true;
    User? currentUser = _auth.currentUser;

    if (currentUser != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('favorites')
          .snapshots()
          .listen((snapshot) async {
        favoriteRestaurants.clear();

        for (var doc in snapshot.docs) {
          DocumentSnapshot restaurantSnapshot = await FirebaseFirestore.instance
              .collection('restaurants')
              .doc(doc.id)
              .get();

          if (restaurantSnapshot.exists) {
            favoriteRestaurants.add(restaurantSnapshot);
          }
        }

        isLoading.value = false;
      });
    }
  }
}
