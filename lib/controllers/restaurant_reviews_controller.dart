import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantReviewsController extends GetxController {
  final String restaurantId;

  RestaurantReviewsController(this.restaurantId);

  var reviews = <QueryDocumentSnapshot>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _fetchReviews();
  }

  void _fetchReviews() async {
    try {
      isLoading.value = true;
      FirebaseFirestore.instance
          .collection('restaurants')
          .doc(restaurantId)
          .collection('reviews')
          .snapshots()
          .listen((snapshot) {
        reviews.value = snapshot.docs;
        isLoading.value = false;
      });
    } catch (e) {
      isLoading.value = false;
      print("Error fetching reviews: $e");
    }
  }
}
