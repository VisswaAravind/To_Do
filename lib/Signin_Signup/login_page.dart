import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../Home_Page/task_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? errorMessage = '';
  bool isLogin = true;
  bool passwordVisible = false;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  Future<void> signInWithEmailAndPassword() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _controllerEmail.text, password: _controllerPassword.text);
      navigateToHomePage();
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'No user found for that email.';
            break;
          case 'wrong-password':
            errorMessage = 'Wrong password provided.';
            break;
          default:
            errorMessage = 'An error occurred. Please try again.';
        }
      });
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _controllerEmail.text, password: _controllerPassword.text);
      signInWithEmailAndPassword();
    } on FirebaseAuthException catch (e) {
      print("Exce   >>> $e");
      setState(() {
        switch (e.code) {
          case 'email-already-in-use':
            errorMessage = 'The email address is already in use.';
            break;
          case 'weak-password':
            errorMessage = 'The password is too weak.';
            break;
          default:
            errorMessage = 'An error occurred. Please try again.';
        }
      });
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      await GoogleSignIn().signOut(); // clear old sessions
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() {
          errorMessage = 'Google sign-in was canceled.';
        });
        return;
      }

      final GoogleSignInAuthentication? googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      await FirebaseAuth.instance.currentUser?.reload();
      User? user = userCredential.user;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('Personals')
            .doc(user.uid)
            .set({
          'uid': user.uid,
          'name': user.displayName ?? '',
          'email': user.email ?? '',
        }, SetOptions(merge: true));
      }
      navigateToHomePage();
    } catch (e) {
      print("Exception is >>>>>> $e");
      setState(() {
        errorMessage =
            'An error occurred during Google sign-in. Please try again.';
      });
    }
  }

  void navigateToHomePage() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => TaskPage()),
    );
  }

  Widget _entryField(String title, TextEditingController controller,
      TextInputType type, bool isPassword) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? !passwordVisible : false,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: title,
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  passwordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    passwordVisible = !passwordVisible;
                  });
                },
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _errorMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        errorMessage == '' ? '' : errorMessage!,
        style: TextStyle(color: Colors.red),
      ),
    );
  }

  Widget _submitButton() {
    return IconButton(
      onPressed:
          isLogin ? signInWithEmailAndPassword : createUserWithEmailAndPassword,
      icon: Icon(
        isLogin ? Icons.login : Icons.person_add,
        size: 30,
        color: Colors.blue.shade800,
      ),
      tooltip: isLogin ? "Login" : "Register",
    );
  }

  Widget _googleSignInButton() {
    return IconButton(
      onPressed: signInWithGoogle,
      icon: Icon(Icons.g_mobiledata, color: Colors.black, size: 60),
    );
  }

  Widget _loginOrRegisterButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          isLogin = !isLogin;
          errorMessage = '';
        });
      },
      child: Text(
        isLogin
            ? 'Don\'t have an account? Sign-Up'
            : 'Already have an account? Sign-In',
        style: TextStyle(color: Colors.black),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade100,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.task_alt, size: 100, color: Colors.blue.shade800),
              const SizedBox(height: 20),
              _entryField(
                  'Email', _controllerEmail, TextInputType.emailAddress, false),
              const SizedBox(height: 15),
              _entryField('Password', _controllerPassword,
                  TextInputType.visiblePassword, true),
              _errorMessage(),
              const SizedBox(height: 15),
              _submitButton(),
              _loginOrRegisterButton(),
              const SizedBox(height: 10),
              _googleSignInButton(),
            ],
          ),
        ),
      ),
    );
  }
}
