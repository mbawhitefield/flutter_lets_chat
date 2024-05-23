import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lets_chat/screens/chat/chat_screen.dart';
import 'package:flutter_lets_chat/screens/chat/widgets/image_picker.dart';
import 'package:flutter_lets_chat/screens/loginScreen/login_screen.dart';

final _auth = FirebaseAuth.instance;

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  static const routeName = '/signup_screen';

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  void _submit() async {
    
    try {
      final isValid = formKey.currentState!.validate();
      if (!isValid && profileImage == null) {}
      formKey.currentState!.save();
      setState(() {
        isLoading = true;
      });
      final userCredentials = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${userCredentials.user!.uid}.jpg');
          
      await storageRef.putFile(profileImage!);
      final imageUrl = await storageRef.getDownloadURL();

      Navigator.pushNamed(context, ChatScreen.routeName);
      emailController.clear();
      passwordController.clear();
      usernameController.clear();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredentials.user!.uid)
          .set({
        'username': username,
        'email': email,
        'image_url': imageUrl,
      });
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message ?? 'Authentication failed')));
    }
    setState(() {
      isLoading = false;
    });
  }

  GlobalKey<FormState> formKey = GlobalKey();
  bool isLoading = false;
  File? profileImage;
  var email = '';
  var password = '';
  var username = '';

  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              UserImagePicker(
                onpickedImage: (pickedImage) {
                  profileImage = pickedImage;
                },
              ),
              TextFormField(
                controller: emailController,
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty ||
                      !value.contains('@')) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
                onSaved: (value) {
                  email = value!;
                },
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(hintText: 'Email'),
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                onSaved: (value) {
                  username = value!;
                },
                controller: usernameController,
                decoration: const InputDecoration(hintText: 'Username'),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length < 4) {
                    return 'Username must be at least 4 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: passwordController,
                validator: (value) {
                  if (value == null || value.trim().length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
                onSaved: (value) {
                  password = value!;
                },
                obscureText: true,
                decoration: const InputDecoration(hintText: 'Password'),
              ),
              const SizedBox(
                height: 40,
              ),
              isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : ElevatedButton(
                      onPressed: _submit, child: const Text('Sign up')),
              isLoading
                  ? Container()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Already have an account?'),
                        TextButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                  context, LoginScreen.routeName);
                            },
                            child: const Text('Login'))
                      ],
                    )
            ],
          ),
        ),
      ),
    );
  }
}
