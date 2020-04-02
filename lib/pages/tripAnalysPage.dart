import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/arguments/passToTripAnalysArgs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class TripAnalysPage extends StatefulWidget {
  static const routeName = '/trip-analys';
  @override
  _TripAnalysPageState createState() => _TripAnalysPageState();
}

class _TripAnalysPageState extends State<TripAnalysPage> {
  int _weaving, _swerving, _sideslipping, _fastUTurn;
  DateTime startTime, endTime;
  // bool _isStopped;
  Timer timerForWeaving,
      timerForSwerving,
      timerForSideslipping,
      timerForFastUTurn;

  @override
  void initState() {
    super.initState();
    _weaving = _swerving = _sideslipping = _fastUTurn = 0;
    startTime = DateTime.now();
    print(DateFormat("dd.MM.yyyy, HH:mm:ss").format(startTime));
    
    // _total = _weaving + _swerving + _sideslipping + _fastUTurn;
    // _isStopped = false;
    // print(_isStopped);
    // if (!_isStopped) {
    // timer = Timer.periodic(Duration(seconds: 5), (Timer t) => increaseValue());
    timerForWeaving = Timer.periodic(Duration(seconds: 3), (timer) {
      increaseWeaving();
    });
    timerForSwerving = Timer.periodic(Duration(seconds: 5), (timer) {
      increaseSwerving();
    });
    timerForSideslipping = Timer.periodic(Duration(seconds: 7), (timer) {
      increaseSideslipping();
    });
    timerForFastUTurn = Timer.periodic(Duration(seconds: 10), (timer) {
      increaseFastUTurn();
    });
    // }
  }

  @override
  void dispose() {
    super.dispose();
    timerForWeaving?.cancel();
    timerForSwerving?.cancel();
    timerForSideslipping?.cancel();
    timerForFastUTurn?.cancel();
  }

  void increaseWeaving() {
    setState(() {
      _weaving += 1;
    });
  }

  void increaseSwerving() {
    setState(() {
      _swerving += 1;
    });
  }

  void increaseSideslipping() {
    setState(() {
      _sideslipping += 1;
    });
  }

  void increaseFastUTurn() {
    setState(() {
      _fastUTurn += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final PassToTripAnalysArgs args = ModalRoute.of(context).settings.arguments;
    // print(args.userId);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Warning"),
                  content: Text("Do you want to quit without saving?"),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () {
                        timerForWeaving.cancel();
                        timerForSwerving.cancel();
                        timerForSideslipping.cancel();
                        timerForFastUTurn.cancel();
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        },
                      child: Text("Yes"),
                    ),
                    SizedBox(width: 10),
                    FlatButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text("No"),
                    ),
                  ],
                );
              }),
        ),
        title: Text(
          "Trip",
          style: TextStyle(
              color: Colors.white,
              fontFamily: "Montserrat",
              fontWeight: FontWeight.w700,
              fontSize: 20.0),
        ),
        backgroundColor: Color(0xFF717e81),
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
              margin: EdgeInsets.fromLTRB(16.0, 60.0, 16.0, 16.0),
              height: 50.0,
              child: Card(
                  elevation: 10.0,
                  color: Colors.white,
                  child: Container(
                    padding: EdgeInsets.only(left: 20.0, right: 20.0),
                    child: Row(
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
                          "$_weaving",
                          style: TextStyle(
                              color: Color(0xFF336666),
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.w300,
                              fontSize: 17.0),
                        ),
                      ],
                    ),
                  )),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 16.0),
              height: 50.0,
              child: Card(
                  elevation: 10.0,
                  color: Colors.white,
                  child: Container(
                    padding: EdgeInsets.only(left: 20.0, right: 20.0),
                    child: Row(
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
                          "$_swerving",
                          style: TextStyle(
                              color: Color(0xFF336666),
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.w300,
                              fontSize: 17.0),
                        ),
                      ],
                    ),
                  )),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 16.0),
              height: 50.0,
              child: Card(
                  elevation: 10.0,
                  color: Colors.white,
                  child: Container(
                    padding: EdgeInsets.only(left: 20.0, right: 20.0),
                    child: Row(
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
                          "$_sideslipping",
                          style: TextStyle(
                              color: Color(0xFF336666),
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.w300,
                              fontSize: 17.0),
                        ),
                      ],
                    ),
                  )),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 16.0),
              height: 50.0,
              child: Card(
                  elevation: 10.0,
                  color: Colors.white,
                  child: Container(
                    padding: EdgeInsets.only(left: 20.0, right: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Fast U-turn",
                          style: TextStyle(
                              color: Color(0xFF336666),
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.w300,
                              fontSize: 17.0),
                        ),
                        Text(
                          "$_fastUTurn",
                          style: TextStyle(
                              color: Color(0xFF336666),
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.w300,
                              fontSize: 17.0),
                        ),
                      ],
                    ),
                  )),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 16.0),
              height: 60.0,
              child: Card(
                  elevation: 10.0,
                  color: Colors.white,
                  child: Container(
                    padding: EdgeInsets.only(left: 20.0, right: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Total",
                          style: TextStyle(
                              color: Color(0xFF2a4848),
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.w700,
                              fontSize: 17.0),
                        ),
                        Text(
                          (_weaving + _swerving + _sideslipping + _fastUTurn)
                              .toString(),
                          style: TextStyle(
                              color: Color(0xFF2a4848),
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.w700,
                              fontSize: 17.0),
                        ),
                      ],
                    ),
                  )),
            ),
            Container(
              margin: EdgeInsets.only(top: 160, left: 16.0, right: 16.0),
              width: MediaQuery.of(context).size.width,
              child: SizedBox(
                height: 40.0,
                child: RaisedButton(
                  elevation: 5.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)),
                  color: Color(0xFF669999),
                  child: Text(
                    "STOP",
                    style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.white,
                        fontFamily: "Palatino",
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  onPressed: () {
                    print("Pressed");
                    timerForWeaving.cancel();
                    timerForSwerving.cancel();
                    timerForSideslipping.cancel();
                    timerForFastUTurn.cancel();
                    setState(() {
                      endTime = DateTime.now();
                    });
                    print(DateFormat("dd.MM.yyyy, HH:mm:ss").format(endTime));
                    Firestore.instance.collection("statistics").document().setData({"uid": args.userId,
                                    "weaving": _weaving,                                    
                                    "swerving": _swerving, 
                                    "sideslipping": _sideslipping,
                                    "fastUTurn": _fastUTurn, 
                                    "startTime" : startTime,
                                    "endTime": endTime});
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
