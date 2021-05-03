import 'package:cloud_firestore/cloud_firestore.dart';

class Assignment {
  final String assId;
  final String ext;
  final String url;
  final String title;
  final dynamic submissions;
  final Timestamp timestamp;

  Assignment({this.assId, this.ext, this.url, this.title,this.submissions, this.timestamp});

  factory Assignment.fromDocument(DocumentSnapshot doc) {
    return Assignment(
        assId: doc['assId'],
        ext: doc['ext'],
        url: doc['url'],
        title: doc['title'],
        submissions: doc['submissions'],
        timestamp: doc['timestamp']);
  }
}
