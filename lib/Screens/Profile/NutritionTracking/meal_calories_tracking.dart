import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro/Screens/Profile/NutritionTracking/nutrition_page.dart';

class MealCaloriesTrackingSection extends StatefulWidget {
  final String mealName;
  final int calories;
  final int carbs;
  final int fat;
  final int protein;



  MealCaloriesTrackingSection({
    required this.mealName,
    required this.calories,
    required this.carbs,
    required this.fat,
    required this.protein,

  });

  @override
  _MealCaloriesTrackingSectionState createState() =>
      _MealCaloriesTrackingSectionState();
}

class _MealCaloriesTrackingSectionState extends State<MealCaloriesTrackingSection> {
  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          const Divider(
            thickness: 4,
            color: Color(0xFFDEBB00),
          ),
          const SizedBox(height: 16),
          Text(
            "${widget.mealName}: ${widget.calories}",
            style: const TextStyle(
              fontFamily: 'TrebuchetMS',
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MacroItem(
                  image: const AssetImage('assets/images/protein.png'),
                  label: 'Protein',
                  value: '${widget.protein}g',
                ),
                MacroItem(
                  image: const AssetImage('assets/images/carbs.jpeg'),
                  label: 'Carbs',
                  value: '${widget.carbs}g',
                ),
                MacroItem(
                  image: const AssetImage('assets/images/fat.png'),
                  label: 'Fats',
                  value: '${widget.fat}g',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

