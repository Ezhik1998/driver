import 'package:driver/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:driver/services/firebaseAuthUtils.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.auth, this.onSignedOut, this.userId, this.userEmail})
      : super(key: key);

  final AuthFunc auth;
  final VoidCallback onSignedOut;
  final String userId, userEmail;

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
      appBar: AppBar(
        title: Text("Flutter Auth Email"),
        actions: <Widget>[
          // FlatButton(
          //   child: Text("Sign Out"),
          //   onPressed: _signOut,
          // )
          PopupMenuButton<String>(  
            offset: Offset(0, 5),            
            onSelected: _choiceAction,
            itemBuilder: (BuildContext context) {
              return Constants.choices.map((String choice){
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice));
              }).toList();
            },
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Text("Hello " + widget.userEmail),
          ),
          Center(
            child: Text("Your id: " + widget.userId),
          )
        ],
      ),
    );
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
    if(choice == Constants.SIGN_OUT)
      _signOut();
  }
}
