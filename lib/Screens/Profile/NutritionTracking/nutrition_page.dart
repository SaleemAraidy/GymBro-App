import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gymbro/Screens/Profile/NutritionTracking/meal_calories_tracking.dart';
import 'package:gymbro/Widgets/date_picker.dart';
import 'package:gymbro/Widgets/user_utility.dart';

class NutritionPage extends StatefulWidget {
  @override
  _NutritionPageState createState() => _NutritionPageState();
}

class _NutritionPageState extends State<NutritionPage> with SingleTickerProviderStateMixin {
  int totalCalories = 0;
  int totalProtein = 0;
  int totalCarbs = 0;
  int totalFats = 0;
  
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  DateTime selectedDate = DateTime.now();
  String username = "";

  // Map to store exercise data for each date
  Map<DateTime, List<Meal>> mealsData = {};

  late Stream<DocumentSnapshot> _userDataStream = const Stream.empty();
  
  Future<void> _handleDateSelected(DateTime pickedDate) async {
    setState(() {
      selectedDate = pickedDate;
    });

    final userID = await UserUtility.getUserIDFromName(username);

    // Create a nutrition document for the selected date
    final nutrition = <String, dynamic> {
      'userID' : userID,
      'calories': 0,
      'carbs' : 0,
      'fat' : 0,
      'protein' : 0,
      'date' : selectedDate,
    };

    // Add the nutrition document with an automatically generated document ID

    final existingDocs = await FirebaseFirestore.instance
        .collection('nutritions')
        .where('userID', isEqualTo: userID)
        .where('date', isGreaterThanOrEqualTo: DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 0, 0, 0))
        .where('date', isLessThanOrEqualTo: DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59))
        .limit(1)
        .get();

    if (existingDocs.docs.isEmpty) {
      try {
        DocumentReference nutritionRef = FirebaseFirestore.instance
            .collection('nutritions')
            .doc();
        await nutritionRef.set(nutrition);

        print('Nutrition document added successfully!');
      } catch (e) {
        print('Failed to add nutrition document: $e');
      }
    }

  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _progressAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(_animationController);
    _getUserData();
  }

  Stream<List<int?>?> _fetchTotalCaloriesAndMacros() async* {
    // Query the document with the current selected date
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await _retrieveOneDocFromDate();

    if (querySnapshot.docs.isNotEmpty) {
      totalCalories = querySnapshot.docs[0]['calories'];
      totalCarbs = querySnapshot.docs[0]['carbs'];
      totalFats = querySnapshot.docs[0]['fat'];
      totalProtein = querySnapshot.docs[0]['protein'];

      yield [totalCalories, totalProtein, totalCarbs, totalFats];
    }

    // yield null;
  }

  Future<void> _getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    final userID = user?.uid ?? '';
    final snapshot = await FirebaseFirestore.instance.collection("users").doc(userID).get();

    if (snapshot.exists) {
      setState(() {
        _userDataStream = snapshot.reference.snapshots();
        username = snapshot.data()?["username"] as String? ?? '';
      });
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> _retrieveOneDocFromDate() async {

    // Query the document with the current selected date
    final querySnapshot = await FirebaseFirestore.instance
        .collection('nutritions')
        .where('userID', isEqualTo: await UserUtility.getUserIDFromName(username))
        .where('date', isGreaterThanOrEqualTo: DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 0, 0, 0))
        .where('date', isLessThanOrEqualTo: DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59))
        .limit(1)
        .get();
    return querySnapshot;
  }

  Future<void> addTotalCalories(int calories) async {
    setState(() {
      totalCalories += calories;
      _animationController.reset();
      _animationController.forward();
    });

    // Query the document with the current selected date
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await _retrieveOneDocFromDate();

    if (querySnapshot.docs.isNotEmpty) {
      final docSnapshot = querySnapshot.docs[0];
      final documentID = docSnapshot.id;

      try {
        await FirebaseFirestore.instance
            .collection('nutritions')
            .doc(documentID)
            .update({'calories' : FieldValue.increment(calories)});
        print("Update nutrition document's total calories successfully");
      } catch(e) {
        print('Failed to update nutrition document: $e');
      }
    }
  }

  Future<void> removeTotalCalories(int calories) async {
    setState(() {
      totalCalories -= calories;
      _animationController.reset();
      _animationController.forward();
    });

    // Query the document with the current selected date
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await _retrieveOneDocFromDate();

    if (querySnapshot.docs.isNotEmpty) {
      final docSnapshot = querySnapshot.docs[0];
      final documentID = docSnapshot.id;

      try {
        await FirebaseFirestore.instance
            .collection('nutritions')
            .doc(documentID)
            .update({'calories' : FieldValue.increment(-calories)});
        print("Update nutrition document's total calories successfully");
      } catch(e) {
        print('Failed to update nutrition document: $e');
      }
    }
  }

  Future<void> addTotalCarbs(int grams) async {
    setState(() {
      totalCarbs += grams;
      _animationController.reset();
      _animationController.forward();
    });

    // Query the document with the current selected date
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await _retrieveOneDocFromDate();

    if (querySnapshot.docs.isNotEmpty) {
      final docSnapshot = querySnapshot.docs[0];
      final documentID = docSnapshot.id;

      try {
        await FirebaseFirestore.instance
            .collection('nutritions')
            .doc(documentID)
            .update({'carbs' : FieldValue.increment(grams)});
        print("Update nutrition document's total carbs successfully");
      } catch(e) {
        print('Failed to update nutrition document: $e');
      }
    }
  }

  Future<void> removeTotalCarbs(int grams) async {
    setState(() {
      totalCarbs -= grams;
      _animationController.reset();
      _animationController.forward();
    });

    // Query the document with the current selected date
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await _retrieveOneDocFromDate();

    if (querySnapshot.docs.isNotEmpty) {
      final docSnapshot = querySnapshot.docs[0];
      final documentID = docSnapshot.id;

      try {
        await FirebaseFirestore.instance
            .collection('nutritions')
            .doc(documentID)
            .update({'carbs' : FieldValue.increment(-grams)});
        print("Update nutrition document's total carbs successfully");
      } catch(e) {
        print('Failed to update nutrition document: $e');
      }
    }
  }

  Future<void> addTotalFats(int grams) async {
    setState(() {
      totalFats += grams;
      _animationController.reset();
      _animationController.forward();
    });

    // Query the document with the current selected date
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await _retrieveOneDocFromDate();

    if (querySnapshot.docs.isNotEmpty) {
      final docSnapshot = querySnapshot.docs[0];
      final documentID = docSnapshot.id;

      try {
        await FirebaseFirestore.instance
            .collection('nutritions')
            .doc(documentID)
            .update({'fat' : FieldValue.increment(grams)});
        print("Update nutrition document's total fat successfully");
      } catch(e) {
        print('Failed to update nutrition document: $e');
      }
    }
  }

  Future<void> removeTotalFats(int grams) async {
    setState(() {
      totalFats -= grams;
      _animationController.reset();
      _animationController.forward();
    });

    // Query the document with the current selected date
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await _retrieveOneDocFromDate();

    if (querySnapshot.docs.isNotEmpty) {
      final docSnapshot = querySnapshot.docs[0];
      final documentID = docSnapshot.id;

      try {
        await FirebaseFirestore.instance
            .collection('nutritions')
            .doc(documentID)
            .update({'calories' : FieldValue.increment(-grams)});
        print("Update nutrition document's total calories successfully");
      } catch(e) {
        print('Failed to update nutrition document: $e');
      }
    }
  }

  Future<void> addTotalProtein(int grams) async {
    setState(() {
      totalProtein += grams;
      _animationController.reset();
      _animationController.forward();
    });

    // Query the document with the current selected date
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await _retrieveOneDocFromDate();

    if (querySnapshot.docs.isNotEmpty) {
      final docSnapshot = querySnapshot.docs[0];
      final documentID = docSnapshot.id;

      try {
        await FirebaseFirestore.instance
            .collection('nutritions')
            .doc(documentID)
            .update({'protein' : FieldValue.increment(grams)});
        print("Update nutrition document's total protein successfully");
      } catch(e) {
        print('Failed to update nutrition document: $e');
      }
    }
  }

  Future<void> removeTotalProtein(int grams) async {
    setState(() {
      totalProtein -= grams;
      _animationController.reset();
      _animationController.forward();
    });

    // Query the document with the current selected date
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await _retrieveOneDocFromDate();

    if (querySnapshot.docs.isNotEmpty) {
      final docSnapshot = querySnapshot.docs[0];
      final documentID = docSnapshot.id;

      try {
        await FirebaseFirestore.instance
            .collection('nutritions')
            .doc(documentID)
            .update({'protein' : FieldValue.increment(-grams)});
        print("Update nutrition document's total protein successfully");
      } catch(e) {
        print('Failed to update nutrition document: $e');
      }
    }
  }

  Future<void> _addMealDocToDatabase(String mealName, int calories, int carbs, int fat, int protein) async {
    // Get user ID
    String? userID = await UserUtility.getUserIDFromName(username);

    // Create a new document for meals collection
    final meal = <String, dynamic> {
      'userID': userID,
      'date': selectedDate,
      'title': mealName,
      'calories' : calories,
      'carbs' : carbs,
      'fat' : fat,
      'protein' : protein,
    };

    addTotalCalories(calories);
    addTotalCarbs(carbs);
    addTotalFats(fat);
    addTotalProtein(protein);

    // Add the goal document with an automatically generated document ID
    DocumentReference mealRef = FirebaseFirestore.instance
        .collection('meals')
        .doc();
    await mealRef.set(meal);
  }

  Stream<Map<DateTime, List<Meal>>> _fetchMealsData() async* {
    try {
      final userID = await UserUtility.getUserIDFromName(username);

      final querySnapshot = await FirebaseFirestore.instance
          .collection('meals')
          .where('userID', isEqualTo: userID)
          .where('date', isGreaterThanOrEqualTo: DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 0, 0, 0))
          .where('date', isLessThanOrEqualTo: DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59))
          .get();

      final fetchedData = <DateTime, List<Meal>>{};
      for (final docSnapshot in querySnapshot.docs) {
        if (docSnapshot['date'] != null || docSnapshot['date'] != '') {
          final date = docSnapshot['date'].toDate();

          final truncatedDate = DateTime(date.year, date.month, date.day);

          final meal = Meal(
            title: docSnapshot['title'],
            calories: int.tryParse(docSnapshot['calories'].toString()) ?? 0,
            carbs: int.tryParse(docSnapshot['carbs'].toString()) ?? 0,
            fat: int.tryParse(docSnapshot['fat'].toString()) ?? 0,
            protein: int.tryParse(docSnapshot['protein'].toString()) ?? 0,
          );

          if (fetchedData.containsKey(truncatedDate)) {
            fetchedData[truncatedDate]!.add(meal);
          } else {
            fetchedData[truncatedDate] = [meal];
          }
        }
      }
      yield fetchedData;
    } catch (e) {
      print('Error fetching meals data: $e');
      yield {};
    }
  }


  void _showAddMealDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Declare controllers for capturing input
        TextEditingController mealNameController = TextEditingController();
        TextEditingController caloriesController = TextEditingController();
        TextEditingController carbsController = TextEditingController();
        TextEditingController fatController = TextEditingController();
        TextEditingController proteinController = TextEditingController();

        return AlertDialog(
          title: const Text("Enter your meal"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextField(
                  controller: mealNameController, // Assign the controller
                  decoration: const InputDecoration(labelText: 'Meal Title'),
                ),
                TextField(
                  controller: caloriesController, // Assign the controller
                  decoration: const InputDecoration(labelText: 'Total Calories'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: carbsController, // Assign the controller
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Carbs'),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: fatController, // Assign the controller
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Fats'),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: proteinController, // Assign the controller
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Protein'),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // Get exercise details from the controllers
                final String mealName = mealNameController.text;
                final int calories = int.tryParse(caloriesController.text) ?? 0;
                final int carbs = int.tryParse(carbsController.text) ?? 0;
                final int fat = int.tryParse(fatController.text) ?? 0;
                final int protein = int.tryParse(proteinController.text) ?? 0;


                await _addMealDocToDatabase(mealName, calories, carbs, fat, protein);

                // Show a scaffold message to indicate successful upload
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('The meal uploaded successfully!'),
                ),
                );

                Navigator.of(context).pop();
              },
              child: const Text("Enter"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nutrition Tracking',
          style: TextStyle(
            fontFamily: 'KaushanScript',
            fontSize: 24,
          ),
        ),
        backgroundColor: const Color(0xFFDEBB00),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              child: DatePickerWidget(
                initialDate: selectedDate,
                onDateSelected: _handleDateSelected,
              ),
            ),
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (BuildContext context, Widget? child) {
                return Column(
                  children: [
                    StreamBuilder<List<int?>?>(
                        stream: _fetchTotalCaloriesAndMacros(),
                        builder: (BuildContext context, AsyncSnapshot<List<int?>?> snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            List<int?> totalCaloriesAndMacros = snapshot.data ??
                                [0, 0, 0, 0];
                            // Use a default value if the data is null
                            totalCalories = totalCaloriesAndMacros[0] ?? 0;
                            return Container(
                              height: 150,
                              color: const Color(0xFFDEBB00),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    totalCalories.toString(),
                                    style: const TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const Text(
                                    'TOTAL CALORIES',
                                    style: TextStyle(
                                      fontFamily: 'TrebuchetMS',
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  LinearProgressIndicator(
                                    value: _progressAnimation.value,
                                    valueColor: const AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                    backgroundColor: Colors.white.withOpacity(0.3),
                                  ),
                                ],
                              ),
                            );
                          }
                        }),

                    StreamBuilder<List<int?>?>(
                        stream: _fetchTotalCaloriesAndMacros(),
                        builder: (BuildContext context, AsyncSnapshot<List<int?>?> snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            List<int?> totalCaloriesAndMacros = snapshot.data ?? [0, 0, 0, 0];
                            totalProtein = totalCaloriesAndMacros[1] ?? 0;
                            totalCarbs = totalCaloriesAndMacros[2] ?? 0;
                            totalFats = totalCaloriesAndMacros[3] ?? 0;

                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  MacroItem(
                                    image: const AssetImage('assets/images/protein.png'),
                                    label: 'Protein',
                                    value: '${totalProtein}g',
                                  ),
                                  MacroItem(
                                    image: const AssetImage('assets/images/carbs.jpeg'),
                                    label: 'Carbs',
                                    value: '${totalCarbs}g',
                                  ),
                                  MacroItem(
                                    image: const AssetImage('assets/images/fat.png'),
                                    label: 'Fats',
                                    value: '${totalFats}g',
                                  ),
                                ],
                              ),
                            );
                          }
                        }
                    ),
                  ],
                );

              },
            ),
            Container(
              padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    StreamBuilder<Map<DateTime, List<Meal>>>(
                      stream: _fetchMealsData(),
                      builder: (BuildContext context, AsyncSnapshot<Map<DateTime, List<Meal>>> snapshot) {
                        if (snapshot.hasData) {
                          mealsData = snapshot.data!;
                          final truncatedDate = DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            selectedDate.day,
                          );
                          return ListView(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(), // Disable outer scrolling
                            children: List.generate(
                              mealsData[truncatedDate]?.length ?? 0,
                                  (index) {
                                Meal meal = mealsData[truncatedDate]![index];
                                return MealCaloriesTrackingSection(
                                  mealName: meal.title,
                                  calories: meal.calories,
                                  carbs: meal.carbs,
                                  fat: meal.fat,
                                  protein: meal.protein,
                                );
                              },
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          return Container();
                        }
                      },
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: ElevatedButton(
                        onPressed: _showAddMealDialog,
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFFDEBB00)),
                        ),
                        child: const Text(
                            'Add Meal',
                            style: TextStyle(fontFamily: 'TrebuchetMS'),
                        ),
                      ),
                    ),
                  ],
                ),
            ),
          ],
        ),
      ),
    );
  }
}

class MacroItem extends StatelessWidget {
  final AssetImage image;
  final String label;
  final String value;

  MacroItem({
    required this.image,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[200],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image(
              image: image,
              width: 40,
              height: 40,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'TrebuchetMS',
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Meal {
  final String title;
  final int calories;
  final int carbs;
  final int fat;
  final int protein;

  Meal({
    required this.title,
    required this.calories,
    required this.carbs,
    required this.fat,
    required this.protein,
  });
}