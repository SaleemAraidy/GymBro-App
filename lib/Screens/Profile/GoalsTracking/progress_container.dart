import 'dart:async'; // Import for working with asynchronous operations
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gymbro/Widgets/date_picker.dart';
import 'package:gymbro/Widgets/user_utility.dart';

class ProgressContainer extends StatefulWidget {
  @override
  _ProgressContainerState createState() => _ProgressContainerState();
}

class _ProgressContainerState extends State<ProgressContainer> {
  DateTime selectedDate = DateTime.now();
  String username = "";
  late Stream<DocumentSnapshot> _userDataStream = const Stream.empty();
  // Map to store exercise data for each date
  Map<DateTime, List<Exercise>> exerciseData = {};

  Future<bool> _exerciseExistsThatDay(String exerciseName) async {
    final completer = Completer<bool>();

    FirebaseFirestore.instance
        .collection('goals')
        .where('userID', isEqualTo: UserUtility.getUserIDFromName(username))
        .where('exercise', isEqualTo: exerciseName)
        .where('date', isGreaterThanOrEqualTo: DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 0, 0, 0))
        .where('date', isLessThanOrEqualTo: DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59))
        .get()
        .then((querySnapshot) {
      for (var docSnapshot in querySnapshot.docs) {
        if (docSnapshot['exercise'] == exerciseName) {
          completer.complete(true);
          return;
        }
      }
      completer.complete(false);
    })
        .catchError((error) {
      completer.complete(false);
    });

    return completer.future;
  }


  void _handleDateSelected(DateTime pickedDate) {
    setState(() {
      selectedDate = pickedDate;
    });
  }

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _saveCheckBoxStatus(Exercise exercise, bool value) async {
    // Get the goal ID associated with the exercise
    await FirebaseFirestore.instance
        .collection('goals')
        .where('userID', isEqualTo: UserUtility.getUserIDFromName(username))
        .where('exercise', isEqualTo: exercise.name)
        .where('date', isGreaterThanOrEqualTo: DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 0, 0, 0))
        .where('date', isLessThanOrEqualTo: DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59))
        .get().then(
        (querySnapshot) {
          if (querySnapshot.docs.isNotEmpty) {
            final goalID = querySnapshot.docs[0].id;

            // Perform any additional action when the checkbox is toggled
            // Update checkbox status to the database
            FirebaseFirestore.instance
                .collection('goals')
                .doc(goalID)
                .update({
              'status': value ?? false,
            })
            .then((_) {
              print('Checkbox status updated successfully');

              // Update the local state with the updated value
              setState(() {
                exercise.setStatus(value);
              });

              setState(() {}); // Trigger a UI update
            })
            .catchError((error) {
              print('Failed to update checkbox status: $error');
            });
          }
        });
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

  Stream<Map<DateTime, List<Exercise>>> _fetchExerciseData() {
    final userID = UserUtility.getUserIDFromName(username).asStream();

    return userID.asyncMap((userID) async {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('goals')
          .where('userID', isEqualTo: userID)
          .where('date', isGreaterThanOrEqualTo: DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 0, 0, 0))
          .where('date', isLessThanOrEqualTo: DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59))
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final fetchedData = <DateTime, List<Exercise>>{};
        for (final docSnapshot in querySnapshot.docs) {
          if (docSnapshot['date'] != null && docSnapshot['date'] != "") {
            final date = docSnapshot['date'].toDate();

            // Create a new DateTime object with only the year, month, and day components
            final truncatedDate = DateTime(date.year, date.month, date.day);

            final exercise = Exercise(
              name: docSnapshot['exercise'],
              weight: docSnapshot['weight'],
              sets: docSnapshot['sets'],
              reps: docSnapshot['reps'],
              status: docSnapshot['status'],
            );

            if (fetchedData.containsKey(truncatedDate)) {
              fetchedData[truncatedDate]!.add(exercise);
            } else {
              fetchedData[truncatedDate] = [exercise];
            }
          }
        }

        return fetchedData;
      }

      return <DateTime, List<Exercise>>{};
    });
  }

  void _showAddExerciseDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Declare controllers for capturing input
        TextEditingController exerciseNameController = TextEditingController();
        TextEditingController exerciseWeightController = TextEditingController();
        TextEditingController exerciseSetsController = TextEditingController();
        TextEditingController exerciseRepsController = TextEditingController();

        return AlertDialog(
          title: const Text("Enter your exercise"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextField(
                  controller: exerciseNameController, // Assign the controller
                  decoration: const InputDecoration(labelText: 'Exercise Name'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: exerciseWeightController, // Assign the controller
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Weight'),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: exerciseSetsController, // Assign the controller
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Sets'),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: exerciseRepsController, // Assign the controller
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Reps'),
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
                final String exerciseName = exerciseNameController.text;
                final int exerciseWeight = int.tryParse(exerciseWeightController.text) ?? 0;
                final int exerciseSets = int.tryParse(exerciseSetsController.text) ?? 0;
                final int exerciseReps = int.tryParse(exerciseRepsController.text) ?? 0;
                const bool status = false;

                if (await _exerciseExistsThatDay(exerciseName)) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Duplicated exercise name!'),
                  ),
                  );
                } else {
                  await _addGoalDocToDatabase(exerciseName, exerciseWeight, exerciseSets, exerciseReps, status);

                  // Show a scaffold message to indicate successful upload
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Goal uploaded successfully!'),
                  ),
                  );

                  Navigator.of(context).pop();
                }
              },
              child: const Text("Enter"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addGoalDocToDatabase(String exerciseName, int exerciseWeight, int exerciseSets, int exerciseReps, bool status) async {
    setState(() {
      final exercise = Exercise(
        name: exerciseName,
        weight: exerciseWeight,
        sets: exerciseSets,
        reps: exerciseReps,
        status: status,
      );

      // Check if the selected date already has exercise data
      if (exerciseData.containsKey(selectedDate)) {
        exerciseData[selectedDate]?.add(exercise);
      }
      else {
        exerciseData[selectedDate] = [exercise];
      }
    });

    // TODO: Add backend code to save the exercise data
    final userID = await UserUtility.getUserIDFromName(username);
    // Create a new document for goals collection
    final goal = <String, dynamic>{
      "userID" : userID,
      'exercise' : exerciseName,
      'weight' : exerciseWeight,
      'sets' : exerciseSets,
      'reps' : exerciseReps,
      'status' : false,
      'date' : selectedDate,
    };

    // Add the goal document with an automatically generated document ID
    DocumentReference goalRef = FirebaseFirestore.instance
        .collection('goals').doc();
    await goalRef.set(goal);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          child: DatePickerWidget(
            initialDate: selectedDate,
            onDateSelected: _handleDateSelected,
          ),
        ),
        Expanded(
          child: Card(
            child: Column(
              children: [
                Expanded(
                  child: StreamBuilder<Map<DateTime, List<Exercise>>>(
                    stream: _fetchExerciseData(),
                    builder: (BuildContext context, AsyncSnapshot<Map<DateTime, List<Exercise>>> snapshot) {
                      if (snapshot.hasData) {
                        exerciseData = snapshot.data!;
                        final truncatedDate = DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            selectedDate.day
                        );
                        return ListView.builder(
                          itemCount: exerciseData[truncatedDate]?.length ?? 0,
                          itemBuilder: (context, index) {
                            Exercise exercise = exerciseData[truncatedDate]![index];
                            bool isExerciseAchieved = exercise.status; // Track the achieved state of the exercise
                            return ListTile(
                              leading: const SizedBox(
                                width: 35,
                                height: 35,
                                child: Image(
                                    image: AssetImage('assets/images/dumbbell.png')
                                )
                              ),
                              title: Row(
                                children: [
                                  Text(
                                      exercise.name,
                                      style: const TextStyle(
                                        fontFamily: 'TrebuchetMS',
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF000000),
                                      )
                                  ),
                                  Checkbox(
                                      value: isExerciseAchieved,
                                      onChanged: (value) {
                                        _saveCheckBoxStatus(
                                          exercise,
                                          value!
                                        );
                                      }
                                  ),
                                ],
                              ),
                              subtitle: Text(
                                  "Weight: ${exercise.weight} kg, Sets: ${exercise.sets}, Reps: ${exercise.reps}",
                                  style: const TextStyle(
                                    fontFamily: 'TrebuchetMS',
                                    color: Color(0xFF000000),
                                  )
                              ),
                            );
                          },
                        );
                      }
                      else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      else {
                        return Container();
                      }
                    },
                  )
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: ElevatedButton(
                    onPressed: _showAddExerciseDialog,
                    style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.all<Color>(const Color(0xFFDEBB00)),
                    ),
                    child: const Text(
                      'Add Exercise',
                    ),
                  ),
                ),
              ]
            )
          ),
        ),
      ],
    );
  }
}


class Exercise {
  final String name;
  final int weight;
  final int sets;
  final int reps;
  bool status;

  Exercise({
    required this.name,
    required this.weight,
    required this.sets,
    required this.reps,
    required this.status,
  });

  void setStatus(bool newStatus) {
    status = newStatus;
  }
}
