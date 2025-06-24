import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ingredient.dart';
import '../models/user_data.dart';
import '../services/firebase_service.dart';
import '../widgets/ingredient_card.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseService _firebaseService = FirebaseService();
  
  // Track selected ingredients and their quantities
  final Map<String, Ingredient> _selectedIngredients = {};
  double _totalCalories = 0;
  double _totalPrice = 0;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Initialize sample data (in a real app, this would be done separately)
    _firebaseService.initializeSampleData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  // Update the order summary when ingredients are added/removed
  void _updateOrderSummary() {
    double calories = 0;
    double price = 0;
    
    for (final ingredient in _selectedIngredients.values) {
      calories += ingredient.calories * ingredient.quantity;
      price += ingredient.price * ingredient.quantity;
    }
    
    setState(() {
      _totalCalories = calories;
      _totalPrice = price;
    });
  }
  
  // Check if the order is within 10% of the daily calorie requirement
  bool _isWithinCalorieRange(double dailyCalories) {
    if (dailyCalories == 0) return false;
    
    final lowerBound = dailyCalories * 0.9;
    final upperBound = dailyCalories * 1.1;
    
    return _totalCalories >= lowerBound && _totalCalories <= upperBound;
  }
  
  // Navigate to order summary screen
  void _proceedToOrderSummary() {
    final userData = Provider.of<UserData>(context, listen: false);
    
    // Convert selected ingredients to a list of order items
    final orderItems = _selectedIngredients.values
        .where((ingredient) => ingredient.quantity > 0)
        .map((ingredient) => {
              'name': ingredient.name,
              'total_price': ingredient.price * ingredient.quantity,
              'quantity': ingredient.quantity,
            })
        .toList();
    
    // Navigate to order summary screen
    Navigator.pushNamed(
      context,
      '/order-summary',
      arguments: {
        'items': orderItems,
        'totalCalories': _totalCalories,
        'totalPrice': _totalPrice,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData>(context);
    final dailyCalories = userData.dailyCalories ?? 0;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create your order'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Meats'),
            Tab(text: 'Vegetables'),
            Tab(text: 'Carbs'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Tab bar view for ingredient categories
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Meats
                _buildIngredientList('meat'),
                // Vegetables
                _buildIngredientList('vegetable'),
                // Carbs
                _buildIngredientList('carbs'),
              ],
            ),
          ),
          
          // Order summary card
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
                // Calorie progress
                _buildSummaryRow(
                  'Cal',
                  '${_totalCalories.toStringAsFixed(0)} / ${dailyCalories.toStringAsFixed(0)} Cal',
                  _totalCalories / (dailyCalories > 0 ? dailyCalories : 1),
                ),
                const SizedBox(height: 12),
                // Total price
                _buildSummaryRow('Price', '\$${_totalPrice.toStringAsFixed(2)}', null),
                const SizedBox(height: 16),
                // Place order button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isWithinCalorieRange(dailyCalories) ? _proceedToOrderSummary : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE67E22),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Place Order',
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
  
  // Build a list of ingredients for a specific category
  Widget _buildIngredientList(String category) {
    return StreamBuilder<List<Ingredient>>(
      stream: _firebaseService.getIngredientsByCategory(category),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        
        final ingredients = snapshot.data ?? [];
        
        if (ingredients.isEmpty) {
          return const Center(child: Text('No ingredients available'));
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: ingredients.length,
          itemBuilder: (context, index) {
            final ingredient = ingredients[index];
            final selectedIngredient = _selectedIngredients[ingredient.id] ?? 
                ingredient.copyWith(quantity: 0);
            
            return IngredientCard(
              ingredient: selectedIngredient,
              onAdd: () {
                setState(() {
                  _selectedIngredients[ingredient.id] = selectedIngredient.copyWith(
                    quantity: selectedIngredient.quantity + 1,
                  );
                  _updateOrderSummary();
                });
              },
              onRemove: () {
                if (selectedIngredient.quantity > 0) {
                  setState(() {
                    _selectedIngredients[ingredient.id] = selectedIngredient.copyWith(
                      quantity: selectedIngredient.quantity - 1,
                    );
                    _updateOrderSummary();
                  });
                }
              },
            );
          },
        );
      },
    );
  }
  
  // Build a summary row with label, value, and optional progress indicator
  Widget _buildSummaryRow(String label, String value, double? progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
        if (progress != null) ...[
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              progress >= 0.9 && progress <= 1.1 ? Colors.green : Colors.orange,
            ),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ],
    );
  }
}
