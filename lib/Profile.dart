import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:srm/home.dart';
import 'package:srm/progress.dart';

import 'models/classes.dart';
import 'models/user.dart';

class profile extends StatefulWidget {
  @override
  _profileState createState() => _profileState();
}

class _profileState extends State<profile> {
  bool isEdit = false;
  bool isLoading = false;
  List<String> c = [];
  @override
  void initState() {
    super.initState();

    getu();
  }

  String dropdownValue = currentUser.des;
  String dropdownValue1 = currentUser.branch.split("-")[0];
  String dropdownValue2 = currentUser.branch.split("-")[1];
  String dropdownValue3 = currentUser.year;
  String dropdownValue4 = currentUser.sem;

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

  String mob = currentUser.mobile;

  submit() async {
    usersRef.doc(currentUser?.reg).update({
      "mobile": mob,
      "des": dropdownValue,
      "year": dropdownValue3,
      "sem": dropdownValue4,
      "branch": dropdownValue1 + "-" + dropdownValue2,
    });

    DocumentSnapshot doc = await usersRef.doc(currentUser?.reg).get();

    currentUser = User.fromDocument(doc);

    setState(() {
      isEdit = false;
    });

    getu();
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

  getu() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await usersRef.doc(currentUser?.reg).get();

    currentUser = User.fromDocument(doc);

    c = [];

    currentUser.classes.forEach((d) async {
      DocumentSnapshot doc = await classRef.doc(d).get();

      Class cl = Class.fromDocument(doc);
      print("Sybject:" + cl.sub);
      setState(() {
        c.add(cl.sub);
      });
      print(c.toString());
    });

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isEdit == true)
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
                            "Edit Profile",
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
                  Container(
                    child: Column(
                      children: <Widget>[
                        (currentUser?.des == "Student")
                            ? Column(
                                children: [
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
                                        dropdownColor:
                                            _getColorFromHex("#f0f4ff"),
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
                                        items: year()
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
                                        dropdownColor:
                                            _getColorFromHex("#f0f4ff"),
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
                                        items: sem()
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
                                onChanged: (val) {
                                  setState(() {
                                    mob = val;
                                  });
                                },
                                initialValue: mob,
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
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 1.0),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 1.0),
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
                            if (mob == "")
                              fun1();
                            else if (mob.length != 10)
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
                                "Save Details",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                        Container(height: 50),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isEdit = false;
                            });
                          },
                          child: Container(
                            height: 50.0,
                            width: 200.0,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(7.0),
                            ),
                            child: Center(
                              child: Text(
                                "No Changes",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(height: 30)
                ],
              ),
            ),
          ));
    else if (isLoading == true && isEdit == false)
      return Scaffold(body: Center(child: circularProgress()));
    else if (isLoading == false && isEdit == false)
      return Scaffold(
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
                          "Profile",
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
                Row(
                  children: [
                    FlatButton(
                      child: Icon(Icons.edit, size: 30),
                      onPressed: () {
                        setState(() {
                          isEdit = true;
                        });
                      },
                    ),
                  ],
                  mainAxisAlignment: MainAxisAlignment.end,
                ),
                Column(
                  children: <Widget>[
                    Container(
                      child: Column(
                        children: <Widget>[
                          Center(
                              child: Container(
                            height: 210,
                            width: 190,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(100.0),
                                  bottomRight: Radius.circular(100.0),
                                  topLeft: Radius.circular(100.0),
                                  topRight: Radius.circular(100.0)),
                              gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.amber, Colors.red],
                                  stops: [0.0, 1.0]),
                            ),
                            padding: EdgeInsets.all(16),
                            child: GestureDetector(
                              child: CircleAvatar(
                                  radius: 150.0,
                                  backgroundColor: Colors.transparent,
                                  child: Icon(Icons.person,
                                      color: Colors.black, size: 150)),
                              onTap: () {},
                            ),
                          )),
                          Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              children: <Widget>[
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Padding(
                                              padding:
                                                  EdgeInsets.only(top: 12.0),
                                              child: Text(
                                                "Name",
                                                style: TextStyle(
                                                    color: Colors.black54),
                                              )),
                                          Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              padding:
                                                  EdgeInsets.only(top: 10.0),
                                              child: Text(
                                                "${(currentUser?.des == "Teacher") ? "Prof." + currentUser.displayName.split(" ")[0] : currentUser.displayName.split(" ")[0]}",
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 20.0,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ))
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Padding(
                                              padding:
                                                  EdgeInsets.only(top: 12.0),
                                              child: Text(
                                                "Reg",
                                                style: TextStyle(
                                                    color: Colors.black54),
                                              )),
                                          Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              padding:
                                                  EdgeInsets.only(top: 10.0),
                                              child: Text(
                                                "${currentUser?.reg}",
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 20.0,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ))
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                (currentUser?.des == "Student")
                                    ? Row(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 12.0),
                                                    child: Text(
                                                      "Branch",
                                                      style: TextStyle(
                                                          color:
                                                              Colors.black54),
                                                    )),
                                                Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            3,
                                                    padding: EdgeInsets.only(
                                                        top: 10.0),
                                                    child: Text(
                                                      "${currentUser?.branch}",
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 20.0,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ))
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                              flex: 1,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 12.0),
                                                      child: Text(
                                                        "Year / Semester",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black54),
                                                      )),
                                                  Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              3,
                                                      padding: EdgeInsets.only(
                                                          top: 10.0),
                                                      child: Text(
                                                        "${currentUser?.year}  /  ${currentUser?.sem}",
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 20.0,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ))
                                                ],
                                              )),
                                        ],
                                      )
                                    : Container(width: 0, height: 0),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                        padding: EdgeInsets.only(top: 12.0),
                                        child: Text(
                                          "No. of Classes Enrolled",
                                          style:
                                              TextStyle(color: Colors.black54),
                                        )),
                                    Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        padding: EdgeInsets.only(top: 10.0),
                                        child: Text(
                                          "${currentUser.classes.length}",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.bold),
                                        ))
                                  ],
                                ),
                                Container(
                                    child: ListTile(
                                        leading: Icon(Icons.mail),
                                        title: Text("${currentUser?.email}")),
                                    height: 30),
                                Container(
                                    child: ListTile(
                                        leading: Icon(Icons.call),
                                        title: Text("${currentUser?.mobile}")),
                                    height: 30),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    else
      return circularProgress();
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
