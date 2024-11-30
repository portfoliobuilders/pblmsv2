import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:portfoliobuilderslms/user/videoplayer.dart';
import 'package:url_launcher/url_launcher.dart';


class UserAllocatedCoursesPage extends StatefulWidget {
  const UserAllocatedCoursesPage({Key? key}) : super(key: key);

  @override
  _UserAllocatedCoursesPageState createState() =>
      _UserAllocatedCoursesPageState();
}

class _UserAllocatedCoursesPageState extends State<UserAllocatedCoursesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Map<String, bool> expandedStates = {};

  Stream<QuerySnapshot> _getUserCourses(String userId) {
    return _firestore.collection('users').doc(userId).collection('courses').snapshots();
  }

  Future<String> _getCourseNameById(String courseId) async {
    try {
      DocumentSnapshot courseDoc = await _firestore.collection('courses').doc(courseId).get();
      return courseDoc.exists ? courseDoc['name'] ?? 'Unnamed Course' : 'Course Not Found';
    } catch (e) {
      print('Error fetching course name: $e');
      return 'Error';
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('User Allocated Courses'),
          centerTitle: true,
        ),
        body: const Center(
          child: Text('Please log in to see your courses'),
        ),
      );
    }

    String userId = user.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Allocated Courses'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getUserCourses(userId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final userCourses = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              itemCount: userCourses.length,
              itemBuilder: (context, index) {
                final userCourse = userCourses[index];
                final courseId = userCourse['courseId'];

                return FutureBuilder<String>(
                  future: _getCourseNameById(courseId),
                  builder: (context, courseSnapshot) {
                    if (courseSnapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox();
                    }
                    if (courseSnapshot.hasData) {
                      final courseName = courseSnapshot.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [const Color.fromARGB(255, 68, 218, 163), const Color.fromARGB(255, 18, 118, 4)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.book_outlined, size: 32, color: Colors.white),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      courseName,
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 22,
                                            color: Colors.white,
                                            letterSpacing: 1.2,
                                          ),
                                    ),
                                  ),
                                  Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 18),
                                ],
                              ),
                            ),
                          ),
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('courses')
                                .doc(courseId)
                                .collection('modules')
                                .orderBy('order') // Ensure modules are sorted by order
                                .snapshots(),
                            builder: (context, moduleSnapshot) {
                              if (!moduleSnapshot.hasData) {
                                return const SizedBox();
                              }

                              final modules = moduleSnapshot.data!.docs;

                              return Column(
                                children: modules.map((moduleDoc) {
                                  final moduleId = moduleDoc.id;
                                  final moduleName = moduleDoc['name'] ?? 'Unnamed Module';

                                  if (!expandedStates.containsKey(moduleId)) {
                                    expandedStates[moduleId] = false;
                                  }

                                  return Column(
                                    children: [
                                      Card(
                                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                                        elevation: 6.0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16.0),
                                        ),
                                        child: ListTile(
                                          contentPadding: const EdgeInsets.all(16.0),
                                          title: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  StreamBuilder<QuerySnapshot>(
                                                    stream: FirebaseFirestore.instance
                                                        .collection('courses')
                                                        .doc(courseId)
                                                        .collection('modules')
                                                        .doc(moduleId)
                                                        .collection('lessons')
                                                        .snapshots(),
                                                    builder: (context, lessonSnapshot) {
                                                      if (!lessonSnapshot.hasData) {
                                                        return CircleAvatar(
                                                          radius: 20,
                                                          backgroundColor: Colors.grey[300],
                                                          child: Text(
                                                            '0',
                                                            style: TextStyle(color: Colors.black),
                                                          ),
                                                        );
                                                      }
                                                      final lessons = lessonSnapshot.data!.docs;
                                                      return CircleAvatar(
                                                        radius: 20,
                                                        backgroundColor: Colors.green[100],
                                                        foregroundColor: Colors.green[800],
                                                        child: Text(
                                                          '${lessons.length}',
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.green[800],
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Text(
                                                      moduleName,
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.w600,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              StreamBuilder<QuerySnapshot>(
                                                stream: FirebaseFirestore.instance
                                                    .collection('courses')
                                                    .doc(courseId)
                                                    .collection('modules')
                                                    .doc(moduleId)
                                                    .collection('lessons')
                                                    .snapshots(),
                                                builder: (context, lessonCountSnapshot) {
                                                  if (!lessonCountSnapshot.hasData) {
                                                    return const SizedBox.shrink();
                                                  }
                                                  final lessonCount = lessonCountSnapshot.data!.docs.length;
                                                  return Padding(
                                                    padding: const EdgeInsets.only(top: 4.0),
                                                    child: Text(
                                                      '$lessonCount Recorded Videos',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                          trailing: Icon(
                                            expandedStates[moduleId]!
                                                ? Icons.arrow_drop_up
                                                : Icons.arrow_drop_down,
                                            color: Colors.greenAccent,
                                          ),
                                          onTap: () {
                                            setState(() {
                                              expandedStates[moduleId] = !expandedStates[moduleId]!;
                                            });
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 16.0),
                                        child: Visibility(
                                          visible: expandedStates[moduleId]!,
                                          child: StreamBuilder<QuerySnapshot>(
                                            stream: FirebaseFirestore.instance
                                                .collection('courses')
                                                .doc(courseId)
                                                .collection('modules')
                                                .doc(moduleId)
                                                .collection('lessons')
                                                .snapshots(),
                                            builder: (context, lessonSnapshot) {
                                              if (!lessonSnapshot.hasData) {
                                                return const SizedBox();
                                              }

                                              final lessons = lessonSnapshot.data!.docs;
                                              return Column(
  children: lessons.map((lessonDoc) {
    final lessonName = lessonDoc['name'] ?? 'Unnamed Lesson';
    final lessonUrl = lessonDoc['url'] ?? '';
    final lessonActivity = lessonDoc['activity'] ?? ''; // Check for activity URL

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerScreen(url: lessonUrl),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  lessonName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              Icon(Icons.play_circle_outline, color: Colors.greenAccent),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min, // Ensure buttons are in the same row without overflow
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  backgroundColor: const Color.fromARGB(255, 2, 72, 38),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoPlayerScreen(url: lessonUrl),
                    ),
                  );
                },
                child: const Text(
                  'Watch',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              if (lessonActivity.isNotEmpty) 
                Padding(
                  padding: const EdgeInsets.only(left: 8.0), // Adds spacing between buttons
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    onPressed: () async {
                          // Open the URL in the default browser
                          if (await canLaunch(lessonActivity)) {
                            await launch(lessonActivity);
                          } else {
                            throw 'Could not launch $lessonActivity';
                          }
                        },
                    child: const Text(
                      'Activity',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }).toList(),
);

                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ],
                      );
                    }
                    return const SizedBox();
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
