import 'package:flutter/material.dart';
import 'package:driver/services/firebaseAuthUtils.dart';
import 'package:driver/enums/enums.dart';

// enum FormType { SIGN_IN, SIGN_UP, RESET }

class SignInSignUpPage extends StatefulWidget {
  SignInSignUpPage({this.auth, this.onSignedIn});

  final AuthFunc auth;
  final VoidCallback onSignedIn;

  @override
  _SignInSignUpPageState createState() => _SignInSignUpPageState();
}

class _SignInSignUpPageState extends State<SignInSignUpPage> {
  final _formKey = GlobalKey<FormState>();

  String _email, _password, _errorMessage;

  // FormType _formState = FormType.SIGN_IN;
  bool _isIos, _isLoading, _isSignInForm, _isResetForm, _showForgotPassword, _obscurePassword;

// Check if form is valid before perform login or signup
  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    setState(() {
      _isLoading = false;
    });
    return false;
  }

// Perform sign in/sign up
  void _validateAndSubmit() async {
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });
    if (_validateAndSave()) {
      String userId = "";
      try {
        if (_isSignInForm) {
          userId = await widget.auth.signIn(_email, _password);
          print("Sign in user: $userId");
        } else if (_isResetForm) {
          await widget.auth.sendPasswordResetEmail(_email);
          print("Password was reset");
          setState(() {
            // _formState = FormType.SIGN_IN;
            _isSignInForm = true;
            // _isResetForm = false;
            _showForgotPassword = true;
          });
        } else {
          userId = await widget.auth.signUp(_email, _password);
          widget.auth.sendEmailVerification();
          _showVerifyEmailSentDialog();
          print("Sign up user: $userId");
        }
        setState(() {
          _isLoading = false;
        });
        if (userId.length > 0 && userId != null && _isSignInForm)
          widget.onSignedIn();
      } catch (e) {
        print(e);
        setState(() {
          _isLoading = false;
          if (_isIos)
            _errorMessage = e.details;
          else
            _errorMessage = e.message;
          // _formKey.currentState.reset();
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _errorMessage = "";
    // _warning = "";
    _isLoading = false;
    _isSignInForm = true;
    _isResetForm = false;
    _showForgotPassword = true;
    _obscurePassword = true;
    // print(_showForgotPassword);
  }

  void toggleForm() {
    _formKey.currentState.reset();
    _errorMessage = "";
    setState(() {
      _isSignInForm = !_isSignInForm;
      _showForgotPassword = !_showForgotPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    _isIos = Theme.of(context).platform == TargetPlatform.iOS;
    return Scaffold(
      backgroundColor: Color(0xFFE6E6E6),
      // appBar: AppBar(
      //   title: Text("Driver Auth"),
      // ),
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
            title: Text('Verify your account'),
            content: Text('Link verify has been sent to your email'),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  toggleForm();
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
            _showForgotPasswordButton(),
            _showButton(),
            _showSecondaryButton(),
            _showErrorMessage(),
          ],
        ),
      ),
    );
  }


  Widget _showErrorMessage() {
    if (_errorMessage.length > 0 && _errorMessage != null) {      
      return Container(
        child: Text(
          _errorMessage,
          textAlign: TextAlign.center,
          maxLines: 5,
          style: TextStyle(
              fontSize: 14.0,
              color: Colors.red,
              height: 1.0,
              fontWeight: FontWeight.w300),
        ),
      );
    } else {
      return Container(
        height: 0.0,
        width: 0.0,
      );
    }
  }

  Widget _showSecondaryButton() {
    return FlatButton(
      onPressed: () {
        if (_isResetForm == true) _isResetForm = false;
        toggleForm();
        // Dismiss the keyboard
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: _isSignInForm
          ? Text("Create an account",
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300, color: Color(0xFF666666)))
          : _isResetForm
              ? Text("Back to sign in",
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300, color: Color(0xFF666666)))
              : Text(
                  "Have an account? Sign In",
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300, color: Color(0xFF666666)),
                ),
    );
  }

  Widget _showButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
      child: SizedBox(
        height: 40.0,
        child: Builder(
          builder: (context) => RaisedButton(
            onPressed: () {
              _validateAndSubmit();
              // Dismiss the keyboard
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
              if (_isResetForm) {
                setState(() {
                  _isResetForm = !_isResetForm;
                });
                print("snackbar");
                Scaffold.of(context).showSnackBar(SnackBar(
                  content:
                      Text("A password reset link has been sent to $_email"),
                  duration: const Duration(seconds: 3),
                ));
              }
            },
            elevation: 5.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)),
            color: Color(0xFF2A4848),
            child: _isSignInForm
                ? Text("SIGN IN",
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.white,
                    ))
                : _isResetForm
                    ? Text("Submit",
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
      ),
    );
  }

  _showPasswordInput() {
    // print(_showForgotPassword);
    // print(_isSignInForm);
    return Visibility(
      child: Padding(
          padding: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
          child: TextFormField(
            maxLines: 1,
            obscureText: _obscurePassword,
            autofocus: false,
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
                borderSide: BorderSide(color: Color(0xFF3C5859))
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
                borderSide: BorderSide(color: Color(0xFF999999))
              ),
                hintText: "Enter Password",                               
                hintStyle: TextStyle(color: Color(0xFF999999)),
                prefixIcon: Icon(Icons.lock, color: Colors.grey),
                suffixIcon: IconButton(icon: _obscurePassword ? Icon(Icons.visibility_off, color: Colors.grey,) : Icon(Icons.visibility, color: Colors.grey,), onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                })
            ),
                
            validator: (value) =>
                value.isEmpty ? "Password can not be empty" : null,
            onSaved: (value) => _password = value.trim(),
          )),
      visible: !_isResetForm,
    );
  }

  Widget _showForgotPasswordButton() {
    return Visibility(
      child: FlatButton(
          child: Text(
            "Forgot Password?",
            style: TextStyle(color: Color(0xFF666666)),
          ),
          onPressed: () {
            setState(() {
              // _formState = FormType.RESET;
              _isResetForm = true;
              _isSignInForm = false;
              _showForgotPassword = !_showForgotPassword;
            });
          }),
      visible: _showForgotPassword,
    );
  }

  _showEmailInput() {
    return Padding(
        padding: EdgeInsets.fromLTRB(0.0, 100.0, 0.0, 0.0),
        child: TextFormField(
          maxLines: 1,
          keyboardType: TextInputType.emailAddress,
          // obscureText: true,
          autofocus: false,
          decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
                borderSide: BorderSide(color: Color(0xFF3C5859))
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
                borderSide: BorderSide(color: Color(0xFF999999))
              ),
              hintText: "Enter email",
              hintStyle: TextStyle(color: Color(0xFF999999)),
              prefixIcon: Icon(Icons.email, color: Colors.grey)),
          validator: (value) => value.isEmpty ? "Email can not be empty" : null,
          onSaved: (value) => _email = value.trim(),
        ));
  }

  _showText() {
    return Hero(
      tag: 'here',
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.0, 70.0, 0.0, 0.0),
        child: _isSignInForm
            ? Center(
                child: Text(
                  "SIGN IN",
                  style: TextStyle(
                      fontSize: 40.0,
                      color: Color(0xFF2A4848),
                      fontWeight: FontWeight.bold),
                ),
              )
            : _isResetForm
                ? Center(
                    child: Text(
                      "RESET FORM",
                      style: TextStyle(
                          fontSize: 40.0,
                          color: Color(0xFF2A4848),
                          fontWeight: FontWeight.bold),
                    ),
                  )
                : Center(
                    child: Text(
                      "SIGN UP",
                      style: TextStyle(
                          fontSize: 40.0,
                          color: Color(0xFF2A4848),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
      ),
    );
  }
}
