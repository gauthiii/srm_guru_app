import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:srm/home.dart';
import 'package:srm/models/announcements.dart';
import 'package:srm/progress.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:uuid/uuid.dart';

import 'models/classes.dart';

class Make_Announcement extends StatefulWidget {
  final String name;
  final Class x;
  Make_Announcement({this.name, this.x});
  @override
  Stu createState() => Stu();
}

class Stu extends State<Make_Announcement> {
  ScrollController bouncecontrol = new ScrollController();
  bool isAnnounce = false;
  bool isLoading = false;
  Class currentClass;
  List<Announcement> ann = [];
  String tit = "";
  String con = "";

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

    getan();
  }

  getan() async {
    setState(() {
      isLoading = true;
    });
    ann = [];

    DocumentSnapshot doc = await classRef.doc(widget.x?.classId).get();

    currentClass = Class.fromDocument(doc);

    currentClass.announcements.forEach((a) async {
      DocumentSnapshot d = await announcementsRef.doc(a).get();

      setState(() {
        ann.add(Announcement.fromDocument(d));
      });
    });

    ann.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    setState(() {
      isLoading = false;
    });
  }

  post() {
    final DateTime ts = DateTime.now();
    String aid = Uuid().v4();
    announcementsRef
        .doc(aid)
        .set({"annId": aid, "title": tit, "content": con, "timestamp": ts});

    setState(() {
      currentClass.announcements.add(aid);
    });

    classRef.doc(currentClass.classId).update(
        {"announcements": FieldValue.arrayUnion(currentClass.announcements)});

    setState(() {
      isAnnounce = false;
      data = null;
      callme();
    });

    getan();
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
  Widget build(BuildContext context) {
    if (isAnnounce == true)
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 25.0),
            child: Center(
              child: Text(
                "Enter Announcement Title",
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
                child: TextFormField(
                  onChanged: (val) {
                    setState(() {
                      tit = val;
                    });
                  },
                  style: TextStyle(
                      fontSize: 15.0,
                      color: Colors.black,
                      fontFamily: "Poppins-Regular"),
                  decoration: InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 1.0),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 1.0),
                    ),
                    labelText: "Title",
                    labelStyle: TextStyle(
                        fontSize: 12.0,
                        color: Colors.black54,
                        fontFamily: "Poppins-Regular"),
                    hintText: "Enter a tite",
                    hintStyle: TextStyle(
                        fontSize: 12.0,
                        color: Colors.black54,
                        fontFamily: "Poppins-Regular"),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 25.0),
            child: Center(
              child: Text(
                "Enter Announcement Content",
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
                child: TextFormField(
                  onChanged: (val) {
                    setState(() {
                      con = val;
                    });
                  },
                  style: TextStyle(
                      fontSize: 15.0,
                      color: Colors.black,
                      fontFamily: "Poppins-Regular"),
                  decoration: InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 1.0),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 1.0),
                    ),
                    labelText: "Content",
                    labelStyle: TextStyle(
                        fontSize: 12.0,
                        color: Colors.black54,
                        fontFamily: "Poppins-Regular"),
                    hintText: "Type Something",
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
              if (tit.trim().isEmpty || con.trim().isEmpty)
                fun1();
              else
                post();
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
                isAnnounce = false;
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
          Container(height: 30)
        ],
      );
    else if (isLoading == true)
      return Scaffold(body: Center(child: circularProgress()));
    else if (isLoading == false)
      return Scaffold(
        resizeToAvoidBottomInset: false,
        /*appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.deepOrange[800],
            centerTitle: true,
            title: Text("Classroom",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    color: Colors.black)))*/
        body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                  child: Card(
                    elevation: 10,
                    color: Colors.green,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    child: Scrollbar(
                      child: (ann.isEmpty && isLoading == false)
                          ? data == null
                              ? Container(
                                  child: circularProgress(), height: 500)
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(25, 12, 15, 5),
                                      child: Text(
                                        "Announcements",
                                        style: TextStyle(
                                            fontSize: 30.0,
                                            fontFamily: 'SFUI',
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                    Center(
                                        child: Text("\n",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 35))),
                                    Center(
                                        child: Icon(Icons.block_rounded,
                                            color: Colors.black, size: 150)),
                                    Center(
                                        child: Text("\nNo Announcements\n",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 35))),
                                    SizedBox(
                                      child: Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(10, 5, 10, 0),
                                        child: Card(
                                          // for teacher's attendance -> color: _selected[index] ? null : Colors.red[100],
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10.0))),
                                          borderOnForeground: true,
                                          elevation: 5.0,
                                          child: ListTile(
                                            onTap: () {
                                              setState(() {
                                                isAnnounce = true;
                                              });
                                            },
                                            leading: IconButton(
                                                icon: Icon(Icons.notifications,
                                                    color: Colors.black),
                                                onPressed: () {}),
                                            title: Text(
                                              'Make Announcement',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            subtitle: Text(
                                              "You can do more here!",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            trailing: IconButton(
                                                icon: Icon(Icons.file_upload,
                                                    color: Colors.black),
                                                onPressed: () {}),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.fromLTRB(25, 12, 15, 5),
                                  child: Text(
                                    "Announcements",
                                    style: TextStyle(
                                        fontSize: 30.0,
                                        fontFamily: 'SFUI',
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.6,
                                  // padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: ListView.builder(
                                      physics: BouncingScrollPhysics(),
                                      controller: bouncecontrol,
                                      itemCount: ann.length,
                                      itemBuilder: (context, int index) {
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
                                                                      'assets/megaphone.png',
                                                                      height:
                                                                          30),
                                                                  title: Text(
                                                                      "${ann[index].title}",
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .bold)),
                                                                  subtitle: Text(
                                                                      "Posted " +
                                                                          timeago.format(ann[index]
                                                                              .timestamp
                                                                              .toDate()),
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.grey))),
                                                              ListTile(
                                                                  title: Text(
                                                                      "${ann[index].content}")),
                                                              Text("")
                                                            ],
                                                          ),
                                                        ))),
                                              ),
                                            ));
                                      }),
                                ),
                                SizedBox(
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(10, 5, 10, 0),
                                    child: Card(
                                      // for teacher's attendance -> color: _selected[index] ? null : Colors.red[100],
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10.0))),
                                      borderOnForeground: true,
                                      elevation: 5.0,
                                      child: ListTile(
                                        onTap: () {
                                          setState(() {
                                            isAnnounce = true;
                                          });
                                        },
                                        leading: IconButton(
                                            icon: Icon(Icons.notifications,
                                                color: Colors.black),
                                            onPressed: () {}),
                                        title: Text(
                                          'Make Announcement',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Text(
                                          "You can do more here!",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        trailing: IconButton(
                                            icon: Icon(Icons.file_upload,
                                                color: Colors.black),
                                            onPressed: () {}),
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
        ]),
      );
    else
      return Scaffold(body: Center(child: circularProgress()));
  }
}
