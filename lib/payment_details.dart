import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/payment_controller.dart';
import 'add_card_form.dart';

class PaymentDetailsPage extends StatelessWidget {
  final PaymentController paymentController = Get.put(PaymentController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Details'),
        backgroundColor: Colors.yellow.shade700,
      ),
      body: Container(
        width: double.infinity,
        color: Colors.yellow.shade200,
        child: Obx(() {
          if (paymentController.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          } else if (paymentController.cards.isEmpty) {
            return Center(child: Text('No cards available'));
          }

          return ListView(
            children: paymentController.cards.map((doc) {
              String cardNumber = doc['cardNumber'] ?? '';
              String lastFourDigits = cardNumber.length >= 4
                  ? cardNumber.substring(cardNumber.length - 4)
                  : cardNumber;

              return ListTile(
                leading: Icon(Icons.credit_card),
                title: Text('**** **** **** $lastFourDigits'),
                trailing: ElevatedButton(
                  onPressed: () {
                    paymentController.deleteCard(doc.id);
                  },
                  child: Text('Delete Card'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddCardDialog(context);
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showAddCardDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.yellow.shade200,
            child: SingleChildScrollView(
              child: AddCardForm(
                onSubmit: (Map<String, dynamic> cardData) {
                  paymentController.addCard(cardData);
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
