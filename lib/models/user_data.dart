import 'package:flutter/foundation.dart';

class UserData extends ChangeNotifier {
  String? _gender;
  double? _weight;
  double? _height;
  int? _age;
  double? _dailyCalories;
  
  // Getters
  String? get gender => _gender;
  double? get weight => _weight;
  double? get height => _height;
  int? get age => _age;
  double? get dailyCalories => _dailyCalories;
  
  // Check if all user data is provided
  bool get isComplete => _gender != null && _weight != null && _height != null && _age != null;
  
  // Set user details and calculate calories
  void setUserDetails({
    required String gender,
    required double weight,
    required double height,
    required int age,
  }) {
    _gender = gender;
    _weight = weight;
    _height = height;
    _age = age;
    
    // Calculate daily calories based on gender
    if (gender.toLowerCase() == 'female') {
      // For women: BMR = 655.1 + (9.56 × weight in kg) + (1.85 × height in cm) - (4.67 × age in years)
      _dailyCalories = 655.1 + (9.56 * weight) + (1.85 * height) - (4.67 * age);
    } else {
      // For men: BMR = 66.47 + (13.75 × weight in kg) + (5 × height in cm) - (6.75 × age in years)
      _dailyCalories = 666.47 + (13.75 * weight) + (5 * height) - (6.75 * age);
    }
    
    notifyListeners();
  }
  
  // Reset user data
  void reset() {
    _gender = null;
    _weight = null;
    _height = null;
    _age = null;
    _dailyCalories = null;
    notifyListeners();
  }
}
