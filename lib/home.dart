import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:srm/Dashboard_structure.dart';
import 'package:srm/Profile.dart';
import 'package:srm/create.dart';
import 'package:srm/progress.dart';

import 'Dashboard_layout.dart';

import 'models/user.dart';

final usersRef = FirebaseFirestore.instance.collection('users');
final classRef = FirebaseFirestore.instance.collection('classes');
final announcementsRef = FirebaseFirestore.instance.collection('announcements');
final assignmentsRef = FirebaseFirestore.instance.collection('assignments');
final notesRef = FirebaseFirestore.instance.collection('notes');
final followersRef = FirebaseFirestore.instance.collection('userFollowers');
final timeRef = FirebaseFirestore.instance.collection('timeline');
final idRef = FirebaseFirestore.instance.collection('Fid');
final tpRef = FirebaseFirestore.instance.collection('tposts');
final DateTime timestamp = DateTime.now();
int index = 0;
User currentUser;
bool isAuth = false;
bool isReg = false;
bool isLoading = false;

final GoogleSignIn googleSignIn = GoogleSignIn();
final firebase_storage.Reference storageRef =
    firebase_storage.FirebaseStorage.instance.ref();
GoogleSignInAccount guser;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  static List<Widget> _widgetoptions = <Widget>[
    Dash_struct(),
    profile(),
    AlertDialog(
      title: new Text("Do you want to logout?",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontFamily: "JustAnotherHand",
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.black)),
      actions: [
        FlatButton(
          child: Text("Logout"),
          onPressed: () {
            googleSignIn.signOut();
            index = 0;
          },
        )
      ],
    ),
  ];
  @override
  // ignore: override_on_non_overriding_member
  void tap(int currindex) {
    setState(() {
      index = currindex;
    });
  }

  String dropdownValue = "Student";
  String dropdownValue1 = "B.Tech";
  String dropdownValue2 = "CSE";
  String dropdownValue3 = "I";
  String dropdownValue4 = "1";

  year() {
    if (dropdownValue1 == "B.Tech")
      return ["I", "II", "III", "IV"];
    else
      return ["I", "II", "III"];
  }

  sem() {
    if (dropdownValue3 == "I")
      return ["1", "2"];
    else if (dropdownValue3 == "II")
      return ["3", "4"];
    else if (dropdownValue3 == "III")
      return ["5", "6"];
    else if (dropdownValue3 == "IV") return ["7", "8"];
  }

  branch() {
    if (dropdownValue1 == "B.Tech")
      return [
        "CSE",
        "IT",
        "Mech",
        "EEE",
        "ECE",
        "Civil",
        "Bio-Med",
        "Robotics",
        "Software"
      ];
    else if (dropdownValue1 == "B.A")
      return [
        "English",
        "Political Science",
        "Economics",
        "Psychology",
      ];
    else if (dropdownValue1 == "B.C.A" ||
        dropdownValue1 == "B.Com" ||
        dropdownValue1 == "B.B.A")
      return ["No Branch"];
    else if (dropdownValue1 == "B.Sc")
      return [
        "Math",
        "Phy",
        "Chem",
        "Food Tech",
        "Agriculture Science",
        "Hotel Management"
      ];
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  TextEditingController mob = TextEditingController();

  submit() async {
    usersRef.doc(currentUser.reg).update({
      "displayName":
          ((currentUser?.email).toString().contains("@srmist.edu.in"))
              ? currentUser.displayName.substring(
                  0,
                  currentUser.displayName
                      .indexOf(' ' + (currentUser.reg).toString()))
              : currentUser?.displayName?.split(" ")[1],
      "mobile": mob.text,
      "des": dropdownValue,
      "year": dropdownValue3,
      "sem": dropdownValue4,
      "branch": dropdownValue1 + "-" + dropdownValue2,
    });

    DocumentSnapshot doc = await usersRef.doc(currentUser?.reg).get();

    currentUser = User.fromDocument(doc);

    setState(() {
      isReg = false;
      isAuth = true;
      mob.text = "";
    });

    fun();
  }

  fun() {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              backgroundColor: Colors.white,
              title: new Text("Details Saved !!!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
            ));
  }

  fun1() {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              backgroundColor: Colors.white,
              title: new Text("Fields can't be blank !!!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
            ));
  }

  fun2() {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              backgroundColor: Colors.white,
              title: new Text("Mobile number must contain only 10 digits!!!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
            ));
  }

  @override
  void initState() {
    super.initState();

    google();
  }

  google() {
    // Reauthenticate user when app is opened
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      setState(() {
        isLoading = true;
      });
      handleSignIn(account);
    }).catchError((err) {
      print('Error signing in: $err');
    });

    // Detects when user signed in
    googleSignIn.onCurrentUserChanged.listen((account) {
      setState(() {
        isLoading = true;
      });
      handleSignIn(account);
    }, onError: (err) {
      print('Error signing in: $err');
    });
  }

  handleSignIn(GoogleSignInAccount account) async {
    setState(() {
      isLoading = true;
    });

    if (account != null &&
        (account.email.contains('@srmist.edu.in') ||
            account.email.contains('gautham_vijayaraj@srmuniv.edu.in'))) {
      print('User signed in!: $account');

      await createUserInFirestore();

      setState(() {
        isAuth = true;
      });
    } else if (account != null &&
        !(account.email.contains('@srmist.edu.in') ||
            account.email.contains('gautham_vijayaraj@srmuniv.edu.in'))) {
      showDialog(
          context: context,
          builder: (_) => new AlertDialog(
                backgroundColor: Colors.white,
                title: new Text("Sign in using SRMIST ID only!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
              ));
      googleSignIn.signOut();
      setState(() {
        isLoading = false;
      });
    } else {
      googleSignIn.signOut();
      setState(() {
        isAuth = false;
        isLoading = false;
      });
    }
  }

  createUserInFirestore() async {
    // 1) check if user exists in users collection in database (according to their id)
    final GoogleSignInAccount user = googleSignIn.currentUser;
    String r;
    setState(() {
      if (user.email.contains("@srmist.edu.in"))
        r = user.displayName.split(" ")[user.displayName.split(" ").length - 1];
      else
        r = user.displayName.split(" ")[0];
    });

    DocumentSnapshot doc = await usersRef.doc(r).get();

    if (!doc.exists) {
      // 2) if the user doesn't exist, then we want to take them to the create account page

      setState(() {
        isReg = true;
      });

      // 3) get username from create account, use it to make new user document in users collection

      usersRef.doc(r).set({
        "reg": r,
        "email": user.email,
        "photoUrl": user.photoUrl,
        "mobile": mob.text,
        "displayName": user.displayName,
        "des": dropdownValue,
        "year": dropdownValue3,
        "sem": dropdownValue4,
        "branch": dropdownValue1 + "-" + dropdownValue2,
        "classes": [],
        "timestamp": timestamp
      });

      doc = await usersRef.doc(r).get();
    }

    setState(() {
      isLoading = false;
    });

    currentUser = User.fromDocument(doc);
    print(currentUser);
    print(currentUser?.classes);
  }

  @override
  Widget build(BuildContext context) {
    if (isAuth == false)
      return login();
    else if (isAuth == true && isReg == false)
      return Scaffold(
        resizeToAvoidBottomInset: false,
        bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: index,
            onTap: tap,
            selectedItemColor: Colors.deepOrangeAccent[400],
            items: [
              BottomNavigationBarItem(
                  title: Text("Dashboard"), icon: Icon(Icons.dashboard)),
              BottomNavigationBarItem(
                  title: Text("Profile"), icon: Icon(Icons.person_outline)),
              BottomNavigationBarItem(
                  title: Text("Log out"), icon: Icon(Icons.exit_to_app)),
            ]),
        body: _widgetoptions.elementAt(index),
      );
    else if (isAuth == true && isReg == true)
      return Scaffold(
          key: _scaffoldKey,
          resizeToAvoidBottomInset: false,
          body: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Container(
                      child: SafeArea(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              "Setup Profile",
                              style: TextStyle(
                                fontSize: 50.0,
                                fontFamily: 'SFUI',
                                fontWeight: FontWeight.w400,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.25,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(50.0),
                            bottomRight: Radius.circular(50.0)),
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.amber, Colors.red],
                            stops: [0.0, 1.0]),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 25.0),
                      child: Center(
                        child: Text(
                          "Are you a Student/Teacher ?",
                          style: TextStyle(
                              fontSize: 20.0,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Poppins-Regular"),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: DropdownButton<String>(
                          dropdownColor: _getColorFromHex("#f0f4ff"),
                          value: dropdownValue,
                          icon: Text(
                            " ( Tap to change )",
                            style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.black54,
                                fontFamily: "Poppins-Regular"),
                          ),
                          iconSize: 24,
                          elevation: 16,
                          style: TextStyle(
                              fontSize: 15.0,
                              color: Colors.black,
                              fontFamily: "Poppins-Regular"),
                          underline: Container(
                            height: 1,
                            color: Colors.black,
                          ),
                          onChanged: (String newValue) {
                            setState(() {
                              dropdownValue = newValue;
                              if (dropdownValue == "Teacher") {
                                dropdownValue1 = "";
                                dropdownValue2 = "";
                                dropdownValue3 = "";
                                dropdownValue4 = "";
                              } else if (dropdownValue == "Student") {
                                dropdownValue1 = "B.Tech";
                                dropdownValue2 = "CSE";
                                dropdownValue3 = "I";
                                dropdownValue4 = "1";
                              }
                            });
                          },
                          items: <String>["Student", "Teacher"]
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              onTap: () {
                                print(value);
                              },
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    (dropdownValue == "Student")
                        ? Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(top: 25.0),
                                child: Center(
                                  child: Text(
                                    "Select your Course",
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "Poppins-Regular"),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: DropdownButton<String>(
                                    dropdownColor: _getColorFromHex("#f0f4ff"),
                                    value: dropdownValue1,
                                    icon: Text(
                                      " ( Tap to change the Course )",
                                      style: TextStyle(
                                          fontSize: 12.0,
                                          color: Colors.black54,
                                          fontFamily: "Poppins-Regular"),
                                    ),
                                    iconSize: 24,
                                    elevation: 16,
                                    style: TextStyle(
                                        fontSize: 15.0,
                                        color: Colors.black,
                                        fontFamily: "Poppins-Regular"),
                                    underline: Container(
                                      height: 1,
                                      color: Colors.black,
                                    ),
                                    onChanged: (String newValue) {
                                      setState(() {
                                        dropdownValue1 = newValue;
                                      });
                                    },
                                    items: <String>[
                                      "B.Tech",
                                      "B.A",
                                      "B.Sc",
                                      "B.C.A",
                                      "B.B.A",
                                      "B.Com"
                                    ].map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                        onTap: () {
                                          print(value);
                                          setState(() {
                                            if (value == "B.Tech")
                                              dropdownValue2 = "CSE";
                                            else if (value == "B.A")
                                              dropdownValue2 = "English";
                                            else if (value == "B.Sc")
                                              dropdownValue2 = "Math";
                                            else
                                              dropdownValue2 = "No Branch";
                                          });
                                        },
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 25.0),
                                child: Center(
                                  child: Text(
                                    "Select your Branch",
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "Poppins-Regular"),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: DropdownButton<String>(
                                    dropdownColor: _getColorFromHex("#f0f4ff"),
                                    value: dropdownValue2,
                                    icon: Text(
                                      " ( Tap to change the Branch )",
                                      style: TextStyle(
                                          fontSize: 12.0,
                                          color: Colors.black54,
                                          fontFamily: "Poppins-Regular"),
                                    ),
                                    iconSize: 24,
                                    elevation: 16,
                                    style: TextStyle(
                                        fontSize: 15.0,
                                        color: Colors.black,
                                        fontFamily: "Poppins-Regular"),
                                    underline: Container(
                                      height: 1,
                                      color: Colors.black,
                                    ),
                                    onChanged: (String newValue) {
                                      setState(() {
                                        dropdownValue2 = newValue;
                                      });
                                    },
                                    items: branch()
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem<String>(
                                        onTap: () {
                                          print(value);
                                        },
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 25.0),
                                child: Center(
                                  child: Text(
                                    "Choose the Year",
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "Poppins-Regular"),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: DropdownButton<String>(
                                    dropdownColor: _getColorFromHex("#f0f4ff"),
                                    value: dropdownValue3,
                                    icon: Text(
                                      " ( Tap to change )",
                                      style: TextStyle(
                                          fontSize: 12.0,
                                          color: Colors.black54,
                                          fontFamily: "Poppins-Regular"),
                                    ),
                                    iconSize: 24,
                                    elevation: 16,
                                    style: TextStyle(
                                        fontSize: 15.0,
                                        color: Colors.black,
                                        fontFamily: "Poppins-Regular"),
                                    underline: Container(
                                      height: 1,
                                      color: Colors.black,
                                    ),
                                    onChanged: (String newValue) {
                                      setState(() {
                                        dropdownValue3 = newValue;
                                        if (dropdownValue3 == "I")
                                          dropdownValue4 = "1";
                                        else if (dropdownValue3 == "II")
                                          dropdownValue4 = "3";
                                        else if (dropdownValue3 == "III")
                                          dropdownValue4 = "5";
                                        else if (dropdownValue3 == "IV")
                                          dropdownValue4 = "7";
                                      });
                                    },
                                    items: year().map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                        onTap: () {
                                          print(value);
                                        },
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 25.0),
                                child: Center(
                                  child: Text(
                                    "Choose the Semester",
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "Poppins-Regular"),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: DropdownButton<String>(
                                    dropdownColor: _getColorFromHex("#f0f4ff"),
                                    value: dropdownValue4,
                                    icon: Text(
                                      " ( Tap to change )",
                                      style: TextStyle(
                                          fontSize: 12.0,
                                          color: Colors.black54,
                                          fontFamily: "Poppins-Regular"),
                                    ),
                                    iconSize: 24,
                                    elevation: 16,
                                    style: TextStyle(
                                        fontSize: 15.0,
                                        color: Colors.black,
                                        fontFamily: "Poppins-Regular"),
                                    underline: Container(
                                      height: 1,
                                      color: Colors.black,
                                    ),
                                    onChanged: (String newValue) {
                                      setState(() {
                                        dropdownValue4 = newValue;
                                      });
                                    },
                                    items: sem().map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                        onTap: () {
                                          print(value);
                                        },
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Container(width: 0, height: 0),
                    Padding(
                      padding: EdgeInsets.only(top: 25.0),
                      child: Center(
                        child: Text(
                          "Select your Mobile Number",
                          style: TextStyle(
                              fontSize: 20.0,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Poppins-Regular"),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Container(
                        child: Form(
                          key: _formKey,
                          child: TextFormField(
                            style: TextStyle(
                                fontSize: 15.0,
                                color: Colors.black,
                                fontFamily: "Poppins-Regular"),
                            validator: (val) {
                              if (val?.trim().length != 10) {
                                return "Invalid Number";
                              } else {
                                return null;
                              }
                            },
                            controller: mob,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              focusedBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.black, width: 1.0),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.black, width: 1.0),
                              ),
                              labelText: "Mobile Number",
                              labelStyle: TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.black54,
                                  fontFamily: "Poppins-Regular"),
                              hintText: "Enter a valid number",
                              hintStyle: TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.black54,
                                  fontFamily: "Poppins-Regular"),
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (mob.text == "")
                          fun1();
                        else if (mob.text.length != 10)
                          fun2();
                        else
                          submit();
                      },
                      child: Container(
                        height: 50.0,
                        width: 350.0,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.amber, Colors.red],
                              stops: [0.0, 1.0]),
                          borderRadius: BorderRadius.circular(7.0),
                        ),
                        child: Center(
                          child: Text(
                            "Submit",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    Container(height: 30)
                  ],
                ),
              )));
    else
      return Text("");
  }

  login() {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.amber, Colors.red],
              stops: [0.0, 1.0]),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 300.0,
                height: 200.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/applogo.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(height: 50.0),
              Text(
                "SRM Guru",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'SFUI',
                  fontWeight: FontWeight.w800,
                  fontSize: 35.0,
                ),
              ),
              SizedBox(
                height: 50,
              ),
              Container(
                height: 40.0,
                child: RaisedButton(
                  onPressed: () {
                    setState(() {
                      isLoading = true;
                    });

                    googleSignIn.signIn();
                  },
                  color: Colors.white,
                  // splashColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      side: BorderSide(color: Colors.black)),
                  child: Text(
                    "Sign in with SRM Google Account",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'SFUI',
                      fontSize: 20.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              (isLoading == true)
                  ? circularProgress()
                  : Container(
                      height: 0,
                      width: 0,
                    )
            ],
          ),
        ),
      ),
    );
  }
}

// ignore: missing_return
Color _getColorFromHex(String hexColor) {
  hexColor = hexColor.replaceAll("#", "");
  if (hexColor.length == 6) {
    hexColor = "FF" + hexColor;
  }
  if (hexColor.length == 8) {
    return Color(int.parse("0x$hexColor"));
  }
  return Colors.white;
}
