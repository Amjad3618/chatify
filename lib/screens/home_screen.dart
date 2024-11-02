// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';


// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   @override
//   Widget build(BuildContext context) {
//     final currentUser = FirebaseAuth.instance.currentUser;

//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: StreamBuilder<QuerySnapshot>(
//           stream: FirebaseFirestore.instance
//               .collection('chatRooms')
//               .where('users', arrayContains: currentUser!.uid)
//               .snapshots(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             }

//             if (snapshot.hasError) {
//               return Center(child: Text('Error: ${snapshot.error}'));
//             }

//             if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//               return const Center(child: Text('No chats found.'));
//             }

//             final chatRooms = snapshot.data!.docs;

//             return Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: ListView.builder(
//                 itemCount: chatRooms.length,
//                 itemBuilder: (context, index) {
//                   final chatRoom = chatRooms[index];
//                   final otherUserId =
//                       chatRoom['users'].firstWhere((id) => id != currentUser.uid);
//                   final lastMessage = chatRoom['lastMessage'] ?? 'No messages yet';
              
//                   return FutureBuilder<DocumentSnapshot>(
//                     future: FirebaseFirestore.instance
//                         .collection('users')
//                         .doc(otherUserId)
//                         .get(),
//                     builder: (context, userSnapshot) {
//                       if (!userSnapshot.hasData) {
//                         return const SizedBox.shrink();
//                       }
              
//                       final userData = userSnapshot.data!;
//                       final name = userData['name'] ?? 'No Name';
//                       final imageUrl = userData['imageUrl'] ?? '';
//                       final imageProvider = imageUrl.isNotEmpty
//                           ? NetworkImage(imageUrl)
//                           : const AssetImage('assets/images/default-image.png')
//                               as ImageProvider;
              
//                       return Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: Colors.orange,
//                             border: Border.all(color: Colors.green, width: 2),
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: ListTile(
//                             trailing: const Icon(Icons.arrow_forward_ios),
//                             leading: CircleAvatar(
//                               backgroundImage: imageProvider,
//                             ),
//                             title: Text(
//                               name,
//                               style: const TextStyle(
//                                   fontSize: 20,
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.w600),
//                             ),
//                             subtitle: Text(
//                               lastMessage,
//                               style: const TextStyle(
//                                   fontSize: 14,
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.w400),
//                             ),
//                             onTap: () {
                            
//                             },
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//             );
//           },
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: const Color.fromARGB(255, 2, 241, 54),
//         onPressed: () {
//         },
//         child: const Icon(Icons.add, color: Colors.white),
//       ),
//     );
//   }
// }
