import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:core';
import 'dart:nativewrappers';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/arguments/passToSensorsArgs.dart';
import 'package:driver/arguments/passToTripAnalysArgs.dart';
import 'package:driver/constants/themeConstants.dart';
// import 'package:driver/models/db.dart';
import 'package:driver/pages/tripAnalysPage.dart';
import 'package:driver/services/calculate.dart';
import 'package:driver/services/themeNotifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oscilloscope/oscilloscope.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sensors/sensors.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:driver/models/behaviorModels.json' as file;

class SensorsPage extends StatefulWidget {
  static const routeName = '/sensors';
  @override
  _SensorsPageState createState() => _SensorsPageState();
}

class _SensorsPageState extends State<SensorsPage> {
  List<double> _accelerometerValues;
  List<double> _userAccelerometerValues;
  List<double> _gyroscopeValues;
  List<double> _accelerometerXValues = <double>[];
  List<double> _accelerometerYValues = <double>[];
  List<double> _gyroscopeXValues = <double>[];
  List<double> _gyroscopeYValues = <double>[];
  List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];
  List<Map<String, dynamic>> _data = <Map<String, dynamic>>[];
  Timer _timerToSave;
  int _secs = 0;
  int period = 500;
  int _weaving, _swerving, _suddenBraking, _fastUTurn, _suddenBehavior;
  DateTime startTime, endTime;
  bool _autoSave = false;

  int _convertValuesToPoints(int value) {
    if (value == 0)
      return 100;
    else if (value <= 2)
      return 90;
    else if (value <= 5)
      return 80;
    else if (value <= 7)
      return 70;
    else if (value <= 9)
      return 60;
    else if (value <= 11)
      return 50;
    else if (value <= 13)
      return 40;
    else if (value <= 15)
      return 30;
    else if (value <= 17)
      return 20;
    else if (value <= 19)
      return 10;
    else
      return 0;
  }

  int _getAverage() {
    return ((_convertValuesToPoints(_weaving) +
                _convertValuesToPoints(_swerving) +
                _convertValuesToPoints(_suddenBraking) +
                _convertValuesToPoints(_fastUTurn)) /
            4)
        .round();
  }

  void _saveDataToDB(args) {
    Firestore.instance.collection("statistics").document().setData({
      "uid": args.userId,
      "weaving": _convertValuesToPoints(_weaving),
      "swerving": _convertValuesToPoints(_swerving),
      "suddenBraking": _convertValuesToPoints(_suddenBraking),
      "fastUTurn": _convertValuesToPoints(_fastUTurn),
      "average": _getAverage(),
      "startTime": startTime,
      "endTime": endTime
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    var _darkTheme = (themeNotifier.getTheme() == darkTheme);
    final PassToSensorsArgs args = ModalRoute.of(context).settings.arguments;
    var _width = MediaQuery.of(context).size.width;
    var _height = MediaQuery.of(context).size.height;
    final List<String> accelerometer =
        _accelerometerValues?.map((double v) => v.toStringAsFixed(2))?.toList();
    final List<String> gyroscope =
        _gyroscopeValues?.map((double v) => v.toStringAsFixed(2))?.toList();
    final List<String> userAccelerometer = _userAccelerometerValues
        ?.map((double v) => v.toStringAsFixed(2))
        ?.toList();

    Oscilloscope oscilloscopeAccX = Oscilloscope(
      showYAxis: true,
      yAxisColor: Colors.grey,
      padding: 5.0,
      backgroundColor: Colors.black,
      traceColor: Colors.green,
      yAxisMax: 10.0,
      yAxisMin: -10.0,
      dataSet: _accelerometerXValues,
    );
    Oscilloscope oscilloscopeAccY = Oscilloscope(
      showYAxis: true,
      yAxisColor: Colors.grey,
      padding: 5.0,
      backgroundColor: Colors.transparent,
      traceColor: Colors.red,
      yAxisMax: 10.0,
      yAxisMin: -10.0,
      dataSet: _accelerometerYValues,
    );
    Oscilloscope oscilloscopeOriX = Oscilloscope(
      showYAxis: true,
      yAxisColor: Colors.grey,
      padding: 5.0,
      backgroundColor: Colors.black,
      traceColor: Colors.green,
      yAxisMax: 5.0,
      yAxisMin: -5.0,
      dataSet: _gyroscopeXValues,
    );
    Oscilloscope oscilloscopeOriY = Oscilloscope(
      showYAxis: true,
      yAxisColor: Colors.grey,
      padding: 5.0,
      backgroundColor: Colors.transparent,
      traceColor: Colors.red,
      yAxisMax: 5.0,
      yAxisMin: -5.0,
      dataSet: _gyroscopeYValues,
    );

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
                        _timerToSave?.cancel();
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
              fontFamily: "Montserrat",
              fontWeight: FontWeight.w700,
              fontSize: _height * 0.024),
        ),
        backgroundColor: Color(0xFFbdbfbe),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          // Padding(
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: <Widget>[
          //       Text('Accelerometer: $accelerometer'),
          //     ],
          //   ),
          //   padding: const EdgeInsets.all(16.0),
          // ),
          // Padding(
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: <Widget>[
          //       Text('UserAccelerometer: $userAccelerometer'),
          //     ],
          //   ),
          //   padding: const EdgeInsets.all(16.0),
          // ),
          // Padding(
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: <Widget>[
          //       Text('Gyroscope: $gyroscope'),
          //     ],
          //   ),
          //   padding: const EdgeInsets.all(16.0),
          // ),
          Row(
            children: <Widget>[
              Container(
                width: 300,
                child: Stack(children: <Widget>[
                  Container(
                    height: _height * 0.3,
                    padding:
                        EdgeInsets.fromLTRB(16.0, _height * 0.01, 16.0, 0.0),
                    // padding: EdgeInsets.all(16.0),
                    width: MediaQuery.of(context).size.width,
                    child: oscilloscopeAccX,
                  ),
                  Container(
                    height: _height * 0.3,
                    padding:
                        EdgeInsets.fromLTRB(16.0, _height * 0.01, 16.0, 0.0),
                    // padding: EdgeInsets.all(16.0),
                    width: MediaQuery.of(context).size.width,
                    child: oscilloscopeAccY,
                  ),
                ]),
              ),
              Container(
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(right: 10.0),
                          color: Colors.green,
                          height: 3.0,
                          width: 20.0,
                        ),
                        Text("X axis"),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(right: 10.0),
                          color: Colors.red,
                          height: 3.0,
                          width: 20.0,
                        ),
                        Text("Y axis"),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
          Container(
            margin: EdgeInsets.only(top: 0.0),
            child: Text("Accelerometer"),
          ),
          Row(
            children: <Widget>[
              Container(
                width: 300,
                child: Stack(children: <Widget>[
                  Container(
                    height: _height * 0.3,
                    padding:
                        EdgeInsets.fromLTRB(16.0, _height * 0.01, 16.0, 0.0),
                    // padding: EdgeInsets.all(16.0),
                    width: MediaQuery.of(context).size.width,
                    child: oscilloscopeOriX,
                  ),
                  Container(
                    height: _height * 0.3,
                    padding:
                        EdgeInsets.fromLTRB(16.0, _height * 0.01, 16.0, 0.0),
                    // padding: EdgeInsets.all(16.0),
                    width: MediaQuery.of(context).size.width,
                    child: oscilloscopeOriY,
                  ),
                ]),
              ),
              Container(
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(right: 10.0),
                          color: Colors.green,
                          height: 3.0,
                          width: 20.0,
                        ),
                        Text("X axis"),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(right: 10.0),
                          color: Colors.red,
                          height: 3.0,
                          width: 20.0,
                        ),
                        Text("Y axis"),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
          Container(
            margin: EdgeInsets.only(top: 0.0),
            child: Text("Gyroscope"),
          ),
          // Stack(children: <Widget>[
          //   Container(
          //     height: 250,
          //     padding: EdgeInsets.fromLTRB(16.0, _height * 0.01, 16.0, 0.0),
          //     width: MediaQuery.of(context).size.width,
          //     child: oscilloscopeOriX,
          //   ),
          //   Container(
          //     height: 250,
          //     padding: EdgeInsets.fromLTRB(16.0, _height * 0.01, 16.0, 0.0),
          //     width: MediaQuery.of(context).size.width,
          //     child: oscilloscopeOriY,
          //   ),
          // ]),
          // Container(
          //   child: Text("Gyroscope"),
          // ),
          Container(
            margin: EdgeInsets.only(left: 16.0, right: 16.0),
            width: _width,
            child: SizedBox(
              height: 40.0,
              child: RaisedButton(
                elevation: 5.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0)),
                color: _darkTheme ? Color(0xFFbdbfbe) : Color(0xFF669999),
                child: Text(
                  "STOP",
                  style: TextStyle(
                      fontSize: _height * 0.019,
                      color: _darkTheme ? Color(0xFF2a4848) : Colors.white,
                      fontFamily: "Palatino",
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                onPressed: () {
                  print("Pressed");
                  print("Autosave: $_autoSave");
                  _timerToSave?.cancel();
                  setState(() {
                    endTime = DateTime.now();
                  });
                  // writeDataToJSON(_data, args, startTime, endTime);
                  // _analysData();
                  _analysDataFromDB();
                  if (_autoSave) {
                    _saveDataToDB(args);
                    showProfile(context, args);
                    // Navigator.pushNamed(context, TripAnalysPage.routeName,
                    //     arguments: PassToTripAnalysArgs(args.auth, args.userId,
                    //         _weaving, _swerving, _fastUTurn, _suddenBraking));
                  } else {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Warning"),
                            content: Text("Do you want to save trip?"),
                            actions: <Widget>[
                              FlatButton(
                                onPressed: () {
                                  _timerToSave?.cancel();
                                  _saveDataToDB(args);
                                  Navigator.of(context).pop();
                                  showProfile(context, args);
                                  // Navigator.pushNamed(
                                  //     context, TripAnalysPage.routeName,
                                  //     arguments: PassToTripAnalysArgs(
                                  //         args.auth,
                                  //         args.userId,
                                  //         _weaving,
                                  //         _swerving,
                                  //         _fastUTurn,
                                  //         _suddenBraking));
                                },
                                child: Text("Yes"),
                              ),
                              SizedBox(width: 10),
                              FlatButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  showProfile(context, args);
                                  // Navigator.of(context).pop();
                                  // Navigator.pushNamed(
                                  //     context, TripAnalysPage.routeName,
                                  //     arguments: PassToTripAnalysArgs(
                                  //         args.auth,
                                  //         args.userId,
                                  //         _weaving,
                                  //         _swerving,
                                  //         _fastUTurn,
                                  //         _suddenBraking));
                                },
                                child: Text("No"),
                              ),
                            ],
                          );
                        });
                  }
                },
              ),
            ),
          ),
          // Container(
          //   margin:
          //       EdgeInsets.only(top: _height * 0.12, left: 16.0, right: 16.0),
          //   width: _width,
          //   child: SizedBox(
          //     height: 40.0,
          //     child: RaisedButton(
          //       elevation: 5.0,
          //       shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(30.0)),
          //       color: Color(0xFFbdbfbe),
          //       child: Text(
          //         "STOP",
          //         style: TextStyle(
          //             fontSize: _height * 0.019,
          //             color: Color(0xFF2a4848),
          //             fontFamily: "Palatino",
          //             fontWeight: FontWeight.bold),
          //         textAlign: TextAlign.center,
          //       ),
          //       onPressed: () {
          //         print("Pressed");
          //         _timerToSave.cancel();
          //         // _analysData();
          //       },
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    _timerToSave?.cancel();
    _accelerometerXValues = List();
    _accelerometerYValues = List();
    _gyroscopeXValues = List();
    _gyroscopeYValues = List();
  }

  double roundDouble(double value, int places) {
    double mod = pow(10.0, places);
    return ((value * mod).round().toDouble() / mod);
  }

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        _autoSave = prefs.getBool('autoSave') ?? false;
      });
    });
    _weaving = _swerving = _suddenBraking = _fastUTurn = _suddenBehavior = 0;
    startTime = DateTime.now();
    _accelerometerXValues = List();
    _accelerometerYValues = List();
    _gyroscopeXValues = List();
    _gyroscopeYValues = List();
    _streamSubscriptions
        .add(accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _accelerometerValues = <double>[event.x, event.y, event.z];
        _accelerometerXValues.add(roundDouble(event.x, 2));
        _accelerometerYValues.add(roundDouble(event.y, 2));
        // print(_accelerometerXValues);
        // _accelerometerYValues.add(event.y);
      });
    }));
    _streamSubscriptions.add(gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        _gyroscopeValues = <double>[event.x, event.y, event.z];
        _gyroscopeXValues.add(roundDouble(event.x, 2));
        _gyroscopeYValues.add(roundDouble(event.y, 2));
      });
    }));
    _streamSubscriptions
        .add(userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      setState(() {
        _userAccelerometerValues = <double>[event.x, event.y, event.z];
      });
    }));
    _timerToSave = Timer.periodic(Duration(milliseconds: period), (timer) {
      _secs += period;
      // print({
      //   "acc.x": _accelerometerValues[0],
      //   "acc.y": _accelerometerValues[1],
      //   "ori.x": _gyroscopeValues[0],
      //   "ori.y": _gyroscopeValues[1],
      //   "time": (_secs / 1000)
      // });
      // _data.add({
      //   "acc.x": _accelerometerValues[0],
      //   "acc.y": _accelerometerValues[1],
      //   "ori.x": _gyroscopeValues[0],
      //   "ori.y": _gyroscopeValues[1],
      //   "time": (_secs / 1000)
      // });
    });

    // print(_data);
    // _data = [
    //   {"acc.x": -0.1, "acc.y": 1.2, "ori.x": -10.0, "ori.y": -0.3, "time": 0},
    //   {"acc.x": -0.2, "acc.y": 1.1, "ori.x": -9.8, "ori.y": -0.5, "time": 0.5},
    //   {"acc.x": -0.1, "acc.y": 1.2, "ori.x": -9.9, "ori.y": -0.4, "time": 1},
    //   {"acc.x": -0.3, "acc.y": 1.1, "ori.x": -10.1, "ori.y": -0.3, "time": 1.5},
    //   {"acc.x": 2.5, "acc.y": 1.0, "ori.x": -10.2, "ori.y": -0.2, "time": 2},
    //   {"acc.x": 1.9, "acc.y": 1.9, "ori.x": -7.5, "ori.y": -0.3, "time": 2.5},
    //   {"acc.x": -9.7, "acc.y": -0.1, "ori.x": 2.3, "ori.y": 0.1, "time": 3},
    //   {"acc.x": 1.4, "acc.y": 1.4, "ori.x": -11.5, "ori.y": -0.1, "time": 3.5},
    //   {"acc.x": -1.9, "acc.y": 0.9, "ori.x": -9.0, "ori.y": -0.1, "time": 4},
    //   {"acc.x": -1.5, "acc.y": 0.0, "ori.x": -9.8, "ori.y": 0.0, "time": 4.5},
    //   {"acc.x": -1.1, "acc.y": 0.0, "ori.x": -9.8, "ori.y": 0.0, "time": 5},
    //   {"acc.x": -0.4, "acc.y": 0.0, "ori.x": -9.8, "ori.y": 0.0, "time": 5.5},
    //   {"acc.x": -0.1, "acc.y": 0.0, "ori.x": -9.8, "ori.y": 0.0, "time": 6},
    //   {"acc.x": -0.1, "acc.y": 0.0, "ori.x": -9.9, "ori.y": 0.0, "time": 6.5},
    //   {"acc.x": -0.1, "acc.y": 0.0, "ori.x": -9.8, "ori.y": 0.0, "time": 7},
    //   {"acc.x": -0.2, "acc.y": 0.1, "ori.x": -9.8, "ori.y": 0.0, "time": 7.5},
    //   {"acc.x": -0.1, "acc.y": 0.0, "ori.x": -9.9, "ori.y": 0.0, "time": 8},
    //   {"acc.x": -2.0, "acc.y": 2.1, "ori.x": -6.0, "ori.y": -1.5, "time": 8.5},
    //   {"acc.x": -1.6, "acc.y": -0.8, "ori.x": -8.9, "ori.y": 0.0, "time": 9},
    //   {"acc.x": -0.5, "acc.y": -5.0, "ori.x": -13.0, "ori.y": 2.7, "time": 9.5},
    //   {"acc.x": -0.2, "acc.y": -4.0, "ori.x": -12.2, "ori.y": 1.4, "time": 10},
    //   {
    //     "acc.x": -0.1,
    //     "acc.y": -4.2,
    //     "ori.x": -12.4,
    //     "ori.y": 1.7,
    //     "time": 10.5
    //   },
    //   {"acc.x": 0.0, "acc.y": -4.0, "ori.x": -12.1, "ori.y": 1.6, "time": 11},
    //   {"acc.x": 0.1, "acc.y": -4.9, "ori.x": -13.5, "ori.y": 1.7, "time": 11.5},
    //   {"acc.x": 0.0, "acc.y": 0.0, "ori.x": -9.8, "ori.y": 0.0, "time": 12},
    //   {"acc.x": -0.1, "acc.y": 0.1, "ori.x": -9.8, "ori.y": 0.0, "time": 12.5},
    //   {"acc.x": -0.1, "acc.y": 0.0, "ori.x": -9.9, "ori.y": 0.0, "time": 13},
    // ];
  }

  double mean(a, b) {
    return (a + b) / 2;
  }

  double st_deviation(a, b, mean) {
    return sqrt(pow((a - mean), 2) + pow((b - mean), 2));
  }

  Future<void> _analysData() async {
    print("Analys data");
    List<dynamic> _abnormalClassifications = [];
    List<Map<String, dynamic>> _smoothedData = <Map<String, dynamic>>[];
    var dataOfUknown = {};
    String classification = "";

    _smoothedData = smoothingSMAUnknown(_data);
    // dataOfUknown = calculateUnknown(_smoothedData);
    // print(_data);
    // final Directory directory = await getApplicationDocumentsDirectory();
    // print(directory);

    //   double standartDeviationAccX = 0;
    //   double meanAccX = 0;
    bool startAbnormal = false;
    int abnormalBeginIndex = 0;
    int abnormal = 0;
    //   // int startAbnormal = 0;
    //   for (var d in savedData) {
    //     meanAccX += d["acc.x"];
    //   }
    //   meanAccX /= savedData.length;
    //   print("Av: $meanAccX");
    //   for (var d in savedData) {
    //     print(d);
    //     standartDeviationAccX += pow((d["acc.x"] - meanAccX), 2);
    //   }
    //   standartDeviationAccX = sqrt(standartDeviationAccX / (savedData.length - 1));
    //   print(standartDeviationAccX);
    var _dataModels =
        json.decode(await rootBundle.loadString('models/behaviorModels.json'));
    for (var i = 1; i < _smoothedData.length; i++) {
      // print("I = $i");
      // print((_data[i]["acc.x"] + _data[i - 1]["acc.x"]).abs() / 2);

      if (st_deviation(_smoothedData[i]["acc.x"], _smoothedData[i - 1]["acc.x"],
              mean(_smoothedData[i]["acc.x"], _smoothedData[i - 1]["acc.x"])) >
          0.3) {
        if (startAbnormal != true && i != _smoothedData.length - 1) {
          startAbnormal = true;
          abnormalBeginIndex = i - 1;
          print("Start i: $i");
        }
        if (i == _smoothedData.length - 1 && startAbnormal == true) {
          print("End i: $i");
          startAbnormal = false;
          abnormal += 1;
          _abnormalClassifications.add(classifyAbnormal(
              _smoothedData, _dataModels, abnormalBeginIndex, i));
        }
      } else if (startAbnormal == true && i == _smoothedData.length - 1) {
        print("End i: $i");
        startAbnormal = false;
        abnormal += 1;
        _abnormalClassifications.add(classifyAbnormal(
            _smoothedData, _dataModels, abnormalBeginIndex, i));
      } else if (startAbnormal == true) {
        if (st_deviation(
                _smoothedData[i]["acc.x"],
                _smoothedData[i + 1]["acc.x"],
                mean(
                    _smoothedData[i]["acc.x"], _smoothedData[i + 1]["acc.x"])) >
            0.23) {
          print("Continue");
        } else {
          print("End i: $i");
          startAbnormal = false;
          abnormal += 1;
          _abnormalClassifications.add(classifyAbnormal(
              _smoothedData, _dataModels, abnormalBeginIndex, i));
        }
      }
    }
    print("Abnormal: $abnormal");
    // print(_abnormalClassifications);

    if (_abnormalClassifications.length > 0) {
      for (var ab in _abnormalClassifications) {
        ab == "Weaving"
            ? _weaving++
            : ab == "Swerving"
                ? _swerving++
                : ab == "Fast U-turn" ? _fastUTurn++ : _suddenBraking++;
      }
      print("In analys");
      print("Weaving: $_weaving");
      print("Swerving: $_swerving");
      print("Fast: $_fastUTurn");
      print("Sudden: $_suddenBraking");
    }

    // if (abnormal > 0) {

    // classification = KNN(dataOfUknown, _dataModels);
    // print(classification);
    // }
    // _dataModels =
    //     json.decode(await rootBundle.loadString('models/behaviorModels.json'));

    // classification = KNN(dataOfUknown, _dataModels);
    // print(classification);
  }

  Future<void> _analysDataFromDB() async {
    print("Analys data");
    List<dynamic> _abnormalClassifications = [];
    List<Map<String, dynamic>> _smoothedData = <Map<String, dynamic>>[];
    var dataOfUknown = {};
    String classification = "";

    bool startAbnormal = false;
    int abnormalBeginIndex = 0;
    int abnormal = 0;
    var _dataModels =
        json.decode(await rootBundle.loadString('models/behaviorModels.json'));
    _makeTemplate().then((d) {
      _smoothedData = smoothingSMAUnknown(d);
      print("smoothed");

      for (var i = 1; i < _smoothedData.length; i++) {
        // print("I = $i");
        // print((_data[i]["acc.x"] + _data[i - 1]["acc.x"]).abs() / 2);
        print("Deviation:" +
            st_deviation(
                    _smoothedData[i]["acc.x"],
                    _smoothedData[i - 1]["acc.x"],
                    mean(_smoothedData[i]["acc.x"],
                        _smoothedData[i - 1]["acc.x"]))
                .toString());
        if (st_deviation(
                _smoothedData[i]["acc.x"],
                _smoothedData[i - 1]["acc.x"],
                mean(
                    _smoothedData[i]["acc.x"], _smoothedData[i - 1]["acc.x"])) >
            0.3) {
          if (startAbnormal != true && i != _smoothedData.length - 1) {
            startAbnormal = true;
            abnormalBeginIndex = i - 1;
            print("Start i: $i");
          }
          if (i == _smoothedData.length - 1 && startAbnormal == true) {
            print("End i: $i");
            startAbnormal = false;
            abnormal += 1;
            _abnormalClassifications.add(classifyAbnormal(
                _smoothedData, _dataModels, abnormalBeginIndex, i));
          }
        } else if (startAbnormal == true && i == _smoothedData.length - 1) {
          print("End i: $i");
          startAbnormal = false;
          abnormal += 1;
          _abnormalClassifications.add(classifyAbnormal(
              _smoothedData, _dataModels, abnormalBeginIndex, i));
        } else if (startAbnormal == true) {
          if (st_deviation(
                  _smoothedData[i]["acc.x"],
                  _smoothedData[i + 1]["acc.x"],
                  mean(_smoothedData[i]["acc.x"],
                      _smoothedData[i + 1]["acc.x"])) >
              0.23) {
            print("Continue");
          } else {
            print("End i: $i");
            startAbnormal = false;
            abnormal += 1;
            _abnormalClassifications.add(classifyAbnormal(
                _smoothedData, _dataModels, abnormalBeginIndex, i));
          }
        }
      }
      print("Abnormal: $abnormal");
      // print(_abnormalClassifications);

      if (_abnormalClassifications.length > 0) {
        for (var ab in _abnormalClassifications) {
          ab == "Weaving"
              ? _weaving++
              : ab == "Swerving"
                  ? _swerving++
                  : ab == "Fast U-turn" ? _fastUTurn++ : _suddenBraking++;
        }
        print("In analys");
        print("Weaving: $_weaving");
        print("Swerving: $_swerving");
        print("Fast: $_fastUTurn");
        print("Sudden: $_suddenBraking");
      }
    });
    // _smoothedData = smoothingSMAUnknown(_data);
    // dataOfUknown = calculateUnknown(_smoothedData);
    // print(_data);
    // final Directory directory = await getApplicationDocumentsDirectory();
    // print(directory);

    //   double standartDeviationAccX = 0;
    //   double meanAccX = 0;

    //   // int startAbnormal = 0;
    //   for (var d in savedData) {
    //     meanAccX += d["acc.x"];
    //   }
    //   meanAccX /= savedData.length;
    //   print("Av: $meanAccX");
    //   for (var d in savedData) {
    //     print(d);
    //     standartDeviationAccX += pow((d["acc.x"] - meanAccX), 2);
    //   }
    //   standartDeviationAccX = sqrt(standartDeviationAccX / (savedData.length - 1));
    //   print(standartDeviationAccX);

    // if (abnormal > 0) {

    // classification = KNN(dataOfUknown, _dataModels);
    // print(classification);
    // }
    // _dataModels =
    //     json.decode(await rootBundle.loadString('models/behaviorModels.json'));

    // classification = KNN(dataOfUknown, _dataModels);
    // print(classification);
  }

  String classifyAbnormal(
      _data, _dataModels, int abnormalBeginIndex, int abnormalEndIndex) {
    // print(_data);
    // List<dynamic> _dataModels = [];
    List<Map<String, dynamic>> dataOfAbnormal = [];
    var featuresOfAbnormal = {};
    String classification = "";

    for (var i = abnormalBeginIndex; i <= abnormalEndIndex; i++) {
      dataOfAbnormal.add(_data[i]);
    }
    //  print("data of abnormal");
    //   print(dataOfAbnormal);
    featuresOfAbnormal = calculateUnknown(dataOfAbnormal);
    print(featuresOfAbnormal);
    for (var f in featuresOfAbnormal.entries) {
      if (f.key == "Duration") {
        if (f.value <= 5) {
          _suddenBehavior++;
        }
      }
    }
    // if (featuresOfAbnormal.values("Duration") <= 5) {

    // }
    // print(featuresOfAbnormal);
    classification = KNN(featuresOfAbnormal, _dataModels);
    return classification;
  }

  Future<void> showProfile(BuildContext context, args) {
    print("Weaving: $_weaving");
    print("Swerving: $_swerving");
    print("Fast: $_fastUTurn");
    print("Sudden: $_suddenBraking");

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('AlertDialog Title'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[Text("Hello")],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, TripAnalysPage.routeName,
                    arguments: PassToTripAnalysArgs(args.auth, args.userId,
                        _weaving, _swerving, _fastUTurn, _suddenBraking));
              },
            ),
          ],
        );
      },
    );
  }

  String getProfile() {}

  // SMA - Simple Moving Average
  List<Map<String, dynamic>> smoothingSMAUnknown(data) {
    List<Map<String, dynamic>> smoothed = <Map<String, dynamic>>[];
    double smoothedAccX, smoothedAccY, smoothedOriX, smoothedOriY;
    print("Smooting");
    for (var i = 1; i < data.length; i++) {
      smoothedAccX = mean(data[i - 1]["acc.x"], data[i]["acc.x"]);
      // print("SmoothedAccX: $smoothedAccX");
      smoothedAccY = mean(data[i - 1]["acc.y"], data[i]["acc.y"]);
      // print("SmoothedAccY: $smoothedAccY");
      smoothedOriX = mean(data[i - 1]["ori.x"], data[i]["ori.x"]);
      // print("SmoothedOriX: $smoothedOriX");
      smoothedOriY = mean(data[i - 1]["ori.y"], data[i]["ori.y"]);
      // print("SmoothedOriY: $smoothedOriY");
      smoothed.add({
        "acc.x": smoothedAccX,
        "acc.y": smoothedAccY,
        "ori.x": smoothedOriX,
        "ori.y": smoothedOriY,
        "time": data[i]["time"]
      });
    }
    for (var d in smoothed) {
      print(d);
    }
    return smoothed;
  }

  dynamic _makeTemplate() {
    var list;
    var smoothedList;
    var features;
    list = Firestore.instance
        .collection('trip')
        .document('t6v4D3L9bMdtubTf7vD9')
        .get()
        .then((DocumentSnapshot ds) => ds.data['data']
            // smoothedList = smoothingSMAUnknown(list);
            // features = calculate(smoothedList, "Swerving");
            // print(features);

            // for (var s in list) {
            //   print(s);
            // }
            );
    print("List: $list");
    return list;
  }

  // double meanForSMA(a, b, c) {
  //   return (a + b + c) / 3;
  // }
}

Future<void> writeDataToJSON(data, args, startTime, endTime) async {
  // print("DATA");
  // print(data);
  // Firestore.instance.collection("trip").document().setData({
  //   "uid": args.userId,
  //   "data": data,
  //   "startTime": startTime,
  //   "endTime": endTime
  // });
  // String file = args.userId.toString();
  // File('$file.json').create(recursive: true).then((File file){
  //   file.writeAsStringSync(json.encode(data));
  // });
//   print("Data");
//   print(data);
//  var jsonFile = File("models/trip.json");
//   List<dynamic> jsonFileContent = json.decode(await rootBundle.loadString('models/trip.json'));
//   print(jsonFileContent);
//   jsonFileContent.add(data);
// String data = json.decode(await DefaultAssetBundle.of(context).loadString("models/trip.json"));
// final jsonResult = json.decode(data);
}
