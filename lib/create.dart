import 'dart:async';

import 'package:flutter/material.dart';
import 'package:srm/progress.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
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
    if (dropdownValue1 == "B.Tech")
      return ["1", "2", "3", "4", "5", "6", "7", "8"];
    else
      return ["1", "2", "3", "4", "5", "6"];
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

  String username = "";

  submit() {
    username = mob.text +
        "|" +
        dropdownValue +
        "|" +
        dropdownValue1 +
        "|" +
        dropdownValue2 +
        "|" +
        dropdownValue3 +
        "|" +
        dropdownValue4;

    Navigator.pop(context, username);
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

    Navigator.pop(context);
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

  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _getColorFromHex("#f0f4ff"),
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        /*   leading: GestureDetector(
          child: Icon(Icons.arrow_back),
          onTap: () {
            Navigator.pop(context);
          },
        ),*/
        automaticallyImplyLeading: false,
        title: Text(
          "Enter the following the details",
          style: TextStyle(),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(8),
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
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
                                ].map<DropdownMenuItem<String>>((String value) {
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
                                items: branch().map<DropdownMenuItem<String>>(
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
                    else
                      submit();
                  },
                  child: Container(
                    height: 50.0,
                    width: 350.0,
                    decoration: BoxDecoration(
                      color: Colors.black,
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
              ],
            ),
          )
        ],
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
