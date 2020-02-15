import 'package:flutter/material.dart';
import 'package:driver/utils/firebaseAuthUtils.dart';
import 'package:driver/pages/signIn_signUp_Page.dart';
import 'package:driver/pages/homePage.dart';
import 'package:driver/enums/enums.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: MaterialApp(
        title: "Driver Auth",
        debugShowCheckedModeBanner: false,
        home: MyAppHome(auth: MyAuth()),
      ),
    );
  }
}

class MyAppHome extends StatefulWidget {
  MyAppHome({this.auth});

  final AuthFunc auth;

  @override
  // State<StatefulWidget> createState() => _MyAppHomeState();
  _MyAppHomeState createState() => _MyAppHomeState();
}

// enum AuthStatus { NOT_LOGIN, NOT_DETERMINED, LOGIN }

class _MyAppHomeState extends State<MyAppHome> {
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  String _userId = "", _userEmail = "";

  @override
  void initState() {
    super.initState();
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        if (user != null) {
          _userId = user?.uid;
          _userEmail = user?.email;
        }
        authStatus =
            user?.uid == null ? AuthStatus.NOT_LOGGED_IN : AuthStatus.LOGGED_IN;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.NOT_DETERMINED:
        return _showLoading();
        break;
      case AuthStatus.NOT_LOGGED_IN:
        return SignInSignUpPage(auth: widget.auth, onSignedIn: _onSignedIn);
        break;
      case AuthStatus.LOGGED_IN:
        if (_userId.length > 0 && _userId != null) {
          return HomePage(
              userId: _userId,
              userEmail: _userEmail,
              auth: widget.auth,
              onSignedOut: _onSignedOut);
        } else
          return _showLoading();
        break;
      default:
        return _showLoading();
        break;
    }
  }

  void _onSignedIn() {
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        _userId = user.uid.toString();
        _userEmail = user.email.toString();
      });

      setState(() {
        authStatus = AuthStatus.LOGGED_IN;
      });
    });
  }

  void _onSignedOut() {
    setState(() {
      authStatus = AuthStatus.NOT_LOGGED_IN;
      _userId = _userEmail = "";
    });
  }
}

Widget _showLoading() {
  return Scaffold(
    body: Container(
      alignment: Alignment.center,
      child: CircularProgressIndicator(),
    ),
  );
}
