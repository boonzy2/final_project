import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../checkout.dart';
import '../payment_details.dart';

class CartController extends GetxController {
  // Observable list to hold the items in the cart
  var cartItems = <DocumentSnapshot>[].obs;

  // Observable to keep track of the total price of items in the cart
  var totalPrice = 0.0.obs;

  // Get the current user from Firebase Authentication
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  void onInit() {
    super.onInit();
    // Load cart items when the controller is initialized
    loadCartItems();
  }

  // Method to load cart items from Firestore
  void loadCartItems() {
    if (currentUser != null) {
      FirebaseFirestore.instance
          .collection('carts')
          .doc(currentUser!.uid)
          .collection('items')
          .snapshots()
          .listen((snapshot) {
        // Update the cartItems list whenever there's a change in Firestore
        cartItems.value = snapshot.docs;
        // Recalculate the total price whenever the cart items change
        calculateTotalPrice();
      });
    }
  }

  // Method to delete a specific cart item from Firestore
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

  // Method to clear all items from the cart
  void clearCart() {
    if (currentUser != null) {
      FirebaseFirestore.instance
          .collection('carts')
          .doc(currentUser!.uid)
          .collection('items')
          .get()
          .then((snapshot) {
        // Delete each document in the cart
        for (DocumentSnapshot ds in snapshot.docs) {
          ds.reference.delete();
        }
      });
    }
  }

  // Method to increment the quantity of a specific item
  void incrementQuantity(String itemId) {
    FirebaseFirestore.instance
        .collection('carts')
        .doc(currentUser!.uid)
        .collection('items')
        .doc(itemId)
        .update({'quantity': FieldValue.increment(1)});
  }

  // Method to decrement the quantity of a specific item
  // If quantity reaches 1, the item is removed from the cart
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

  // Method to calculate the total price of all items in the cart
  void calculateTotalPrice() async {
    double total = 0.0;
    for (var cartItem in cartItems) {
      var data = cartItem.data() as Map<String, dynamic>;
      var itemTotal = await calculateItemTotal(data);
      total += itemTotal;
    }
    totalPrice.value = total;
  }

  // Method to calculate the total price of a specific item, including add-ons
  Future<double> calculateItemTotal(Map<String, dynamic> cartItem) async {
    double itemPrice = cartItem['price'] ?? 0.0;
    int quantity = cartItem['quantity'] ?? 1;

    double addOnsTotal = 0.0;
    // Loop through the add-ons and calculate their total price
    for (var addOn in cartItem['addOns']) {
      if (addOn is Map<String, dynamic>) {
        addOnsTotal += (addOn['price'] ?? 0.0) * quantity;
      } else if (addOn is String) {
        // If add-on is a string, fetch its details from Firestore
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

    // Return the total price for this item, including add-ons
    return (itemPrice * quantity) + addOnsTotal;
  }

  // Method to check if the current user has any saved cards
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

  // Method to check if the user has enough balance on their saved card
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

  // Method to handle the checkout process
  Future<void> checkout() async {
    if (await _checkUserHasSavedCard()) {
      bool canProceedToCheckout = await _checkCardValue(totalPrice.value);

      if (canProceedToCheckout) {
        // Clear the cart and navigate to the checkout page
        clearCart();
        Get.to(() => CheckoutPage());
      } else {
        // Show a message if the card doesn't have enough value
        Fluttertoast.showToast(
          msg:
              "Card does not have enough value. Please add a card with more value.",
          gravity: ToastGravity.TOP,
        );
        // Navigate to the payment details page
        Get.to(() => PaymentDetailsPage());
      }
    } else {
      // Show a message if no payment card is found
      Fluttertoast.showToast(
        msg: "Please add a payment card before proceeding.",
        gravity: ToastGravity.TOP,
      );
      // Navigate to the payment details page
      Get.to(() => PaymentDetailsPage());
    }
  }
}
