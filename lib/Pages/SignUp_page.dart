import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Utils/email_verification.dart'; // Assuming this is the VerificationPage
import '../models/use_Model.dart';


class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _passwordVisible = false;
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _isLoading = false; // To manage loading state

  final _formKey = GlobalKey<FormState>(); // For form validation

  void checkValues() {
    String name = _nameCtrl.text.trim();
    String email = _emailCtrl.text.trim();
    String password = _passwordCtrl.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      // Show SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields.'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      signUp(name, email, password);
    }
  }

  void signUp(String name, String email, String password) async {
    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      String uid = credential.user!.uid;
      UserModel newUser = UserModel(
          uid: uid, email: email, fullname: name, profilepic: "");

      // Save the new user to Firestore
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .set(newUser.toMap());

      log("New User Created!");

      // Send email verification
      await credential.user!.sendEmailVerification();

      // Navigate to Email Verification Page
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
          builder: (context) => VerificationPage(
            firebaseUser: credential.user!,
            userModel: newUser,
          ),
        ),
      );
    } on FirebaseAuthException catch (ex) {
      log(ex.message.toString());
      String message = '';

      switch (ex.code) {
        case 'email-already-in-use':
          message = 'Email is already in use.';
          break;
        case 'invalid-email':
          message = 'Invalid email address.';
          break;
        case 'weak-password':
          message = 'Password is too weak.';
          break;
        default:
          message = 'An error occurred. Please try again.';
      }

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      log(e.toString());
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An unexpected error occurred.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
      _nameCtrl.clear();
      _emailCtrl.clear();
      _passwordCtrl.clear();
    }
  }

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Rest of the code remains similar, with minor adjustments.

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(15.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey, // For future validation
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 100),
                      Text(
                        "Register a new user with your email and password",
                        style: TextStyle(
                          color:
                              Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      nameForm(context),
                      const SizedBox(height: 20),
                      emailForm(context),
                      const SizedBox(height: 20),
                      passwordForm(context),
                      const SizedBox(height: 30),
                      Center(
                        child: signUpButton(),
                      ),
                      const SizedBox(height: 10),
                      navigationServices()
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Row navigationServices() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Already have an account?"),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            "Log In",
            style: TextStyle(color: Colors.orange),
          ),
        ),
      ],
    );
  }

  GestureDetector signUpButton() {
    return GestureDetector(
      onTap: () {
        checkValues();
      },
      child: Container(
        width: 180,
        height: 55,
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: Text(
            "Sign Up",
            style: TextStyle(
              color: Colors.black,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  TextFormField nameForm(BuildContext context) {
    return TextFormField(
      controller: _nameCtrl,
      decoration: InputDecoration(
        hintText: "Name",
        hintStyle: TextStyle(color: Theme.of(context).highlightColor),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        prefixIcon:
            Icon(Icons.person, color: Theme.of(context).highlightColor),
      ),
      style:
          TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
    );
  }

  TextFormField emailForm(BuildContext context) {
    return TextFormField(
      controller: _emailCtrl,
      decoration: InputDecoration(
        hintText: "Email",
        hintStyle: TextStyle(color: Theme.of(context).highlightColor),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        prefixIcon:
            Icon(Icons.email, color: Theme.of(context).highlightColor),
      ),
      style:
          TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
    );
  }

  TextFormField passwordForm(BuildContext context) {
    return TextFormField(
      controller: _passwordCtrl,
      decoration: InputDecoration(
        hintText: "Password",
        hintStyle: TextStyle(color: Theme.of(context).highlightColor),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        prefixIcon:
            Icon(Icons.lock, color: Theme.of(context).highlightColor),
        suffixIcon: IconButton(
          icon: Icon(
            _passwordVisible ? Icons.visibility : Icons.visibility_off,
            color: Theme.of(context).highlightColor,
          ),
          onPressed: () {
            setState(() {
              _passwordVisible = !_passwordVisible;
            });
          },
        ),
      ),
      style:
          TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
      obscureText: !_passwordVisible,
    );
  }
}
