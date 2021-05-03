import 'dart:convert';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as path;
import 'package:srm/progress.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:srm/models/assignments.dart';
import 'package:uuid/uuid.dart';
import 'home.dart';
import 'models/classes.dart';

class Post_Assigment extends StatefulWidget {
  final String name;
  final Class x;
  Post_Assigment({this.name, this.x});
  @override
  Stu createState() => Stu();
}

class Stu extends State<Post_Assigment> {
  ScrollController bouncecontrol = new ScrollController();
  String _extension = '';
  String _fileName;
  Class currentClass;
  bool isLoading = false;
  bool isUpload = false;
  bool isF = false;
  File fileForFirebase;
  List<PlatformFile> _paths;
  List<Assignment> assignments = [];
  int init_file = 1;
  int total_file;
  bool sd = false;

  final Dio _dio = Dio();

  String _progress = "";

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();

    getC();

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    final android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iOS = IOSInitializationSettings();
    final initSettings = InitializationSettings(android: android, iOS: iOS);

    flutterLocalNotificationsPlugin.initialize(initSettings,
        onSelectNotification: _onSelectNotification);
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

  getC() async {
    setState(() {
      isLoading = true;
    });

    assignments = [];

    DocumentSnapshot doc = await classRef.doc(widget.x.classId).get();
    currentClass = Class.fromDocument(doc);

    currentClass.assignments.forEach((element) async {
      DocumentSnapshot doc = await assignmentsRef.doc(element).get();

      setState(() {
        assignments.add(Assignment.fromDocument(doc));
        assignments.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      });
    });

    setState(() {
      isLoading = false;
    });
  }

  uploadImage(imageFile, ext) async {
    setState(() {
      isUpload = true;
    });

    String assId = Uuid().v4();
    firebase_storage.UploadTask uploadTask = storageRef
        .child('${currentClass.sub}')
        .child('/${currentClass.code}')
        .child('/assignments')
        .child("$assId.$ext")
        .putFile(imageFile);
    firebase_storage.TaskSnapshot storageSnap = await Future.value(uploadTask);
    String downloadUrl = await storageSnap.ref.getDownloadURL();

    print(downloadUrl);

    assignmentsRef.doc(assId).set({
      "assId": assId,
      "url": downloadUrl,
      "title": _fileName.substring(1, _fileName.length - 1),
      "ext": ext,
      "submissions": {},
      "timestamp": DateTime.now()
    });

    setState(() {
      currentClass.assignments.add(assId);
    });

    classRef
        .doc(currentClass.classId)
        .update({"assignments": currentClass.assignments});

    _clearCachedFiles();
    setState(() {
      fileForFirebase = null;
      isUpload = false;
    });
    getC();
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
    if (isLoading == true)
      return Scaffold(body: circularProgress());
    else if (currentClass.assignments.isNotEmpty)
      return Scaffold(
        resizeToAvoidBottomInset: false,
        body: ListView(children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                  child: Card(
                    elevation: 10,
                    color: Colors.red,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    child: Scrollbar(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.fromLTRB(25, 12, 15, 5),
                            child: Text(
                              "Notes",
                              style: TextStyle(
                                  fontSize: 30.0,
                                  fontFamily: 'SFUI',
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                          (isUpload == true)
                              ? linearProgress()
                              : Container(
                                  width: 0,
                                  height: 0,
                                ),
                          (assignments.isEmpty)
                              ? circularProgress()
                              : SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.6,
                                  // padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: ListView.builder(
                                      physics: BouncingScrollPhysics(),
                                      controller: bouncecontrol,
                                      itemCount: assignments.length,
                                      itemBuilder: (context, int index) {
                                        return GestureDetector(
                                          onLongPress: () {},
                                          child: SizedBox(
                                            child: Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  10, 5, 10, 0),
                                              child: Card(
                                                // for teacher's attendance -> color: _selected[index] ? null : Colors.red[100],
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                10.0))),
                                                borderOnForeground: true,
                                                elevation: 5.0,
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      alignment:
                                                          Alignment.center,
                                                      height: 100,
                                                      child: ListTile(
                                                        leading: Image.asset(
                                                            (assignments[index]
                                                                        .ext ==
                                                                    "pdf")
                                                                ? 'assets/pdf.png'
                                                                : (assignments[index]
                                                                            .ext ==
                                                                        "doc")
                                                                    ? 'assets/doc.png'
                                                                    : 'assets/docx.png',
                                                            height: 35),
                                                        title: Text(
                                                          '${assignments[index].title}',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        subtitle: Text(
                                                          "Uploaded " +
                                                              timeago.format(
                                                                  assignments[
                                                                          index]
                                                                      .timestamp
                                                                      .toDate()),
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        trailing: IconButton(
                                                            icon: Icon(
                                                                Icons
                                                                    .file_download,
                                                                color: Colors
                                                                    .black),
                                                            onPressed: () {
                                                              _download(
                                                                  assignments[
                                                                          index]
                                                                      .title,
                                                                  assignments[
                                                                          index]
                                                                      .url);
                                                            }),
                                                      ),
                                                    ),
                                                    ListTile(
                                                        title: Text(
                                                            "Submissions : ${assignments[index].submissions.length}")),
                                                    (assignments[index]
                                                                .submissions
                                                                .length >
                                                            0)
                                                        ? Container(
                                                            child: Center(
                                                              child:
                                                                  RaisedButton(
                                                                onPressed: () {
                                                                  setState(() {
                                                                    total_file = assignments[
                                                                            index]
                                                                        .submissions
                                                                        .length;
                                                                    sd = true;
                                                                  });
                                                                  assignments[
                                                                          index]
                                                                      .submissions
                                                                      .forEach(
                                                                          (k, v) {
                                                                    String x = v
                                                                        .split(
                                                                            '')
                                                                        .reversed
                                                                        .join();

                                                                    x = x.substring(
                                                                        x.indexOf('?') +
                                                                            1,
                                                                        x.indexOf('.') +
                                                                            1);
                                                                    x = x
                                                                        .split(
                                                                            '')
                                                                        .reversed
                                                                        .join();
                                                                    print(x);
                                                                    _download(
                                                                        k + x,
                                                                        v);

                                                                    setState(
                                                                        () {
                                                                      init_file =
                                                                          init_file +
                                                                              1;
                                                                    });
                                                                  });

                                                                  if (total_file >
                                                                      1)
                                                                    showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (_) {
                                                                          return AlertDialog(
                                                                              backgroundColor: Colors.white,
                                                                              title: Text("All $total_file files downloaded!!!"));
                                                                        });

                                                                  setState(() {
                                                                    sd = false;
                                                                  });
                                                                },
                                                                color: Colors
                                                                    .amber,
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            30.0)),
                                                                child: Text(
                                                                    "Download all submissions",
                                                                    style:
                                                                        TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          20.0,
                                                                    )),
                                                              ),
                                                            ),
                                                          )
                                                        : Text(""),
                                                    Text("\n")
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                ),
                          Center(
                            child: Text(
                              '$_progress',
                              style: Theme.of(context).textTheme.display1,
                            ),
                          ),
                          SizedBox(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                              child: Card(
                                // for teacher's attendance -> color: _selected[index] ? null : Colors.red[100],
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(10.0))),
                                borderOnForeground: true,
                                elevation: 5.0,
                                child: (isF == true)
                                    ? circularProgress()
                                    : ListTile(
                                        onTap: () {
                                          if (fileForFirebase == null)
                                            _openFileExplorer();
                                          else
                                            uploadImage(fileForFirebase,
                                                _paths.first.extension);
                                        },
                                        leading: IconButton(
                                            icon: Icon(Icons.book,
                                                color: Colors.black),
                                            onPressed: () {}),
                                        title: Text(
                                          (fileForFirebase == null)
                                              ? 'Upload Assignment'
                                              : _fileName.substring(
                                                  1, _fileName.length - 1),
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Text(
                                          (fileForFirebase == null)
                                              ? "Click here to load file"
                                              : "Click here to upload file",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        trailing: (fileForFirebase == null)
                                            ? Icon(Icons.file_upload,
                                                color: Colors.black)
                                            : Icon(Icons.file_upload,
                                                color: Colors.black),
                                      ),
                              ),
                            ),
                          ),
                          (fileForFirebase == null)
                              ? Container(
                                  width: 0,
                                  height: 0,
                                )
                              : Container(
                                  child: Center(
                                    child: RaisedButton(
                                      onPressed: () {
                                        setState(() {
                                          fileForFirebase = null;
                                          FilePicker.platform
                                              .clearTemporaryFiles();
                                        });
                                      },
                                      color: Colors.amber,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30.0)),
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
                    ),
                  ),
                ),
              ],
            ),
          ),
        ]),
      );
    else if (currentClass.assignments.isEmpty)
      return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          (isUpload == true)
              ? linearProgress()
              : Container(
                  width: 0,
                  height: 0,
                ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                  child: Card(
                    elevation: 10,
                    color: Colors.red,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    child: Scrollbar(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.fromLTRB(25, 12, 15, 5),
                            child: Text(
                              "Assignments",
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
                              child: Text("\nNo Assignments\n",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 35))),
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
                                child: (isF == true)
                                    ? circularProgress()
                                    : ListTile(
                                        onTap: () {
                                          if (fileForFirebase == null)
                                            _openFileExplorer();
                                          else
                                            uploadImage(fileForFirebase,
                                                _paths.first.extension);
                                        },
                                        leading: IconButton(
                                            icon: Icon(Icons.book,
                                                color: Colors.black),
                                            onPressed: () {}),
                                        title: Text(
                                          (fileForFirebase == null)
                                              ? 'Upload Assignment'
                                              : _fileName.substring(
                                                  1, _fileName.length - 1),
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Text(
                                          (fileForFirebase == null)
                                              ? "Click here to load file"
                                              : "Click here to upload file",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        trailing: (fileForFirebase == null)
                                            ? Icon(Icons.file_upload,
                                                color: Colors.black)
                                            : Icon(Icons.file_upload,
                                                color: Colors.black),
                                      ),
                              ),
                            ),
                          ),
                          (fileForFirebase == null)
                              ? Container(
                                  width: 0,
                                  height: 0,
                                )
                              : Container(
                                  child: Center(
                                    child: RaisedButton(
                                      onPressed: () {
                                        setState(() {
                                          fileForFirebase = null;
                                          FilePicker.platform
                                              .clearTemporaryFiles();
                                        });
                                      },
                                      color: Colors.amber,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30.0)),
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
                    ),
                  ),
                ),
              ],
            ),
          ),
        ]),
      );
    else if (sd == true)
      return Scaffold(
          body: Column(
        children: [
          Text("$init_file out of $total_file downloading...."),
          circularProgress()
        ],
      ));
  }
}
