import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OrderSummaryScreen extends StatefulWidget {
  const OrderSummaryScreen({super.key});

  @override
  State<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  bool _isLoading = false;
  bool _orderPlaced = false;
  String? _errorMessage;

  // API endpoint for placing orders
  static const String _apiUrl = 'https://uz8if7.buildship.run/placeOrder';

  // Function to place the order
  Future<void> _placeOrder(List<dynamic> items) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Prepare the request body
      final requestBody = {
        'items': items.map((item) => {
          'name': item['name'],
          'total_price': item['total_price'],
          'quantity': item['quantity'],
        }).toList()
      };

      debugPrint('Sending order: ${jsonEncode(requestBody)}');
      
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData == true) {
          setState(() {
            _orderPlaced = true;
          });
          
          // Show success message and navigate back to home after a short delay
          await Future.delayed(const Duration(seconds: 1));
          
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/',  // Navigate to root (home) screen
              (route) => false,  // Remove all previous routes
            );
          }
        } else {
          setState(() {
            _errorMessage = 'Failed to place order. Please try again.';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Error: ${response.statusCode}. Please try again.';
        });
      }
    } catch (e) {
      debugPrint('Error placing order: $e');
      setState(() {
        _errorMessage = 'An error occurred. Please check your connection and try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get order data from the previous screen
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    if (args == null) {
      return const Scaffold(
        body: Center(
          child: Text('Error: No order data found'),
        ),
      );
    }

    final List<dynamic> items = args['items'] as List<dynamic>;
    final double totalCalories = args['totalCalories'] as double;
    final double totalPrice = args['totalPrice'] as double;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Order Summary'),
      ),
      body: Column(
        children: [
          // Order items list
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Order Items',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...items.map((item) => _buildOrderItem(
                        item['name'] as String,
                        item['quantity'] as int,
                        (item['total_price'] as num).toDouble(),
                      )),
                  const SizedBox(height: 24),
                  _buildSummaryRow('Total Calories', '${totalCalories.toStringAsFixed(0)} Cal'),
                  const SizedBox(height: 12),
                  _buildSummaryRow('Total Price', '\$${totalPrice.toStringAsFixed(2)}'),
                ],
              ),
            ),
          ),
          
          // Order confirmation button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (_orderPlaced)
                  const Column(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 48,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Order Placed Successfully!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Redirecting to home...',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () => _placeOrder(items),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE67E22),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Confirm Order',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build an order item row
  Widget _buildOrderItem(String name, int quantity, double totalPrice) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                '$quantity x ',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Text(
            '\$${totalPrice.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }


  // Build a summary row with label and value
  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
