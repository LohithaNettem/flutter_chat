import 'dart:io';

import 'package:chat_app/widgets/auth_form.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  Future<void> _submitAuthForm(String email, String userName, String pswd,
      File userImageFile, bool isLogin, BuildContext context) async {
    UserCredential result;
    try {
      setState(() {
        _isLoading = true;
      });
      if (isLogin) {
        result = await _auth.signInWithEmailAndPassword(
            email: email, password: pswd);
      } else {
        result = await _auth.createUserWithEmailAndPassword(
            email: email, password: pswd);

// Adds userImage to firestore storage
        final ref = FirebaseStorage.instance
            .ref()
            .child('user_image')
            .child(result.user!.uid + '.jpg');

        await ref.putFile(userImageFile);
        final url = await ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(result.user?.uid)
            .set({'username': userName, 'email': email, 'image_url': url});
      }
    } on PlatformException catch (error) {
      var message = 'An error occurred, please check your credentials.';
      if (error.message != null) {
        message = error.message.toString();
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).errorColor,
      ));
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
        backgroundColor: Theme.of(context).errorColor,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: AuthForm(_submitAuthForm, _isLoading),
    );
  }
}
