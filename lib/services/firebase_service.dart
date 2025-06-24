import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ingredient.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Collection references
  CollectionReference get _ingredientsCollection => _firestore.collection('ingredients');
  
  // Get all ingredients
  Stream<List<Ingredient>> getIngredients() {
    return _ingredientsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Ingredient.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
  
  // Get ingredients by category
  Stream<List<Ingredient>> getIngredientsByCategory(String category) {
    return _ingredientsCollection
        .where('category', isEqualTo: category.toLowerCase())
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Ingredient.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
  
  // Add a new ingredient (for admin use)
  Future<void> addIngredient(Ingredient ingredient) async {
    await _ingredientsCollection.add(ingredient.toMap());
  }
  
  // Update an existing ingredient (for admin use)
  Future<void> updateIngredient(Ingredient ingredient) async {
    await _ingredientsCollection.doc(ingredient.id).update(ingredient.toMap());
  }
  
  // Delete an ingredient (for admin use)
  Future<void> deleteIngredient(String id) async {
    await _ingredientsCollection.doc(id).delete();
  }
  
  // Initialize sample data (run this once to populate Firestore)
  Future<void> initializeSampleData() async {
    // Check if data already exists
    final snapshot = await _ingredientsCollection.limit(1).get();
    if (snapshot.docs.isNotEmpty) return;
    
    // Sample ingredients data using provided JSON
    final sampleIngredients = [
      // Meats
      {
        'name': 'Chicken Breast',
        'category': 'meat',
        'calories': 165.0,
        'price': 12.99,
        'imageUrl': 'https://www.savorynothings.com/wp-content/uploads/2021/02/airy-fryer-chicken-breast-image-8.jpg',
      },
      {
        'name': 'Salmon',
        'category': 'meat',
        'calories': 206.0,
        'price': 16.99,
        'imageUrl': 'https://cdn.apartmenttherapy.info/image/upload/f_jpg,q_auto:eco,c_fill,g_auto,w_1500,ar_1:1/k%2F2023-04-baked-salmon-how-to%2Fbaked-salmon-step6-4792',
      },
      {
        'name': 'Lean Beef',
        'category': 'meat',
        'calories': 250.0,
        'price': 14.99,
        'imageUrl': 'https://www.mashed.com/img/gallery/the-truth-about-lean-beef/l-intro-1621886574.jpg',
      },
      {
        'name': 'Turkey',
        'category': 'meat',
        'calories': 135.0,
        'price': 11.99,
        'imageUrl': 'https://fox59.com/wp-content/uploads/sites/21/2022/11/white-meat.jpg?w=2560&h=1440&crop=1',
      },
      
      // Vegetables
      {
        'name': 'Broccoli',
        'category': 'vegetable',
        'calories': 55.0,
        'price': 2.99,
        'imageUrl': 'https://cdn.britannica.com/25/78225-050-1781F6B7/broccoli-florets.jpg',
      },
      {
        'name': 'Spinach',
        'category': 'vegetable',
        'calories': 23.0,
        'price': 3.49,
        'imageUrl': 'https://www.daysoftheyear.com/cdn-cgi/image/dpr=1%2Cf=auto%2Cfit=cover%2Cheight=650%2Cq=40%2Csharpen=1%2Cwidth=956/wp-content/uploads/fresh-spinach-day.jpg',
      },
      {
        'name': 'Carrot',
        'category': 'vegetable',
        'calories': 41.0,
        'price': 1.99,
        'imageUrl': 'https://cdn11.bigcommerce.com/s-kc25pb94dz/images/stencil/1280x1280/products/271/762/Carrot__40927.1634584458.jpg?c=2',
      },
      {
        'name': 'Bell Pepper',
        'category': 'vegetable',
        'calories': 31.0,
        'price': 2.49,
        'imageUrl': 'https://i5.walmartimages.com/asr/5d3ca3f5-69fa-436a-8a73-ac05713d3c2c.7b334b05a184b1eafbda57c08c6b8ccf.jpeg?odnHeight=768&odnWidth=768&odnBg=FFFFFF',
      },
      
      // Carbs
      {
        'name': 'Brown Rice',
        'category': 'carbs',
        'calories': 111.0,
        'price': 3.99,
        'imageUrl': 'https://assets-jpcust.jwpsrv.com/thumbnails/k98gi2ri-720.jpg',
      },
      {
        'name': 'Oats',
        'category': 'carbs',
        'calories': 389.0,
        'price': 4.49,
        'imageUrl': 'https://media.post.rvohealth.io/wp-content/uploads/2020/03/oats-oatmeal-732x549-thumbnail.jpg',
      },
      {
        'name': 'Sweet Corn',
        'category': 'carbs',
        'calories': 86.0,
        'price': 2.99,
        'imageUrl': 'https://m.media-amazon.com/images/I/41F62-VbHSL._AC_UF1000,1000_QL80_.jpg',
      },
      {
        'name': 'Black Beans',
        'category': 'carbs',
        'calories': 132.0,
        'price': 2.49,
        'imageUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTwxSM9Ib-aDXTUIATZlRPQ6qABkkJ0sJwDmA&usqp=CAU',
      },
    ];
    
    // Add all sample ingredients to Firestore
    final batch = _firestore.batch();
    for (final ingredient in sampleIngredients) {
      final docRef = _ingredientsCollection.doc();
      batch.set(docRef, ingredient);
    }
    
    await batch.commit();
  }
}
