import 'package:cloud_firestore/cloud_firestore.dart';

/// Run once to populate Firestore with sample data for Kali Marketplace.
/// Call `SeedData.seed()` from a button or from main during development.
class SeedData {
  static Future<void> seed() async {
    final firestore = FirebaseFirestore.instance;

    // Categories
    final categories = [
      {'name': 'Restaurants', 'icon': 'restaurant', 'sortOrder': 0},
      {'name': 'Fast Food', 'icon': 'fastfood', 'sortOrder': 1},
      {'name': 'Groceries', 'icon': 'local_grocery_store', 'sortOrder': 2},
      {'name': 'Pharmacy', 'icon': 'local_pharmacy', 'sortOrder': 3},
      {'name': 'Bakery', 'icon': 'bakery_dining', 'sortOrder': 4},
    ];

    for (final cat in categories) {
      await firestore.collection('categories').add(cat);
    }

    // Vendors
    final vendors = [
      {
        'name': 'Mama Nkechi Kitchen',
        'description': 'Authentic Nigerian dishes made with love',
        'imageUrl': '',
        'logoUrl': '',
        'category': 'Restaurants',
        'rating': 4.7,
        'reviewCount': 234,
        'prepTimeMinutes': 25,
        'deliveryFee': 500,
        'minOrder': 1500,
        'isOpen': true,
        'address': '12 Allen Avenue, Ikeja',
        'tags': ['Nigerian', 'Local', 'Rice', 'Soup'],
      },
      {
        'name': 'Chicken Republic',
        'description': 'Tasty chicken meals and fast food',
        'imageUrl': '',
        'logoUrl': '',
        'category': 'Fast Food',
        'rating': 4.3,
        'reviewCount': 456,
        'prepTimeMinutes': 15,
        'deliveryFee': 300,
        'minOrder': 1000,
        'isOpen': true,
        'address': '5 Broad Street, Lagos Island',
        'tags': ['Chicken', 'Fast Food', 'Burgers'],
      },
      {
        'name': 'Dominos Pizza',
        'description': 'Fresh pizza delivered hot to your door',
        'imageUrl': '',
        'logoUrl': '',
        'category': 'Fast Food',
        'rating': 4.5,
        'reviewCount': 890,
        'prepTimeMinutes': 30,
        'deliveryFee': 0,
        'minOrder': 3000,
        'isOpen': true,
        'address': '15 Admiralty Way, Lekki',
        'tags': ['Pizza', 'Italian', 'Fast Food'],
      },
      {
        'name': 'Sweet Sensation',
        'description': 'Nigerian fast food and pastries',
        'imageUrl': '',
        'logoUrl': '',
        'category': 'Fast Food',
        'rating': 4.1,
        'reviewCount': 312,
        'prepTimeMinutes': 20,
        'deliveryFee': 400,
        'minOrder': 800,
        'isOpen': true,
        'address': '8 Ogunlana Drive, Surulere',
        'tags': ['Fast Food', 'Pastries', 'Nigerian'],
      },
      {
        'name': 'The Yellow Chilli',
        'description': 'Premium Nigerian continental cuisine',
        'imageUrl': '',
        'logoUrl': '',
        'category': 'Restaurants',
        'rating': 4.8,
        'reviewCount': 567,
        'prepTimeMinutes': 35,
        'deliveryFee': 700,
        'minOrder': 3000,
        'isOpen': true,
        'address': '27 Adeola Odeku, Victoria Island',
        'tags': ['Nigerian', 'Continental', 'Fine Dining'],
      },
      {
        'name': 'Shoprite Groceries',
        'description': 'Fresh groceries and household items',
        'imageUrl': '',
        'logoUrl': '',
        'category': 'Groceries',
        'rating': 4.2,
        'reviewCount': 145,
        'prepTimeMinutes': 40,
        'deliveryFee': 600,
        'minOrder': 2000,
        'isOpen': true,
        'address': 'Palms Shopping Mall, Lekki',
        'tags': ['Groceries', 'Supermarket', 'Fresh'],
      },
    ];

    final vendorDocs = <String>[];
    for (final vendor in vendors) {
      final doc = await firestore.collection('vendors').add(vendor);
      vendorDocs.add(doc.id);
    }

    // Products for Mama Nkechi (index 0)
    final mamaNkechiProducts = [
      {
        'vendorId': vendorDocs[0],
        'name': 'Jollof Rice & Chicken',
        'description': 'Party-style jollof rice with grilled chicken',
        'imageUrl': '',
        'menuCategory': 'Rice Dishes',
        'price': 2500,
        'discountPrice': null,
        'isAvailable': true,
        'tags': ['Rice', 'Chicken'],
      },
      {
        'vendorId': vendorDocs[0],
        'name': 'Fried Rice & Turkey',
        'description': 'Special fried rice with seasoned turkey',
        'imageUrl': '',
        'menuCategory': 'Rice Dishes',
        'price': 3000,
        'discountPrice': 2700,
        'isAvailable': true,
        'tags': ['Rice', 'Turkey'],
      },
      {
        'vendorId': vendorDocs[0],
        'name': 'Egusi Soup with Pounded Yam',
        'description': 'Rich egusi soup served with fluffy pounded yam',
        'imageUrl': '',
        'menuCategory': 'Soups & Swallow',
        'price': 3500,
        'discountPrice': null,
        'isAvailable': true,
        'tags': ['Soup', 'Swallow'],
      },
      {
        'vendorId': vendorDocs[0],
        'name': 'Pepper Soup',
        'description': 'Spicy goat meat pepper soup',
        'imageUrl': '',
        'menuCategory': 'Soups & Swallow',
        'price': 2000,
        'discountPrice': null,
        'isAvailable': true,
        'tags': ['Soup', 'Spicy'],
      },
      {
        'vendorId': vendorDocs[0],
        'name': 'Moi Moi',
        'description': 'Steamed bean pudding with egg and fish',
        'imageUrl': '',
        'menuCategory': 'Sides',
        'price': 500,
        'discountPrice': null,
        'isAvailable': true,
        'tags': ['Side'],
      },
      {
        'vendorId': vendorDocs[0],
        'name': 'Chapman',
        'description': 'Classic Nigerian cocktail drink',
        'imageUrl': '',
        'menuCategory': 'Drinks',
        'price': 800,
        'discountPrice': null,
        'isAvailable': true,
        'tags': ['Drink'],
      },
    ];

    // Products for Chicken Republic (index 1)
    final chickenProducts = [
      {
        'vendorId': vendorDocs[1],
        'name': 'Chicken Meal Box',
        'description': '2pc chicken with rice, coleslaw and drink',
        'imageUrl': '',
        'menuCategory': 'Combo Meals',
        'price': 3200,
        'discountPrice': 2800,
        'isAvailable': true,
        'tags': ['Combo', 'Chicken'],
      },
      {
        'vendorId': vendorDocs[1],
        'name': 'Chicken Burger',
        'description': 'Crispy chicken fillet burger with fries',
        'imageUrl': '',
        'menuCategory': 'Burgers',
        'price': 2200,
        'discountPrice': null,
        'isAvailable': true,
        'tags': ['Burger'],
      },
      {
        'vendorId': vendorDocs[1],
        'name': 'Sharwarma',
        'description': 'Loaded chicken shawarma wrap',
        'imageUrl': '',
        'menuCategory': 'Wraps',
        'price': 1800,
        'discountPrice': null,
        'isAvailable': true,
        'tags': ['Wrap', 'Shawarma'],
      },
      {
        'vendorId': vendorDocs[1],
        'name': 'Chicken Wings (6pc)',
        'description': 'Crispy fried chicken wings',
        'imageUrl': '',
        'menuCategory': 'Sides',
        'price': 2000,
        'discountPrice': null,
        'isAvailable': true,
        'tags': ['Sides', 'Chicken'],
      },
    ];

    // Products for Dominos (index 2)
    final dominosProducts = [
      {
        'vendorId': vendorDocs[2],
        'name': 'Pepperoni Pizza (Large)',
        'description': 'Classic pepperoni with mozzarella cheese',
        'imageUrl': '',
        'menuCategory': 'Pizza',
        'price': 7500,
        'discountPrice': 6500,
        'isAvailable': true,
        'tags': ['Pizza'],
      },
      {
        'vendorId': vendorDocs[2],
        'name': 'BBQ Chicken Pizza (Medium)',
        'description': 'Grilled chicken, BBQ sauce, onions',
        'imageUrl': '',
        'menuCategory': 'Pizza',
        'price': 5500,
        'discountPrice': null,
        'isAvailable': true,
        'tags': ['Pizza', 'Chicken'],
      },
      {
        'vendorId': vendorDocs[2],
        'name': 'Garlic Bread',
        'description': 'Buttery garlic bread with herbs',
        'imageUrl': '',
        'menuCategory': 'Sides',
        'price': 1200,
        'discountPrice': null,
        'isAvailable': true,
        'tags': ['Side', 'Bread'],
      },
    ];

    final allProducts = [
      ...mamaNkechiProducts,
      ...chickenProducts,
      ...dominosProducts,
    ];

    for (final product in allProducts) {
      await firestore.collection('products').add(product);
    }
  }
}
