import 'package:authapp/screens/profile_edit.dart';
import 'package:authapp/screens/profile_page.dart';
import 'package:authapp/widgets/header.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double screenHeight, screenWidth;
  final _auth = FirebaseAuth.instance;
  FirebaseUser loggedInUser;
  @override
  void initState() {
    getCurrentUser();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return ProfilePage();
        }));
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _googleSignUp() async {
    try {
      final GoogleSignIn _googleSignIn = GoogleSignIn(
        scopes: ['email'],
      );
      final FirebaseAuth _auth = FirebaseAuth.instance;

      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final FirebaseUser user =
          (await _auth.signInWithCredential(credential)).user;

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return ProfileEdit();
      }));
      // return user;
    } catch (e) {
      print(e.message);
    }
  }

  Future<void> signUpWithFacebook() async {
    try {
      var facebookLogin = FacebookLogin();
      var result = await facebookLogin.logIn(['email']);

      if (result.status == FacebookLoginStatus.loggedIn) {
        final AuthCredential credential = FacebookAuthProvider.getCredential(
          accessToken: result.accessToken.token,
        );
        final FirebaseUser user =
            (await FirebaseAuth.instance.signInWithCredential(credential)).user;
        print('signed in ' + user.displayName);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return ProfileEdit();
        }));

        //return user;
      }
    } catch (e) {
      print(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            Header(screenHeight: screenHeight, screenWidth: screenWidth),
            SizedBox(
              height: screenHeight / 9,
            ),
            Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      'assets/images/google.png',
                      width: 40,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    MaterialButton(
                      elevation: 3,
                      color: Colors.white,
                      onPressed: _googleSignUp,
                      child: Text('Sign in with Google'),
                    ),
                  ],
                ),
                SizedBox(
                  height: screenHeight / 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      'assets/images/fb.png',
                      width: 40,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    MaterialButton(
                      elevation: 3,
                      color: Colors.white,
                      onPressed: signUpWithFacebook,
                      child: Text('Sign in with Facebook'),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
