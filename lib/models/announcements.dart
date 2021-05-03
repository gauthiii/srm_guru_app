import 'package:cloud_firestore/cloud_firestore.dart';

class Announcement {
  final String annId;
  final String title;
  final String content;
  final Timestamp timestamp;

  Announcement({this.annId, this.title, this.content, this.timestamp});

  factory Announcement.fromDocument(DocumentSnapshot doc) {
    return Announcement(
        annId: doc.data()['assId'],
        title: doc.data()['title'],
        content: doc.data()['content'],
        timestamp: doc.data()['timestamp']);
  }
}
