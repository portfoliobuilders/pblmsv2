import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:portfoliobuilderslms/admin/adcourseadmin.dart';
import 'package:portfoliobuilderslms/admin/assignment.dart';
import 'package:portfoliobuilderslms/admin/dashboard.dart';

class ModuleScreen extends StatefulWidget {
  final String courseId;

  const ModuleScreen({Key? key, required this.courseId, required Null Function() onBackPressed}) : super(key: key);

  @override
  _ModuleScreenState createState() => _ModuleScreenState();
}

class _ModuleScreenState extends State<ModuleScreen> {
  String? selectedModuleId;
    String? selectedCourseId;
  String? selectedModuleName;

  @override
void initState() {
  super.initState();
  selectedCourseId = widget.courseId; // Initialize selectedCourseId with the courseId passed from the parent
}
  List<Map<String, dynamic>> lessons = [];

  // Fetch modules
// Fetch modules sorted by order
Future<List<Map<String, dynamic>>> _fetchModules() async {
  final querySnapshot = await FirebaseFirestore.instance
      .collection('courses')
      .doc(widget.courseId)
      .collection('modules')
      .orderBy('order') // Order modules by the 'order' field
      .get();

  return querySnapshot.docs
      .map((doc) => {
            'id': doc.id,
            'name': doc['name'],
            'order': doc['order'],
          })
      .toList();
}


  // Fetch lessons for a module
  Future<void> _fetchLessons(String moduleId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.courseId)
        .collection('modules')
        .doc(moduleId)
        .collection('lessons')
        .get();

    setState(() {
      lessons = querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc['name'],
                'url': doc['url'],
              })
          .toList();
    });
  }

  // Add a lesson
  Future<void> _addLesson(String moduleId, String name, String url,String activity) async {
    final lessonData = {'name': name, 'url': url ,'activity' : activity};
    await FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.courseId)
        .collection('modules')
        .doc(moduleId)
        .collection('lessons')
        .add(lessonData);

    // Fetch the updated list of lessons after adding a new lesson
    _fetchLessons(moduleId);
  }

  // Add a module
// Add a module with an order field
Future<void> _addModule(String name) async {
  final querySnapshot = await FirebaseFirestore.instance
      .collection('courses')
      .doc(widget.courseId)
      .collection('modules')
      .orderBy('order', descending: true)
      .limit(1)
      .get();

  int newOrder = 1; // Default order if there are no modules
  if (querySnapshot.docs.isNotEmpty) {
    newOrder = querySnapshot.docs.first['order'] + 1; // Set new order to the last order + 1
  }

  final moduleData = {
    'name': name,
    'order': newOrder, // Set the order field
  };
  await FirebaseFirestore.instance
      .collection('courses')
      .doc(widget.courseId)
      .collection('modules')
      .add(moduleData);

  // Refresh the module list
  setState(() {});
}


  // Delete a course
Future<void> _deleteCourse() async {
  final shouldDelete = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Delete Course'),
        content: const Text('Are you sure you want to delete this course?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Cancel and close dialog
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(true); // Confirm deletion and close dialog
            },
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );

  if (shouldDelete == true) {
    // Delete the course from Firestore
    await FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.courseId)
        .delete();

    // Navigate to the DashboardScreen after deletion
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => DashboardScreen()),
    );
  }
}
// Delete a module
Future<void> _deleteModule(String moduleId) async {
  final shouldDelete = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Delete Module'),
        content: const Text('Are you sure you want to delete this module?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Cancel
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Confirm
            },
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );

  if (shouldDelete == true) {
    // Delete the module from Firestore
    await FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.courseId)
        .collection('modules')
        .doc(moduleId)
        .delete();

    // Refresh the module list
    setState(() {});
  }
}


  // Show dialog to add lesson
  void _showAddLessonDialog(BuildContext context, String moduleId) {
    final TextEditingController _nameController = TextEditingController();
    final TextEditingController _urlController = TextEditingController();
    final TextEditingController _activityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Lesson'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Lesson Name'),
              ),
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(labelText: 'Lesson URL'),
              ),
                TextField(
                controller: _activityController,
                decoration: const InputDecoration(labelText: 'Breakout Activity'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final String name = _nameController.text;
                final String url = _urlController.text;
                                final String activity = _activityController.text;


                if (name.isNotEmpty && url.isNotEmpty ) {
                  _addLesson(moduleId, name, url, activity);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter both name and URL')),
                  );
                }
              },
              child: const Text('Add Lesson'),
            ),
          ],
        );
      },
    );
  }

void _navigateToAssignmentPage(BuildContext context, String courseId, String moduleId) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AssignmentPage(
        courseId: courseId,  // Pass the courseId here
        moduleId: moduleId,  // Pass the moduleId here
      ),
    ),
  );
}


  // Show dialog to add module
  void _showAddModuleDialog(BuildContext context) {
    final TextEditingController _nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Module'),
          content: TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Module Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final String name = _nameController.text;
                if (name.isNotEmpty) {
                  _addModule(name);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a module name')),
                  );
                }
              },
              child: const Text('Add Module'),
            ),
          ],
        );
      },
    );
  }
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
  // Edit a module
Future<void> _editModule(String moduleId, String currentName) async {
    final TextEditingController nameController = TextEditingController(text: currentName);

    final String? newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Module'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Module Name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, nameController.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty && newName != currentName) {
      try {
        await FirebaseFirestore.instance
            .collection('courses')
            .doc(widget.courseId)
            .collection('modules')
            .doc(moduleId)
            .update({
              'name': newName,
              'updatedAt': FieldValue.serverTimestamp(),
            });

        _showSuccessSnackBar('Module updated successfully');
        setState(() {
          if (selectedModuleId == moduleId) {
            selectedModuleName = newName;
          }
        });
      } catch (e) {
        _showErrorSnackBar('Error updating module');
        debugPrint('Error updating module: $e');
      }
    }
  }

  // Edit a lesson
  void _editLesson(BuildContext context, String moduleId, String lessonId, String currentName, String currentUrl) {
    final TextEditingController _nameController = TextEditingController(text: currentName);
    final TextEditingController _urlController = TextEditingController(text: currentUrl);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Lesson'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Lesson Name'),
              ),
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(labelText: 'Lesson URL'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final String name = _nameController.text;
                final String url = _urlController.text;
                if (name.isNotEmpty && url.isNotEmpty) {
                  FirebaseFirestore.instance
                      .collection('courses')
                      .doc(widget.courseId)
                      .collection('modules')
                      .doc(moduleId)
                      .collection('lessons')
                      .doc(lessonId)
                      .update({'name': name, 'url': url});
                  setState(() {});
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter both name and URL')),
                  );
                }
              },
              child: const Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }

  // Delete a lesson
 // Delete a lesson
Future<void> _deleteLesson(String moduleId, String lessonId) async {
  final shouldDelete = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Delete Lesson'),
        content: const Text('Are you sure you want to delete this lesson?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Cancel
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Confirm
            },
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );

  if (shouldDelete == true) {
    // Delete the lesson from Firestore
    await FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.courseId)
        .collection('modules')
        .doc(moduleId)
        .collection('lessons')
        .doc(lessonId)
        .delete();
    
    // Refresh the list of lessons
    _fetchLessons(moduleId);
  }
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => DashboardScreen()),
          );
        },
      ),
      title: const Text('Admin Course'),
    ),
    body: SingleChildScrollView(  // Wrap the body with SingleChildScrollView to enable scrolling
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () => _showAddModuleDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                child: const Text('Add Module'),
              ),
              ElevatedButton(
                onPressed: _deleteCourse,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                child: const Text('Delete Course'),
              ),

              
            ],
          ),
          const SizedBox(height: 20),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _fetchModules(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No modules available'));
              }

              final modules = snapshot.data!;
              return DropdownButton<String>(
                value: selectedModuleId,
                hint: const Text('Select a Module'),
                isExpanded: true,
                items: modules.map((module) {
                  return DropdownMenuItem<String>(
                    value: module['id'],
                    child: Text(module['name'], style: TextStyle(fontSize: 16)
                    ),

                    
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedModuleId = value;
                    selectedModuleName = modules.firstWhere((module) => module['id'] == value)['name'];
                  });
                  if (value != null) {
                    _fetchLessons(value);
                  }
                  
                },
              );
            },
          ),
          const SizedBox(height: 20),
          if (selectedModuleId != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: () => _showAddLessonDialog(context, selectedModuleId!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text('Create Lesson'),
                ),
                const SizedBox(height: 20),
             ElevatedButton(
  onPressed: () => _navigateToAssignmentPage(context, widget.courseId, selectedModuleId!),
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.greenAccent,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  ),
  child: const Text('Create Assignment'),
),
     const SizedBox(height: 20),

                          TextButton(
  onPressed: () => _editModule(
    selectedModuleId!,
    selectedModuleName!,
  ),
  child: Row(
    children: const [
      Icon(Icons.edit, size: 18), // Add an icon for edit
      SizedBox(width: 4), // Spacing between icon and text
      Text("Edit Module"), // Add the label
    ],
  ),
),
TextButton(
  onPressed: () => _deleteModule(selectedModuleId!),
  style: TextButton.styleFrom(
    foregroundColor: Colors.red, // Set text and icon color to red
  ),
  child: Row(
    children: const [
      Icon(Icons.delete, size: 18), // Add an icon for delete
      SizedBox(width: 4), // Spacing between icon and text
      Text("Delete Module"), // Add the label
    ],
  ),
),

                          


                const SizedBox(height: 20),
                if (lessons.isNotEmpty)
                 ListView.builder(
  shrinkWrap: true,
  itemCount: lessons.length,
  itemBuilder: (context, index) {
    final lesson = lessons[index];
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 8,
      child: ListTile(
        title: Text(lesson['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        subtitle: Text(lesson['url'], style: const TextStyle(fontSize: 14)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => _editLesson(
                context,
                selectedModuleId!,
                lesson['id'],
                lesson['name'],
                lesson['url'],
              ),
              icon: const Icon(Icons.edit, color: Colors.blue),
            ),
            TextButton(
              onPressed: () => _deleteLesson(selectedModuleId!, lesson['id']),
              child: Row(
                children: const [
                  Icon(Icons.delete, color: Colors.red, size: 24),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),

           
          ],
        ),
      ),
    );
  },
),

                if (lessons.isEmpty)
                  const Text('No lessons available', style: TextStyle(fontSize: 16)),
              ],
            ),
        ],
      ),
    ),
  );
}

}

