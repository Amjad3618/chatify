import 'package:chatify/Pages/home_page.dart';
import 'package:chatify/Pages/login_page.dart';
import 'package:chatify/screens/calls_screen.dart';
import 'package:chatify/screens/statuse_scren.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/use_Model.dart';

class BottomNavBarScreen extends StatelessWidget {
  final UserModel userModel;
  final User firebaseUser;
  const BottomNavBarScreen({
    super.key,
    required this.userModel,
    required this.firebaseUser,
  });
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text(
              "Chatify",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.logout,
                  color: Colors.orange,
                ),
                onPressed: () {
                  // Add logout functionality here
                  FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (_) => LoginPage()));
                },
              ),
              IconButton(
                icon: const Icon(Icons.search),
                color: Colors.orange,
                onPressed: () {
                  // Add search functionality here
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.more_vert,
                  color: Colors.orange,
                ),
                onPressed: () {
                  // Add more options functionality here
                },
              ),
            ],
            bottom: const TabBar(
              indicatorColor: Colors.orange,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(
                  text: 'Chats',
                ),
                Tab(text: 'Status'),
                Tab(text: 'Calls'),
              ],
            ),
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: TabBarView(
            children: [
              HomePage(
                userModel: userModel,
                firebaseUser: firebaseUser,
              ),
              const StatuseScren(), // Fixed typo in class name
              const CallsScreen(),
            ],
          ),
        ),
      ),
    );
  }
}
