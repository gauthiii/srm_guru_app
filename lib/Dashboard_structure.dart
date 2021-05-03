import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pie_chart/pie_chart.dart';
import 'Attendance_teacher.dart';
import 'Dash_classes_cards.dart';

class Dash_struct extends StatefulWidget {
  @override
  _Dash_structState createState() => _Dash_structState();
}

class _Dash_structState extends State<Dash_struct> {
  // final items = List<String>.generate(20, (i) => "Item ${i + 1}");
  ScrollController bouncecontrol = new ScrollController();
  ScrollController bouncecontrol1 = new ScrollController();

  // List<bool> _selected = List.generate(20, (i) => true);
  Map<String, double> dataMap = new Map();
  List<Color> colorlist = [Colors.green, Colors.red];
  @override
  void initState() {
    super.initState();
    dataMap.putIfAbsent("Present", () => 5);
    dataMap.putIfAbsent("Absent", () => 3);
  }

  @override
  Widget build(BuildContext context) {
    int teacher = 0;
    String add_join = "Add";
    if (teacher == 0) {
      add_join = "Join";
    }
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          controller: bouncecontrol1,
          child: Column(
            children: <Widget>[
              Container(
                child: SafeArea(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    //SizedBox(height: 120),
                    Center(
                      child: Text(
                        "Dashboard",
                        style: TextStyle(
                          fontSize: 50.0,
                          fontFamily: 'SFUI',
                          fontWeight: FontWeight.w400,
                          color: Colors.black87,
                        ),
                      ),
                    )
                  ],
                )),
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
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    //color: Colors.white,
                    ),
                child: Column(children: <Widget>[
                  SizedBox(height: 30.0),
                  Dash_class_card(),
                ]),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class TopWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    // This is where we decide what part of our image is going to be visible.
    var path = Path();
    path.lineTo(0.0, size.height);

    var firstControlPoint = new Offset(size.width / 7, size.height - 30);
    var firstEndPoint = new Offset(size.width / 6, size.height / 1.5);

    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint = Offset(size.width / 5, size.height / 4);
    var secondEndPoint = Offset(size.width / 1.5, size.height / 5);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    var thirdControlPoint =
        Offset(size.width - (size.width / 9), size.height / 6);
    var thirdEndPoint = Offset(size.width, 0.0);
    path.quadraticBezierTo(thirdControlPoint.dx, thirdControlPoint.dy,
        thirdEndPoint.dx, thirdEndPoint.dy);

    ///move from bottom right to top
    path.lineTo(size.width, 0.0);

    ///finally close the path by reaching start point from top right corner
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class FooterWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width, 0.0);
    path.lineTo(size.width, size.height);
    path.lineTo(0.0, size.height);
    path.lineTo(0.0, size.height - 60);
    var secondControlPoint = Offset(size.width - (size.width / 6), size.height);
    var secondEndPoint = Offset(size.width, 0.0);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
