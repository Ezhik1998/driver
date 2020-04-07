import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/arguments/passToEditArgs.dart';
import 'package:driver/constants/constants.dart';
import 'package:driver/icons/custom_icons_icons.dart';
import 'package:driver/pages/editPage.dart';
import 'package:firebase_storage/firebase_storage.dart';
// import 'package:driver/icons/driver_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:driver/services/firebaseAuthUtils.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Future<void> _getUserInfo(String id) async {
//   var snapshot =
//       await Firestore.instance.collection('users').document(id).get();
//   print(snapshot.data);
// }

class ProfilePage extends StatefulWidget {
  ProfilePage({Key key, this.auth, this.onSignedOut, this.userId})
      : super(key: key);

  final AuthFunc auth;
  final VoidCallback onSignedOut;
  final String userId;

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  // bool _isEmailVerified = false;
  String _name, _email;
  bool _isSwitchedDarkMode = false;
  bool _isSwitchedAutosave = true;
  File imageFile;
  var imageUrl;

  @override
  void initState() {
    super.initState();
    // _checkEmailVerification();
  }

  _uploadImage(ImageSource source) async {
    var image = await ImagePicker.pickImage(source: source);

    // //Create a reference to the location you want to upload to in firebase
    // StorageReference reference = FirebaseStorage.instance.ref().child("images/");

    // //Upload the file to firebase
    // StorageUploadTask uploadTask = reference.putFile(picture);

    // Uri location = (await uploadTask.future).downloadUrl;

    if (image != null) {
      setState(() {
        imageFile = image;
      });
      StorageReference storageReference =
          FirebaseStorage.instance.ref().child(widget.userId);
      StorageUploadTask uploadTask = storageReference.putFile(image);

      StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;

      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      Firestore.instance
          .collection("users")
          .document(widget.userId)
          .updateData(({"image": downloadUrl, "uid": widget.userId}));
    }

    // return downloadUrl;
    // print(downloadUrl);
  }

  _openGallery(BuildContext context) async {
    var picture = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (picture != null)
      this.setState(() {
        imageFile = picture;
      });
    // Navigator.of(context).pop();
  }

  _openCamera(BuildContext context) async {
    var picture = await ImagePicker.pickImage(source: ImageSource.camera);
    this.setState(() {
      imageFile = picture;
    });
    // Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // _getUserInfo(widget.userId);
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/road.jpg'),
                fit: BoxFit.fill,
              ),
            ),
            child: Column(children: <Widget>[
              Expanded(
                flex: 3,
                child: Container(
                  margin: EdgeInsets.only(top: 40),
                  color: Colors.transparent,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        // SizedBox(height: 10.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                color: Color(0xFFe6e6e6),
                                shape: BoxShape.circle,
                              ),
                              // alignment: Alignment.centerRight,
                              child: IconButton(
                                  icon: Icon(
                                    CustomIcons.edit,
                                    color: Color(0xFF666666),
                                    size: 20.0,
                                  ),
                                  onPressed: () => _navigate(context)
                                  // {
                                  //   Navigator.pushNamed(
                                  //       context, EditPage.routeName,
                                  //       arguments: PassToEditArgs(
                                  //           widget.auth, _name, _email));
                                  // }
                                  ),
                            ),
                            Container(
                              height: 115,
                              width: 115,
                              decoration: BoxDecoration(
                                // color: Color(0xFFe6e6e6),
                                color: Color(0xFF666666),
                                shape: BoxShape.circle,
                              ),
                              // alignment: Alignment.center,
                              child: StreamBuilder<DocumentSnapshot>(
                                  stream: Firestore.instance
                                      .collection("users")
                                      .document(widget.userId)
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      print(snapshot.data['image']);
                                      return GestureDetector(
                                        child: snapshot.data['image'] == ""
                                            ? IconButton(
                                                alignment: Alignment.center,
                                                icon: Icon(
                                                  CustomIcons.person,
                                                  color: Color(0xFFe6e6e6),
                                                  // color: Color(0xFF666666),
                                                  size: 64.0,
                                                ),
                                                onPressed: () {
                                                  _uploadImage(
                                                      ImageSource.gallery);
                                                  // _openGallery(context);
                                                })
                                            : CircleAvatar(
                                              backgroundColor: Color(0xFFe6e6e6),
                                                backgroundImage: NetworkImage(
                                                    snapshot.data['image']),
                                              ),
                                        onTap: () {
                                          _uploadImage(ImageSource.gallery);
                                          // _openGallery(context);
                                        },
                                      );
                                    } else {
                                      print("else");
                                      return Container(
                                        color: Colors.white,
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              new AlwaysStoppedAnimation<Color>(
                                                  Color(0xFF669999)),
                                        ),
                                      );
                                    }
                                  }),
                            ),
                            Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                color: Color(0xFFe6e6e6),
                                shape: BoxShape.circle,
                              ),
                              // alignment: Alignment.center,
                              child: IconButton(
                                  // Use the FaIcon Widget + FontAwesomeIcons class for the IconData
                                  icon: Icon(
                                    CustomIcons.camera,
                                    color: Color(0xFF666666),
                                    // size: 24.0,
                                  ),
                                  onPressed: () {
                                    print("Pressed");
                                    _uploadImage(ImageSource.camera);
                                  }),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.0),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  StreamBuilder<DocumentSnapshot>(
                                      stream: Firestore.instance
                                          .collection("users")
                                          .document(widget.userId)
                                          .snapshots(),
                                      builder: (context, snapshot) {
                                        // if (snapshot.connectionState ==
                                        //     ConnectionState.waiting) {
                                        //   // print("waiting");
                                        //   return new Center(
                                        //       // child:
                                        //       //     new CircularProgressIndicator()
                                        //           );
                                        // }
                                        if (snapshot.hasData) {
                                          // print("in has data");
                                          // return Text(snapshot.data.data["name"]);
                                          // // print(snapshot.data.data["name"]);
                                          // return Container();
                                          _name = snapshot.data["name"];
                                          _email = snapshot.data["email"];
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Center(
                                                // height: 100,
                                                child: Text(
                                                  snapshot.data["name"],
                                                  style: TextStyle(
                                                      color: Color(0xFF2a4848),
                                                      fontFamily: "Montserrat",
                                                      fontWeight:
                                                          FontWeight.w300,
                                                      fontSize: 17.0),
                                                ),
                                              ),
                                              Center(
                                                // height: 100,
                                                child: Text(
                                                  snapshot.data["email"],
                                                  style: TextStyle(
                                                      color: Color(0xFF2a4848),
                                                      fontFamily: "Montserrat",
                                                      fontWeight:
                                                          FontWeight.w300,
                                                      fontSize: 17.0),
                                                ),
                                              )
                                            ],
                                          );
                                        } else {
                                          // print("in error");
                                          return new Container(
                                            color: Colors.transparent,
                                          );
                                        }
                                      }),
                                ])
                          ],
                        )
                      ]),
                ),
              ),
              Expanded(
                flex: 5,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  color: Color(0xFF666666),
                  child: Container(
                    color: Colors.transparent,
                    margin: EdgeInsets.only(top: 20),
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(left: 25),
                              child: Text(
                                "Dark Mode",
                                style: TextStyle(
                                    // color: Color(0xFF336666),
                                    color: Colors.white,
                                    fontFamily: "Montserrat",
                                    fontWeight: FontWeight.w300,
                                    fontSize: 17.0),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(right: 20),
                              child: Switch(
                                value: _isSwitchedDarkMode,
                                onChanged: (value) {
                                  setState(() {
                                    _isSwitchedDarkMode = value;
                                    // print(_isSwitchedDarkMode);
                                  });
                                },
                                inactiveTrackColor: Color(0xFFcccccc),
                                inactiveThumbColor: Color(0xFF999999),
                                activeTrackColor: Color(0xFF669999),
                                activeColor: Color(0xFF336666),
                              ),
                            ),
                          ],
                        ),
                        // SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(left: 25),
                              child: Text(
                                "Autosave",
                                style: TextStyle(
                                    // color: Color(0xFF336666),
                                    color: Color(0xFFe6e6e6),
                                    fontFamily: "Montserrat",
                                    fontWeight: FontWeight.w300,
                                    fontSize: 17.0),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(right: 20),
                              child: Switch(
                                value: _isSwitchedAutosave,
                                onChanged: (value) {
                                  setState(() {
                                    _isSwitchedAutosave = value;
                                    // print(_isSwitchedDarkMode);
                                  });
                                },
                                inactiveTrackColor: Color(0xFFcccccc),
                                inactiveThumbColor: Color(0xFF999999),
                                activeTrackColor: Color(0xFF669999),
                                activeColor: Color(0xFF336666),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // child: Column(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: <Widget>[
                  //     Container(
                  //       height: 100,
                  //       width: MediaQuery.of(context).size.width,
                  //       color: Colors.blue,
                  //       alignment: Alignment.center,
                  //       child: Text(DateFormat("dd.MM.yyyy, HH:mm")
                  //           .format(DateTime.now())),
                  //     ),
                  //   ],
                  // ),
                ),
              )
            ]),
            //   child: Column(children: <Widget>[
            //     Container(
            //       color: Colors.white,
            //       margin: EdgeInsets.only(
            //           top: MediaQuery.of(context).size.height / 2.8),
            //     ),
            //     Positioned(
            //       top: 0.0,
            //       left: 0.0,
            //       right: 0.0,
            //       child: AppBar(
            //         backgroundColor: Colors.transparent,
            //         elevation: 0.0,
            //         actions: <Widget>[
            //           PopupMenuButton<String>(
            //             offset: Offset(0, 5),
            //             onSelected: _choiceAction,
            //             itemBuilder: (BuildContext context) {
            //               return Constants.choices.map((String choice) {
            //                 return PopupMenuItem<String>(
            //                   value: choice,
            //                   child: Text(choice),
            //                 );
            //               }).toList();
            //             },
            //           )
            //         ],
            //       ),
            //     )
            //   ]),
            //   // child: Column(
            //   //   // mainAxisAlignment: MainAxisAlignment.center,
            //   //   children: <Widget> [
            //   //     Row(
            //   //       mainAxisAlignment: MainAxisAlignment.spaceAround,
            //   //       children: <Widget>[
            //   //         Container(
            //   //           height: 10.0,
            //   //           decoration: BoxDecoration(
            //   //             color: Color(0xFF336666),
            //   //             shape: BoxShape.circle,
            //   //           ),
            //   //         ),
            //   //         Container(
            //   //           height: 20.0,
            //   //           decoration: BoxDecoration(
            //   //             color: Color(0xFF336666),
            //   //             shape: BoxShape.circle,
            //   //           ),
            //   //         ),
            //   //         Container(
            //   //           height: 10.0,
            //   //           decoration: BoxDecoration(
            //   //             color: Color(0xFF336666),
            //   //             shape: BoxShape.circle,
            //   //           ),
            //   //         ),
            //   //       ],
            //   //     ),
            //   //     Row(),
            //   //   ]
            //   // ),
            // ),
            // Container(
            //   color: Colors.white,
            //   margin:
            //       EdgeInsets.only(top: MediaQuery.of(context).size.height / 2.8),
            // ),
            // Positioned(
            //   top: 0.0,
            //   left: 0.0,
            //   right: 0.0,
            //   child: AppBar(
            //     backgroundColor: Colors.transparent,
            //     elevation: 0.0,
            //     actions: <Widget>[
            //       PopupMenuButton<String>(
            //         offset: Offset(0, 5),
            //         onSelected: _choiceAction,
            //         itemBuilder: (BuildContext context) {
            //           return Constants.choices.map((String choice) {
            //             return PopupMenuItem<String>(
            //               value: choice,
            //               child: Text(choice),
            //             );
            //           }).toList();
            //         },
            //       )
            //     ],
            //   ),
            // )
            // ],
            // ),
          ),
          Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              actions: <Widget>[
                PopupMenuButton<String>(
                  offset: Offset(0, 5),
                  onSelected: _choiceAction,
                  itemBuilder: (BuildContext context) {
                    return Constants.choices.map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(choice),
                      );
                    }).toList();
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
    // return Scaffold(
    //   body: Stack(
    //     children: <Widget>[
    //       Container(
    //         decoration: BoxDecoration(
    //           color: Colors.white,
    //           image: DecorationImage(
    //             image: AssetImage("images/road.jpg"),
    //             fit: BoxFit.fill,
    //           ),
    //         ),
    //         child: Column(
    //           crossAxisAlignment: CrossAxisAlignment.center,
    //           mainAxisAlignment: MainAxisAlignment.center,
    //           children: <Widget>[
    //             Center(
    //               child: Text(
    //                 "Hello " + widget.userEmail,
    //                 style: TextStyle(fontSize: 26.0, color: Colors.white),
    //               ),
    //             ),
    //             Center(
    //               child: Text(
    //                 "Your id: " + widget.userId,
    //                 style: TextStyle(fontSize: 18.0, color: Colors.white),
    //               ),
    //             )
    //           ],
    //         ),
    //       ),
    //       Positioned(
    //         width: MediaQuery.of(context).size.width,
    //         height: MediaQuery.of(context).size.height / 10,
    //         child: AppBar(
    //           title: Text(
    //             "Flutter Auth Email",
    //             style: TextStyle(color: Colors.white),
    //           ),
    //           backgroundColor: Colors.transparent,
    //           actions: <Widget>[
    //             PopupMenuButton<String>(
    //               offset: Offset(0, 5),
    //               onSelected: _choiceAction,
    //               itemBuilder: (BuildContext context) {
    //                 return Constants.choices.map((String choice) {
    //                   return PopupMenuItem<String>(
    //                       value: choice, child: Text(choice));
    //                 }).toList();
    //               },
    //             )
    //           ],
    //         ),
    //       )
    //     ],
    //   ),
    // );
  }

  void _navigate(BuildContext context) async {
    final data = await Navigator.pushNamed(context, EditPage.routeName,
        arguments: PassToEditArgs(widget.auth, widget.userId, _name, _email));
    if (data != null)
      Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(
            backgroundColor: Color(0xFF99CCCC),
            content: Text(
              "$data",
              style: TextStyle(
                  color: Color(0xFF2a4848),
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.w700,
                  fontSize: 16.0),
            ),
            duration: const Duration(seconds: 1)));
  }

  void _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut(); //callback
    } catch (e) {
      print(e);
    }
  }

  void _choiceAction(String choice) {
    if (choice == Constants.SIGN_OUT) _signOut();
  }
}
