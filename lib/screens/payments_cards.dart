import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../model/order_model.dart'; // Import your Order model
import '../provider/cartdata_provider.dart';
import '../provider/order_provder.dart';

class PaymentGatewayPage extends ConsumerStatefulWidget {
  final Order order;

  PaymentGatewayPage({Key? key, required this.order}) : super(key: key);

  @override
  _PaymentGatewayPageState createState() => _PaymentGatewayPageState();
}

class _PaymentGatewayPageState extends ConsumerState<PaymentGatewayPage> {
  final _formKey = GlobalKey<FormState>();
  String _cardNumber = '';
  String _cardHolderName = '';
  String _expiryDate = '';
  String _cvv = '';
  bool _isLoading = false;

  bool _isCardNumberValid(String cardNumber) {
    // Basic Luhn algorithm for card number validation
    int sum = 0;
    bool isAlternate = false;

    for (int i = cardNumber.length - 1; i >= 0; i--) {
      int n = int.parse(cardNumber[i]);

      if (isAlternate) {
        n *= 2;
        if (n > 9) n -= 9;
      }
      sum += n;
      isAlternate = !isAlternate;
    }
    return sum % 10 == 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment Gateway"),
        centerTitle: true,
        backgroundColor: Colors.blue,
        leading: IconButton(
          onPressed: () {
            context.go('/checkout');
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
                    } else if (!_isCardNumberValid(value)) {
                      return 'Invalid card number';
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
                          } else if (!RegExp(r'^(0[1-9]|1[0-2])\/?([0-9]{2})$').hasMatch(value)) {
                            return 'Invalid expiry date format';
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
                        obscureText: true, // Mask CVV input
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter CVV';
                          } else if (value.length < 3 || value.length > 4) {
                            return 'CVV must be 3 or 4 digits';
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
                    onPressed: _isLoading ? null : () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        setState(() {
                          _isLoading = true;
                        });

                        try {
                          // Simulate payment processing
                          await Future.delayed(const Duration(seconds: 2));
                          await ref.read(orderProvider.notifier).saveOrder(widget.order);
                          await ref.read(cartProvider.notifier).clearCart();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Payment successful for $_cardHolderName'),
                            ),
                          );

                          context.go('/homepage');
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Payment failed: $e')),
                          );
                        } finally {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      }
                    },
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Pay Now"),
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
