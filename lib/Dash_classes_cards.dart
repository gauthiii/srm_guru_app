import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:srm/progress.dart';
import 'package:uuid/uuid.dart';

import 'Student_Classroom.dart';
import 'Teacher_Classroom.dart';
import 'home.dart';
import 'models/classes.dart';
import 'models/user.dart';

class Dash_class_card extends StatefulWidget {
  @override
  _Dash_class_cardState createState() => _Dash_class_cardState();
}

class _Dash_class_cardState extends State<Dash_class_card> {
  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();

  TextEditingController sub = TextEditingController();
  final items = List<String>.generate(20, (i) => "Item ${i + 1}");
  ScrollController bouncecontrol = new ScrollController();
  ScrollController bouncecontrol1 = new ScrollController();

  // List<bool> _selected = List.generate(20, (i) => true);

  List<Class> classes = [];

  List<String> codes = [];
  List<String> ids = [];
  @override
  void initState() {
    super.initState();

    getc();
  }

  getc() async {
    classes = [];
    codes = [];
    ids = [];

    setState(() {
      isLoading = true;
    });

    DocumentSnapshot doc = await usersRef.doc(currentUser?.reg).get();
    currentUser = User.fromDocument(doc);

    currentUser.classes.forEach((e) async {
      DocumentSnapshot doc1 = await classRef.doc(e).get();
      setState(() {
        classes.add(Class.fromDocument(doc1));
      });
    });

    QuerySnapshot snapshot =
        await classRef.orderBy('timestamp', descending: true).get();

    snapshot.docs.forEach((doc) {
      setState(() {
        Class c = Class.fromDocument(doc);
        codes.add(c.code);
        ids.add(c.classId);
      });
    });

    classes.sort((a, b) => a.sub.compareTo(b.sub));

    setState(() {
      isLoading = false;
    });
  }

  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  create() {
    if (currentUser?.des == "Teacher")
      create1();
    else
      join();

    sub.clear();
  }

  leave(String x, List<dynamic> students, Map n, Map ct1, Map ct2, Map ct3,
      Map st, Map as) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            backgroundColor: Colors.white,
            actions: [
              FlatButton(
                child: Text("Yes", style: TextStyle(color: Colors.blue)),
                onPressed: () async {
                  if (currentUser?.des == "Student") {
                    print(n);
                    currentUser.classes.remove(x);
                    students.remove(currentUser?.reg);
                    n.remove(currentUser.reg);
                    ct1.remove(currentUser.reg);
                    ct2.remove(currentUser.reg);
                    ct3.remove(currentUser.reg);
                    st.remove(currentUser.reg);
                    as.remove(currentUser.reg);

                    classRef.doc(x).update({
                      "students": students,
                      'attendance': n,
                      "ct1": ct1,
                      "ct2": ct2,
                      "ct3": ct3,
                      "st": st,
                      "as": as
                    });

                    usersRef
                        .doc(currentUser?.reg)
                        .update({"classes": currentUser?.classes});

                    Navigator.pop(context);
                    getc();
                  } else {
                    currentUser.classes.remove(x);

                    usersRef
                        .doc(currentUser.reg)
                        .update({"classes": currentUser.classes});

                    classRef.doc(x).get().then((doc) {
                      if (doc.exists) {
                        doc.reference.delete();
                      }
                    });

                    students.forEach((id) async {
                      DocumentSnapshot doc = await usersRef.doc(id).get();
                      User u = User.fromDocument(doc);

                      if (u.classes.contains(x)) u.classes.remove(x);

                      usersRef.doc(id).update({"classes": u.classes});
                    });

                    Navigator.pop(context);
                    getc();
                  }
                },
              ),
              FlatButton(
                child: Text("Cancel", style: TextStyle(color: Colors.red)),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
            title: new Text(
                (currentUser?.des == "Student")
                    ? "Are you sure you want to leave this class?"
                    : "Are you sure you want to delete this class?",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
          );
        });
  }

  join() {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            backgroundColor: Colors.white,
            actions: [
              FlatButton(
                child: Text("Join", style: TextStyle(color: Colors.blue)),
                onPressed: () async {
                  int x = codes.indexOf(sub.text);

                  if (x != -1) {
                    currentUser.classes.add(ids[x]);

                    usersRef.doc(currentUser?.reg).update({
                      "classes": FieldValue.arrayUnion(currentUser.classes)
                    });

                    DocumentSnapshot doc = await classRef.doc(ids[x]).get();
                    Class p = Class.fromDocument(doc);
                    print("Students : " + p.students.toString());
                    p.students.add(currentUser.reg);

                    classRef.doc(ids[x]).update({
                      "students": FieldValue.arrayUnion(p.students),
                      'attendance.${currentUser.reg}': 0
                    });

                    Navigator.pop(context);
                    getc();
                    showDialog(
                        context: context,
                        builder: (_) {
                          return AlertDialog(
                              backgroundColor: Colors.white,
                              title: Text("New Class Joined"));
                        });
                  } else {
                    Navigator.pop(context);
                    showDialog(
                        context: context,
                        builder: (_) {
                          return AlertDialog(
                              backgroundColor: Colors.white,
                              title: Text("Class Not Found"));
                        });
                  }
                },
              ),
              FlatButton(
                child: Text("Cancel", style: TextStyle(color: Colors.red)),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
            title: new Text("Enter Subject Code",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            content: Container(
              height: 120,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Container(
                      child: TextFormField(
                        controller: sub,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Subject Code",
                          labelStyle: TextStyle(fontSize: 15.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  create1() {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            backgroundColor: Colors.white,
            actions: [
              FlatButton(
                child: Text("Create", style: TextStyle(color: Colors.blue)),
                onPressed: () {
                  if (sub.text.trim().isNotEmpty) {
                    final DateTime ts = DateTime.now();
                    String cid = Uuid().v4();
                    classRef.doc(cid).set({
                      "classId": cid,
                      "teacherId": currentUser?.reg,
                      "code": getRandomString(8),
                      "sub": sub.text,
                      "classes": 0,
                      "attendance": {},
                      "ct1": {},
                      "ct2": {},
                      "ct3": {},
                      "st": {},
                      "as": {},
                      "students": [],
                      "announcements": [],
                      "assignments": [],
                      "notes": [],
                      "timestamp": ts
                    });

                    setState(() {
                      currentUser?.classes?.add(cid);
                    });

                    usersRef.doc(currentUser?.reg).update({
                      "classes": FieldValue.arrayUnion(currentUser.classes)
                    });

                    Navigator.pop(context);
                    getc();
                  } else {
                    Navigator.pop(context);

                    showDialog(
                        context: context,
                        builder: (_) {
                          return AlertDialog(
                              backgroundColor: Colors.white,
                              title: Text("Subject musn't be Empty"));
                        });
                  }
                },
              ),
              FlatButton(
                child: Text("Cancel", style: TextStyle(color: Colors.red)),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
            title: new Text("Enter Subject Name",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            content: Container(
              height: 120,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Container(
                      child: TextFormField(
                        controller: sub,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Subject Name",
                          labelStyle: TextStyle(fontSize: 15.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  miss(int total, int present) {
    int c = 1;

    if ((present / total) < 0.75) {
      while ((present / total) < 0.75) {
        if (((present + c) / (total + c)) >= 0.75)
          break;
        else
          c = c + 1;
      }
    } else if ((present / total) > 0.75) {
      while ((present / total) > 0.75) {
        if ((present / (total + c)) <= 0.75)
          break;
        else
          c = c + 1;
      }
    } else if ((present / total) == 0.75) {
      c = 0;
    }
    return c;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading == true)
      return circularProgress();
    else if (isLoading == false && currentUser.classes.length == 0)
      return Container(
        padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
        height: MediaQuery.of(context).size.height * 0.7,
        child: Card(
          elevation: 10,
          color: Colors.amber,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(25, 12, 15, 5),
                  child: Text(
                    "Classes",
                    style: TextStyle(
                        fontSize: 30.0,
                        fontFamily: 'SFUI',
                        fontWeight: FontWeight.w400),
                  ),
                ),
                Column(
                  children: [
                    Center(
                        child: Text("\n",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 35))),
                    Center(
                        child: Icon(Icons.block_rounded,
                            color: Colors.black, size: 150)),
                    Center(
                        child: Text("\nNo Classes\n",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 35))),
                    Container(
                        margin: EdgeInsets.all(15.0),
                        child: Card(
                            color: Colors.black,
                            shape: StadiumBorder(),
                            elevation: 10.0,
                            child: ListTile(
                              onTap: () {
                                create();
                              },
                              leading: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Text(
                                  (currentUser?.des == "Student")
                                      ? "Join Classroom"
                                      : "Create Classroom",
                                  style: TextStyle(
                                      fontSize: 20.0,
                                      fontFamily: 'SFUI',
                                      color: Colors.white,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                              trailing: Icon(
                                Icons.add,
                                color: Colors.white,
                              ),
                            ))),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    else if (isLoading == false && currentUser.classes.length > 0)
      return Container(
        padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
        height: MediaQuery.of(context).size.height * 0.7,
        child: Card(
          elevation: 10,
          color: Colors.amber,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(25, 12, 15, 5),
                child: Text(
                  "Classes",
                  style: TextStyle(
                      fontSize: 30.0,
                      fontFamily: 'SFUI',
                      fontWeight: FontWeight.w400),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                // padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    controller: bouncecontrol,
                    itemCount: classes.length,
                    itemBuilder: (context, int index) {
                      Map<String, double> dataMap = new Map();
                      List<Color> colorlist = [Colors.green, Colors.red];
                      if (currentUser?.des == "Student") {
                        dataMap.putIfAbsent(
                            "Present",
                            () => (classes[index].attendance[currentUser?.reg])
                                .toDouble());
                        dataMap.putIfAbsent(
                            "Absent",
                            () => (classes[index].classes -
                                    classes[index].attendance[currentUser.reg])
                                .toDouble());
                      }
                      return GestureDetector(
                        onLongPress: () {
                          if (currentUser?.des == "Student")
                            showModalBottomSheet(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(30.0),
                                        topRight: Radius.circular(30.0))),
                                context: context,
                                builder: (BuildContext c) {
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 15, 0, 0),
                                              child: Text(
                                                "Classes Conducted",
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontFamily: 'SFUI',
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 15, 0, 0),
                                              child: Text(
                                                "${classes[index].classes}",
                                                style: TextStyle(
                                                    fontSize: 50,
                                                    fontFamily: 'SFUI',
                                                    fontWeight:
                                                        FontWeight.w400),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 15, 0, 0),
                                              child: Text(
                                                "Classes Attended",
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontFamily: 'SFUI',
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 15, 0, 0),
                                              child: Text(
                                                "${classes[index].attendance[currentUser?.reg]}",
                                                style: TextStyle(
                                                    fontSize: 50,
                                                    fontFamily: 'SFUI',
                                                    fontWeight:
                                                        FontWeight.w400),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 15, 0, 0),
                                              child: Text(
                                                (classes[index].attendance[
                                                                currentUser
                                                                    .reg] /
                                                            classes[index]
                                                                .classes >=
                                                        0.75)
                                                    ? "You Can Miss"
                                                    : "You Need",
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontFamily: 'SFUI',
                                                    color: (classes[index]
                                                                        .attendance[
                                                                    currentUser
                                                                        .reg] /
                                                                classes[index]
                                                                    .classes >=
                                                            0.75)
                                                        ? Colors.black
                                                        : Colors.red,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 15, 0, 0),
                                              child: Text(
                                                "${miss(classes[index].classes, classes[index].attendance[currentUser.reg])}",
                                                style: TextStyle(
                                                    fontSize: 50,
                                                    fontFamily: 'SFUI',
                                                    color: (classes[index]
                                                                        .attendance[
                                                                    currentUser
                                                                        .reg] /
                                                                classes[index]
                                                                    .classes >=
                                                            0.75)
                                                        ? Colors.black
                                                        : Colors.red,
                                                    fontWeight:
                                                        FontWeight.w400),
                                              ),
                                            )
                                          ]),
                                      SizedBox(
                                        width: 0,
                                        child: Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 35, 0, 35),
                                          child: VerticalDivider(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      PieChart(
                                        chartValueBackgroundColor: Colors.grey,
                                        chartRadius:
                                            MediaQuery.of(context).size.width *
                                                0.27,
                                        chartType: ChartType.disc,
                                        dataMap: dataMap,
                                        animationDuration:
                                            Duration(milliseconds: 800),
                                        chartLegendSpacing: 32.0,
                                        showChartValues: true,
                                        showChartValuesInPercentage: true,
                                        showLegends: true,
                                        colorList: colorlist,
                                        legendPosition: LegendPosition.top,
                                      ),
                                    ],
                                  );
                                });
                        },
                        child: SizedBox(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(10, 5, 10, 0),
                            child: Card(
                              // for teacher's attendance -> color: _selected[index] ? null : Colors.red[100],
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0))),
                              borderOnForeground: true,
                              elevation: 5.0,
                              child: ListTile(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          (currentUser?.des == "Teacher")
                                              ? Teacher_Classroom(
                                                  className: classes[index],
                                                )
                                              : Student_Classroom(
                                                  className: classes[index],
                                                ),
                                    ),
                                  );
                                },
                                leading: FlutterLogo(),
                                title: Text('${classes[index].sub}'),
                                subtitle: Text((currentUser.des == "Student")
                                    ? "Attendance : ${(classes[index].attendance[currentUser.reg] * 100 / classes[index].classes).toStringAsFixed(2)} %"
                                    : "No. of Students : ${classes[index].students.length}"),
                                trailing: IconButton(
                                    icon: Icon(Icons.more_vert),
                                    onPressed: () {
                                      leave(
                                        classes[index].classId,
                                        classes[index].students,
                                        classes[index].attendance,
                                        classes[index].ct1,
                                        classes[index].ct2,
                                        classes[index].ct3,
                                        classes[index].st,
                                        classes[index].as,
                                      );
                                    }),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
              ),
              Container(
                  margin: EdgeInsets.all(15.0),
                  child: Card(
                      color: Colors.black,
                      shape: StadiumBorder(),
                      elevation: 10.0,
                      child: ListTile(
                        onTap: () {
                          create();
                        },
                        leading: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            (currentUser?.des == "Student")
                                ? "Join Classroom"
                                : "Create Classroom",
                            style: TextStyle(
                                fontSize: 20.0,
                                fontFamily: 'SFUI',
                                color: Colors.white,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                        trailing: Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                      ))),
            ],
          ),
        ),
      );
    else
      return circularProgress();
  }
}
