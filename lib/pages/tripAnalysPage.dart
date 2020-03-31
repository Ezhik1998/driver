import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class TripAnalysPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Trip"),
        // backgroundColor: Colors.black,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/road.jpg"),
            fit: BoxFit.fill,
          ),
        ),
        child: Center(
          child: Text('Analys'),
        ),
      ),
    );
  }
}
