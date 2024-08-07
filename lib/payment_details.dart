import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PaymentDetailsPage extends StatefulWidget {
  @override
  _PaymentDetailsPageState createState() => _PaymentDetailsPageState();
}

class _PaymentDetailsPageState extends State<PaymentDetailsPage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  void _showAddCardDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: AddCardForm(
                onSubmit: (Map<String, dynamic> cardData) async {
                  User? user = _auth.currentUser;
                  if (user != null) {
                    await _firestore
                        .collection('cards')
                        .doc(user.email)
                        .collection('userCards')
                        .add(cardData);
                    Navigator.pop(context);
                    Fluttertoast.showToast(
                      msg: "Card added successfully",
                      gravity: ToastGravity.TOP,
                    );
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(String label, String hint) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Details'),
        backgroundColor: Colors.yellow.shade700,
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              // Navigate to cart
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('cards')
            .doc(_auth.currentUser!.email)
            .collection('userCards')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No cards available'));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              String cardNumber = doc['cardNumber'] ?? '';
              String lastFourDigits = cardNumber.length >= 4
                  ? cardNumber.substring(cardNumber.length - 4)
                  : cardNumber;

              return ListTile(
                leading: Icon(Icons.credit_card),
                title: Text('**** **** **** $lastFourDigits'),
                trailing: ElevatedButton(
                  onPressed: () {
                    _deleteCard(doc.id);
                  },
                  child: Text('Delete Card'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCardDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _deleteCard(String cardId) async {
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

class AddCardForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  AddCardForm({required this.onSubmit});

  @override
  _AddCardFormState createState() => _AddCardFormState();
}

class _AddCardFormState extends State<AddCardForm> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryMonthController = TextEditingController();
  final _expiryYearController = TextEditingController();
  final _cvvController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _cardValueController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Add Credit/Debit Card',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          SizedBox(height: 10),
          _buildTextFormField(
              controller: _cardNumberController,
              label: 'Card Number',
              hint: 'Card Number',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter card number';
                }
                if (value.length < 16) {
                  return 'Card number must be 16 digits';
                }
                return null;
              }),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildTextFormField(
                    controller: _expiryMonthController,
                    label: 'Expiry',
                    hint: 'MM',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter expiry month';
                      }
                      if (int.tryParse(value) == null ||
                          int.parse(value) < 1 ||
                          int.parse(value) > 12) {
                        return 'Invalid month';
                      }
                      return null;
                    }),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _buildTextFormField(
                    controller: _expiryYearController,
                    label: '',
                    hint: 'YYYY',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter expiry year';
                      }
                      if (int.tryParse(value) == null ||
                          int.parse(value) < DateTime.now().year) {
                        return 'Invalid year';
                      }
                      return null;
                    }),
              ),
            ],
          ),
          SizedBox(height: 10),
          _buildTextFormField(
              controller: _cvvController,
              label: 'Card Security Code',
              hint: 'CVV',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter CVV';
                }
                if (value.length != 3) {
                  return 'CVV must be 3 digits';
                }
                return null;
              }),
          SizedBox(height: 10),
          _buildTextFormField(
              controller: _firstNameController,
              label: 'First Name',
              hint: 'First Name',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter first name';
                }
                return null;
              }),
          SizedBox(height: 10),
          _buildTextFormField(
              controller: _lastNameController,
              label: 'Last Name',
              hint: 'Last Name',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter last name';
                }
                return null;
              }),
          SizedBox(height: 10),
          _buildTextFormField(
              controller: _cardValueController,
              label: 'Card Value',
              hint: 'Card Value',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter card value';
                }
                return null;
              }),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                Map<String, dynamic> cardData = {
                  'cardNumber': _cardNumberController.text,
                  'expiryMonth': _expiryMonthController.text,
                  'expiryYear': _expiryYearController.text,
                  'cvv': _cvvController.text,
                  'firstName': _firstNameController.text,
                  'lastName': _lastNameController.text,
                  'cardValue': _cardValueController.text,
                };
                widget.onSubmit(cardData);
              }
            },
            child: Text('Add Card'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      validator: validator,
    );
  }
}
