import 'package:flutter/material.dart';
import 'dart:async'; //Helps in dealing with async codes and here we use timer to make an automatic logout
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/http_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  //with is for mixedin
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String get userId {
    return _userId;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url =
        "https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyCymILbWH09n3nNRmKvMm5Ue4FAGt46mI0"; //key=[ApiKey] replace [ApiKey] with ypur webApi key from project stting
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'email': email,
          'password': password,
          'returnSecureToken':
              true, //Whether or not to return an ID and refresh token. Should always be true.
        }),
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        //the ['error'] key is inbuilt in firebase error
        throw HttpException(responseData['error']
            ['message']); //this exception can be handled in another screens
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData['expiresIn'],
          ),
        ),
      );
      _autoLogout(); //to autologout after user has logged in using timer as mentioned in function below
      notifyListeners();      

      final prefs = await SharedPreferences.getInstance(); //getInstance returns a future of SharedPreference so to get the actual path we await for the result
      final userData = json.encode(
        {
          'token': _token,
          'userId': _userId,
          'expiryDate': _expiryDate.toIso8601String(),
        },
      ); //we encode the datato json to set the userData as string format
      prefs.setString('userData', userData); //storing Data

    } catch (error) {
      throw error;
    }

    notifyListeners();
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;
    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);

    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _expiryDate = expiryDate;
    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> signUp(String email, String password) async {
    return _authenticate(email, password, "signUp");
  }

  Future<void> logIn(String email, String password) async {
    return _authenticate(email, password, "signInWithPassword");
  } 
Future<void> logOut() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();//to avoid creating multiple timer
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    // prefs.remove('userData'); used when key is known
    prefs.clear();//clears all data
  }
  
  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();//to avoid creating multiple timer
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logOut);
  }
}
