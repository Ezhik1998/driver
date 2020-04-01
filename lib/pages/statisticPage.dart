import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:driver/services/firebaseAuthUtils.dart';

class StatisticPage extends StatefulWidget {
  StatisticPage({Key key, this.auth, this.onSignedOut, this.userId})
      : super(key: key);

  final AuthFunc auth;
  final VoidCallback onSignedOut;
  final String userId;

  @override
  _StatisticPageState createState() => _StatisticPageState();
}

class _StatisticPageState extends State<StatisticPage> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  // bool _isEmailVerified = false;

  @override
  void initState() {
    super.initState();
    // _checkEmailVerification();
  }

  // Future<Map<String, dynamic>> _getUserInfo(String id) async {
  //   var snapshot =
  //       await Firestore.instance.collection('users').document(id).get();
  //   print(snapshot.data);
  //   return snapshot.data;
  // }

  // getUserData(AsyncSnapshot<DocumentSnapshot> snapshot) {
  //   // return snapshot.data.documents
  //   //     .map((doc) => ListTile(
  //   //         title: Text(doc["name"]), subtitle: Text(doc["email"].toString())))
  //   //     .toList();
  // }

  @override
  Widget build(BuildContext context) {
    // _getUserInfo(widget.userId);
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("Flutter Auth Email"),
      //   actions: <Widget>[
      //     // FlatButton(
      //     //   child: Text("Sign Out"),
      //     //   onPressed: _signOut,
      //     // )
      //     PopupMenuButton<String>(
      //       offset: Offset(0, 5),
      //       onSelected: _choiceAction,
      //       itemBuilder: (BuildContext context) {
      //         return Constants.choices.map((String choice) {
      //           return PopupMenuItem<String>(
      //               value: choice, child: Text(choice));
      //         }).toList();
      //       },
      //     )
      //   ],
      // ),
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              image: DecorationImage(
                image: AssetImage("images/road.jpg"),
                // colorFilter: ColorFilter.mode(
                //     Colors.black.withOpacity(0.8), BlendMode.dstOver),
                fit: BoxFit.fill,
              ),
            ),
            child: StreamBuilder<DocumentSnapshot>(
                stream: Firestore.instance
                    .collection("users")
                    .document(widget.userId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return new Center(child: new CircularProgressIndicator());
                  if (snapshot.hasData) {
                    // return Text(snapshot.data.data["name"]);
                    // // print(snapshot.data.data["name"]);
                    // return Container();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Center(
                          child: Text(
                            "Hello " + snapshot.data["name"],
                            style:
                                TextStyle(fontSize: 26.0, color: Colors.white),
                          ),
                        ),
                        Center(
                          child: Text(
                            "Your email: " + snapshot.data["email"],
                            style:
                                TextStyle(fontSize: 18.0, color: Colors.white),
                          ),
                        )
                      ],
                    );
                  } else {
                    return new Center(
                      child: new Text('Error', style: TextStyle(color: Colors.red),),
                    );
                  }
                }),
          ),
          Positioned(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 10,
            child: AppBar(
              title: Text(
                "Flutter Auth Email",
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.transparent,
              // elevation: 0,
              actions: <Widget>[
                // FlatButton(
                //   child: Text("Sign Out"),
                //   onPressed: _signOut,
                // )
                PopupMenuButton<String>(
                  offset: Offset(0, 5),
                  onSelected: _choiceAction,
                  itemBuilder: (BuildContext context) {
                    return Constants.choices.map((String choice) {
                      return PopupMenuItem<String>(
                          value: choice, child: Text(choice));
                    }).toList();
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  // void _checkEmailVerification() async {
  //   _isEmailVerified = await widget.auth.isEmailVerified();
  //   if (!_isEmailVerified) _showVerifyEmailDialog();
  // }

  // void _showVerifyEmailDialog() {
  //   showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: Text('Please verify your email'),
  //           content: Text('We need you verify email to continue use this app'),
  //           actions: <Widget>[
  //             FlatButton(
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //                 _sendVerifyEmail();
  //               },
  //               child: Text('Send me !'),
  //             ),
  //             FlatButton(
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //               },
  //               child: Text('Dismiss'),
  //             ),
  //           ],
  //         );
  //       });
  // }

  // void _sendVerifyEmail() {
  //   widget.auth.sendEmailVerification();
  //   _showVerifyEmailSentDialog();
  // }

  // void _showVerifyEmailSentDialog() {
  //   showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: Text('Thank you'),
  //           content: Text('Link verify has been sent to your email'),
  //           actions: <Widget>[
  //             FlatButton(
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //               },
  //               child: Text('OK'),
  //             ),
  //           ],
  //         );
  //       });
  // }

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
