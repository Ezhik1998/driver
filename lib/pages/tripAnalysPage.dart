import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/arguments/passToTripAnalysArgs.dart';
import 'package:driver/constants/themeConstants.dart';
import 'package:driver/services/themeNotifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TripAnalysPage extends StatefulWidget {
  static const routeName = '/trip-analys';
  @override
  _TripAnalysPageState createState() => _TripAnalysPageState();
}

class _TripAnalysPageState extends State<TripAnalysPage> {
  // int _weaving, _swerving, _suddenBraking, _fastUTurn;
  DateTime startTime, endTime;
  bool _autoSave = false;
  // Timer timerForWeaving,
  //     timerForSwerving,
  //     timerForSideslipping,
  //     timerForFastUTurn;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        _autoSave = prefs.getBool('autoSave') ?? false;
      });
    });
    // _weaving = _swerving = _suddenBraking = _fastUTurn = 0;
    // startTime = DateTime.now();
    // timerForWeaving = Timer.periodic(Duration(seconds: 3), (timer) {
    //   increaseWeaving();
    // });
    // timerForSwerving = Timer.periodic(Duration(seconds: 5), (timer) {
    //   increaseSwerving();
    // });
    // timerForSideslipping = Timer.periodic(Duration(seconds: 7), (timer) {
    //   increaseSideslipping();
    // });
    // timerForFastUTurn = Timer.periodic(Duration(seconds: 10), (timer) {
    //   increaseFastUTurn();
    // });
  }

  @override
  void dispose() {
    super.dispose();
    // timerForWeaving?.cancel();
    // timerForSwerving?.cancel();
    // timerForSideslipping?.cancel();
    // timerForFastUTurn?.cancel();
  }

  // void increaseWeaving() {
  //   setState(() {
  //     _weaving += 1;
  //   });
  // }

  // void increaseSwerving() {
  //   setState(() {
  //     _swerving += 1;
  //   });
  // }

  // void increaseSideslipping() {
  //   setState(() {
  //     _suddenBraking += 1;
  //   });
  // }

  // void increaseFastUTurn() {
  //   setState(() {
  //     _fastUTurn += 1;
  //   });
  // }

  // int _convertValuesToPoints(int value) {
  //   if (value == 0)
  //     return 100;
  //   else if (value <= 2)
  //     return 90;
  //   else if (value <= 5)
  //     return 80;
  //   else if (value <= 7)
  //     return 70;
  //   else if (value <= 9)
  //     return 60;
  //   else if (value <= 11)
  //     return 50;
  //   else if (value <= 13)
  //     return 40;
  //   else if (value <= 15)
  //     return 30;
  //   else if (value <= 17)
  //     return 20;
  //   else if (value <= 19)
  //     return 10;
  //   else
  //     return 0;
  // }

  // int _getAverage() {
  //   return ((_convertValuesToPoints(_weaving) +
  //               _convertValuesToPoints(_swerving) +
  //               _convertValuesToPoints(_suddenBraking) +
  //               _convertValuesToPoints(_fastUTurn)) / 4)
  //       .round();
  // }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    var _darkTheme = (themeNotifier.getTheme() == darkTheme);
    var _width = MediaQuery.of(context).size.width;
    var _height = MediaQuery.of(context).size.height;
    final PassToTripAnalysArgs args = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              // if (!_autoSave) {
              //   Navigator.of(context).pop();
              // }
            }
            // onPressed: () => showDialog(
            //     context: context,
            //     builder: (BuildContext context) {
            //       return AlertDialog(
            //         title: Text("Warning"),
            //         content: Text("Do you want to quit without saving?"),
            //         actions: <Widget>[
            //           FlatButton(
            //             onPressed: () {
            //               timerForWeaving.cancel();
            //               timerForSwerving.cancel();
            //               timerForSideslipping.cancel();
            //               timerForFastUTurn.cancel();
            //               Navigator.of(context).pop();
            //               Navigator.of(context).pop();
            //             },
            //             child: Text("Yes"),
            //           ),
            //           SizedBox(width: 10),
            //           FlatButton(
            //             onPressed: () => Navigator.of(context).pop(),
            //             child: Text("No"),
            //           ),
            //         ],
            //       );
            //     }),
            ),
        title: Text(
          "Trip",
          style: TextStyle(
              fontFamily: "Montserrat",
              fontWeight: FontWeight.w700,
              fontSize: _height * 0.024),
        ),
        backgroundColor: Color(0xFFbdbfbe),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/road.jpg"),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.fromLTRB(
                  16.0, _height * 0.07, 16.0, _height * 0.019),
              height: _height * 0.06,
              child: Card(
                  elevation: 10.0,
                  color: _darkTheme ? Color(0xFF1d3a38) : Colors.white,
                  child: Container(
                    padding: EdgeInsets.only(left: 20.0, right: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Weaving",
                          style: TextStyle(
                              color:
                                  _darkTheme ? Colors.white : Color(0xFF1d3a38),
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.w300,
                              fontSize: _height * 0.022),
                        ),
                        Text(
                          args.weaving.toString(),
                          style: TextStyle(
                              color:
                                  _darkTheme ? Colors.white : Color(0xFF1d3a38),
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.w300,
                              fontSize: _height * 0.022),
                        ),
                      ],
                    ),
                  )),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(
                  16.0, _height * 0.024, 16.0, _height * 0.019),
              height: 50.0,
              child: Card(
                  elevation: 10.0,
                  color: _darkTheme ? Color(0xFF1d3a38) : Colors.white,
                  child: Container(
                    padding: EdgeInsets.only(left: 20.0, right: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Swerving",
                          style: TextStyle(
                              color:
                                  _darkTheme ? Colors.white : Color(0xFF1d3a38),
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.w300,
                              fontSize: _height * 0.022),
                        ),
                        Text(
                          args.swerving.toString(),
                          style: TextStyle(
                              color:
                                  _darkTheme ? Colors.white : Color(0xFF1d3a38),
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.w300,
                              fontSize: _height * 0.022),
                        ),
                      ],
                    ),
                  )),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(
                  16.0, _height * 0.024, 16.0, _height * 0.019),
              height: 50.0,
              child: Card(
                  elevation: 10.0,
                  color: _darkTheme ? Color(0xFF1d3a38) : Colors.white,
                  child: Container(
                    padding: EdgeInsets.only(left: 20.0, right: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Sudden Braking",
                          style: TextStyle(
                              color:
                                  _darkTheme ? Colors.white : Color(0xFF1d3a38),
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.w300,
                              fontSize: _height * 0.022),
                        ),
                        Text(
                          args.suddenBraking.toString(),
                          style: TextStyle(
                              color:
                                  _darkTheme ? Colors.white : Color(0xFF1d3a38),
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.w300,
                              fontSize: _height * 0.022),
                        ),
                      ],
                    ),
                  )),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(
                  16.0, _height * 0.024, 16.0, _height * 0.019),
              height: 50.0,
              child: Card(
                  elevation: 10.0,
                  color: _darkTheme ? Color(0xFF1d3a38) : Colors.white,
                  child: Container(
                    padding: EdgeInsets.only(left: 20.0, right: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Fast U-turn",
                          style: TextStyle(
                              color:
                                  _darkTheme ? Colors.white : Color(0xFF1d3a38),
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.w300,
                              fontSize: _height * 0.022),
                        ),
                        Text(
                          args.fastUTurn.toString(),
                          style: TextStyle(
                              color:
                                  _darkTheme ? Colors.white : Color(0xFF1d3a38),
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.w300,
                              fontSize: _height * 0.022),
                        ),
                      ],
                    ),
                  )),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(
                  16.0, _height * 0.024, 16.0, _height * 0.019),
              height: 60.0,
              child: Card(
                  elevation: 10.0,
                  color: _darkTheme ? Color(0xFF1d3a38) : Colors.white,
                  child: Container(
                    padding: EdgeInsets.only(left: 20.0, right: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Total",
                          style: TextStyle(
                              color:
                                  _darkTheme ? Colors.white : Color(0xFF1d3a38),
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.w700,
                              fontSize: _height * 0.022),
                        ),
                        Text(
                          (args.weaving +
                                  args.swerving +
                                  args.suddenBraking +
                                  args.fastUTurn)
                              .toString(),
                          style: TextStyle(
                              color:
                                  _darkTheme ? Colors.white : Color(0xFF1d3a38),
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.w700,
                              fontSize: _height * 0.022),
                        ),
                      ],
                    ),
                  )),
            ),
            // Container(
            //   margin: EdgeInsets.only(top: _height * 0.12, left: 16.0, right: 16.0),
            //   width: _width,
            //   child: SizedBox(
            //     height: 40.0,
            //     child: RaisedButton(
            //       elevation: 5.0,
            //       shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(30.0)),
            //       color: _darkTheme ? Color(0xFFbdbfbe) : Color(0xFF669999),
            //       child: Text(
            //         "STOP",
            //         style: TextStyle(
            //             fontSize: _height * 0.019,
            //             color: _darkTheme ? Color(0xFF2a4848) : Colors.white,
            //             fontFamily: "Palatino",
            //             fontWeight: FontWeight.bold),
            //         textAlign: TextAlign.center,
            //       ),
            //       onPressed: () {
            //         print("Pressed");
            //         timerForWeaving.cancel();
            //         timerForSwerving.cancel();
            //         timerForSideslipping.cancel();
            //         timerForFastUTurn.cancel();
            //         setState(() {
            //           endTime = DateTime.now();
            //         });
            //         Firestore.instance
            //             .collection("statistics")
            //             .document()
            //             .setData({
            //           "uid": args.userId,
            //           "weaving": _convertValuesToPoints(_weaving),
            //           "swerving": _convertValuesToPoints(_swerving),
            //           "sideslipping": _convertValuesToPoints(_suddenBraking),
            //           "fastUTurn": _convertValuesToPoints(_fastUTurn),
            //           "average": _getAverage(),
            //           "startTime": startTime,
            //           "endTime": endTime
            //         });
            //         Navigator.of(context).pop();
            //       },
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
