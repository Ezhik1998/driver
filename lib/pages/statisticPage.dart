import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:driver/services/firebaseAuthUtils.dart';
import 'package:intl/intl.dart';
import 'dart:math';

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
  List<int> _isClicked;
  bool _viewMore;
  // bool _isEmailVerified = false;

  @override
  void initState() {
    super.initState();
    _isClicked = List();
    _viewMore = false;
    // _checkEmailVerification();
  }

  void _checkIsClicked(int index) {
    // if(_isClicked.isEmpty) {
    //   _isClicked.add(index);
    // }
    if (_isClicked.contains(index)) {
      // print("Now containes, will remove");
      _isClicked.remove(index);
      setState(() {
        // _clicked = null;
      });
    } else {
      // print("Now no, will add");
      _isClicked.add(index);
      setState(() {
        // _clicked = index;
      });
    }
    // print(_isClicked);
  }

  Color getColor(int value) {
    // int value = int.parse(value);
    value = value < 10 ? value * 10 : value;
    // print(value);
    if (value <= 40)
      return Color(0xFFFF0000);
    else if (value <= 60)
      return Color(0xFFFF6600);
    else if (value <= 80)
      return Color(0xFF33CC33);
    else
      return Color(0xFF336699);
  }

  _sortList(list) {
    list.sort((a, b) => Comparable.compare(b['startTime'], a['startTime']));
    // list.reversed.toList();
  }

  _getUserInfo(String id) async {
    var snapshot =
        await Firestore.instance.collection('statistics').getDocuments();

    var list = snapshot.documents.map((docs) => docs.data).toList();
    var filtList = list.where((doc) => doc['uid'] == id);
    // print(filtList.map((l) => l['startTime']));
    // print(filtList);
    return filtList;
    // return snapshot.data;
  }

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
      body: Stack(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: Colors.white,
              image: DecorationImage(
                image: AssetImage("images/road.jpg"),
                // colorFilter: ColorFilter.mode(
                //     Colors.black.withOpacity(0.8), BlendMode.dstOver),
                fit: BoxFit.fill,
              ),
            ),
            child: Container(
              margin: EdgeInsets.only(top: 80.0),
              child: StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance
                      .collection("statistics")
                      .getDocuments()
                      .asStream(),
                  builder: (context, snapshot) {
                    // print("data");
                    if (snapshot.hasData) {
                      var list = snapshot.data.documents
                          .map((docs) => docs.data)
                          .where((d) => d['uid'] == widget.userId)
                          .toList();
                      _sortList(list);
                      // print(list);
                      return list.length != 0
                          ? ListView.builder(
                              itemCount: list.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Stack(
                                  children: <Widget>[
                                    (_isClicked == null ||
                                            !_isClicked.contains(index))
                                        ? cardLess(index, list)
                                        : cardMore(index, list),
                                    Positioned(
                                      left: 40,
                                      child: Container(
                                        width: 100,
                                        height: 30,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                          color: Color(0xFF2a4848),
                                        ),
                                        child: Text(
                                          "TRIP",
                                          style: TextStyle(
                                              fontSize: 14.0,
                                              color: Colors.white,
                                              fontFamily: "Palatino",
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            )
                          : Center(
                              child: Container(
                                height: MediaQuery.of(context).size.height / 10,
                                margin: EdgeInsets.only(left: 20, right: 20),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20)),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        "You don't have any saved statistics",
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
                            );
                    } else {
                      return Center(
                          child: CircularProgressIndicator(
                        valueColor: new AlwaysStoppedAnimation<Color>(
                            Color(0xFF669999)),
                      ));
                    }
                  }),
            ),
            // child: StreamBuilder<DocumentSnapshot>(
            //     stream: Firestore.instance
            //         .collection("users")
            //         .document(widget.userId)
            //         .snapshots(),
            //     builder: (context, snapshot) {
            //       if (snapshot.connectionState == ConnectionState.waiting)
            //         return new Center(child: new CircularProgressIndicator());
            //       if (snapshot.hasData) {
            //         // return Text(snapshot.data.data["name"]);
            //         // // print(snapshot.data.data["name"]);
            //         // return Container();
            //         return Column(
            //           crossAxisAlignment: CrossAxisAlignment.center,
            //           mainAxisAlignment: MainAxisAlignment.center,
            //           children: <Widget>[
            //             Center(
            //               child: Text(
            //                 "Hello " + snapshot.data["name"],
            //                 style:
            //                     TextStyle(fontSize: 26.0, color: Colors.white),
            //               ),
            //             ),
            //             Center(
            //               child: Text(
            //                 "Your email: " + snapshot.data["email"],
            //                 style:
            //                     TextStyle(fontSize: 18.0, color: Colors.white),
            //               ),
            //             )
            //           ],
            //         );
            //       } else {
            //         return new Center(
            //           child: new Text('Error', style: TextStyle(color: Colors.red),),
            //         );
            //       }
            //     }),
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
          ),
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

  Widget cardLess(index, list) {
    return GestureDetector(
      onTap: () {
        _checkIsClicked(index);
      },
      child: Container(
        height: 80.0,
        margin: EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 16.0),
        child:
            // StreamBuilder<QuerySnapshot>(
            // stream: Firestore.instance
            //     .collection("statistics")
            //     .getDocuments()
            //     .asStream(),
            // builder: (context, snapshot) {
            //   if (snapshot.hasData) {
            //     var l = snapshot.data.documents
            //         .map((docs) => docs.data)
            //         .where((d) => d['uid'] == widget.userId)
            //         .toList();
            // print(l[0]['startTime']);
            // print(list.toString());
            Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 10.0,
          color: Colors.white,
          child: Container(
            padding: EdgeInsets.only(left: 20.0, top: 5.0, right: 0.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      DateFormat("dd.MM, HH:mm")
                          .format(list[index]['startTime'].toDate()),
                      style: TextStyle(
                          color: Color(0xFF336666),
                          fontFamily: "Montserrat",
                          fontWeight: FontWeight.w300,
                          fontSize: 14.0),
                    ),
                    Text(
                      DateFormat("dd.MM, HH:mm")
                          .format(list[index]['endTime'].toDate()),
                      style: TextStyle(
                          color: Color(0xFF336666),
                          fontFamily: "Montserrat",
                          fontWeight: FontWeight.w300,
                          fontSize: 14.0),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      list[index]['average'].toString(),
                      style: TextStyle(
                          color: getColor(list[index]['average']),
                          fontFamily: "Montserrat",
                          fontWeight: FontWeight.w700,
                          fontSize: 24.0),
                    ),
                    SizedBox(width: 5.0),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(height: 5.0),
                        Text(
                          "points",
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.w700,
                              fontSize: 12.0),
                        ),
                      ],
                    ),
                    IconButton(
                        icon:
                            (_isClicked == null || !_isClicked.contains(index))
                                ? Icon(
                                    Icons.arrow_back_ios,
                                    color: Colors.black,
                                    size: 14.0,
                                  )
                                : Transform.rotate(
                                    angle: 270 * pi / 180,
                                    child: Icon(
                                      Icons.arrow_back_ios,
                                      color: Colors.black,
                                      size: 14.0,
                                    ),
                                  ),
                        onPressed: () {
                          print("Pressed");
                          _checkIsClicked(index);
                          setState(() {
                            _viewMore = true;
                            // if (_isClicked == null || _isClicked != index) {
                            //   _isClicked = index;
                            // } else {
                            //   _isClicked = null;
                            // }
                          });
                        }),
                  ],
                ),
              ],
            ),
          ),
        ),
        // } else {
        //   // print("in error");
        //   return Center(child: Text("Waiting for data"));
        // }
        // }),
      ),
    );
    // (_isClicked == null || !_isClicked.contains(index)) ? cardLess(index) : cardMore(index)),
  }

  Widget cardMore(index, list) {
    return GestureDetector(
      onTap: () {
        _checkIsClicked(index);
      },
      child: Container(
        height: 235.0,
        margin: EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 16.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 10.0,
          color: Colors.white,
          child: Container(
            padding: EdgeInsets.only(left: 20.0, top: 5.0, right: 0.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          DateFormat("dd.MM, HH:mm")
                              .format(list[index]['startTime'].toDate()),
                          style: TextStyle(
                              color: Color(0xFF336666),
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.w300,
                              fontSize: 14.0),
                        ),
                        Text(
                          DateFormat("dd.MM, HH:mm")
                              .format(list[index]['endTime'].toDate()),
                          style: TextStyle(
                              color: Color(0xFF336666),
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.w300,
                              fontSize: 14.0),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          list[index]['average'].toString(),
                          style: TextStyle(
                              color: getColor(list[index]['average']),
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.w700,
                              fontSize: 24.0),
                        ),
                        SizedBox(width: 5.0),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(height: 5.0),
                            Text(
                              "points",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: "Montserrat",
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.0),
                            ),
                          ],
                        ),
                        IconButton(
                            icon: (_isClicked == null ||
                                    !_isClicked.contains(index))
                                ? Icon(
                                    Icons.arrow_back_ios,
                                    color: Colors.black,
                                    size: 14.0,
                                  )
                                : Transform.rotate(
                                    angle: 270 * pi / 180,
                                    child: Icon(
                                      Icons.arrow_back_ios,
                                      color: Colors.black,
                                      size: 14.0,
                                    ),
                                  ),
                            onPressed: () {
                              print("Pressed");
                              _checkIsClicked(index);
                              setState(() {
                                _viewMore = true;
                                // if (_isClicked == null || _isClicked != index) {
                                //   _isClicked = index;
                                // } else {
                                //   _isClicked = null;
                                // }
                              });
                            }),
                      ],
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(right: 15.0),
                  child: Divider(
                    height: 5.0,
                    color: Color(0xFF717e81),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(right: 15.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              "Weaving",
                              style: TextStyle(
                                  color: Color(0xFF336666),
                                  fontFamily: "Montserrat",
                                  fontWeight: FontWeight.w300,
                                  fontSize: 17.0),
                            ),
                            Text(
                              list[index]['weaving'].toString(),
                              style: TextStyle(
                                  color: getColor(list[index]['weaving']),
                                  fontFamily: "Montserrat",
                                  fontWeight: FontWeight.w300,
                                  fontSize: 17.0),
                            ),
                          ],
                        ),
                        SizedBox(height: 5.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              "Swerving",
                              style: TextStyle(
                                  color: Color(0xFF336666),
                                  fontFamily: "Montserrat",
                                  fontWeight: FontWeight.w300,
                                  fontSize: 17.0),
                            ),
                            Text(
                              list[index]['swerving'].toString(),
                              style: TextStyle(
                                  color: getColor(list[index]['swerving']),
                                  fontFamily: "Montserrat",
                                  fontWeight: FontWeight.w300,
                                  fontSize: 17.0),
                            ),
                          ],
                        ),
                        SizedBox(height: 5.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              "Sideslipping",
                              style: TextStyle(
                                  color: Color(0xFF336666),
                                  fontFamily: "Montserrat",
                                  fontWeight: FontWeight.w300,
                                  fontSize: 17.0),
                            ),
                            Text(
                              list[index]['sideslipping'].toString(),
                              style: TextStyle(
                                  color: getColor(list[index]['sideslipping']),
                                  fontFamily: "Montserrat",
                                  fontWeight: FontWeight.w300,
                                  fontSize: 17.0),
                            ),
                          ],
                        ),
                        SizedBox(height: 5.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              "Fast U-Turn",
                              style: TextStyle(
                                  color: Color(0xFF336666),
                                  fontFamily: "Montserrat",
                                  fontWeight: FontWeight.w300,
                                  fontSize: 17.0),
                            ),
                            Text(
                              list[index]['fastUTurn'].toString(),
                              style: TextStyle(
                                  color: getColor(list[index]['fastUTurn']),
                                  fontFamily: "Montserrat",
                                  fontWeight: FontWeight.w300,
                                  fontSize: 17.0),
                            ),
                          ],
                        ),
                      ]),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
