import 'package:driver/icons/custom_icons_icons.dart';
import 'package:driver/pages/editPage.dart';
import 'package:driver/pages/profilePage.dart';
import 'package:driver/pages/statisticPage.dart';
import 'package:driver/pages/tripAnalysPage.dart';
import 'package:flutter/material.dart';
import 'package:driver/services/firebaseAuthUtils.dart';
import 'package:driver/pages/signIn_signUp_Page.dart';
import 'package:driver/pages/homePage.dart';
import 'package:driver/pages/sensorMainHome.dart';
import 'package:driver/enums/enums.dart';
import 'package:flutter/services.dart';
import 'package:splashscreen/splashscreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: MaterialApp(
        title: "EasyDrive",
        debugShowCheckedModeBanner: false,
        home: AppSplash(),
        // home: MyAppHome(auth: MyAuth()),
        theme: ThemeData.dark(),
        // initialRoute: '/',
        routes: {
          // '/': (context) => MyAppHome(auth: MyAuth()),
          '/trip-analys': (context) => TripAnalysPage(),
          EditPage.routeName: (context) => EditPage(),
          // '/edit': (context) => EditPage(),
        },
      ),
    );
  }
}

class AppSplash extends StatefulWidget {
  @override
  _AppSplashState createState() => _AppSplashState();
}

class _AppSplashState extends State<AppSplash> {
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: 2,
      navigateAfterSeconds: MyAppHome(auth: MyAuth()),
      title: Text(
        "EasyDrive",
        style: TextStyle(
            fontSize: 18.0,
            color: Color(0xFF2A4848),
            fontFamily: "Montserrat",
            fontWeight: FontWeight.w900),
      ),
      image: Image(image: AssetImage("images/app_logo.png")),
      backgroundColor: Colors.white,
      loaderColor: Color(0xFF2a4848),      
      photoSize: 65.0,
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
      // if(mounted){
      setState(() {
        if (user != null) {
          _userId = user?.uid;
          _userEmail = user?.email;
        }
        authStatus =
            user?.uid == null ? AuthStatus.NOT_LOGGED_IN : AuthStatus.LOGGED_IN;
      });
      // }
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
          return DefaultTabController(
              length: 3,
              child: Scaffold(
                bottomNavigationBar: TabBar(
                  tabs: [
                    Tab(
                      icon: Icon(Icons.home),
                      text: "Home",
                    ),
                    Tab(
                      icon: Icon(CustomIcons.bar),
                      text: "Statictic",
                    ),
                    Tab(
                      icon: Icon(Icons.person),
                      text: "Profile",
                    )
                  ],
                  unselectedLabelColor: Color(0xFF999999),
                  // labelColor: Colors.black,
                  indicatorColor: Colors.transparent,
                ),
                body: TabBarView(children: [
                  HomePage(
                      // userId: _userId,
                      // userEmail: _userEmail,
                      auth: widget.auth,
                      onSignedOut: _onSignedOut),
                  // SensorMainHome(),
                  StatisticPage(
                      userId: _userId,
                      auth: widget.auth,
                      onSignedOut: _onSignedOut),
                  ProfilePage(
                      userId: _userId,
                      auth: widget.auth,
                      onSignedOut: _onSignedOut),
                  // Center(child: Text("Statistic"),),
                  // Center(
                  //   child: Text('Profile'),
                  // )
                ]),
              ));

          // return HomePage(
          //     userId: _userId,
          //     userEmail: _userEmail,
          //     auth: widget.auth,
          //     onSignedOut: _onSignedOut);
          // return SensorMainHome();
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
      // if (mounted)
      setState(() {
        _userId = user.uid.toString();
        _userEmail = user.email.toString();
      });
      // if (mounted)
      setState(() {
        authStatus = AuthStatus.LOGGED_IN;
      });
    });
  }

  void _onSignedOut() {
    // if (mounted)
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
      child: CircularProgressIndicator(
        valueColor: new AlwaysStoppedAnimation<Color>(Color(0xFF669999)),
      ),
    ),
  );
}
