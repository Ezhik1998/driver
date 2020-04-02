import 'package:driver/services/firebaseAuthUtils.dart';

class PassToTripAnalysArgs {
  final AuthFunc auth;
  String userId; 
  

  PassToTripAnalysArgs(this.auth, this.userId);
}