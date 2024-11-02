import 'package:chatify/Pages/SignUp_page.dart';
import 'package:chatify/navBar/bootom_nav_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/use_Model.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _passwordVisible = false;
  bool _isLoading = false;  // Added to manage loading state
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void checkValues() {
    String email = _emailCtrl.text.trim();
    String password = _passwordCtrl.text.trim();

    if (email.isEmpty || password.isEmpty) {
      print("Fill all the blanks");
    } else {
      logIn(email, password);
    }
  }

  void logIn(String email, String password) async {
    setState(() {
      _isLoading = true;  // Show loading indicator
    });

    UserCredential? credential;

    try {
      credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      print(ex.toString());
    }

    setState(() {
      _isLoading = false;  // Hide loading indicator
    });

    if (credential != null) {
      String uid = credential.user!.uid;

      DocumentSnapshot userData =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      UserModel userModel =
          UserModel.fromMap(userData.data() as Map<String, dynamic>);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) {
          return BottomNavBarScreen(
              userModel: userModel, firebaseUser: credential!.user!);
        }),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 100),
              Text(
                "Log in with your email and password",
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              emailForm(context),
              const SizedBox(height: 20),
              passwordForm(context),
              const SizedBox(height: 30),
              Center(
                child: GestureDetector(
                  onTap: checkValues,
                  child: loginButton(),
                ),
              ),
              const SizedBox(height: 10),
              navigationServices()
            ],
          ),
        ),
      ),
    );
  }

  Row navigationServices() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account?"),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SignUpPage()),
            );
          },
          child: const Text(
            "Sign Up",
            style: TextStyle(color: Colors.orange),
          ),
        ),
      ],
    );
  }

  Widget loginButton() {
    return Container(
      width: 150,
      height: 55,
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: _isLoading
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              )
            : const Text(
                "Log in",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
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
        prefixIcon: Icon(Icons.email, color: Theme.of(context).highlightColor),
      ),
      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
    );
  }

  TextFormField passwordForm(BuildContext context) {
    return TextFormField(
      controller: _passwordCtrl,
      obscureText: !_passwordVisible,
      decoration: InputDecoration(
        hintText: "Password",
        hintStyle: TextStyle(color: Theme.of(context).highlightColor),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(Icons.lock, color: Theme.of(context).highlightColor),
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
      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
    );
  }
}
