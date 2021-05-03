import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:dio/dio.dart';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:srm/models/announcements.dart';
import 'package:srm/models/assignments.dart';
import 'package:srm/progress.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import 'home.dart';
import 'models/classes.dart';
import 'models/notes.dart';
import 'models/user.dart';

class Student_Classroom extends StatefulWidget {
  final Class className;
  Student_Classroom({this.className});
  @override
  Stu createState() => Stu();
}

class Stu extends State<Student_Classroom> {
  ScrollController bouncecontrol = new ScrollController();
  ScrollController bouncecontrol1 = new ScrollController();
  ScrollController bouncecontrol2 = new ScrollController();
  Class currentClass;
  User teacher;
  bool isLoading = false;
  List<Announcement> ann = [];
  List<Notes> notes = [];
  List<Assignment> assignments = [];
  var s = 51.0;

  final Dio _dio = Dio();

  String _progress = "";

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  String _extension = '';
  String _fileName;
  bool isUpload = false;
  bool isF = false;
  File fileForFirebase;
  List<PlatformFile> _paths;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getClass();

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    final android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iOS = IOSInitializationSettings();
    final initSettings = InitializationSettings(android: android, iOS: iOS);

    flutterLocalNotificationsPlugin.initialize(initSettings,
        onSelectNotification: _onSelectNotification);
  }

  uploadImage(imageFile, ext, assignment) async {
    setState(() {
      isUpload = true;
    });

    firebase_storage.UploadTask uploadTask = storageRef
        .child('${currentClass.sub}')
        .child('/${currentClass.code}')
        .child('/assignments')
        .child("/${assignment.assId}")
        .child("${currentUser.reg + (Uuid().v4())}.$ext")
        .putFile(imageFile);
    firebase_storage.TaskSnapshot storageSnap = await Future.value(uploadTask);
    String downloadUrl = await storageSnap.ref.getDownloadURL();

    print(downloadUrl);

    assignmentsRef.doc(assignment.assId).update({
      "submissions.${currentUser.reg}": downloadUrl,
    });

    _clearCachedFiles();
    setState(() {
      fileForFirebase = null;
      isUpload = false;
    });
    getClass();
  }

  void _openFileExplorer() async {
    setState(() {
      isF = true;
    });
    try {
      _paths = (await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
        allowedExtensions: (_extension?.isNotEmpty ?? false)
            ? _extension?.replaceAll(' ', '').split(',')
            : null,
      ))
          ?.files;
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
    } catch (ex) {
      print(ex);
    }

    if (_paths == null)
      setState(() {
        isUpload = false;
      });
    else {
      if (!mounted) return;

      setState(() {
        fileForFirebase = File(_paths.first.path);
        _fileName =
            _paths != null ? _paths.map((e) => e.name).toString() : '...';
        isF = false;
        print(fileForFirebase.path);
      });
    }
  }

  void _clearCachedFiles() {
    FilePicker.platform.clearTemporaryFiles().then((result) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: result ? Colors.green : Colors.red,
          content: Text((result
              ? 'File uploaded Successfully'
              : 'Failed to clean temporary files')),
        ),
      );
    });
  }

  Future<void> _onSelectNotification(String json) async {
    final obj = jsonDecode(json);

    if (obj['isSuccess']) {
      OpenFile.open(obj['filePath']);
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Error'),
          content: Text('${obj['error']}'),
        ),
      );
    }
  }

  getClass() async {
    setState(() {
      isLoading = true;
    });

    ann = [];
    notes = [];
    assignments = [];

    DocumentSnapshot doc = await classRef.doc(widget.className?.classId).get();
    currentClass = Class.fromDocument(doc);

    currentClass.announcements.forEach((a) async {
      DocumentSnapshot d = await announcementsRef.doc(a).get();

      setState(() {
        ann.add(Announcement.fromDocument(d));
        if (currentClass.ct1[currentUser?.reg] != null &&
            currentClass.ct2[currentUser?.reg] != null &&
            currentClass.ct3[currentUser?.reg] != null &&
            currentClass.st[currentUser?.reg] != null &&
            currentClass.as[currentUser?.reg] != null)
          s = currentClass.ct1[currentUser?.reg] +
              currentClass.ct2[currentUser?.reg] +
              currentClass.ct3[currentUser?.reg] +
              currentClass.st[currentUser?.reg] +
              currentClass.as[currentUser?.reg];
      });
    });

    currentClass.notes.forEach((a) async {
      DocumentSnapshot d = await notesRef.doc(a).get();

      setState(() {
        notes.add(Notes.fromDocument(d));
        notes.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      });
    });

    currentClass.assignments.forEach((a) async {
      DocumentSnapshot d = await assignmentsRef.doc(a).get();

      setState(() {
        assignments.add(Assignment.fromDocument(d));
        assignments.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      });
    });

    ann.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    DocumentSnapshot doc1 =
        await usersRef.doc(widget.className?.teacherId).get();
    teacher = User.fromDocument(doc1);

    setState(() {
      isLoading = false;
    });
  }

  miss(int present, int total) {
    int c = 1;

    if ((present / total) < 0.75) {
      while ((present / total) < 0.75) {
        if (((present + c) / (total + c)) >= 0.75)
          break;
        else
          c = c + 1;
      }
    } else if ((present / total) > 0.75) {
      while ((present / total) >= 0.75) {
        if ((present / (total + c)) < 0.75)
          break;
        else
          c = c + 1;
      }
    } else if ((present / total) == 0.75) {
      c = 0;
    }
    return c;
  }

  Future<void> _download(x, y) async {
    final dir = await _getDownloadDirectory();
    final isPermissionStatusGranted = await _requestPermissions();

    print(isPermissionStatusGranted);
    print(dir);

    if (isPermissionStatusGranted) {
      final savePath = path.join(dir.path, x);
      print(savePath);
      await _startDownload(savePath, y);
    } else {
      // handle the scenario when user declines the permissions
    }
  }

  Future<void> _startDownload(String savePath, String url) async {
    Map<String, dynamic> result = {
      'isSuccess': false,
      'filePath': null,
      'error': null,
    };

    try {
      final response = await _dio.download(url, savePath,
          onReceiveProgress: _onReceiveProgress);

      result['isSuccess'] = response.statusCode == 200;
      result['filePath'] = savePath;
    } catch (ex) {
      result['error'] = ex.toString();
    } finally {
      await _showNotification(result);
      print(result);
    }

    Future.delayed(const Duration(milliseconds: 500), () {
// Here you can write your code

      setState(() {
        _progress = "";
      });
    });
  }

  void _onReceiveProgress(int received, int total) {
    if (total != -1) {
      setState(() {
        _progress = (received / total * 100).toStringAsFixed(0) + "%";
      });
    }
  }

  Future<void> _showNotification(Map<String, dynamic> downloadStatus) async {
    final android = AndroidNotificationDetails(
        'channel id', 'channel name', 'channel description',
        priority: Priority.high, importance: Importance.max);
    final iOS = IOSNotificationDetails();
    final platform = NotificationDetails(android: android, iOS: iOS);
    final json = jsonEncode(downloadStatus);
    final isSuccess = downloadStatus['isSuccess'];

    await flutterLocalNotificationsPlugin.show(
        0, // notification id
        isSuccess ? 'Success' : 'Failure',
        isSuccess
            ? 'File has been downloaded successfully!'
            : 'There was an error while downloading the file.',
        platform,
        payload: json);
  }

  Future<Directory> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      return await DownloadsPathProvider.downloadsDirectory;
    }

    // in this example we are using only Android and iOS so I can assume
    // that you are not trying it for other platforms and the if statement
    // for iOS is unnecessary

    // iOS directory visible to user
    return await getApplicationDocumentsDirectory();
  }

  Future<bool> _requestPermissions() async {
    var permission = await Permission.storage.status;

    if (permission != PermissionStatus.granted) {
      await Permission.storage.request();
      permission = await Permission.storage.request();
    }

    return permission == PermissionStatus.granted;
  }

  @override
  Widget build(BuildContext context) {
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
      body: (isLoading == true)
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
                              "${widget.className?.sub}",
                              style: TextStyle(
                                fontSize: 50.0,
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
                                    "Faculty Name",
                                    style: TextStyle(color: Colors.black54),
                                  )),
                              Container(
                                  width: MediaQuery.of(context).size.width,
                                  padding: EdgeInsets.only(top: 10.0),
                                  child: Text(
                                    "Prof.${teacher?.displayName}",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold),
                                  )),
                              Padding(
                                  padding: EdgeInsets.only(top: 12.0),
                                  child: Text(
                                    "Subject Code",
                                    style: TextStyle(color: Colors.black54),
                                  )),
                              Container(
                                  width: MediaQuery.of(context).size.width,
                                  padding: EdgeInsets.only(top: 10.0),
                                  child: SelectableText(
                                    "${currentClass?.code}",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold),
                                  )),
                              Padding(
                                  padding: EdgeInsets.only(top: 12.0),
                                  child: Text(
                                    "Attendance",
                                    style: TextStyle(color: Colors.black54),
                                  )),
                              Container(
                                  width: MediaQuery.of(context).size.width,
                                  padding: EdgeInsets.only(top: 10.0),
                                  child: Text(
                                    "${(currentClass?.attendance[currentUser?.reg] * 100 / currentClass?.classes).toStringAsFixed(2)} %",
                                    style: TextStyle(
                                        color: ((currentClass?.attendance[
                                                        currentUser?.reg] /
                                                    currentClass?.classes) >=
                                                0.75)
                                            ? Colors.black
                                            : Colors.red[900],
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold),
                                  )),
                              Container(
                                  width: MediaQuery.of(context).size.width,
                                  padding: EdgeInsets.only(top: 10.0),
                                  child: Text(
                                    ((currentClass?.attendance[
                                                    currentUser?.reg] /
                                                currentClass?.classes) >=
                                            0.75)
                                        ? ((currentClass?.attendance[
                                                        currentUser?.reg] /
                                                    currentClass?.classes) ==
                                                0.75)
                                            ? "(You can't miss any more classes)"
                                            : "(You can miss ${miss(currentClass?.attendance[currentUser?.reg], currentClass.classes)} more classes)"
                                        : "(Need to attend ${miss(currentClass?.attendance[currentUser?.reg], currentClass.classes)} more classes)",
                                    style: TextStyle(
                                      color: ((currentClass?.attendance[
                                                      currentUser?.reg] /
                                                  currentClass?.classes) >=
                                              0.75)
                                          ? Colors.black
                                          : Colors.red[900],
                                      fontSize: 15.0,
                                    ),
                                  )),
                              Padding(
                                  padding: EdgeInsets.only(top: 12.0),
                                  child: Text(
                                    "Marks",
                                    style: TextStyle(color: Colors.black54),
                                  )),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.only(top: 10.0),
                                child: Table(
                                  border: TableBorder.all(
                                      color: Colors.black,
                                      style: BorderStyle.solid,
                                      width: 2),
                                  children: [
                                    TableRow(children: [
                                      TableCell(
                                        child: SizedBox(
                                          height: 30,
                                          child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text('CT1/10',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 15.0))
                                              ]),
                                        ),
                                      ),
                                      TableCell(
                                        child: SizedBox(
                                          height: 30,
                                          child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text('CT2/15',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 15.0))
                                              ]),
                                        ),
                                      ),
                                      TableCell(
                                        child: SizedBox(
                                          height: 30,
                                          child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text('CT3/15',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 15.0))
                                              ]),
                                        ),
                                      ),
                                      TableCell(
                                        child: SizedBox(
                                          height: 30,
                                          child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text('ST/5',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 15.0))
                                              ]),
                                        ),
                                      ),
                                      TableCell(
                                        child: SizedBox(
                                          height: 30,
                                          child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text('AS/5',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 15.0))
                                              ]),
                                        ),
                                      ),
                                      TableCell(
                                        child: SizedBox(
                                          height: 30,
                                          child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text('TOT/50',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 15.0))
                                              ]),
                                        ),
                                      ),
                                    ]),
                                    TableRow(children: [
                                      TableCell(
                                        child: SizedBox(
                                          height: 50,
                                          child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                    '${(currentClass?.ct1[currentUser?.reg] == null) ? "NA" : currentClass?.ct1[currentUser?.reg]}',
                                                    style: TextStyle(
                                                        fontSize: 17.0))
                                              ]),
                                        ),
                                      ),
                                      TableCell(
                                        child: SizedBox(
                                          height: 50,
                                          child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                    '${(currentClass?.ct2[currentUser?.reg] == null) ? "NA" : currentClass?.ct2[currentUser?.reg]}',
                                                    style: TextStyle(
                                                        fontSize: 17.0))
                                              ]),
                                        ),
                                      ),
                                      TableCell(
                                        child: SizedBox(
                                          height: 50,
                                          child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                    '${(currentClass?.ct3[currentUser?.reg] == null) ? "NA" : currentClass?.ct3[currentUser?.reg]}',
                                                    style: TextStyle(
                                                        fontSize: 17.0))
                                              ]),
                                        ),
                                      ),
                                      TableCell(
                                        child: SizedBox(
                                          height: 50,
                                          child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                    '${(currentClass?.st[currentUser?.reg] == null) ? "NA" : currentClass?.st[currentUser?.reg]}',
                                                    style: TextStyle(
                                                        fontSize: 17.0))
                                              ]),
                                        ),
                                      ),
                                      TableCell(
                                        child: SizedBox(
                                          height: 50,
                                          child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                    '${(currentClass?.as[currentUser?.reg] == null) ? "NA" : currentClass?.as[currentUser?.reg]}',
                                                    style: TextStyle(
                                                        fontSize: 17.0))
                                              ]),
                                        ),
                                      ),
                                      TableCell(
                                        child: SizedBox(
                                          height: 50,
                                          child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                    '${(s == 51.0) ? "NA" : s}',
                                                    style: TextStyle(
                                                        fontSize: 17.0))
                                              ]),
                                        ),
                                      ),
                                    ]),
                                  ],
                                ),
                              ),
                              Text("NA - The marks have not been uploaded yet"),
                              Text(""),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(15, 15, 15, 15),
                                child: Card(
                                  elevation: 10,
                                  color: Colors.green,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0))),
                                  child: Scrollbar(
                                    child: (ann.length > 0)
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    25, 12, 15, 5),
                                                child: Text(
                                                  "Announcements",
                                                  style: TextStyle(
                                                      fontSize: 30.0,
                                                      fontFamily: 'SFUI',
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                              ),
                                              SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.6,
                                                // padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                child: ListView.builder(
                                                    physics:
                                                        BouncingScrollPhysics(),
                                                    controller: bouncecontrol,
                                                    itemCount: ann.length,
                                                    itemBuilder:
                                                        (context, int index) {
                                                      return GestureDetector(
                                                          onLongPress: () {},
                                                          child: SizedBox(
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .fromLTRB(
                                                                          10,
                                                                          5,
                                                                          10,
                                                                          0),
                                                              child: Card(
                                                                  // for teacher's attendance -> color: _selected[index] ? null : Colors.red[100],
                                                                  color: Colors
                                                                      .white,
                                                                  borderOnForeground:
                                                                      true,
                                                                  elevation:
                                                                      5.0,
                                                                  child:
                                                                      Container(
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            borderRadius: BorderRadius.only(
                                                                                topRight: Radius.circular(40.0),
                                                                                bottomRight: Radius.circular(40.0),
                                                                                topLeft: Radius.circular(40.0),
                                                                                bottomLeft: Radius.circular(40.0)),
                                                                          ),
                                                                          child:
                                                                              SizedBox(
                                                                            child:
                                                                                Column(
                                                                              children: [
                                                                                ListTile(leading: Image.asset('assets/megaphone.png', height: 30), title: Text("${ann[index].title}", style: TextStyle(fontWeight: FontWeight.bold)), subtitle: Text("Posted " + timeago.format(ann[index].timestamp.toDate()), style: TextStyle(color: Colors.grey))),
                                                                                ListTile(title: Text("${ann[index].content}")),
                                                                                Text("")
                                                                              ],
                                                                            ),
                                                                          ))),
                                                            ),
                                                          ));
                                                    }),
                                              ),
                                            ],
                                          )
                                        : Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    25, 12, 15, 5),
                                                child: Text(
                                                  "Announcements",
                                                  style: TextStyle(
                                                      fontSize: 30.0,
                                                      fontFamily: 'SFUI',
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                              ),
                                              Center(
                                                  child: Text("\n",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 35))),
                                              Center(
                                                  child: Icon(
                                                      Icons.block_rounded,
                                                      color: Colors.black,
                                                      size: 150)),
                                              Center(
                                                  child: Text(
                                                      "\nNo Announcements\n",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 35))),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(15, 15, 15, 15),
                                child: Card(
                                  elevation: 10,
                                  color: Colors.red,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0))),
                                  child: Scrollbar(
                                    child: (assignments.length > 0)
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    25, 12, 15, 5),
                                                child: Text(
                                                  "Assignments",
                                                  style: TextStyle(
                                                      fontSize: 30.0,
                                                      fontFamily: 'SFUI',
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                              ),
                                              SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.6,
                                                // padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                child: ListView.builder(
                                                    physics:
                                                        BouncingScrollPhysics(),
                                                    controller: bouncecontrol,
                                                    itemCount:
                                                        assignments.length,
                                                    itemBuilder:
                                                        (context, int index) {
                                                      return GestureDetector(
                                                          onLongPress: () {},
                                                          child: SizedBox(
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .fromLTRB(
                                                                          10,
                                                                          5,
                                                                          10,
                                                                          0),
                                                              child: Card(
                                                                  // for teacher's attendance -> color: _selected[index] ? null : Colors.red[100],
                                                                  color: Colors
                                                                      .white,
                                                                  borderOnForeground:
                                                                      true,
                                                                  elevation:
                                                                      5.0,
                                                                  child:
                                                                      Container(
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            borderRadius: BorderRadius.only(
                                                                                topRight: Radius.circular(40.0),
                                                                                bottomRight: Radius.circular(40.0),
                                                                                topLeft: Radius.circular(40.0),
                                                                                bottomLeft: Radius.circular(40.0)),
                                                                          ),
                                                                          child:
                                                                              SizedBox(
                                                                            child:
                                                                                Column(
                                                                              children: [
                                                                                ListTile(
                                                                                  leading: Image.asset(
                                                                                      (assignments[index].ext == "pdf")
                                                                                          ? 'assets/pdf.png'
                                                                                          : (assignments[index].ext == "doc")
                                                                                              ? 'assets/doc.png'
                                                                                              : 'assets/docx.png',
                                                                                      height: 35),
                                                                                  title: Text("${assignments[index].title}", style: TextStyle(fontWeight: FontWeight.bold)),
                                                                                  subtitle: Text("Posted " + timeago.format(assignments[index].timestamp.toDate()), style: TextStyle(color: Colors.grey)),
                                                                                  trailing: IconButton(
                                                                                      icon: Icon(Icons.file_download, color: Colors.black),
                                                                                      onPressed: () {
                                                                                        _download(assignments[index].title, assignments[index].url);
                                                                                      }),
                                                                                ),
                                                                                ListTile(
                                                                                  title: Text("${(assignments[index].submissions[currentUser.reg] == null) ? "Not Submitted" : "Submitted"}"),
                                                                                ),
                                                                                (isUpload == true)
                                                                                    ? linearProgress()
                                                                                    : Container(
                                                                                        width: 0,
                                                                                        height: 0,
                                                                                      ),
                                                                                (assignments[index].submissions[currentUser.reg] != null)
                                                                                    ? Text("")
                                                                                    : (isF == true)
                                                                                        ? circularProgress()
                                                                                        : Card(
                                                                                            color: Colors.amber,
                                                                                            borderOnForeground: true,
                                                                                            child: Container(
                                                                                              decoration: BoxDecoration(
                                                                                                borderRadius: BorderRadius.only(topRight: Radius.circular(40.0), bottomRight: Radius.circular(40.0), topLeft: Radius.circular(40.0), bottomLeft: Radius.circular(40.0)),
                                                                                              ),
                                                                                              child: ListTile(
                                                                                                onTap: () {
                                                                                                  if (fileForFirebase == null)
                                                                                                    _openFileExplorer();
                                                                                                  else
                                                                                                    uploadImage(fileForFirebase, _paths.first.extension, assignments[index]);
                                                                                                },
                                                                                                leading: IconButton(icon: Icon(Icons.book, color: Colors.black), onPressed: () {}),
                                                                                                title: Text(
                                                                                                  (fileForFirebase == null) ? 'Upload Assignment' : _fileName.substring(1, _fileName.length - 1),
                                                                                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                                                                                ),
                                                                                                subtitle: Text(
                                                                                                  (fileForFirebase == null) ? "Click here to load file" : "Click here to upload file",
                                                                                                  style: TextStyle(color: Colors.black),
                                                                                                ),
                                                                                                trailing: (fileForFirebase == null) ? Icon(Icons.file_upload, color: Colors.black) : Icon(Icons.file_upload, color: Colors.black),
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                (fileForFirebase == null)
                                                                                    ? Container(
                                                                                        width: 0,
                                                                                        height: 30,
                                                                                      )
                                                                                    : Container(
                                                                                        child: Center(
                                                                                          child: RaisedButton(
                                                                                            onPressed: () {
                                                                                              setState(() {
                                                                                                fileForFirebase = null;
                                                                                                FilePicker.platform.clearTemporaryFiles();
                                                                                              });
                                                                                            },
                                                                                            color: Colors.amber,
                                                                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                                                                                            child: Text("Don't Upload",
                                                                                                style: TextStyle(
                                                                                                  fontWeight: FontWeight.bold,
                                                                                                  fontSize: 20.0,
                                                                                                )),
                                                                                          ),
                                                                                        ),
                                                                                      )
                                                                              ],
                                                                            ),
                                                                          ))),
                                                            ),
                                                          ));
                                                    }),
                                              ),
                                              Center(
                                                child: Text(
                                                  '$_progress',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .display1,
                                                ),
                                              ),
                                            ],
                                          )
                                        : Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    25, 12, 15, 5),
                                                child: Text(
                                                  "Assignments",
                                                  style: TextStyle(
                                                      fontSize: 30.0,
                                                      fontFamily: 'SFUI',
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                              ),
                                              Center(
                                                  child: Text("\n",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 35))),
                                              Center(
                                                  child: Icon(
                                                      Icons.block_rounded,
                                                      color: Colors.black,
                                                      size: 150)),
                                              Center(
                                                  child: Text(
                                                      "\nNo Assignments\n",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 35))),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(15, 15, 15, 15),
                                child: Card(
                                  elevation: 10,
                                  color: Colors.amber,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0))),
                                  child: Scrollbar(
                                    child: (notes.length > 0)
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    25, 12, 15, 5),
                                                child: Text(
                                                  "Notes",
                                                  style: TextStyle(
                                                      fontSize: 30.0,
                                                      fontFamily: 'SFUI',
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                              ),
                                              SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.6,
                                                // padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                child: ListView.builder(
                                                    physics:
                                                        BouncingScrollPhysics(),
                                                    controller: bouncecontrol,
                                                    itemCount: notes.length,
                                                    itemBuilder:
                                                        (context, int index) {
                                                      return GestureDetector(
                                                          onLongPress: () {},
                                                          child: SizedBox(
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .fromLTRB(
                                                                          10,
                                                                          5,
                                                                          10,
                                                                          0),
                                                              child: Card(
                                                                  // for teacher's attendance -> color: _selected[index] ? null : Colors.red[100],
                                                                  color: Colors
                                                                      .white,
                                                                  borderOnForeground:
                                                                      true,
                                                                  elevation:
                                                                      5.0,
                                                                  child:
                                                                      Container(
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            borderRadius: BorderRadius.only(
                                                                                topRight: Radius.circular(40.0),
                                                                                bottomRight: Radius.circular(40.0),
                                                                                topLeft: Radius.circular(40.0),
                                                                                bottomLeft: Radius.circular(40.0)),
                                                                          ),
                                                                          child:
                                                                              SizedBox(
                                                                            child:
                                                                                Container(
                                                                              alignment: Alignment.center,
                                                                              height: 100,
                                                                              child: ListTile(
                                                                                leading: Image.asset(
                                                                                    (notes[index].ext == "pdf")
                                                                                        ? 'assets/pdf.png'
                                                                                        : (notes[index].ext == "doc")
                                                                                            ? 'assets/doc.png'
                                                                                            : 'assets/docx.png',
                                                                                    height: 35),
                                                                                title: Text(
                                                                                  '${notes[index].title}',
                                                                                  style: TextStyle(fontWeight: FontWeight.bold),
                                                                                ),
                                                                                subtitle: Text(
                                                                                  "Uploaded " + timeago.format(notes[index].timestamp.toDate()),
                                                                                  style: TextStyle(color: Colors.grey),
                                                                                ),
                                                                                trailing: IconButton(
                                                                                    icon: Icon(Icons.file_download, color: Colors.black),
                                                                                    onPressed: () {
                                                                                      _download(notes[index].title, notes[index].url);
                                                                                    }),
                                                                              ),
                                                                            ),
                                                                          ))),
                                                            ),
                                                          ));
                                                    }),
                                              ),
                                              Center(
                                                child: Text(
                                                  '$_progress',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .display1,
                                                ),
                                              ),
                                            ],
                                          )
                                        : Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    25, 12, 15, 5),
                                                child: Text(
                                                  "Notes",
                                                  style: TextStyle(
                                                      fontSize: 30.0,
                                                      fontFamily: 'SFUI',
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                              ),
                                              Center(
                                                  child: Text("\n",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 35))),
                                              Center(
                                                  child: Icon(
                                                      Icons.block_rounded,
                                                      color: Colors.black,
                                                      size: 150)),
                                              Center(
                                                  child: Text("\nNo Notes\n",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 35))),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
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
  }
}
