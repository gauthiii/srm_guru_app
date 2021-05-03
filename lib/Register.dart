import 'package:flutter/material.dart';
import 'Register2.dart';

import 'Login.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  @override
  bool _showPassword = false;
  final nameHolder = TextEditingController();
  String email = "";
  String pass = "";
  String conf = "";
  bool isvalid = true;
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  ClipPath(
                    clipper: TopWaveClipper(),
                    child: Container(
                      height: MediaQuery.of(context).size.height / 2.5,
                      //width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.amber, Colors.red],
                            stops: [0.0, 1.0]),
                      ),
                    ),
                  ),
                  Image.asset(
                    'assets/applogo.png',
                    height: MediaQuery.of(context).size.height * 0.2,
                  ),
                ],
              ),
              SizedBox(
                height: 30.0,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 50.0, right: 50.0),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: TextFormField(
                        onChanged: (value) {
                          email = value;
                        },
                        controller: nameHolder,
                        decoration: new InputDecoration(
                          labelText: "SRM Email ID",
                          errorText:
                              isvalid ? null : "Please enter SRM Mail ID",
                          labelStyle: TextStyle(color: Colors.black),
                          fillColor: Colors.red,
                          focusedBorder: new OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(35.0),
                              borderSide: BorderSide(color: Colors.black)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(35.0),
                              borderSide: BorderSide(color: Colors.black)),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        style: new TextStyle(
                            fontFamily: "SFUI", color: Colors.black),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: TextFormField(
                        onChanged: (text) {
                          pass = text;
                        },
                        obscureText: !this._showPassword,
                        decoration: new InputDecoration(
                          labelText: "Password",
                          labelStyle: TextStyle(color: Colors.black),
                          focusedBorder: new OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(35.0),
                              borderSide: BorderSide(color: Colors.black)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(35.0),
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.remove_red_eye,
                              color: this._showPassword
                                  ? Colors.blue
                                  : Colors.grey,
                            ),
                            onPressed: () {
                              setState(() =>
                                  this._showPassword = !this._showPassword);
                            },
                          ),
                          //fillColor: Colors.green
                        ),
                        style: new TextStyle(
                            fontFamily: "SFUI", color: Colors.black),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: TextFormField(
                        onChanged: (text) {
                          conf = text;
                        },
                        obscureText: !this._showPassword,
                        decoration: new InputDecoration(
                          errorText:
                              pass == conf ? null : "Passwords dont match",
                          labelText: "Confirm Password",
                          labelStyle: TextStyle(color: Colors.black),
                          focusedBorder: new OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(35.0),
                              borderSide: BorderSide(color: Colors.black)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(35.0),
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.remove_red_eye,
                              color: this._showPassword
                                  ? Colors.blue
                                  : Colors.grey,
                            ),
                            onPressed: () {
                              setState(() =>
                                  this._showPassword = !this._showPassword);
                            },
                          ),
                          //fillColor: Colors.green
                        ),
                        style: new TextStyle(
                            fontFamily: "SFUI", color: Colors.black),
                      ),
                    ),
                    SizedBox(height: 60.0),
                    GestureDetector(
                      onTap: () {
                        if (!email.contains("@srmist.edu.in") ||
                            (email.isEmpty)) {
                          isvalid = false;
                        } else {
                          isvalid = true;
                        }
                        if (isvalid == false) {
                          setState(() {
                            nameHolder.clear();
                          });
                        } else {
                          Navigator.of(context).push(PageRouteBuilder(
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              var tween = Tween(
                                      begin: Offset(0.0, 1.0), end: Offset.zero)
                                  .chain(CurveTween(curve: Curves.ease));
                              return SlideTransition(
                                position: animation.drive(tween),
                                child: child,
                              );
                            },
                            transitionDuration: Duration(milliseconds: 800),
                            pageBuilder:
                                (context, animation, secondaryAnimation) {
                              return Register2();
                            },
                          ));
                        }
                      },
                      child: Container(
                        width: 150,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.amber, Colors.red],
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              offset: Offset(5, 5),
                              blurRadius: 10,
                            )
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Proceed',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Already have an account??",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'SFUI',
                          ),
                        ),
                        InkWell(
                          child: Text(
                            " Login Here",
                            style: TextStyle(
                                color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                          onTap: () {
                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //       builder: (context) => Login(),
                            //     ));
                            Navigator.of(context).push(PageRouteBuilder(
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                var tween = Tween(
                                        begin: Offset(0.0, 1.0),
                                        end: Offset.zero)
                                    .chain(CurveTween(curve: Curves.ease));
                                return SlideTransition(
                                  position: animation.drive(tween),
                                  child: child,
                                );
                              },
                              transitionDuration: Duration(milliseconds: 800),
                              pageBuilder:
                                  (context, animation, secondaryAnimation) {
                                return Login();
                              },
                            ));
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ClipPath(
                clipper: FooterWaveClipper(),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 5.55,
                  //width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.amber, Colors.red],
                        stops: [0.0, 1.0]),
                  ),
                ),
              ),
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
