import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MoreController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var selectedIndex = 3.obs;

  void onItemTapped(int index) {
    selectedIndex.value = index;

    switch (index) {
      case 0:
        Get.offNamed('/favorites');
        break;
      case 1:
        Get.offNamed('/location');
        break;
      case 2:
        Get.offNamed('/profile');
        break;
      case 3:
        Get.offNamed('/more');
        break;
      case 4:
        Get.offNamed('/home');
        break;
      default:
        Get.offNamed('/home');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    Get.offNamed('/login');
  }
}
