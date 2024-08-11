import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../checkout.dart';
import '../payment_details.dart';

class CartController extends GetxController {
  var cartItems = <DocumentSnapshot>[].obs;
  var totalPrice = 0.0.obs;
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  void onInit() {
    super.onInit();
    loadCartItems();
  }

  void loadCartItems() {
    if (currentUser != null) {
      FirebaseFirestore.instance
          .collection('carts')
          .doc(currentUser!.uid)
          .collection('items')
          .snapshots()
          .listen((snapshot) {
        cartItems.value = snapshot.docs;
        calculateTotalPrice();
      });
    }
  }

  Future<void> deleteCartItem(String itemId) async {
    if (currentUser != null) {
      await FirebaseFirestore.instance
          .collection('carts')
          .doc(currentUser!.uid)
          .collection('items')
          .doc(itemId)
          .delete();
    }
  }

  void clearCart() {
    if (currentUser != null) {
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
    }
  }

  void incrementQuantity(String itemId) {
    FirebaseFirestore.instance
        .collection('carts')
        .doc(currentUser!.uid)
        .collection('items')
        .doc(itemId)
        .update({'quantity': FieldValue.increment(1)});
  }

  void decrementQuantity(String itemId, int currentQuantity) {
    if (currentQuantity > 1) {
      FirebaseFirestore.instance
          .collection('carts')
          .doc(currentUser!.uid)
          .collection('items')
          .doc(itemId)
          .update({'quantity': FieldValue.increment(-1)});
    } else {
      deleteCartItem(itemId);
    }
  }

  void calculateTotalPrice() async {
    double total = 0.0;
    for (var cartItem in cartItems) {
      var data = cartItem.data() as Map<String, dynamic>;
      var itemTotal = await calculateItemTotal(data);
      total += itemTotal;
    }
    totalPrice.value = total;
  }

  Future<double> calculateItemTotal(Map<String, dynamic> cartItem) async {
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

  Future<bool> _checkUserHasSavedCard() async {
    if (currentUser == null) {
      return false;
    }

    final cardCollection = await FirebaseFirestore.instance
        .collection('cards')
        .doc(currentUser!.email)
        .collection('userCards')
        .get();

    return cardCollection.docs.isNotEmpty;
  }

  Future<bool> _checkCardValue(double totalPrice) async {
    if (currentUser == null) {
      return false;
    }

    final cardCollection = await FirebaseFirestore.instance
        .collection('cards')
        .doc(currentUser!.email)
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
            .doc(currentUser!.email)
            .collection('userCards')
            .doc(doc.id)
            .update({'cardValue': cardValue - totalPrice});

        return true; // Can proceed to checkout
      }
    }

    return false; // Card value is not sufficient
  }

  Future<void> checkout() async {
    if (await _checkUserHasSavedCard()) {
      bool canProceedToCheckout = await _checkCardValue(totalPrice.value);

      if (canProceedToCheckout) {
        clearCart();
        Get.to(() => CheckoutPage());
      } else {
        Fluttertoast.showToast(
          msg:
              "Card does not have enough value. Please add a card with more value.",
          gravity: ToastGravity.TOP,
        );
        Get.to(() => PaymentDetailsPage());
      }
    } else {
      Fluttertoast.showToast(
        msg: "Please add a payment card before proceeding.",
        gravity: ToastGravity.TOP,
      );
      Get.to(() => PaymentDetailsPage());
    }
  }
}
