// import 'package:flutter/material.dart';
// import 'package:gtech/login.dart';

// class Adminpanel extends StatelessWidget {
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                 Color.fromARGB(255, 2, 64, 95),
//                 Colors.black,
//                 Color.fromARGB(255, 2, 64, 95)
//               ],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//           child: Center(
//             child: LayoutBuilder(
//               builder: (context, constraints) {
//                 // Define breakpoints for responsive layout
//                 bool isLargeScreen = constraints.maxWidth > 800;
//                 double formWidth = isLargeScreen
//                     ? constraints.maxWidth * 0.4
//                     : constraints.maxWidth * 0.8;
//                 double imageWidth =
//                     isLargeScreen ? constraints.maxWidth * 0.2 : 0;

//                 return Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     // Left Section: Login Form
//                     Container(
//                       width: formWidth,
//                       padding: const EdgeInsets.all(24),
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Image.asset(
//                                 'assets/gtech.png',
//                                 height: 60,
//                                 width: 60,
//                               ),
//                               const SizedBox(width: 8),
//                               Image.asset(
//                                 'assets/gol.png',
//                                 height: 80,
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 12),
//                           const Text(
//                             'Welcome to GOL Admin Panel',
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 22,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           const Text(
//                             'Enter your details to login',
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 14,
//                             ),
//                           ),
//                           const SizedBox(height: 16),
//                           const Text(
//                             'Name',
//                             style: TextStyle(color: Colors.white, fontSize: 16),
//                           ),
//                           const SizedBox(height: 8),
//                           TextFormField(
//                             controller: _nameController,
//                             decoration: InputDecoration(
//                               filled: true,
//                               fillColor: Colors.white.withOpacity(0.9),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(8.0),
//                               ),
//                             ),
//                             style: const TextStyle(color: Colors.black),
//                           ),
//                           const SizedBox(height: 16),
//                           const Text(
//                             'Phone No',
//                             style: TextStyle(color: Colors.white, fontSize: 16),
//                           ),
//                           const SizedBox(height: 8),
//                           TextFormField(
//                             controller: _phoneController,
//                             decoration: InputDecoration(
//                               filled: true,
//                               fillColor: Colors.white.withOpacity(0.9),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(8.0),
//                               ),
//                             ),
//                             style: const TextStyle(color: Colors.black),
//                           ),
//                           SizedBox(
//                             height: 26,
//                           ),
//                           SizedBox(
//                             width: double.infinity,
//                             height: 50,
//                             child: ElevatedButton(
//                               onPressed: () {
//                                 // Implement the action for the Continue button
//                               },
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor:
//                                     const Color.fromARGB(255, 39, 220, 244),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(8.0),
//                                 ),
//                               ),
//                               child: const Text(
//                                 'Continue',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 16),
//                           TextButton(
//                             onPressed: () {
//                               // Navigation to SecondPage when button is pressed
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                     builder: (context) => LoginPage()),
//                               );
//                             },
//                             style: TextButton.styleFrom(
//                               foregroundColor: Colors.white,
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 16.0,
//                                   vertical: 8.0), // Text color
//                             ),
//                             child: const Text(
//                               'Not Admin? Login As User',
//                               style: TextStyle(fontSize: 16),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                     // Right Section: Image (Only shown on large screens)
//                   ],
//                 );
//               },
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
