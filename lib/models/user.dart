import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String reg;
  final String email;
  final String photoUrl;
  final String mobile;
  final String displayName;
  final String year;
  final String des;
  final String sem;
  final String branch;
  final List<dynamic> classes;
  final Timestamp timestamp;

  User(
      {this.reg,
      this.email,
      this.photoUrl,
      this.mobile,
      this.displayName,
      this.des,
      this.year,
      this.sem,
      this.branch,
      this.classes,
      this.timestamp});

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
        reg: doc['reg'],
        email: doc['email'],
        photoUrl: doc['photoUrl'],
        mobile: doc['mobile'],
        displayName: doc['displayName'],
        des: doc['des'],
        year: doc['year'],
        sem: doc['sem'],
        branch: doc['branch'],
        classes: doc['classes'],
        timestamp: doc['timestamp']);
  }
}
