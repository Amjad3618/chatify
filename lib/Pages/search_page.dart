import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/chat_room_model.dart';
import '../models/use_Model.dart';
import 'chat_room_page.dart';

class SearchPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const SearchPage({super.key, required this.userModel, required this.firebaseUser});

  @override
 
  // ignore: library_private_types_in_public_api
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  TextEditingController searchController = TextEditingController();

  Future<ChatRoomModel?> getChatroomModel(UserModel targetUser) async {
  ChatRoomModel? chatRoom;
  var uuid = Uuid();  // Instantiate Uuid

  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection("chatrooms")
      .where("participants.${widget.userModel.uid}", isEqualTo: true)
      .where("participants.${targetUser.uid}", isEqualTo: true)
      .get();

  if (snapshot.docs.isNotEmpty) {
    // Fetch the existing one
    var docData = snapshot.docs[0].data();
    ChatRoomModel existingChatroom = ChatRoomModel.fromMap(docData as Map<String, dynamic>);
    chatRoom = existingChatroom;


    
  } else {
    // Create a new one
    ChatRoomModel newChatroom = ChatRoomModel(
      chatroomid: uuid.v4(),  // Generate a new UUID
      lastMessage: "",
      participants: {
        widget.userModel.uid.toString(): true,
        targetUser.uid.toString(): true,
      },
    );

    await FirebaseFirestore.instance.collection("chatrooms").doc(newChatroom.chatroomid).set(newChatroom.toMap());

    chatRoom = newChatroom;
    log("New Chatroom Created!");
  }

  return chatRoom;
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search"),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          child: Column(
            children: [

              TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  labelText: "Email Address"
                ),
              ),

              const SizedBox(height: 20,),

              CupertinoButton(
                onPressed: () {
                  setState(() {});
                },
                color: Theme.of(context).colorScheme.secondary,
                child: const Text("Search"),
              ),

              const SizedBox(height: 20,),

              StreamBuilder(
                stream: FirebaseFirestore.instance.collection("users").where("email", isEqualTo: searchController.text).where("email", isNotEqualTo: widget.userModel.email).snapshots(),
                builder: (context, snapshot) {
                  if(snapshot.connectionState == ConnectionState.active) {
                    if(snapshot.hasData) {
                      QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;

                      if(dataSnapshot.docs.length > 0) {
                        Map<String, dynamic> userMap = dataSnapshot.docs[0].data() as Map<String, dynamic>;

                        UserModel searchedUser = UserModel.fromMap(userMap);

                        return ListTile(
                          onTap: () async {
                            ChatRoomModel? chatroomModel = await getChatroomModel(searchedUser);

                            if(chatroomModel != null) {
                              // ignore: use_build_context_synchronously
                              Navigator.pop(context);
                              // ignore: use_build_context_synchronously
                              Navigator.push(context, MaterialPageRoute(
                                builder: (context) {
                                  return ChatRoomPage(
                                    targetUser: searchedUser,
                                    userModel: widget.userModel,
                                    firebaseUser: widget.firebaseUser,
                                    chatroom: chatroomModel,
                                  );
                                }
                              ));
                            }
                          },
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(searchedUser.profilepic!),
                            backgroundColor: Colors.grey[500],
                          ),
                          title: Text(searchedUser.fullname!),
                          subtitle: Text(searchedUser.email!),
                          trailing: const Icon(Icons.keyboard_arrow_right),
                        );
                      }
                      else {
                        return const Text("No results found!");
                      }
                      
                    }
                    else if(snapshot.hasError) {
                      return const Text("An error occured!");
                    }
                    else {
                      return const Text("No results found!");
                    }
                  }
                  else {
                    return const CircularProgressIndicator();
                  }
                }
              ),

            ],
          ),
        ),
      ),
    );
  }
}