import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:srm/home.dart';
import 'package:srm/progress.dart';
import 'package:pie_chart/pie_chart.dart';
import 'dart:math';
import 'models/classes.dart';
import 'models/user.dart';
import 'Teacher_Classroom.dart';

class Mark_Attendance extends StatefulWidget {
  final String name;
  final Class x;
  Mark_Attendance({this.name, this.x});
  @override
  Stu createState() => Stu();
}

class Stu extends State<Mark_Attendance> {
  bool isLoading = false;
  int present = 0;
  List<String> abs = [];

  List<bool> _selected = List.generate(10000, (i) => false);
  ScrollController bounce = new ScrollController();

  List<User> stu = [];
  Class currentClass;

  String data;
  Future getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String dataIn = prefs.getString("clockin") ?? 'default';
    return dataIn;
  }

  callme() async {
    await Future.delayed(Duration(seconds: 2));
    getData().then((value) => {
          setState(() {
            data = value;
          })
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    callme();

    print(0);
    getat();
    print(1);
  }

  getclass() async {
    DocumentSnapshot doc = await classRef.doc(widget.x.classId).get();
    setState(() {
      currentClass = Class.fromDocument(doc);
      print(currentClass.students.toString());
    });
  }

  getat() {
    setState(() {
      isLoading = true;
    });

    getclass();

    stu = [];
    print(stu.length);
    widget.x.students.forEach((d) async {
      DocumentSnapshot doc = await usersRef.doc(d).get();
      User u = User.fromDocument(doc);
      print(u.displayName);

      setState(() {
        stu.add(u);
      });
    });
    stu.sort((a, b) => a.displayName.compareTo(b.displayName));
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading == true && currentClass == null)
      return Scaffold(
        body: Center(
          child: circularProgress(),
        ),
      );
    else if (isLoading == false && currentClass != null && stu.length > 0)
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
                          "${widget.name}",
                          style: TextStyle(
                            fontSize: 40.0,
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
                Text(""),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.only(top: 12.0),
                              child: Text(
                                "Subject",
                                style: TextStyle(color: Colors.black54),
                              )),
                          Container(
                              width: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.only(top: 10.0),
                              child: Text(
                                "${currentClass.sub}",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold),
                              )),
                          Padding(
                              padding: EdgeInsets.only(top: 12.0),
                              child: Text(
                                "Subject-Code",
                                style: TextStyle(color: Colors.black54),
                              )),
                          Container(
                              width: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.only(top: 10.0),
                              child: SelectableText(
                                "${currentClass.code}",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold),
                              )),
                          Padding(
                              padding: EdgeInsets.only(top: 12.0),
                              child: Text(
                                "Classes Conducted",
                                style: TextStyle(color: Colors.black54),
                              )),
                          Container(
                              width: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.only(top: 10.0),
                              child: Text(
                                "${currentClass.classes}",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold),
                              )),
                          Padding(
                              padding: EdgeInsets.only(top: 12.0),
                              child: Text(
                                "No: of Students Enrolled",
                                style: TextStyle(color: Colors.black54),
                              )),
                          Container(
                              width: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.only(top: 10.0),
                              child: Text(
                                "${widget.x.students.length}",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold),
                              )),
                          Padding(
                              padding: EdgeInsets.only(top: 12.0),
                              child: Text(
                                "No: of Students Present",
                                style: TextStyle(color: Colors.black54),
                              )),
                          Container(
                              width: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.only(top: 10.0),
                              child: Text(
                                "$present",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold),
                              )),
                          (stu.length > 0)
                              ? Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                  child: ListView.builder(
                                      physics: BouncingScrollPhysics(),
                                      controller: bounce,
                                      shrinkWrap: true,
                                      itemCount: stu.length,
                                      itemBuilder: (context, int index) {
                                        return GestureDetector(
                                          child: Container(
                                            margin: EdgeInsets.fromLTRB(
                                                15, 0, 15, 5),
                                            child: Card(
                                              color: (_selected[index] == true)
                                                  ? Colors.green[300]
                                                  : Colors.red[400],
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              10.0))),
                                              borderOnForeground: true,
                                              elevation: 5.0,
                                              child: ListTile(
                                                onTap: () {
                                                  Map<String, double> dataMap =
                                                      new Map();
                                                  List<Color> colorlist = [
                                                    Colors.green,
                                                    Colors.red
                                                  ];

                                                  setState(() {
                                                    dataMap.putIfAbsent(
                                                        "Present",
                                                        () => (currentClass
                                                                    .attendance[
                                                                stu[index].reg])
                                                            .toDouble());
                                                    dataMap.putIfAbsent(
                                                        "Absent",
                                                        () => (currentClass
                                                                    .classes -
                                                                currentClass
                                                                        .attendance[
                                                                    stu[index]
                                                                        .reg])
                                                            .toDouble());
                                                  });

                                                  showModalBottomSheet(
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          30.0),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          30.0))),
                                                      context: context,
                                                      builder:
                                                          (BuildContext c) {
                                                        return Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
                                                          children: <Widget>[
                                                            Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: <
                                                                    Widget>[
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets.fromLTRB(
                                                                            0,
                                                                            15,
                                                                            0,
                                                                            0),
                                                                    child: Text(
                                                                      "Classes Conducted",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              20,
                                                                          fontFamily:
                                                                              'SFUI',
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets.fromLTRB(
                                                                            0,
                                                                            15,
                                                                            0,
                                                                            0),
                                                                    child: Text(
                                                                      "${currentClass.classes}",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              50,
                                                                          fontFamily:
                                                                              'SFUI',
                                                                          fontWeight:
                                                                              FontWeight.w400),
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets.fromLTRB(
                                                                            0,
                                                                            15,
                                                                            0,
                                                                            0),
                                                                    child: Text(
                                                                      "Classes Attended",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              20,
                                                                          fontFamily:
                                                                              'SFUI',
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets.fromLTRB(
                                                                            0,
                                                                            15,
                                                                            0,
                                                                            0),
                                                                    child: Text(
                                                                      "${currentClass.attendance[stu[index].reg]}",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              50,
                                                                          fontFamily:
                                                                              'SFUI',
                                                                          fontWeight:
                                                                              FontWeight.w400),
                                                                    ),
                                                                  ),
                                                                ]),
                                                            SizedBox(
                                                              width: 0,
                                                              child: Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .fromLTRB(
                                                                            0,
                                                                            35,
                                                                            0,
                                                                            35),
                                                                child:
                                                                    VerticalDivider(
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                              ),
                                                            ),
                                                            PieChart(
                                                              chartValueBackgroundColor:
                                                                  Colors.grey,
                                                              chartRadius:
                                                                  MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.27,
                                                              chartType:
                                                                  ChartType
                                                                      .disc,
                                                              dataMap: dataMap,
                                                              animationDuration:
                                                                  Duration(
                                                                      milliseconds:
                                                                          800),
                                                              chartLegendSpacing:
                                                                  32.0,
                                                              showChartValues:
                                                                  true,
                                                              showChartValuesInPercentage:
                                                                  true,
                                                              showLegends: true,
                                                              colorList:
                                                                  colorlist,
                                                              legendPosition:
                                                                  LegendPosition
                                                                      .top,
                                                            ),
                                                          ],
                                                        );
                                                      });
                                                },
                                                leading: Icon(Icons.person,
                                                    size: 40),
                                                title: Text(
                                                    '${stu[index].displayName}',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                subtitle: Text(
                                                    "Attendance : ${(currentClass.attendance[stu[index].reg] * 100 / currentClass.classes).toStringAsFixed(2)} %"),
                                                trailing: Switch(
                                                  value: _selected[index],
                                                  onChanged: (value) {
                                                    setState(() {
                                                      if (value == true)
                                                        present += 1;
                                                      else
                                                        present -= 1;
                                                      _selected[index] = value;
                                                      print(_selected[index]);
                                                    });
                                                  },
                                                  activeTrackColor: Colors
                                                      .lightBlueAccent[900],
                                                  activeColor: Colors.blue[900],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                )
                              : Center(child: Container(width: 20, height: 20)),
                          Container(
                            padding: EdgeInsets.all(16),
                            width: MediaQuery.of(context).size.width,
                            child: RaisedButton(
                              onPressed: () {
                                setState(() {
                                  abs = [];
                                  for (int i = 0; i < stu.length; i++)
                                    if (_selected[i] == false)
                                      abs.add(
                                          "${stu[i].displayName} - ${stu[i].reg}");
                                });

                                if (abs.isEmpty) {
                                  stu.forEach((e) {
                                    classRef.doc(currentClass.classId).update({
                                      'attendance.${e.reg}':
                                          currentClass.attendance[e.reg] + 1,
                                    });
                                  });
                                }

                                if (abs.isNotEmpty) {
                                  abs.forEach((e) {
                                    classRef.doc(currentClass.classId).update({
                                      'attendance.${e.split(" - ")[1]}':
                                          currentClass
                                              .attendance[e.split(" - ")[1]],
                                    });
                                  });
                                }

                                classRef.doc(currentClass.classId).update({
                                  'classes': currentClass.classes + 1,
                                });

                                getat();
                              },
                              child: Text("SUBMIT!!!"),
                              color: Colors.amber[600],
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    else if (isLoading == false && currentClass != null && stu.length == 0)
      return Scaffold(
          resizeToAvoidBottomInset: false,
          body: data == null
              ? circularProgress()
              : Container(
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
                                  "${widget.name}",
                                  style: TextStyle(
                                    fontSize: 40.0,
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
                            padding: EdgeInsets.only(top: 12.0),
                            child: Text(
                              "Subject",
                              style: TextStyle(color: Colors.black54),
                            )),
                        Padding(
                            padding: EdgeInsets.only(top: 10.0),
                            child: Text(
                              "${currentClass.sub}",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold),
                            )),
                        Padding(
                            padding: EdgeInsets.only(top: 12.0),
                            child: Text(
                              "Subject-Code",
                              style: TextStyle(color: Colors.black54),
                            )),
                        Padding(
                            padding: EdgeInsets.only(top: 10.0),
                            child: SelectableText(
                              "${currentClass.code}",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold),
                            )),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.25,
                          child: Center(
                              child: Text("NO STUDENTS ENROLLED",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 40))),
                        )
                      ],
                    ),
                  ),
                ));
    else
      return Scaffold(
        body: Center(
          child: circularProgress(),
        ),
      );
  }
}
