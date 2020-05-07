import 'dart:io';

import 'package:authapp/screens/home_page.dart';
import 'package:authapp/screens/profile_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class ProfileEdit extends StatefulWidget {
  @override
  _ProfileEditState createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit> {
  TextEditingController nameController;
  TextEditingController ageController;
  final _auth = FirebaseAuth.instance;
  FirebaseUser loggedInUser;
  final fireStoreDatabase = Firestore.instance;
  String gender = 'male', picture = '';
  int genderValue = 0;
  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
        await fireStoreDatabase
            .collection('profile')
            .document(loggedInUser.uid)
            .get()
            .then((DocumentSnapshot snapshot) {
          if (snapshot.exists)
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) {
              return ProfilePage();
            }));
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    nameController = TextEditingController();
    ageController = TextEditingController();
    getCurrentUser();
    super.initState();
  }

  File _image;

  void getImage() async {
    _image = await ImagePicker.pickImage(source: ImageSource.gallery);
  }

  Future addImageToFirebase() async {
    if (picture.isEmpty) {
      StorageReference ref =
          FirebaseStorage().ref().child('gs://auth-app-db6b2.appspot.com');
      StorageUploadTask storageUploadTask =
          ref.child('assets/images/user.png').putFile(_image);

      if (storageUploadTask.isSuccessful || storageUploadTask.isComplete) {
        final String url = await ref.getDownloadURL();
        print("The download URL is " + url);
        picture = url;
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Text('Image added'),
              );
            });
      } else if (storageUploadTask.isInProgress) {
        storageUploadTask.events.listen((event) {
          double percentage = 100 *
              (event.snapshot.bytesTransferred.toDouble() /
                  event.snapshot.totalByteCount.toDouble());
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  content: Text('Uploading image : ' + percentage.toString()),
                );
              });
        });

        StorageTaskSnapshot storageTaskSnapshot =
            await storageUploadTask.onComplete;
        String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();

        picture = downloadUrl;
        print("Download URL " + downloadUrl.toString());
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Text('Image added'),
              );
            });
      } else {
        if (storageUploadTask.isCanceled) {
          print('Cancelled');
        }
      }
    }
  }

  Future updateData() async {
    await addImageToFirebase();
    if (ageController.text.isEmpty ||
        nameController.text.isEmpty ||
        picture.isEmpty) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text('Please fill all required fields'),
            );
          });
    } else {
      try {
        await fireStoreDatabase
            .collection('profile')
            .document(loggedInUser.uid)
            .setData({
          'age': ageController.text,
          'name': nameController.text,
          'gender': gender,
          'picture': picture,
        });
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Text('User added'),
              );
            });
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return ProfilePage();
        }));
      } catch (e) {
        print(e.toString());
      }
    }
  }

  logout() {
    _auth.signOut();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return HomePage();
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            SizedBox(
              height: 18,
            ),
            Center(
              child: Text(
                'Add User Information',
                style: GoogleFonts.poppins(
                  fontSize: 25,
                ),
              ),
            ),
            SizedBox(
              height: 28,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.0, 10, 20, 20),
              child: TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  helperText: 'Enter your Name',
                ),
                validator: (input) {
                  if (input.isEmpty) {
                    return 'Please type a name';
                  } else
                    return '';
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.0, 10, 20, 20),
              child: TextFormField(
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    helperText: 'Enter your age',
                    focusedBorder: OutlineInputBorder()),
                validator: (input) {
                  if (input.isEmpty) {
                    return 'Please type an age';
                  } else
                    return '';
                },
              ),
            ),
            Center(
              child: Text(
                'Gender : ',
                style: TextStyle(fontSize: 20),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Male : '),
                  Radio(
                    onChanged: (value) {
                      setState(() {
                        gender = 'male';
                        genderValue = value;
                      });
                    },
                    activeColor: Color(0xFF3383CD),
                    value: 0,
                    groupValue: genderValue,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text('Female : '),
                  Radio(
                    onChanged: (value) {
                      setState(() {
                        gender = 'female';
                        genderValue = value;
                      });
                    },
                    activeColor: Color(0xFF3383CD),
                    value: 1,
                    groupValue: genderValue,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 60.0, right: 60, top: 20),
              child: OutlineButton.icon(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                onPressed: getImage,
                color: Colors.indigo,
                icon: Icon(Icons.image),
                label: Text('Add image'),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 30, right: 30, top: 30),
              child: RaisedButton(
                padding: EdgeInsets.all(20),
                onPressed: updateData,
                color: Colors.green,
                child: Text(
                  'Add user',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            Padding(
              padding:
                  EdgeInsets.only(left: 30, right: 30, top: 10, bottom: 30),
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
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    super.dispose();
  }
}
