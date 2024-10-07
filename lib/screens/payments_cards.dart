import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../model/order_model.dart'; // Import your Order model
import '../provider/order_provder.dart';

class PaymentGatewayPage extends ConsumerStatefulWidget {
  @override
  _PaymentGatewayPageState createState() => _PaymentGatewayPageState();
}

class _PaymentGatewayPageState extends ConsumerState<PaymentGatewayPage> {
  final _formKey = GlobalKey<FormState>();
  String _cardNumber = '';
  String _cardHolderName = '';
  String _expiryDate = '';
  String _cvv = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment Gateway"),
        centerTitle: true,
        backgroundColor: Colors.blue,
        leading: IconButton(
          onPressed: () {
            context.go('/'); // Navigate back to the home page
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Enter Card Details",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Card Number',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter card number';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _cardNumber = value!;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Card Holder Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter card holder name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _cardHolderName = value!;
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Expiry Date (MM/YY)',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter expiry date';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _expiryDate = value!;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'CVV',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter CVV';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _cvv = value!;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();

                        // Simulate payment process
                        final order = Order(
                          name: 'Customer Name', // Replace with actual customer name
                          address: 'Customer Address', // Replace with actual address
                          paymentMethod: 'Card',
                          items: [], // Populate with ordered items
                          totalPrice: 0.0, // Set total price based on cart
                        );

                        // Save the order using OrderProvider
                        ref.read(orderProvider.notifier).saveOrder(order);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Payment successful for $_cardHolderName'),
                          ),
                        );

                        // Optionally, navigate to a success page or back to home
                        context.go('/');
                      }
                    },
                    child: const Text("Pay Now"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
