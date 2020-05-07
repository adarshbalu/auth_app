import 'package:authapp/models/user.dart';
import 'package:authapp/screens/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _auth = FirebaseAuth.instance;
  FirebaseUser loggedInUser;
  User user;
  bool load = false;
  int age;
  String gender, name, pictureUrl;
  final fireStoreDatabase = Firestore.instance;
  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
        await getUserDetails();
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    getCurrentUser();
    user = User();
    super.initState();
  }

  logout() {
    _auth.signOut();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return HomePage();
    }));
  }

  Future<User> getUserDetails() async {
    setState(() {
      load = true;
    });
    await fireStoreDatabase
        .collection('profile')
        .document(loggedInUser.uid)
        .get()
        .then((DocumentSnapshot snapshot) {
      setState(() {
        user.age = int.parse(snapshot.data['age']);
        user.name = snapshot.data['name'];
        user.gender = snapshot.data['gender'];
        user.pictureUrl = snapshot.data['picture'];
      });
    });

    return user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
            future: getUserDetails(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Center(
                  child: ListView(
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                      ),
                      FadeInImage.assetNetwork(
                        image: snapshot.data.pictureUrl,
                        placeholder: 'assets/images/user.png',
                        width: 150,
                        height: 150,
                      ),
                      SizedBox(
                        height: 18,
                      ),
                      Card(
                        child: ListTile(
                          subtitle: Text('Name'),
                          title: Text(snapshot.data.name),
                        ),
                      ),
                      SizedBox(height: 8),
                      Card(
                        child: ListTile(
                          subtitle: Text('Gener'),
                          title: Text(
                              snapshot.data.gender.toString().toUpperCase()),
                        ),
                      ),
                      SizedBox(height: 8),
                      Card(
                        child: ListTile(
                          subtitle: Text('Age'),
                          title: Text(snapshot.data.age.toString()),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 30, right: 30, top: 20, bottom: 30),
                        child: RaisedButton(
                          padding: EdgeInsets.all(20),
                          onPressed: logout,
                          color: Colors.red,
                          child: Text(
                            'Logout',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            }),
      ),
    );
  }
}
