import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:portfoliobuilderslms/login.dart';

class RegistrationPage extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _register(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        // Check if user already exists
        final signInMethods =
            await _auth.fetchSignInMethodsForEmail(_emailController.text);
        if (signInMethods.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Email is already in use. Please try a different one.')),
          );
          return;
        }

        // Register the user
        final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Save user data in Firestore, including the name field
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': _emailController.text,
          'name': _nameController.text, // Added name field
          'role': 'user', // Default role
        });

        // Navigate to the LoginPage after successful registration
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 5, 63, 23),
                  Colors.black,
                  Color.fromARGB(255, 5, 63, 23),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Top-left corner image
          Positioned(
            top: 16,
            left: 16,
            child: Image.asset(
              'assets/pblogo.png', // Replace with your image path
              width: 100, // Set image width
              height: 100, // Set image height
            ),
          ),
          // Main Form
          Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                bool isLargeScreen = constraints.maxWidth > 800;
                double formWidth = isLargeScreen ? constraints.maxWidth * 0.4 : constraints.maxWidth * 0.8;
                              double imageWidth = isLargeScreen ? constraints.maxWidth * 0.2 : 0;


                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: formWidth,
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          
                            const SizedBox(height: 12),
                            const Text(
                              'Create Your Account',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Enter your email and password to register',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white, fontSize: 14),
                            ),
                            const SizedBox(height: 16),

                            // Name Field
                            const Text('Full Name', style: TextStyle(color: Colors.white, fontSize: 16)),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _nameController, // Controller for Name
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.9),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                              ),
                              style: const TextStyle(color: Colors.black),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your full name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            const Text('Email', style: TextStyle(color: Colors.white, fontSize: 16)),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.9),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                              ),
                              style: const TextStyle(color: Colors.black),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter an email';
                                }
                                if (!RegExp(r'^[\w-]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            const Text('Password', style: TextStyle(color: Colors.white, fontSize: 16)),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.9),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                              ),
                              style: const TextStyle(color: Colors.black),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a password';
                                }
                                if (value.length < 6) {
                                  return 'Password should be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 26),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () => _register(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(255, 4, 58, 21),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                                ),
                                child: const Text(
                                  'Register',
                                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => LoginPage()),
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              ),
                              child: const Text(
                                'Already have an account? Login here',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                     if (isLargeScreen)
                    Container(
                      width: imageWidth,
                      padding: const EdgeInsets.all(16),
                      child: Image.asset(
                        'assets/quuote.png',
                        height: 600,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
