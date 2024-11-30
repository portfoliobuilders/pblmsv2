import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:portfoliobuilderslms/admin/excel/model1.dart';
import 'package:portfoliobuilderslms/admin/excel/test2.dart'; // Make sure to import your model here

class ExcelImportPage extends StatefulWidget {
  @override
  _ExcelImportPageState createState() => _ExcelImportPageState();
}

class _ExcelImportPageState extends State<ExcelImportPage> {
  List<Map<String, dynamic>> _studentData = [];
  bool _isLoading = false;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
Future<void> _saveToFirebase() async {
  setState(() {
    _isLoading = true; // Start loading indicator
  });

  try {
    WriteBatch batch = firestore.batch();

    for (var studentData in _studentData) {
      if (studentData['name'] != null &&
          studentData['email'] != null &&
          studentData['password'] != null) {
        // Trim email to remove extra spaces
        String email = studentData['email'].trim();

        // Validate email format
        if (!isValidEmail(email)) {
          print("Invalid email format: $email");
          continue;
        }

        // Check if user already exists in Firebase Auth
        List<String> signInMethods = await auth.fetchSignInMethodsForEmail(email);
        if (signInMethods.isNotEmpty) {
          print("Email already in use: $email");
          continue; // Skip this student if the email is already in use
        }

        // Create user in Firebase Auth
        UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: email,
          password: studentData['password'],
        );

        if (userCredential.user != null) {
          // Save user data to Firestore
          DocumentReference docRef = firestore.collection('users').doc(userCredential.user!.uid);
          batch.set(docRef, {
            'name': studentData['name'],
            'email': email,
            'branch': studentData['branch'],
            'course': studentData['course'],
            'JoiningDate': studentData['JoiningDate'],
            'enrolmentnumb': studentData['enrolmentnumb'],
          });
        }
      }
    }

    // Commit the batch operation
    await batch.commit();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Students saved to Firebase successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    print("Error: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error saving to Firebase: $e'),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    setState(() {
      _isLoading = false; // Stop loading indicator
    });
  }
}

  bool isValidEmail(String email) {
    String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(email);
  }

  // Future<List<Map<String, dynamic>>> _fetchStudentsFromFirestore() async {
  //   try {
  //     QuerySnapshot snapshot = await firestore.collection('users').get();
  //     return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  //   } catch (e) {
  //     print('Error fetching students from Firestore: $e');
  //     return [];
  //   }
  // }

  Future<void> _pickExcelFile() async {
    setState(() => _isLoading = true);

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        Uint8List? bytes = result.files.single.bytes;
        var excel = Excel.decodeBytes(bytes!);

        for (var table in excel.tables.keys) {
          for (var row in excel.tables[table]!.rows.skip(1)) {
            if (row.length >= 3 && row.any((cell) => cell?.value != null)) {
              _studentData.add({
                'name': row[0]?.value?.toString() ?? 'N/A',
                'enrolmentnumb': row[1]?.value?.toString() ?? 'N/A',
                'branch': row[2]?.value?.toString() ?? 'N/A',
                'course': row[3]?.value?.toString() ?? 'N/A',
                'JoiningDate': row[4]?.value?.toString() ?? 'N/A',
                'password': row[5]?.value?.toString() ?? 'defaultPassword123',
                'email': row[6]?.value?.toString() ?? 'N/A',
              });
            }
          }
          break;
        }
      }
    } catch (e) {
      print('Error importing Excel file: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error importing file')));
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Excel Viewer', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => StudentAnalytics()));
            },
            icon: Icon(Icons.bar_chart, color: Colors.white),
            label: Text("Analytics", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickExcelFile,
              child: Card(
                color: Colors.blue[50],
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.upload_file, size: 36, color: Colors.blue),
                      SizedBox(width: 16),
                      Text(
                        "Import Excel File",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _studentData.isEmpty ? null : _saveToFirebase,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text("Save to Firebase", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 16),
          //   _isLoading
          //       ? Center(child: CircularProgressIndicator())
          //       : Expanded(
          //           child: FutureBuilder<List<Map<String, dynamic>>>(
          //           //  future: _fetchStudentsFromFirestore(),
          //             builder: (context, snapshot) {
          //               if (snapshot.connectionState == ConnectionState.waiting) {
          //                 return Center(child: CircularProgressIndicator());
          //               } else if (snapshot.hasError) {
          //                 return Center(child: Text("Error fetching students: ${snapshot.error}"));
          //               } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          //                 return Center(child: Text("No students found in Firestore"));
          //               }

          //               return ListView.builder(
          //                 itemCount: snapshot.data!.length,
          //                 itemBuilder: (context, index) {
          //                   final student = snapshot.data![index];
          //                   return Card(
          //                     margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          //                     elevation: 3,
          //                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          //                     child: ListTile(
          //                       leading: CircleAvatar(
          //                         child: Icon(Icons.person),
          //                         backgroundColor: Colors.blueAccent,
          //                       ),
          //                       title: Text(student['name'] ?? 'N/A'),
          //                       subtitle: Text("Enrollment: ${student['enrolmentnumb'] ?? 'N/A'}"),
          //                       trailing: Icon(Icons.arrow_forward_ios),
          //                     ),
          //                   );
          //                 },
          //               );
          //             },
          //           ),
          //         ),
          ],
        ),
      ),
    );
  }
}
