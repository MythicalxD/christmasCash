import 'dart:convert';
import 'package:christmas_cash/components/api/api_call.dart';
import 'package:christmas_cash/pages/rootPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';

// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../components/getDeviceId.dart';
import '../../firebase_options.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Http
import 'package:http/http.dart' as http;

import '../components/api/constants.dart';
import '../components/encode.dart';
import '../components/send/getFingerprint.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  void makePostRequest(String requestBody) async {
    String url = '$BASEURL/login';

    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    var response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(<String, String>{
        'encrypted': requestBody,
      }),
    );

    if (response.statusCode != 201) {
      Fluttertoast.showToast(
          msg: response.body,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      final FirebaseAuth _auth = FirebaseAuth.instance;
      await _auth.currentUser!.delete();
    }

    Future.delayed(const Duration(seconds: 2), () async {
      await getData(context);
      goto();
    });
  }

  void goto() {
    Navigator.pop(context);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const RootPage()));
  }

  String createJsonObject(
      String fingerprint, String uid, String deviceID, String time) {
    Map<String, dynamic> jsonObject = {
      'fingerprint': fingerprint,
      'uid': uid,
      'deviceID': deviceID,
      'time': time,
    };

    String jsonString = jsonEncode(jsonObject);
    return (jsonString);
  }

  createDataBase(credential) async {
    try {
      final authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final user = authResult.user;

      if (user != null) {
        // Get current time
        String getEpochTimeString() =>
            (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();

        // create json object
        var req = createJsonObject(await getFingerprint(), user.uid,
            await getUniqueDeviceIdentifier(), getEpochTimeString());

        String encryptedString = await encrypt(req);

        makePostRequest(encryptedString);
      } else {}
    } catch (e) {
      Navigator.pop(context);
    }
  }

  createDataBaseUsingEmail(credential) async {
    try {
      final user = credential.user;

      // Get current time
      String getEpochTimeString() =>
          (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
      // create json object
      var req = createJsonObject(await getFingerprint(), user.uid,
          await getUniqueDeviceIdentifier(), getEpochTimeString());

      String encryptedString = await encrypt(req);

      Fluttertoast.showToast(
          msg: "Creating Database...",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);

      makePostRequest(encryptedString);
    } catch (e) {
      Navigator.pop(context);
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    // show progress Indicator
    showDialog(
        context: context,
        builder: (context) {
          return Material(
            child: Container(
              decoration: const BoxDecoration(color: Colors.white),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset("assets/images/loading.png",
                        width: 300, height: 300),
                    const Text(
                      "Loading...",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ),
          );
        });

    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Sign in with the credential
    final userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    // Check if the user is new
    if (userCredential.additionalUserInfo?.isNewUser ?? false) {
      createDataBase(credential);
    } else {
      gotoHome();
    }

    // Once signed in, return the UserCredential
    return userCredential;
  }

  void gotoHome() {
    Navigator.pop(context);
    Navigator.pop(context);
    getData(context);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const RootPage()));
  }

  initFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  void showLoading(bool i) {
    // show progress Indicator
    if (i) {
      showDialog(
          context: context,
          builder: (context) {
            return Material(
              child: Container(
                decoration: const BoxDecoration(color: Colors.white),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset("assets/images/loading.png",
                          width: 300, height: 300),
                      const Text(
                        "Loading...",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              ),
            );
          });
    }
  }

  double screenHeight = 0.0;
  double screenWidth = 0.0;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String error = '';

  void _submitForm() {
    showLoading(true);
    final email = _emailController.text;
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        error = 'Please fill in all fields.';
      });
      Navigator.pop(context);
    } else {
      _loginToFirebase(email, password);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _loginToFirebase(String email, String pass) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: pass,
      );

      // Successfully logged in
      Fluttertoast.showToast(
          msg: "Logged in as: ${userCredential.user?.email}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const RootPage()));
    } catch (e) {
      if (e.toString().contains("[firebase_auth/INVALID_LOGIN_CREDENTIALS]") ||
          e.toString().contains("The supplied auth credential is incorrect")) {
        // create a new account
        _signUpAccount(email, pass);
      } else {
        Navigator.pop(context);
        Fluttertoast.showToast(
            msg: e.toString(),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }
  }

  Future<void> _signUpAccount(String email, String pass) async {
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: pass,
      );
      // create database
      Fluttertoast.showToast(
          msg: "Account Created",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);

      createDataBaseUsingEmail(credential);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        Fluttertoast.showToast(
            msg: "The password provided is too weak.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      } else if (e.code == 'email-already-in-use') {
        Fluttertoast.showToast(
            msg: "The account already exists for that email.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: e.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    initFirebase();

    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.blue, // Change this to your desired color
    ));

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      body: SafeArea(
        child: Stack(
          children: [
            Image.asset(
              'assets/images/login_bg.png',
              // Replace with your image asset path
              fit: BoxFit.fill,
              width: double.infinity,
              height: double.infinity,
            ),
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const SizedBox(height: 50),
                  const Text("Create Account",
                      style: TextStyle(
                        fontSize: 33,
                        color: Color(0xFF0B49E5),
                        fontWeight: FontWeight.w700,
                      )),
                  const Text("Welcome users ",
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF0B49E5),
                        fontWeight: FontWeight.w400,
                      )),
                  const SizedBox(height: 50),

                  Padding(
                    padding: const EdgeInsets.only(left: 30, right: 30),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: Colors.black.withOpacity(0.7),
                          // Thin black outline
                          width: 1.0, // Adjust the width as needed
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            // Very gentle background shadow
                            blurRadius: 5.0,
                            // Adjust the blur radius as needed
                            offset: const Offset(
                                0, 2), // Adjust the offset as needed
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          hintText: 'Email',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Circular Password Input Field

                  Padding(
                    padding: const EdgeInsets.only(left: 30, right: 30),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: Colors.black.withOpacity(0.7),
                          // Thin black outline
                          width: 1.0, // Adjust the width as needed
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            // Very gentle background shadow
                            blurRadius: 5.0,
                            // Adjust the blur radius as needed
                            offset: const Offset(
                                0, 2), // Adjust the offset as needed
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: 'Password',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 5, right: 40),
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.centerRight,
                      child: const Text("Forgot Password?",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          )),
                    ),
                  ),

                  // Rounded Sign In Button
                  Padding(
                    padding: const EdgeInsets.only(left: 30, right: 30),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        gradient: const LinearGradient(
                          colors: [Colors.blue, Colors.blueAccent],
                        ),
                      ),
                      child: TextButton(
                        onPressed: () {
                          _submitForm();
                        },
                        child: const Text(
                          'LogIn/Signup',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Sign Up Link
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      'Need help? Signing In',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'or',
                    style: TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          showLoading(true);
                          signInWithGoogle();
                        },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.grey,
                                blurRadius: 5.0,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 5),
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Image.asset(
                                  'assets/images/google.png',
                                  width: 30,
                                  height: 30,
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Center(
                                  child: Text(
                                "Login Google",
                                style: TextStyle(fontSize: 15),
                              )),
                              const SizedBox(width: 10)
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          showLoading(true);
                          signInWithGoogle();
                        },
                        child: Container(
                          height: 50,
                          width: 150,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.grey,
                                blurRadius: 5.0,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 5),
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Image.asset(
                                  'assets/images/facebook.png',
                                  width: 30,
                                  height: 30,
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Center(
                                  child: Text(
                                "Facebook",
                                style: TextStyle(fontSize: 15),
                              )),
                              const SizedBox(width: 10)
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  // TODO- change the link
                  Center(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                            child: const Text(
                              'Terms & Conditions',
                              style: TextStyle(color: Colors.black87),
                            ),
                            onTap: () => launch(
                                'https://scartchcash.blogspot.com/2023/10/terms-and-conditions.html')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
