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

class Student extends StatefulWidget {
  final Class x;
  Student({this.x});
  @override
  Stu createState() => Stu();
}

class Stu extends State<Student> {
  bool isLoading = false;
  bool isEdit = false;

  ScrollController bouncecontrol = new ScrollController();

  List<User> stu;
  User user = User();
  Class currentClass;

  int cl;
  double ct1;
  double ct2;
  double ct3;
  double st;
  double as;
  bool isSubmit = true;

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
    getat();
  }

  getat() async {
    setState(() {
      isLoading = true;
    });

    stu = [];

    DocumentSnapshot doc = await classRef.doc(widget.x.classId).get();
    setState(() {
      currentClass = Class.fromDocument(doc);
    });

    currentClass.students.forEach((d) async {
      DocumentSnapshot doc = await usersRef.doc(d).get();
      User u = User.fromDocument(doc);

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
    if (isLoading == true)
      return Scaffold(
        body: Center(
          child: circularProgress(),
        ),
      );
    else if (stu.length > 0)
      return Scaffold(
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 100, 15, 15),
                  child: Card(
                    elevation: 10,
                    color: Colors.indigo[200],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    child: SingleChildScrollView(
                      child: (isEdit == false)
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.fromLTRB(25, 12, 15, 5),
                                  child: Text(
                                    "Student Information",
                                    style: TextStyle(
                                        fontSize: 30.0,
                                        fontFamily: 'SFUI',
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                                Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.6,
                                  padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                  child: ListView.builder(
                                      physics: BouncingScrollPhysics(),
                                      controller: bouncecontrol,
                                      itemCount: stu.length,
                                      itemBuilder: (context, int index) {
                                        bool isPredicted = false;
                                        String t = "Predict final Marks";
                                        var s = 51.0;
                                        if (currentClass
                                                    .ct1[stu[index].reg] !=
                                                null &&
                                            currentClass
                                                    .ct2[stu[index].reg] !=
                                                null &&
                                            currentClass.ct3[stu[index].reg] !=
                                                null &&
                                            currentClass.st[stu[index].reg] !=
                                                null &&
                                            currentClass.as[stu[index].reg] !=
                                                null)
                                          s = currentClass.ct1[stu[index].reg] +
                                              currentClass.ct2[stu[index].reg] +
                                              currentClass.ct3[stu[index].reg] +
                                              currentClass.st[stu[index].reg] +
                                              currentClass.as[stu[index].reg];
                                        return GestureDetector(
                                            onLongPress: () {},
                                            child: SizedBox(
                                              child: Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    10, 5, 10, 0),
                                                child: Card(
                                                    // for teacher's attendance -> color: _selected[index] ? null : Colors.red[100],
                                                    color: Colors.white,
                                                    borderOnForeground: true,
                                                    elevation: 5.0,
                                                    child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius: BorderRadius.only(
                                                              topRight: Radius
                                                                  .circular(
                                                                      40.0),
                                                              bottomRight: Radius
                                                                  .circular(
                                                                      40.0),
                                                              topLeft: Radius
                                                                  .circular(
                                                                      40.0),
                                                              bottomLeft: Radius
                                                                  .circular(
                                                                      40.0)),
                                                        ),
                                                        child: SizedBox(
                                                            child: Column(
                                                          children: [
                                                            ListTile(
                                                                leading: Image.asset(
                                                                    'assets/open-book.png',
                                                                    height: 35),
                                                                title: Text(
                                                                    "${stu[index].displayName}",
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold)),
                                                                trailing:
                                                                    IconButton(
                                                                        onPressed:
                                                                            () {
                                                                          setState(
                                                                              () {
                                                                            isEdit =
                                                                                true;
                                                                            user =
                                                                                stu[index];
                                                                            cl =
                                                                                currentClass.attendance[user.reg];
                                                                            ct1 =
                                                                                currentClass.ct1[user.reg];
                                                                            ct2 =
                                                                                currentClass.ct2[user.reg];
                                                                            ct3 =
                                                                                currentClass.ct3[user.reg];
                                                                            st =
                                                                                currentClass.st[user.reg];
                                                                            as =
                                                                                currentClass.as[user.reg];
                                                                          });
                                                                        },
                                                                        icon: Icon(Icons.edit,
                                                                            color: Colors
                                                                                .black)),
                                                                subtitle: Text(
                                                                    "${stu[index].reg}",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .grey))),
                                                            Center(
                                                                child: Text(
                                                                    "${(currentClass.attendance[stu[index].reg] == null) ? "NA" : currentClass.attendance[stu[index].reg]} classes attended out of ${currentClass.classes} : ${(currentClass.attendance[stu[index].reg] * 100 / currentClass.classes).toStringAsFixed(2)} %")),
                                                            Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(10),
                                                              child: Table(
                                                                border: TableBorder.all(
                                                                    color: Colors
                                                                        .black,
                                                                    style: BorderStyle
                                                                        .solid,
                                                                    width: 2),
                                                                children: [
                                                                  TableRow(
                                                                      children: [
                                                                        TableCell(
                                                                          child:
                                                                              SizedBox(
                                                                            height:
                                                                                30,
                                                                            child:
                                                                                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                                                              Text('CT1/10', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.0))
                                                                            ]),
                                                                          ),
                                                                        ),
                                                                        TableCell(
                                                                          child:
                                                                              SizedBox(
                                                                            height:
                                                                                30,
                                                                            child:
                                                                                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                                                              Text('CT2/15', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.0))
                                                                            ]),
                                                                          ),
                                                                        ),
                                                                        TableCell(
                                                                          child:
                                                                              SizedBox(
                                                                            height:
                                                                                30,
                                                                            child:
                                                                                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                                                              Text('CT3/15', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.0))
                                                                            ]),
                                                                          ),
                                                                        ),
                                                                        TableCell(
                                                                          child:
                                                                              SizedBox(
                                                                            height:
                                                                                30,
                                                                            child:
                                                                                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                                                              Text('ST/5', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.0))
                                                                            ]),
                                                                          ),
                                                                        ),
                                                                        TableCell(
                                                                          child:
                                                                              SizedBox(
                                                                            height:
                                                                                30,
                                                                            child:
                                                                                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                                                              Text('AS/5', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.0))
                                                                            ]),
                                                                          ),
                                                                        ),
                                                                        TableCell(
                                                                          child:
                                                                              SizedBox(
                                                                            height:
                                                                                30,
                                                                            child:
                                                                                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                                                              Text('TOT/50', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.0))
                                                                            ]),
                                                                          ),
                                                                        ),
                                                                      ]),
                                                                  TableRow(
                                                                      children: [
                                                                        TableCell(
                                                                          child:
                                                                              SizedBox(
                                                                            height:
                                                                                50,
                                                                            child:
                                                                                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                                                              Text('${(currentClass.ct1[stu[index].reg] == null) ? "NA" : currentClass.ct1[stu[index].reg]}', style: TextStyle(fontSize: 17.0))
                                                                            ]),
                                                                          ),
                                                                        ),
                                                                        TableCell(
                                                                          child:
                                                                              SizedBox(
                                                                            height:
                                                                                50,
                                                                            child:
                                                                                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                                                              Text('${(currentClass.ct2[stu[index].reg] == null) ? "NA" : currentClass.ct2[stu[index].reg]}', style: TextStyle(fontSize: 17.0))
                                                                            ]),
                                                                          ),
                                                                        ),
                                                                        TableCell(
                                                                          child:
                                                                              SizedBox(
                                                                            height:
                                                                                50,
                                                                            child:
                                                                                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                                                              Text('${(currentClass.ct3[stu[index].reg] == null) ? "NA" : currentClass.ct3[stu[index].reg]}', style: TextStyle(fontSize: 17.0))
                                                                            ]),
                                                                          ),
                                                                        ),
                                                                        TableCell(
                                                                          child:
                                                                              SizedBox(
                                                                            height:
                                                                                50,
                                                                            child:
                                                                                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                                                              Text('${(currentClass.st[stu[index].reg] == null) ? "NA" : currentClass.st[stu[index].reg]}', style: TextStyle(fontSize: 17.0))
                                                                            ]),
                                                                          ),
                                                                        ),
                                                                        TableCell(
                                                                          child:
                                                                              SizedBox(
                                                                            height:
                                                                                50,
                                                                            child:
                                                                                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                                                              Text('${(currentClass.as[stu[index].reg] == null) ? "NA" : currentClass.as[stu[index].reg]}', style: TextStyle(fontSize: 17.0))
                                                                            ]),
                                                                          ),
                                                                        ),
                                                                        TableCell(
                                                                          child:
                                                                              SizedBox(
                                                                            height:
                                                                                50,
                                                                            child:
                                                                                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                                                              Text('${(s == 51.0) ? "NA" : s}', style: TextStyle(fontSize: 17.0))
                                                                            ]),
                                                                          ),
                                                                        ),
                                                                      ]),
                                                                ],
                                                              ),
                                                            ),
                                                            ListTile(
                                                                onTap: () {
                                                                  showDialog(
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (_) {
                                                                        return AlertDialog(
                                                                            backgroundColor: Colors
                                                                                .white,
                                                                            title: Text((s != 51.0)
                                                                                ? "${stu[index].displayName} will score ${s * 2} in the finals"
                                                                                : "Marks can't be predicted until all columns are updated"));
                                                                      });
                                                                },
                                                                leading: Icon(
                                                                    Icons
                                                                        .autorenew,
                                                                    color:
                                                                        Colors.red[
                                                                            900]),
                                                                title: Text(t,
                                                                    style: TextStyle(
                                                                        color: Colors.red[
                                                                            900],
                                                                        fontSize:
                                                                            15,
                                                                        fontWeight:
                                                                            FontWeight.bold)))
                                                          ],
                                                        )))),
                                              ),
                                            ));
                                      }),
                                ),
                                Text("")
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.fromLTRB(25, 12, 15, 5),
                                  child: Text(
                                    "Update Information",
                                    style: TextStyle(
                                        fontSize: 30.0,
                                        fontFamily: 'SFUI',
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(10, 5, 10, 0),
                                    child: Card(
                                      // for teacher's attendance -> color: _selected[index] ? null : Colors.red[100],
                                      color: Colors.white,
                                      borderOnForeground: true,
                                      elevation: 5.0,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(40.0),
                                              bottomRight:
                                                  Radius.circular(40.0),
                                              topLeft: Radius.circular(40.0),
                                              bottomLeft:
                                                  Radius.circular(40.0)),
                                        ),
                                        child: Container(
                                          child: Column(children: [
                                            ListTile(
                                                leading: Image.asset(
                                                    'assets/open-book.png',
                                                    height: 35),
                                                title: Text(
                                                    "${user.displayName}",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                trailing: IconButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        isEdit = false;
                                                        Map<String, dynamic> x =
                                                            {
                                                          "attendance.${user.reg}":
                                                              cl,
                                                          "ct1.${user.reg}":
                                                              ct1,
                                                          "ct2.${user.reg}":
                                                              ct2,
                                                          "ct3.${user.reg}":
                                                              ct3,
                                                          "st.${user.reg}": st,
                                                          "as.${user.reg}": as,
                                                        };

                                                        if (isSubmit == false)
                                                          print("cant submit");
                                                        else {
                                                          if (cl == null)
                                                            x.remove(
                                                                "attendance.${user.reg}");
                                                          if (ct1 == null)
                                                            x.remove(
                                                                "ct1.${user.reg}");
                                                          if (ct2 == null)
                                                            x.remove(
                                                                "ct2.${user.reg}");
                                                          if (ct3 == null)
                                                            x.remove(
                                                                "ct3.${user.reg}");
                                                          if (st == null)
                                                            x.remove(
                                                                "st.${user.reg}");
                                                          if (as == null)
                                                            x.remove(
                                                                "as.${user.reg}");

                                                          print(x.toString());

                                                          classRef
                                                              .doc(currentClass
                                                                  .classId)
                                                              .update(x);
                                                        }

                                                        data = null;
                                                        callme();
                                                        getat();
                                                      });
                                                    },
                                                    icon: Icon(Icons.check,
                                                        size: 30,
                                                        color: Colors.black)),
                                                subtitle: Text("${user.reg}",
                                                    style: TextStyle(
                                                        color: Colors.grey))),
                                            Padding(
                                                padding: EdgeInsets.all(16.0),
                                                child: Text(
                                                    "Total number of classes : ${currentClass.classes}")),
                                            Padding(
                                              padding: EdgeInsets.all(16.0),
                                              child: Container(
                                                child: TextFormField(
                                                  onChanged: (val) {
                                                    setState(() {
                                                      if (int.parse(val) >= 0 &&
                                                          int.parse(val) <=
                                                              currentClass
                                                                  .classes)
                                                        cl = int.parse(val);
                                                      else {
                                                        cl = null;
                                                        isSubmit = false;
                                                      }
                                                    });
                                                  },
                                                  initialValue: cl.toString(),
                                                  style: TextStyle(
                                                      fontSize: 15.0,
                                                      color: Colors.black,
                                                      fontFamily:
                                                          "Poppins-Regular"),
                                                  keyboardType:
                                                      TextInputType.number,
                                                  decoration: InputDecoration(
                                                    focusedBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.black,
                                                          width: 1.0),
                                                    ),
                                                    enabledBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.black,
                                                          width: 1.0),
                                                    ),
                                                    labelText:
                                                        "No: of classes attended",
                                                    labelStyle: TextStyle(
                                                        fontSize: 12.0,
                                                        color: Colors.black54,
                                                        fontFamily:
                                                            "Poppins-Regular"),
                                                    hintText:
                                                        "Enter a number <= ${currentClass.classes}",
                                                    hintStyle: TextStyle(
                                                        fontSize: 12.0,
                                                        color: Colors.black54,
                                                        fontFamily:
                                                            "Poppins-Regular"),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(16.0),
                                              child: Container(
                                                child: TextFormField(
                                                  onChanged: (val) {
                                                    setState(() {
                                                      if (double.parse(val) >=
                                                              0 &&
                                                          double.parse(val) <=
                                                              10)
                                                        ct1 = double.parse(val);
                                                      else {
                                                        ct1 = null;
                                                        isSubmit = false;
                                                      }
                                                    });
                                                  },
                                                  initialValue: ct1.toString(),
                                                  style: TextStyle(
                                                      fontSize: 15.0,
                                                      color: Colors.black,
                                                      fontFamily:
                                                          "Poppins-Regular"),
                                                  keyboardType:
                                                      TextInputType.number,
                                                  decoration: InputDecoration(
                                                    focusedBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.black,
                                                          width: 1.0),
                                                    ),
                                                    enabledBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.black,
                                                          width: 1.0),
                                                    ),
                                                    labelText: "CT1",
                                                    labelStyle: TextStyle(
                                                        fontSize: 12.0,
                                                        color: Colors.black54,
                                                        fontFamily:
                                                            "Poppins-Regular"),
                                                    hintText:
                                                        "Enter a value between 0 and 10",
                                                    hintStyle: TextStyle(
                                                        fontSize: 12.0,
                                                        color: Colors.black54,
                                                        fontFamily:
                                                            "Poppins-Regular"),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(16.0),
                                              child: Container(
                                                child: TextFormField(
                                                  onChanged: (val) {
                                                    setState(() {
                                                      if (double.parse(val) >=
                                                              0 &&
                                                          double.parse(val) <=
                                                              15)
                                                        ct2 = double.parse(val);
                                                      else {
                                                        ct2 = null;
                                                        isSubmit = false;
                                                      }
                                                    });
                                                  },
                                                  initialValue: ct2.toString(),
                                                  style: TextStyle(
                                                      fontSize: 15.0,
                                                      color: Colors.black,
                                                      fontFamily:
                                                          "Poppins-Regular"),
                                                  keyboardType:
                                                      TextInputType.number,
                                                  decoration: InputDecoration(
                                                    focusedBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.black,
                                                          width: 1.0),
                                                    ),
                                                    enabledBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.black,
                                                          width: 1.0),
                                                    ),
                                                    labelText: "CT2",
                                                    labelStyle: TextStyle(
                                                        fontSize: 12.0,
                                                        color: Colors.black54,
                                                        fontFamily:
                                                            "Poppins-Regular"),
                                                    hintText:
                                                        "Enter a value between 0 and 15",
                                                    hintStyle: TextStyle(
                                                        fontSize: 12.0,
                                                        color: Colors.black54,
                                                        fontFamily:
                                                            "Poppins-Regular"),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(16.0),
                                              child: Container(
                                                child: TextFormField(
                                                  onChanged: (val) {
                                                    setState(() {
                                                      if (double.parse(val) >=
                                                              0 &&
                                                          double.parse(val) <=
                                                              15)
                                                        ct3 = double.parse(val);
                                                      else {
                                                        ct3 = null;
                                                        isSubmit = false;
                                                      }
                                                    });
                                                  },
                                                  initialValue: ct3.toString(),
                                                  style: TextStyle(
                                                      fontSize: 15.0,
                                                      color: Colors.black,
                                                      fontFamily:
                                                          "Poppins-Regular"),
                                                  keyboardType:
                                                      TextInputType.number,
                                                  decoration: InputDecoration(
                                                    focusedBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.black,
                                                          width: 1.0),
                                                    ),
                                                    enabledBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.black,
                                                          width: 1.0),
                                                    ),
                                                    labelText: "CT3",
                                                    labelStyle: TextStyle(
                                                        fontSize: 12.0,
                                                        color: Colors.black54,
                                                        fontFamily:
                                                            "Poppins-Regular"),
                                                    hintText:
                                                        "Enter a value between 0 and 15",
                                                    hintStyle: TextStyle(
                                                        fontSize: 12.0,
                                                        color: Colors.black54,
                                                        fontFamily:
                                                            "Poppins-Regular"),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(16.0),
                                              child: Container(
                                                child: TextFormField(
                                                  onChanged: (val) {
                                                    setState(() {
                                                      if (double.parse(val) >=
                                                              0 &&
                                                          double.parse(val) <=
                                                              5)
                                                        st = double.parse(val);
                                                      else {
                                                        st = null;
                                                        isSubmit = false;
                                                      }
                                                    });
                                                  },
                                                  initialValue: st.toString(),
                                                  style: TextStyle(
                                                      fontSize: 15.0,
                                                      color: Colors.black,
                                                      fontFamily:
                                                          "Poppins-Regular"),
                                                  keyboardType:
                                                      TextInputType.number,
                                                  decoration: InputDecoration(
                                                    focusedBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.black,
                                                          width: 1.0),
                                                    ),
                                                    enabledBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.black,
                                                          width: 1.0),
                                                    ),
                                                    labelText: "ST",
                                                    labelStyle: TextStyle(
                                                        fontSize: 12.0,
                                                        color: Colors.black54,
                                                        fontFamily:
                                                            "Poppins-Regular"),
                                                    hintText:
                                                        "Enter a value between 0 and 5",
                                                    hintStyle: TextStyle(
                                                        fontSize: 12.0,
                                                        color: Colors.black54,
                                                        fontFamily:
                                                            "Poppins-Regular"),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(16.0),
                                              child: Container(
                                                child: TextFormField(
                                                  onChanged: (val) {
                                                    setState(() {
                                                      if (double.parse(val) >=
                                                              0 &&
                                                          double.parse(val) <=
                                                              5)
                                                        as = double.parse(val);
                                                      else {
                                                        as = null;
                                                        isSubmit = false;
                                                      }
                                                    });
                                                  },
                                                  initialValue: as.toString(),
                                                  style: TextStyle(
                                                      fontSize: 15.0,
                                                      color: Colors.black,
                                                      fontFamily:
                                                          "Poppins-Regular"),
                                                  keyboardType:
                                                      TextInputType.number,
                                                  decoration: InputDecoration(
                                                    focusedBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.black,
                                                          width: 1.0),
                                                    ),
                                                    enabledBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.black,
                                                          width: 1.0),
                                                    ),
                                                    labelText: "Assignment",
                                                    labelStyle: TextStyle(
                                                        fontSize: 12.0,
                                                        color: Colors.black54,
                                                        fontFamily:
                                                            "Poppins-Regular"),
                                                    hintText:
                                                        "Enter a value between 0 and 5",
                                                    hintStyle: TextStyle(
                                                        fontSize: 12.0,
                                                        color: Colors.black54,
                                                        fontFamily:
                                                            "Poppins-Regular"),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ]),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    else if (stu?.length == 0 && isLoading == false)
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
                                  "Student Info",
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
      return circularProgress();
  }
}
