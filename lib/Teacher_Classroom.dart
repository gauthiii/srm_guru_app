import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:srm/Mark_Attendance.dart';
import 'package:srm/downloader.dart';
import 'package:srm/f.dart';

import 'Make_Announcements.dart';
import 'Post_Assigment.dart';
import 'Post_Notes.dart';

import 'home.dart';
import 'marks.dart';
import 'models/classes.dart';

class Teacher_Classroom extends StatefulWidget {
  final Class className;
  Teacher_Classroom({this.className});
  @override
  Stu createState() => Stu();
}

class Stu extends State<Teacher_Classroom> {
  int index = 0;

  File file;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  // ignore: override_on_non_overriding_member
  void tap(int currindex) {
    setState(() {
      index = currindex;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: index,
          onTap: tap,
          selectedItemColor: Colors.deepOrangeAccent[400],
          items: [
            BottomNavigationBarItem(
                title: Text(
                  "Attendance",
                  style: TextStyle(fontSize: 13),
                ),
                icon: Icon(Icons.people)),
            BottomNavigationBarItem(
                title: Text(
                  "Announcements",
                  style: TextStyle(fontSize: 13),
                ),
                icon: Icon(Icons.notifications)),
            BottomNavigationBarItem(
                title: Text(
                  "Update",
                  style: TextStyle(fontSize: 13),
                ),
                icon: Icon(Icons.edit)),
            BottomNavigationBarItem(
                title: Text(
                  "Assignments",
                  style: TextStyle(fontSize: 13),
                ),
                icon: Icon(Icons.assignment)),
            BottomNavigationBarItem(
                title: Text(
                  "Notes",
                  style: TextStyle(fontSize: 13),
                ),
                icon: Icon(Icons.book)),
          ]),
      body: [
        Mark_Attendance(name: "Mark Attendance", x: widget.className),
        Make_Announcement(name: "Make Announcements", x: widget.className),
        Student(x: widget.className),
        Post_Assigment(name: "Post Assigments", x: widget.className),
        Post_Notes(name: "Post Notes", x: widget.className),
      ].elementAt(index),
    );
  }
}
