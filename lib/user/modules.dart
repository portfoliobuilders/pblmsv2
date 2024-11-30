// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';



// class ModuleScreenuser extends StatelessWidget {
//   final String courseId;

//   const ModuleScreenuser({Key? key, required this.courseId}) : super(key: key);

//   Future<void> _addModule(String name) async {
//     final moduleData = {'name': name};
//     await FirebaseFirestore.instance
//         .collection('courses')
//         .doc(courseId)
//         .collection('modules')
//         .add(moduleData);
//   }

//   void _showAddModuleDialog(BuildContext context) {
//     final TextEditingController _nameController = TextEditingController();

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Add Module'),
//           content: TextField(
//             controller: _nameController,
//             decoration: const InputDecoration(labelText: 'Module Name'),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 final String name = _nameController.text;
//                 if (name.isNotEmpty) {
//                   _addModule(name);
//                   Navigator.of(context).pop();
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Please enter a module name')),
//                   );
//                 }
//               },
//               child: const Text('Add Module'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Modules'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Title and description
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Modules',
//                         style: Theme.of(context).textTheme.headlineSmall,
//                       ),
//                       Text(
//                         'Manage your course modules here.',
//                         style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
//                       ),
//                     ],
//                   ),
//                   ElevatedButton(
//                     onPressed: () => _showAddModuleDialog(context),
//                     child: const Text('Create Module'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blue,
//                       padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 20),
              
//               // Module list with StreamBuilder
//               StreamBuilder<QuerySnapshot>(
//                 stream: FirebaseFirestore.instance
//                     .collection('courses')
//                     .doc(courseId)
//                     .collection('modules')
//                     .snapshots(),
//                 builder: (context, snapshot) {
//                   if (!snapshot.hasData) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//                   final modules = snapshot.data!.docs;
//                   return ListView.builder(
//                     shrinkWrap: true,
//                     physics: NeverScrollableScrollPhysics(),
//                     itemCount: modules.length,
//                     itemBuilder: (context, index) {
//                       final module = modules[index].data() as Map<String, dynamic>;
//                       final moduleName = module['name'] ?? 'No Name';

//                       return GestureDetector(
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => LessonScreenuser(
//                                 courseId: courseId,
//                                 moduleId: modules[index].id,
//                               ),
//                             ),
//                           );
//                         },
//                         child: Container(
//                           margin: const EdgeInsets.symmetric(vertical: 8.0),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(10),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.grey.withOpacity(0.2),
//                                 blurRadius: 5,
//                                 spreadRadius: 2,
//                               ),
//                             ],
//                           ),
//                           child: ListTile(
//                             contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 16.0),
//                             title: Text(
//                               moduleName,
//                               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                             ),
//                             trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class LessonScreenuser extends StatelessWidget {
//   final String moduleId;
//   final String courseId;

//   const LessonScreenuser({Key? key, required this.moduleId, required this.courseId})
//       : super(key: key);

//   Future<void> _addLesson(String name, String url) async {
//     final lessonData = {'name': name, 'url': url};
//     await FirebaseFirestore.instance
//         .collection('courses')
//         .doc(courseId)
//         .collection('modules')
//         .doc(moduleId)
//         .collection('lessons')
//         .add(lessonData);
//   }

//   void _showAddLessonDialog(BuildContext context) {
//     final TextEditingController _nameController = TextEditingController();
//     final TextEditingController _urlController = TextEditingController();

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Add Lesson'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: _nameController,
//                 decoration: const InputDecoration(labelText: 'Lesson Name'),
//               ),
//               TextField(
//                 controller: _urlController,
//                 decoration: const InputDecoration(labelText: 'Lesson URL'),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 final String name = _nameController.text;
//                 final String url = _urlController.text;
//                 if (name.isNotEmpty && url.isNotEmpty) {
//                   _addLesson(name, url);
//                   Navigator.of(context).pop();
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Please enter both name and URL')),
//                   );
//                 }
//               },
//               child: const Text('Add Lesson'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Lessons'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header with title and description
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Lessons',
//                         style: Theme.of(context).textTheme.headlineSmall,
//                       ),
//                       Text(
//                         'Manage your module lessons here.',
//                         style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
//                       ),
//                     ],
//                   ),
//                   ElevatedButton(
//                     onPressed: () => _showAddLessonDialog(context),
//                     child: const Text('Create Lesson'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blue,
//                       padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 20),

//               // Lesson list with StreamBuilder
//               StreamBuilder<QuerySnapshot>(
//                 stream: FirebaseFirestore.instance
//                     .collection('courses')
//                     .doc(courseId)
//                     .collection('modules')
//                     .doc(moduleId)
//                     .collection('lessons')
//                     .snapshots(),
//                 builder: (context, snapshot) {
//                   if (!snapshot.hasData) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//                   final lessons = snapshot.data!.docs;
//                   return ListView.builder(
//                     shrinkWrap: true,
//                     physics: NeverScrollableScrollPhysics(),
//                     itemCount: lessons.length,
//                     itemBuilder: (context, index) {
//                       final lesson = lessons[index].data() as Map<String, dynamic>;
//                       final lessonName = lesson['name'] ?? 'No Name';
//                       final lessonUrl = lesson['url'] ?? 'No URL';

//                       return GestureDetector(
//                         onTap: () {
//                           // You can implement lesson tap functionality here
//                           // For example, open the URL in a browser
//                         },
//                         child: Container(
//                           margin: const EdgeInsets.symmetric(vertical: 8.0),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(10),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.grey.withOpacity(0.2),
//                                 blurRadius: 5,
//                                 spreadRadius: 2,
//                               ),
//                             ],
//                           ),
//                           child: ListTile(
//                             contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 16.0),
//                             title: Text(
//                               lessonName,
//                               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                             ),
//                             subtitle: Text(
//                               lessonUrl,
//                               style: const TextStyle(fontSize: 14, color: Colors.blue),
//                             ),
//                             trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
