import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class UserLiveViewPage extends StatefulWidget {
  const UserLiveViewPage({Key? key}) : super(key: key);

  @override
  _UserLiveViewPageState createState() => _UserLiveViewPageState();
}

class _UserLiveViewPageState extends State<UserLiveViewPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Fetch the courses allocated to the user
  Stream<QuerySnapshot> _getUserCourses(String userId) {
    return _firestore.collection('users').doc(userId).collection('courses').snapshots();
  }

  // Fetch the course name by courseId
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
          elevation: 0,
          backgroundColor: Colors.blueAccent,
        ),
        body: const Center(
          child: Text('Please log in to see your courses', style: TextStyle(fontSize: 16)),
        ),
      );
    }

    String userId = user.uid;

    return Scaffold(
    
      body: StreamBuilder<QuerySnapshot>(
        stream: _getUserCourses(userId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final userCourses = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.3,
              ),
              itemCount: userCourses.length,
              itemBuilder: (context, index) {
                final userCourse = userCourses[index];
                final courseId = userCourse['courseId'];

                return FutureBuilder<String>(
                  future: _getCourseNameById(courseId),
                  builder: (context, courseSnapshot) {
                    if (courseSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (courseSnapshot.hasData) {
                      final courseName = courseSnapshot.data!;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: LiveScreenUser(courseId: courseId),
                                );
                              },
                            ),
                          );
                        },
                        child: Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                colors: [Colors.blueAccent, Colors.purpleAccent],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 12, spreadRadius: 4)
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(Icons.book_online, size: 50, color: Colors.white),
                                  const SizedBox(height: 12),
                                  Text(
                                    courseName,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: Colors.white,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    } else {
                      return const Center(child: Text('Error fetching course name'));
                    }
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

class LiveScreenUser extends StatelessWidget {
  final String courseId;

  const LiveScreenUser({required this.courseId, Key? key}) : super(key: key);

  // Fetch live classes for the specified course
  Stream<QuerySnapshot> _getLiveClasses(String courseId) {
    return FirebaseFirestore.instance
        .collection('courses')
        .doc(courseId)
        .collection('live_classes')
        .snapshots();
  }

  // Method to launch URL in the browser
  Future<void> _launchZoomURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Classes for Course'),
        elevation: 10,
        backgroundColor: Colors.blueAccent,
        shadowColor: Colors.blue.shade400,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getLiveClasses(courseId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final liveClasses = snapshot.data!.docs;

          return ListView.builder(
            itemCount: liveClasses.length,
            itemBuilder: (context, index) {
              final liveClass = liveClasses[index];
              final liveClassName = liveClass['name'] ?? 'Unnamed Live Class';
              final zoomUrl = liveClass['zoom_url'] ?? '';

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  color: Colors.white,
                  shadowColor: Colors.black.withOpacity(0.2),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                    title: Text(
                      liveClassName,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        if (zoomUrl.isNotEmpty) {
                          _launchZoomURL(zoomUrl); // Open URL in the default browser
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('No Zoom URL available')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0), backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      child: const Text('Join Live Class',style: TextStyle(color : Colors.white),),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
