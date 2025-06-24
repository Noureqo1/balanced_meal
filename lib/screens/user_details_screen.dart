import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_data.dart';

class UserDetailsScreen extends StatefulWidget {
  const UserDetailsScreen({super.key});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {
    'gender': null,
    'weight': '',
    'height': '',
    'age': '',
  };
  
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();
  
  final _weightFocusNode = FocusNode();
  final _heightFocusNode = FocusNode();
  final _ageFocusNode = FocusNode();
  
  String? _selectedGender;
  final List<String> _genders = ['Male', 'Female'];
  
  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    _weightFocusNode.dispose();
    _heightFocusNode.dispose();
    _ageFocusNode.dispose();
    super.dispose();
  }
  
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      // Update user data in the provider
      final userData = Provider.of<UserData>(context, listen: false);
      userData.setUserDetails(
        gender: _formData['gender'],
        weight: double.parse(_formData['weight']),
        height: double.parse(_formData['height']),
        age: int.parse(_formData['age']),
      );
      
      // Navigate to create order screen
      Navigator.pushReplacementNamed(context, '/create-order');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter your details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gender Dropdown
              const Text(
                'Gender',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                hint: const Text('Choose your gender'),
                items: _genders.map((String gender) {
                  return DropdownMenuItem<String>(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                    _formData['gender'] = value?.toLowerCase();
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your gender';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Weight Input
              const Text(
                'Weight',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _weightController,
                focusNode: _weightFocusNode,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter your weight',
                  suffixText: 'Kg',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  _weightFocusNode.unfocus();
                  FocusScope.of(context).requestFocus(_heightFocusNode);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your weight';
                  }
                  final weight = double.tryParse(value);
                  if (weight == null || weight <= 0) {
                    return 'Please enter a valid weight';
                  }
                  return null;
                },
                onSaved: (value) => _formData['weight'] = value,
              ),
              
              const SizedBox(height: 24),
              
              // Height Input
              const Text(
                'Height',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _heightController,
                focusNode: _heightFocusNode,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter your height',
                  suffixText: 'Cm',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  _heightFocusNode.unfocus();
                  FocusScope.of(context).requestFocus(_ageFocusNode);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your height';
                  }
                  final height = double.tryParse(value);
                  if (height == null || height <= 0) {
                    return 'Please enter a valid height';
                  }
                  return null;
                },
                onSaved: (value) => _formData['height'] = value,
              ),
              
              const SizedBox(height: 24),
              
              // Age Input
              const Text(
                'Age',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _ageController,
                focusNode: _ageFocusNode,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter your age',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) {
                  _ageFocusNode.unfocus();
                  _submitForm();
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your age';
                  }
                  final age = int.tryParse(value);
                  if (age == null || age <= 0 || age > 120) {
                    return 'Please enter a valid age';
                  }
                  return null;
                },
                onSaved: (value) => _formData['age'] = value,
              ),
              
              const SizedBox(height: 40),
              
              // Next Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE67E22),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Next',
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
      ),
    );
  }
}
