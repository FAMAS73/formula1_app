import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:formula1_app/utils/constants.dart';
import 'package:formula1_app/views/home_page.dart';

class AuthenticationService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> signInWithEmailPassword(
      BuildContext context, String email, String password) async {
    try {
      final User? user = (await _auth.signInWithEmailAndPassword(
              email: email, password: password))
          .user;
      if (user != null) {
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (_) => HomePage()));
      }
    } catch (e) {
      _showSnackbar(context, "Failed to sign in: ${e.toString()}");
    }
  }

  static Future<void> showSignUpDialog(BuildContext context) {
    TextEditingController signUpEmailController = TextEditingController();
    TextEditingController signUpPasswordController = TextEditingController();
    TextEditingController signUpConfirmPasswordController =
        TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Sign Up', style: AppStyles.headingStyle),
          backgroundColor: AppColors.backgroundColor,
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: signUpEmailController,
                  decoration: InputDecoration(
                    hintText: "Enter your email",
                    hintStyle: AppStyles.inputTextStyle,
                    border: OutlineInputBorder(),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: signUpPasswordController,
                  decoration: InputDecoration(
                    hintText: "Enter your password",
                    hintStyle: AppStyles.inputTextStyle,
                    border: OutlineInputBorder(),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 10),
                TextField(
                  controller: signUpConfirmPasswordController,
                  decoration: InputDecoration(
                    hintText: "Confirm your password",
                    hintStyle: AppStyles.inputTextStyle,
                    border: OutlineInputBorder(),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  obscureText: true,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: AppStyles.buttonStyle),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Register',
                  style: TextStyle(
                      color: AppColors.buttonTextColor,
                      fontWeight: FontWeight.bold)),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
              ),
              onPressed: () async {
                if (signUpEmailController.text.isNotEmpty &&
                    signUpPasswordController.text.isNotEmpty &&
                    signUpConfirmPasswordController.text.isNotEmpty &&
                    signUpPasswordController.text ==
                        signUpConfirmPasswordController.text) {
                  try {
                    final User? user =
                        (await _auth.createUserWithEmailAndPassword(
                      email: signUpEmailController.text,
                      password: signUpPasswordController.text,
                    ))
                            .user;
                    if (user != null) {
                      await _firestore.collection('Users').doc(user.uid).set({
                        'email': user.email,
                        'followedTeams': [],
                        'followedDrivers': [],
                      });
                      Navigator.of(context).pop();
                      _showSnackbar(context, "User registered successfully.");
                      Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => HomePage()));
                    }
                  } catch (e) {
                    Navigator.of(context).pop();
                    _showSnackbar(
                        context, "Failed to register: ${e.toString()}");
                  }
                } else {
                  _showSnackbar(context,
                      "All fields are required and passwords must match.");
                }
              },
            ),
          ],
        );
      },
    );
  }

  static void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppStyles.textStyle),
        backgroundColor: AppColors.primaryColor,
      ),
    );
  }
}
