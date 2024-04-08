import 'package:chatt/widgets/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

final _firebase = FirebaseAuth.instance;

class Auth extends StatefulWidget {
  const Auth({super.key});

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  final _formKey = GlobalKey<FormState>();
  var _isLogin = true;
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _enteredUsername='';
  File? _selectedImage;
  var _uploding=false;

  Future<void> _submit() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid || !_isLogin && _selectedImage == null) {
      return;
    } else {
      _formKey.currentState!.save();
      if (_isLogin) {
        try {
          final userCredential = await _firebase.signInWithEmailAndPassword(
              email: _enteredEmail, password: _enteredPassword);
        } on FirebaseAuthException catch (error) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(error.message != null
                  ? "Invalid Credential"
                  : "Authentication Failed")));
        }
      } else {
        try {
          final userCredential = await _firebase.createUserWithEmailAndPassword(
              email: _enteredEmail, password: _enteredPassword);
          final storageRef = FirebaseStorage.instance
              .ref()
              .child("user_image")
              .child('${userCredential.user!.uid}.jpg');
          await storageRef.putFile(_selectedImage!);
          final imageUrl= await storageRef.getDownloadURL();
          print(imageUrl);

          await FirebaseFirestore.instance.collection('user').doc(userCredential.user!.uid).set(
              {
                'username':_enteredUsername,
                'email':_enteredEmail,
                'imageurl':imageUrl,
              });

        } on FirebaseAuthException catch (error) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(error.message ?? "Authentication Failed")));
        }

        setState(() {
          _uploding=false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 30,
                  left: 20,
                  right: 20,
                  bottom: 20,
                ),
                width: 200,
                child: Image.asset('assets/images/chat.png'),
              ),
              Card(
                margin: EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!_isLogin)
                              UserImagePicker(
                                onSelectImage: (File pickedImage) {
                                  _selectedImage = pickedImage;
                                },
                              ),
                            TextFormField(
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    !value.contains('@')) {
                                  return 'Please enter valid email address';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                label: Text("Email Address"),
                              ),
                              autocorrect: false,
                              keyboardType: TextInputType.emailAddress,
                              textCapitalization: TextCapitalization.none,
                              onSaved: (value) {
                                _enteredEmail = value!;
                              },
                            ),
                            if(!_isLogin)
                            TextFormField(
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    value.trim().length<4) {
                                  return 'Please enter valid User Name required minimum 4 character ';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                label: Text("User Name"),
                              ),
                              autocorrect: false,
                              keyboardType: TextInputType.name,

                              onSaved: (value) {
                                _enteredUsername = value!;
                              },
                            ),
                            TextFormField(
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    value.length < 6) {
                                  return 'Please select valid password';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                label: Text("Password"),
                              ),
                              autocorrect: false,
                              obscureText: true,
                              onSaved: (value) {
                                _enteredPassword = value!;
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            if(_uploding)const CircularProgressIndicator(),
                            if(!_uploding)
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer),
                                onPressed: (){
                                  _submit();
                                  setState(() {
                                    _uploding=true;
                                  });
                                },
                                child: Text(_isLogin ? "Sign In" : "Sign Up"),
                            ),
                            if(!_uploding)
                            TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isLogin = !_isLogin;
                                  });
                                },
                                child: Text(_isLogin
                                    ? "Create new account"
                                    : "Already Have Account")),
                          ],
                        )),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
