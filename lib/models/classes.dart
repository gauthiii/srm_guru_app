import 'package:cloud_firestore/cloud_firestore.dart';

class Class {
  final String classId;
  final String teacherId;
  final String code;
  final String sub;
  final int classes;
  final dynamic attendance;
  final dynamic ct1;
  final dynamic ct2;
  final dynamic ct3;
  final dynamic st;
  final dynamic as;
  final List<dynamic> students;
  final List<dynamic> announcements;
  final List<dynamic> assignments;
  final List<dynamic> notes;
  final Timestamp timestamp;

  Class(
      {this.classId,
      this.teacherId,
      this.code,
      this.sub,
      this.classes,
      this.attendance,
      this.ct1,
      this.ct2,
      this.ct3,
      this.st,
      this.as,
      this.students,
      this.announcements,
      this.assignments,
      this.notes,
      this.timestamp});

  factory Class.fromDocument(DocumentSnapshot doc) {
    return Class(
        classId: doc['classId'],
        teacherId: doc['teacherId'],
        code: doc['code'],
        sub: doc['sub'],
        classes: doc['classes'],
        attendance: doc['attendance'],
        ct1: doc['ct1'],
        ct2: doc['ct2'],
        ct3: doc['ct3'],
        st: doc['st'],
        as: doc['as'],
        students: doc['students'],
        announcements: doc['announcements'],
        assignments: doc['assignments'],
        notes: doc['notes'],
        timestamp: doc['timestamp']);
  }
}
