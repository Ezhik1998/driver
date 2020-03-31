import 'package:driver/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:driver/services/firebaseAuthUtils.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.auth, this.onSignedOut}) : super(key: key);

  final AuthFunc auth;
  final VoidCallback onSignedOut;
  // final String userId;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool _isEmailVerified = false;

  @override
  void initState() {
    super.initState();
    _checkEmailVerification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("images/road.jpg"), fit: BoxFit.fill)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height / 10,
                  margin: EdgeInsets.only(top: 150, left: 20, right: 20),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20)),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Welcome on the board!",
                          style: TextStyle(
                              color: Color(0xFF336666),
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.w300,
                              fontSize: 17.0),
                        ),
                        Text(
                          "Test your driving behavior!",
                          style: TextStyle(
                              color: Color(0xFF336666),
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.w300,
                              fontSize: 17.0),
                        ),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/trip-analys');
                    },
                    child: Container(
                      height: 190.0,
                      margin: EdgeInsets.only(top: 150.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Color(0xFFe6e6e6)),
                      child: Container(
                        height: 175.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border:
                              Border.all(width: 1.0, color: Color(0xFF669999)),
                        ),
                        child: Center(
                            child: Text("START",
                                style: TextStyle(
                                    color: Color(0xFF336666),
                                    fontSize: 26,
                                    fontFamily: "Palatino",
                                    fontWeight: FontWeight.bold))),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // color: Colors.blue,
          ),
          Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            child: AppBar(
              leading: Container(
                  margin: EdgeInsets.only(left: 20),
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("images/app_logo_w.png")))),
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
          )
        ],
      ),
    );
    // return Scaffold(
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
    // return Stack(
    //   children: <Widget>[
    //     Container(
    //       height: double.infinity,
    //       width: double.infinity,
    //       decoration: BoxDecoration(
    //         color: Colors.white,
    //         image: DecorationImage(
    //           image: AssetImage("images/road.jpg"),
    //           // colorFilter: ColorFilter.mode(
    //           //     Colors.black.withOpacity(0.8), BlendMode.dstOver),
    //           fit: BoxFit.fill,
    //         ),
    //       ),
    //       child: Column(
    //         crossAxisAlignment: CrossAxisAlignment.center,
    //         mainAxisAlignment: MainAxisAlignment.start,
    //         children: <Widget>[
    //           Container(
    //               height: MediaQuery.of(context).size.height / 10,
    //               margin: EdgeInsets.only(top: 150, left: 20, right: 20),
    //               decoration: BoxDecoration(
    //                   color: Colors.white,
    //                   borderRadius: BorderRadius.circular(20)
    //                   // borderRadius: new BorderRadius.only(
    //                   //   topLeft: const Radius.circular(40.0),
    //                   //   topRight: const Radius.circular(40.0),
    //                   // )
    //                   ),
    //               child: Center(
    //                 child: Column(
    //                   mainAxisAlignment: MainAxisAlignment.center,
    //                   children: <Widget>[
    //                     Text(
    //                       "Welcome on the board!",
    //                       style: TextStyle(
    //                           color: Color(0xFF336666),
    //                           fontFamily: "Montserrat",
    //                           fontWeight: FontWeight.w300,
    //                           fontSize: 17.0),
    //                     ),
    //                     Text(
    //                       "Test your driving behavior!",
    //                       style: TextStyle(
    //                           color: Color(0xFF336666),
    //                           fontFamily: "Montserrat",
    //                           fontWeight: FontWeight.w300,
    //                           fontSize: 17.0),
    //                     ),
    //                   ],
    //                 ),
    //               )),
    //           Center(
    //             child: GestureDetector(
    //               onTap: () {
    //                 Navigator.pushNamed(context, '/trip-analys');
    //               },
    //               // child: Container(
    //               //   height: 200,
    //               //   margin: EdgeInsets.only(top: 150),
    //               //   decoration: BoxDecoration(
    //               //     color: Colors.white,
    //               //     shape: BoxShape.circle,
    //               //     // border:
    //               //     //     Border.all(width: 2.5, color: Color(0xFF9FAEB3)),
    //               //   ),
    //               //   child: Container(
    //               //     height: 10,
    //               //   // margin: EdgeInsets.only(top: 150),
    //               //   decoration: BoxDecoration(
    //               //     color: Colors.white,
    //               //     shape: BoxShape.circle,
    //               //     border:
    //               //         Border.all(width: 2.5, color: Color(0xFF9FAEB3)),
    //               //   ),
    //               //     child: Center(
    //               //         child: Text("START",
    //               //             style: TextStyle(
    //               //                 color: Color(0xFF336666),
    //               //                 fontSize: 26,
    //               //                 fontFamily: "Palatino",
    //               //                 fontWeight: FontWeight.bold))),
    //               //   ),
    //               // ),
    //               child: Container(
    //                 // width: 200.0,
    //                 height: 190.0,
    //                 margin: EdgeInsets.only(top: 150.0),
    //                 alignment: Alignment.center,
    //                 decoration: BoxDecoration(
    //                   shape: BoxShape.circle,
    //                   color: Color(0xFFe6e6e6),
    //                 ), // where to position the child
    //                 child: Container(
    //                   // width: 50.0,
    //                   height: 175.0,
    //                   decoration: BoxDecoration(
    //                     shape: BoxShape.circle,
    //                     color: Colors.white,
    //                     border:
    //                         Border.all(width: 1.0, color: Color(0xFF669999)),
    //                   ),
    //                   child: Center(
    //                       child: Text("START",
    //                           style: TextStyle(
    //                               color: Color(0xFF336666),
    //                               fontSize: 26,
    //                               fontFamily: "Palatino",
    //                               fontWeight: FontWeight.bold))),

    //                   // color: Colors.blue,
    //                 ),
    //               ),
    //             ),
    //           ),

    //           // Center(
    //           //   child: Text(
    //           //     "Hello " + widget.userEmail,
    //           //     style: TextStyle(fontSize: 26.0, color: Colors.white),
    //           //   ),
    //           // ),
    //           // Center(
    //           //   child: Text(
    //           //     "Your id: " + widget.userId,
    //           //     style: TextStyle(fontSize: 18.0, color: Colors.white),
    //           //   ),
    //           // )
    //         ],
    //       ),
    //     ),
    //     Scaffold(
    //       backgroundColor: Colors.transparent,
    //       appBar: AppBar(
    //         leading: Container(
    //             margin: EdgeInsets.only(left: 20),
    //             decoration: BoxDecoration(
    //                 image: DecorationImage(
    //                     image: AssetImage("images/app_logo_w.png")))),
    //       elevation: 0.0,
    //       ),
    //       body: Container(color: Colors.transparent),
    //     )
    //     // Positioned(
    //     //   width: MediaQuery.of(context).size.width,
    //     //   height: MediaQuery.of(context).size.height / 10,
    //     //   child: AppBar(
    //     //     leading: Container(
    //     //       margin: EdgeInsets.only(left: 20),
    //     //       decoration: BoxDecoration(
    //     //           image: DecorationImage(
    //     //               image: AssetImage("images/app_logo_w.png"))),
    //     //     ),
    //     //     // title: Container(
    //     //     //     child: Padding(
    //     //     //       padding: const EdgeInsets.only(top: 5, right: 20),
    //     //     //       child: Image(image: AssetImage("images/logo1.jfif")),
    //     //     //     ),
    //     //     //   ),
    //     //     // title: Text(
    //     //     //   "Flutter Auth Email",
    //     //     //   style: TextStyle(color: Colors.white),
    //     //     // ),
    //     //     backgroundColor: Colors.transparent,
    //     //     // elevation: 0,
    //     //     actions: <Widget>[
    //     //       // FlatButton(
    //     //       //   child: Text("Sign Out"),
    //     //       //   onPressed: _signOut,
    //     //       // )
    //     //       PopupMenuButton<String>(
    //     //         offset: Offset(0, 5),
    //     //         onSelected: _choiceAction,
    //     //         itemBuilder: (BuildContext context) {
    //     //           return Constants.choices.map((String choice) {
    //     //             return PopupMenuItem<String>(
    //     //                 value: choice, child: Text(choice));
    //     //           }).toList();
    //     //         },
    //     //       )
    //     //     ],
    //     //   ),
    //     // )
    //   ],
    //   // ),
    // );
  }

  void _checkEmailVerification() async {
    _isEmailVerified = await widget.auth.isEmailVerified();
    if (!_isEmailVerified) _showVerifyEmailDialog();
  }

  void _showVerifyEmailDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Please verify your email'),
            content: Text('We need you verify email to continue use this app'),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _sendVerifyEmail();
                },
                child: Text('Send me !'),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Dismiss'),
              ),
            ],
          );
        });
  }

  void _sendVerifyEmail() {
    widget.auth.sendEmailVerification();
    _showVerifyEmailSentDialog();
  }

  void _showVerifyEmailSentDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Thank you'),
            content: Text('Link verify has been sent to your email'),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        });
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
