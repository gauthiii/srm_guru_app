import 'package:cloud_firestore/cloud_firestore.dart';

class Notes {
  final String notId;
  final String ext;
  final String url;
  final String title;
  final Timestamp timestamp;

  Notes({this.notId, this.ext, this.url, this.title, this.timestamp});

  factory Notes.fromDocument(DocumentSnapshot doc) {
    return Notes(
        notId: doc['notId'],
        ext: doc['ext'],
        url: doc['url'],
        title: doc['title'],
        timestamp: doc['timestamp']);
  }
}
