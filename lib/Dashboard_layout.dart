import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'Dashboard_structure.dart';
import 'Login.dart';
import 'Profile.dart';

class Dash_layout extends StatefulWidget {
  @override
  _Dash_layoutState createState() => _Dash_layoutState();
}

class _Dash_layoutState extends State<Dash_layout> {
  int index = 0;

  static List<Widget> _widgetoptions = <Widget>[
    Dash_struct(),
    profile(),
    AlertDialog(
      title: new Text("Yet to build!!!",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontFamily: "JustAnotherHand",
              fontSize: 30.0,
              fontWeight: FontWeight.bold,
              color: Colors.black)),
    ),
  ];
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
                title: Text("Dashboard"), icon: Icon(Icons.dashboard)),
            BottomNavigationBarItem(
                title: Text("Profile"), icon: Icon(Icons.person_outline)),
            BottomNavigationBarItem(
                title: Text("Log out"), icon: Icon(Icons.exit_to_app)),
          ]),
      body: _widgetoptions.elementAt(index),
    );
  }
}
