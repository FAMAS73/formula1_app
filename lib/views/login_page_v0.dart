import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:formula1_app/views/home_page.dart';
import 'package:formula1_app/utils/constants.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Future<void> _signInWithEmailPassword() async {
    if (_validateAndSave()) {
      try {
        final User? user = (await _auth.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        ))
            .user;
        if (user != null) {
          Navigator.of(context)
              .pushReplacement(MaterialPageRoute(builder: (_) => HomePage()));
        }
      } catch (e) {
        _showSnackbar("Failed to sign in: ${e.toString()}");
      }
    }
  }

  Future<void> _showSignUpDialog() async {
    TextEditingController signUpEmailController = TextEditingController();
    TextEditingController signUpPasswordController = TextEditingController();
    TextEditingController signUpConfirmPasswordController =
        TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Sign Up',
          ),
          backgroundColor: AppColors
              .backgroundColor, // Ensure this is a suitable color for readability
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
              child: Text(
                'Cancel',
              ),
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
                backgroundColor: AppColors
                    .primaryColor, // Use a bold color for the registration button
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
                      _showSnackbar("User registered successfully.");
                      Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => HomePage()));
                    }
                  } catch (e) {
                    Navigator.of(context).pop();
                    _showSnackbar("Failed to register: ${e.toString()}");
                  }
                } else {
                  _showSnackbar(
                      "All fields are required and passwords must match.");
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppStyles.textStyle),
        backgroundColor: AppColors.primaryColor,
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: 'Password',
        border: OutlineInputBorder(),
        suffixIcon: IconButton(
          icon:
              Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
      ),
      obscureText: _obscurePassword,
      validator: _passwordValidator,
    );
  }

  Widget _buildSignInButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: AppColors.buttonTextColor,
        backgroundColor: AppColors.buttonColor,
      ),
      onPressed: _signInWithEmailPassword,
      child: Text("Sign In", style: AppStyles.buttonStyle),
    );
  }

  Widget _buildSignUpButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: AppColors.buttonTextColor,
        backgroundColor: AppColors.secondaryColor,
      ),
      onPressed: _showSignUpDialog,
      child: Text("Sign Up", style: AppStyles.buttonStyle),
    );
  }

  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern.toString());
    if (!regex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    Pattern pattern = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$';
    RegExp regex = RegExp(pattern.toString());
    if (!regex.hasMatch(value)) {
      return 'Password must be at least 8 characters including a number, an uppercase and a lowercase letter.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login / Sign Up", style: AppStyles.headingStyle),
        backgroundColor: AppColors.primaryColor,
      ),
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    'assets/images/logo.png',
                    height: 120, // Adjust the size as needed
                  ),
                  SizedBox(height: 30),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      labelStyle: AppStyles.inputTextStyle,
                    ),
                    validator: _emailValidator,
                  ),
                  SizedBox(height: 10),
                  _buildPasswordField(),
                  SizedBox(height: 20),
                  _buildSignInButton(),
                  _buildSignUpButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
