import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminLiveClassesPage extends StatelessWidget {
  const AdminLiveClassesPage({Key? key}) : super(key: key);

  // Function to fetch all courses
  Stream<QuerySnapshot> _getCourses() {
    return FirebaseFirestore.instance.collection('courses').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Courses',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // StreamBuilder to display all courses in a GridView
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _getCourses(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final courses = snapshot.data!.docs;

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 600
                          ? 3
                          : 1, // Responsive layout
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.5,
                    ),
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      final course =
                          courses[index].data() as Map<String, dynamic>;
                      final courseId = courses[index].id;
                      final courseName = course['name'] ?? 'No Name';
                      final courseDescription =
                          course['description'] ?? 'No Description';

                      return Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () {
                            // Navigate to Live Classes page when course is tapped
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    LiveClassesPage(courseId: courseId),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  courseName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  courseDescription,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LiveClassesPage extends StatefulWidget {
  final String courseId;

  const LiveClassesPage({Key? key, required this.courseId}) : super(key: key);

  @override
  _LiveClassesPageState createState() => _LiveClassesPageState();
}

class _LiveClassesPageState extends State<LiveClassesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _zoomUrlController = TextEditingController();

  // Function to fetch live classes under the specific course
  Stream<QuerySnapshot> _getLiveClasses(String courseId) {
    return _firestore
        .collection('courses')
        .doc(courseId)
        .collection('live_classes')
        .snapshots();
  }

  // Function to add or update a live class
  Future<void> _saveLiveClass(String? liveClassId) async {
    final String name = _nameController.text;
    final String zoomUrl = _zoomUrlController.text;

    if (name.isEmpty || zoomUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    try {
      if (liveClassId == null) {
        // Add new live class
        await _firestore
            .collection('courses')
            .doc(widget.courseId)
            .collection('live_classes')
            .add({
          'name': name,
          'zoom_url': zoomUrl,
        });
      } else {
        // Update existing live class
        await _firestore
            .collection('courses')
            .doc(widget.courseId)
            .collection('live_classes')
            .doc(liveClassId)
            .update({
          'name': name,
          'zoom_url': zoomUrl,
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(liveClassId == null
                ? 'Live class added!'
                : 'Live class updated!')),
      );
      Navigator.pop(context); // Close dialog after saving
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save live class: $e')),
      );
    }
  }

  // Open dialog to edit live class
  void _openEditDialog(String? liveClassId, String? name, String? zoomUrl) {
    _nameController.text = name ?? '';
    _zoomUrlController.text = zoomUrl ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Live Class'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Live Class Name'),
              ),
              TextField(
                controller: _zoomUrlController,
                decoration: const InputDecoration(labelText: 'Zoom URL'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _saveLiveClass(
                    liveClassId); // Save the live class (either add or update)
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Function to delete live class
  Future<void> _deleteLiveClass(String liveClassId) async {
    try {
      await _firestore
          .collection('courses')
          .doc(widget.courseId)
          .collection('live_classes')
          .doc(liveClassId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Live class deleted!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete live class: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Classes for Course'),
        elevation: 0,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Live Classes',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () {
                    _openEditDialog(
                        null, '', ''); // Open dialog to add a new live class
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Add Live Class',style: TextStyle(color : Colors.white),),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // StreamBuilder to display live classes
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _getLiveClasses(widget.courseId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final liveClasses = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: liveClasses.length,
                    itemBuilder: (context, index) {
                      final liveClass =
                          liveClasses[index].data() as Map<String, dynamic>;
                      final liveClassId = liveClasses[index].id;
                      final liveClassName = liveClass['name'] ?? 'No Name';
                      final zoomUrl = liveClass['zoom_url'] ?? 'No Zoom URL';

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(liveClassName),
                          subtitle: Text('$zoomUrl'),
                          trailing: SizedBox(
                            width: 140,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: TextButton(
                                    onPressed: () {
                                      _openEditDialog(
                                          liveClassId, liveClassName, zoomUrl);
                                    },
                                    child: const Text(
                                      'Edit',
                                      style:
                                          TextStyle(color: Colors.blueAccent),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: TextButton(
                                    onPressed: () {
                                      _deleteLiveClass(liveClassId);
                                    },
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onTap: () {
                            // Handle on tap, if needed
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
