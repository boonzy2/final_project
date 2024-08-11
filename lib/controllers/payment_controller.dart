import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PaymentController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var cards = <DocumentSnapshot>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _fetchCards();
  }

  void _fetchCards() async {
    isLoading.value = true;
    User? user = _auth.currentUser;

    if (user != null) {
      _firestore
          .collection('cards')
          .doc(user.email)
          .collection('userCards')
          .snapshots()
          .listen((snapshot) {
        cards.value = snapshot.docs;
        isLoading.value = false;
      });
    } else {
      isLoading.value = false;
    }
  }

  void addCard(Map<String, dynamic> cardData) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('cards')
          .doc(user.email)
          .collection('userCards')
          .add(cardData);
      Fluttertoast.showToast(
        msg: "Card added successfully",
        gravity: ToastGravity.TOP,
      );
    }
  }

  void deleteCard(String cardId) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('cards')
          .doc(user.email)
          .collection('userCards')
          .doc(cardId)
          .delete();
      Fluttertoast.showToast(
        msg: "Card deleted successfully",
        gravity: ToastGravity.TOP,
      );
    }
  }
}
