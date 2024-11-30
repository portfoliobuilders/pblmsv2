import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AttemptAssignmentPage extends StatefulWidget {
  final String courseId;
  final String moduleId;

  const AttemptAssignmentPage({required this.courseId, required this.moduleId, Key? key}) : super(key: key);

  @override
  _AttemptAssignmentPageState createState() => _AttemptAssignmentPageState();
}

class _AttemptAssignmentPageState extends State<AttemptAssignmentPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, String> studentAnswers = {}; // Map to store the answers
  bool isSubmitted = false;
  bool canSeeNextModule = false;

  Stream<QuerySnapshot> _fetchAssignments() {
    return _firestore
        .collection('courses')
        .doc(widget.courseId)
        .collection('modules')
        .doc(widget.moduleId)
        .collection('assignments')
        .snapshots();
  }

  Future<void> _submitQuiz() async {
    final assignments = await _fetchAssignments().first;

    // Check if the student has answered all questions
    if (studentAnswers.length != assignments.docs.length) {
      _showError('Please answer all the questions');
      return;
    }

    // Calculate the percentage mark
    int totalQuestions = assignments.docs.length;
    int correctAnswers = 0;

    assignments.docs.forEach((assignmentDoc) {
      final question = assignmentDoc['question'];
      final correctAnswer = assignmentDoc['correctAnswer'];

      if (studentAnswers[question] == correctAnswer) {
        correctAnswers++;
      }
    });

    double percentageMark = (correctAnswers / totalQuestions) * 100;

    // Check if the percentage mark is greater than or equal to 50%
    if (percentageMark >= 50) {
      await _unlockNextModule();  // Unlock the next module if the score is 50% or more
    }

    // You can store the student's answers in Firestore, if needed
    try {
      await _firestore.collection('courses')
          .doc(widget.courseId)
          .collection('modules')
          .doc(widget.moduleId)
          .collection('submissions')
          .add({
        'studentAnswers': studentAnswers,
        'submittedAt': FieldValue.serverTimestamp(),
      });

      // Show submission success message
      _showSuccess('Your answers have been submitted successfully!');
      setState(() {
        isSubmitted = true;
        canSeeNextModule = percentageMark >= 50;  // Allow viewing the next module if the score is 50% or more
      });

      _showCompletionDialog(percentageMark, correctAnswers, totalQuestions);
    } catch (e) {
      _showError('Failed to submit the quiz: $e');
    }
  }

  Future<void> _unlockNextModule() async {
  try {
    print('Attempting to unlock next module');
    
    // Get current module's order
    DocumentSnapshot moduleDoc = await _firestore
        .collection('courses')
        .doc(widget.courseId)
        .collection('modules')
        .doc(widget.moduleId)
        .get();
    
    int currentOrder = moduleDoc['order'] ?? 0;
    print('Current module order: $currentOrder');
    
    // Find next module
    QuerySnapshot nextModuleQuery = await _firestore
        .collection('courses')
        .doc(widget.courseId)
        .collection('modules')
        .where('order', isEqualTo: currentOrder + 1)
        .limit(1)
        .get();
    
    print('Next module query results: ${nextModuleQuery.docs.length}');
    
    // If next module exists, unlock it
    if (nextModuleQuery.docs.isNotEmpty) {
      String nextModuleId = nextModuleQuery.docs.first.id;
      print('Unlocking next module: $nextModuleId');
      
      await _firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('unlockedModules')
          .doc(nextModuleId)
          .set({
        'unlockedAt': FieldValue.serverTimestamp(),
        'courseId': widget.courseId,
      });
      
      print('Next module unlocked successfully');
    } else {
      print('No next module found');
    }
  } catch (e) {
    print('Detailed error unlocking next module: $e');
  }
}

  void _showCompletionDialog(double percentage, int correct, int total) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Quiz Complete'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Score: ${percentage.toStringAsFixed(1)}%'),
              Text('Correct answers: $correct out of $total'),
              if (percentage >= 50)
                const Text('\nCongratulations! You have unlocked the next module.'),
              if (percentage < 50)
                const Text('\nYou need 50% or higher to unlock the next module.'),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                if (canSeeNextModule) {
                  Navigator.of(context).pop(); // Return to course page
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attempt Assignment')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _fetchAssignments(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final assignments = snapshot.data?.docs ?? [];

          if (assignments.isEmpty) {
            return const Center(child: Text('No assignments available.'));
          }

          return Column(
            children: [
              // Display the questions dynamically
              Expanded(
                child: ListView.builder(
                  itemCount: assignments.length,
                  itemBuilder: (context, index) {
                    final assignment = assignments[index].data() as Map<String, dynamic>;
                    final question = assignment['question'] ?? 'No question';
                    final choices = List<String>.from(assignment['choices'] ?? []);

                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Question ${index + 1}: $question',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8.0,
                              children: choices.map((choice) {
                                return ChoiceChip(
                                  label: Text(choice),
                                  selected: studentAnswers[question] == choice,
                                  onSelected: (selected) {
                                    setState(() {
                                      studentAnswers[question] = selected ? choice : '';
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Submit button
              isSubmitted
                  ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: null,
                        child: const Text('Quiz Submitted'),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: _submitQuiz,
                        child: const Text('Submit Quiz'),
                      ),
                    ),
              // Show next module button if eligible
              if (canSeeNextModule)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      // Get the next module ID dynamically
                      final nextModuleId = await _getNextModuleId();
                      
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AttemptAssignmentPage(
                            courseId: widget.courseId,
                            moduleId: nextModuleId,  // Pass the next module ID here
                          ),
                        ),
                      );
                    },
                    child: const Text('Go to Next Module'),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<String> _getNextModuleId() async {
    try {
      // Get the current module's order
      DocumentSnapshot moduleDoc = await _firestore
          .collection('courses')
          .doc(widget.courseId)
          .collection('modules')
          .doc(widget.moduleId)
          .get();
      
      int currentOrder = moduleDoc['order'] ?? 0;

      // Get the next module
      QuerySnapshot nextModuleQuery = await _firestore
          .collection('courses')
          .doc(widget.courseId)
          .collection('modules')
          .where('order', isEqualTo: currentOrder + 1)
          .limit(1)
          .get();

      if (nextModuleQuery.docs.isNotEmpty) {
        return nextModuleQuery.docs.first.id;
      }
    } catch (e) {
      print('Error fetching next module: $e');
    }
    return ''; // Return an empty string if no next module is found
  }
}
