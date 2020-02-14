import 'package:flutter/material.dart';
import 'package:driver/utils/firebaseAuthUtils.dart';
import 'package:driver/enums/enums.dart';


// enum STATE { SIGNIN, SIGNUP }

class SignInSignUpPage extends StatefulWidget {
  AuthFunc auth;
  VoidCallback onSignedIn;
  @override
  _SignInSignUpPageState createState() => _SignInSignUpPageState();

  SignInSignUpPage({this.auth, this.onSignedIn});
}

class _SignInSignUpPageState extends State<SignInSignUpPage> {
  final _formKey = GlobalKey<FormState>();

  String _email, _password, _errorMessage;

  STATE _formState = STATE.SIGN_IN;
  bool _isIos, _isLoading;

  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void _validateAndSubmit() async {
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });
    if (_validateAndSave()) {
      String userId = "";
      try {
        if (_formState == STATE.SIGN_IN) {
          userId = await widget.auth.signIn(_email, _password);
        } else {
          userId = await widget.auth.signUp(_email, _password);
          widget.auth.sendEmailVerification();
          _showVerifyEmailSentDialog();
        }
        setState(() {
          _isLoading = false;
        });
        if (userId.length > 0 && userId != null && _formState == STATE.SIGN_IN)
          widget.onSignedIn();
      } catch (e) {
        print(e);
        _isLoading = false;
        if (_isIos)
          _errorMessage = e.details;
        else
          _errorMessage = e.message;
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _errorMessage = "";
    _isLoading = false;
  }

  void _changeFormToSignUp() {
    _formKey.currentState.reset();
    _errorMessage = "";
    setState(() {
      _formState = STATE.SIGN_UP;
    });
  }

  void _changeFormToSignIn() {
    _formKey.currentState.reset();
    _errorMessage = "";
    setState(() {
      _formState = STATE.SIGN_IN;
    });
  }

  @override
  Widget build(BuildContext context) {
    _isIos = Theme.of(context).platform == TargetPlatform.iOS;
    return Scaffold(
      appBar: AppBar(
        title: Text("Firebase Auth"),
      ),
      body: Stack(
        children: <Widget>[
          showBody(),
          showCircularProgress(),
        ],
      ),
    );
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
                  _changeFormToSignIn();
                  Navigator.of(context).pop();

                },
                child: Text('OK'),
              ),
            ],
          );
        });
  }

  showCircularProgress() {
    if (_isLoading)
      return Center(
        child: CircularProgressIndicator(),
      );
    return Container(height: 0.0, width: 0.0); // Empty view
  }

  showBody() {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            _showText(),
            _showEmailInput(),
            _showPasswordInput(),
            _showButton(),
            _showAskQuestion(),
            _showErrorMessage(),
          ],
        ),
      ),
    );
  }

  Widget _showErrorMessage() {
    if (_errorMessage.length > 0 && _errorMessage != null) {
      return Text(
        _errorMessage,
        style: TextStyle(
            fontSize: 14.0,
            color: Colors.red,
            height: 1.0,
            fontWeight: FontWeight.w300),
      );
    } else {
      return Container(
        height: 0.0,
        width: 0.0,
      );
    }
  }

  Widget _showAskQuestion() {
    return FlatButton(
        onPressed: _formState == STATE.SIGN_IN
            ? _changeFormToSignUp
            : _changeFormToSignIn,
        child: _formState == STATE.SIGN_IN
            ? Text("Create an account",
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300))
            : Text(
                "Already ? Just Sign In",
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300),
              ));
  }

  Widget _showButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
      child: SizedBox(
        height: 40.0,
        child: RaisedButton(
          onPressed: _validateAndSubmit,
          elevation: 5.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
          color: Colors.blue,
          child: _formState == STATE.SIGN_IN
              ? Text("SIGN IN",
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.white,
                  ))
              : Text("SIGN UP",
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.white,
                  )),
        ),
      ),
    );
  }

  _showPasswordInput() {
    return Padding(
        padding: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
        child: TextFormField(
          maxLines: 1,
          obscureText: true,
          autofocus: false,
          decoration: InputDecoration(
              hintText: "Enter Password",
              icon: Icon(Icons.lock, color: Colors.grey)),
          validator: (value) =>
              value.isEmpty ? "Password can not be empty" : null,
          onSaved: (value) => _password = value.trim(),
        ));
  }

  _showEmailInput() {
    return Padding(
        padding: EdgeInsets.fromLTRB(0.0, 100.0, 0.0, 0.0),
        child: TextFormField(
          maxLines: 1,
          obscureText: true,
          autofocus: false,
          decoration: InputDecoration(
              hintText: "Enter email",
              icon: Icon(Icons.email, color: Colors.grey)),
          validator: (value) => value.isEmpty ? "Email can not be empty" : null,
          onSaved: (value) => _email = value.trim(),
        ));
  }

  _showText() {
    return Hero(
      tag: 'here',
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.0, 70.0, 0.0, 0.0),
        child: _formState == STATE.SIGN_IN
            ? Center(
                child: Text(
                  "SIGN IN",
                  style: TextStyle(
                      fontSize: 40.0,
                      color: Colors.lightBlue,
                      fontWeight: FontWeight.bold),
                ),
              )
            : Center(
                child: Text(
                  "SIGN UP",
                  style: TextStyle(
                      fontSize: 40.0,
                      color: Colors.lightBlue,
                      fontWeight: FontWeight.bold),
                ),
              ),
      ),
    );
  }
}
