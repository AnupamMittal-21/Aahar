import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food_donation_app/Models/Community/ChatRoom.model.dart';
import 'package:food_donation_app/Models/Community/Chatting.model.dart';
import 'package:food_donation_app/Models/User.model.dart';
import 'package:food_donation_app/Pages/Community/Functions/nameProfile.dart';
import 'package:food_donation_app/Pages/Community/Widgets/myBackButton.dart';
import 'package:food_donation_app/Provider/communityProvider.dart';
import 'package:food_donation_app/Provider/userProvider.dart';
import 'package:pinput/pinput.dart';

@RoutePage()
class ChatScreen extends ConsumerStatefulWidget {
  final UserModel TargetUser;
  final Chatroommodel ChatRoom;
  const ChatScreen(
      {required this.TargetUser, required this.ChatRoom, super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    String TargetUserImage = widget.TargetUser.photoURL.toString();
    String TargetUserName = widget.TargetUser.displayName.toString();
    TextEditingController msgcontroller = TextEditingController();
    String currentUser = ref.watch(authStateProvider).user!.uid;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leadingWidth: 100.w,
        centerTitle: true,
        leading: Container(
          // color: Colors.green,
          child: Center(
            child: MyBackButton(),
          ),
        ),
        title: Container(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                backgroundColor: Colors.black,
                radius: 16.r,
                child: Image.network(
                  TargetUserImage,
                  errorBuilder: (BuildContext context, Object exception,
                      StackTrace? stackTrace) {
                    return Center(
                      child: Text(
                        nameProfile(TargetUserName),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.sp,
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w400,
                          height: 0,
                          letterSpacing: 0.96.sp,
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                width: 10.w,
              ),
              Text(
                TargetUserName,
                style: TextStyle(
                  color: Color(0xFF201F24),
                  fontSize: 24.sp,
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w400,
                  height: 0,
                  letterSpacing: 0.96.sp,
                ),
              )
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("ChatRoom")
                  .doc(widget.ChatRoom.chatroomuid)
                  .collection("Messages")
                  .orderBy("sendOn", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                //
                //
                if (snapshot.connectionState == ConnectionState.active) {
                  QuerySnapshot querySnapshot = snapshot.data as QuerySnapshot;
                  // if (!snapshot.hasData) {
                  //   log("Loading Data");
                  //   return Text("data loading");
                  // }
                  if (snapshot.hasData) {
                    log(snapshot.data!.docs.length.toString());
                    //
                    //
                    return ListView.builder(
                      reverse: true,
                      itemCount: querySnapshot.docs.length,
                      itemBuilder: (context, index) {
                        log("message1");
                        Chattingmodel chattingModel = Chattingmodel.fromMap(
                            querySnapshot.docs[index].data()
                                as Map<String, dynamic>);
                        log(chattingModel.toString());
                        return Padding(
                          padding: EdgeInsets.all(8.0.sp),
                          child: Row(
                            mainAxisAlignment:
                                (chattingModel.sender == currentUser)
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                            children: [
                              Container(
                                  decoration: BoxDecoration(
                                      color: (chattingModel.sender == currentUser)
                                          ? Color(0xFF6A4DFF)
                                          : Color(0xFFF2F3F4),
                                      borderRadius: (chattingModel.sender == currentUser)
                                          ? BorderRadius.only(
                                              topLeft: BorderRadius.circular(20.r)
                                                  .topLeft,
                                              bottomLeft: BorderRadius.circular(20.r)
                                                  .bottomLeft,
                                              bottomRight:
                                                  BorderRadius.circular(20.r)
                                                      .bottomRight)
                                          : BorderRadius.only(
                                              topRight: BorderRadius.circular(20.r)
                                                  .topRight,
                                              bottomLeft: BorderRadius.circular(20.r)
                                                  .bottomLeft,
                                              bottomRight:
                                                  BorderRadius.circular(20.r)
                                                      .bottomRight)),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () {},
                                        child: Text(
                                            chattingModel.lastmessage
                                                .toString(),
                                            style: TextStyle(
                                              color: Colors.white,
                                            )),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(right: 6.w),
                                        child: Text(
                                          DateTime.parse(chattingModel.sendtime
                                                  .toString())
                                              .toLocal()
                                              .toString()
                                              .substring(11, 16),
                                          style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 181, 189, 194)),
                                        ),
                                      ),
                                      // Padding(
                                      //   padding: EdgeInsets.only(right: 6.w),
                                      //   child: Text(
                                      //     DateTime.parse(chattingModel.sendtime
                                      //             .toString())
                                      //         .toLocal()
                                      //         .toString()
                                      //         .substring(0, 10),
                                      //     style: TextStyle(
                                      //         color: Color.fromARGB(
                                      //             255, 181, 189, 194)),
                                      // ),
                                      // ),
                                    ],
                                  )),
                            ],
                          ),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                          "An error occured! Please check your internet connection."),
                    );
                  } else {
                    return Container();
                  }
                } else {
                  return Container();
                }
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 80.h,
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: msgcontroller,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                            hintText: "Type a message",
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.r),
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.r),
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (msgcontroller.text.trim().isNotEmpty) {
                            ref.watch(communityProvider.notifier).SendMessage(
                                  msgcontroller.text.trim(),
                                  widget.ChatRoom.chatroomuid,
                                );
                            msgcontroller.clear();
                          }
                        },
                        icon: Icon(
                          Icons.send,
                          color: Colors.blue,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
