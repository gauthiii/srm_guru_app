import 'package:flutter/material.dart';
import 'Login.dart';

class Register2 extends StatefulWidget {
  @override
  _Register2State createState() => _Register2State();
}

class _Register2State extends State<Register2> {
  @override
  bool _showPassword = false;
  bool option = false;
  String reg = "";
  String out = "";
  final nameHolder = TextEditingController();
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
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Teacher",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'SFUI',
                                fontSize: 17.0),
                          ),
                          Switch(
                            value: option,
                            onChanged: (o) {
                              setState(() {
                                option = o;
                              });
                            },
                            activeColor: Colors.white,
                            //focusColor: Colors.black,
                            activeTrackColor: Colors.red,
                            inactiveTrackColor: Colors.amber,
                          ),
                          Text(
                            "Student",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.black,
                                //fontWeight: FontWeight.bold,
                                fontFamily: 'SFUI',
                                fontSize: 17.0),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: TextFormField(
                        decoration: new InputDecoration(
                          labelText: "Name",
                          labelStyle: TextStyle(color: Colors.black),
                          fillColor: Colors.red,
                          focusedBorder: new OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(35.0),
                              borderSide: BorderSide(color: Colors.black)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(35.0),
                              borderSide: BorderSide(color: Colors.black)),
                        ),
                        keyboardType: TextInputType.text,
                        style: new TextStyle(
                            fontFamily: "SFUI", color: Colors.black),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: TextFormField(
                        onChanged: (text) {
                          reg = text;
                        },
                        controller: nameHolder,
                        decoration: new InputDecoration(
                          labelText: "Registration No",
                          errorText: out == "" ? null : out,
                          labelStyle: TextStyle(color: Colors.black),
                          fillColor: Colors.red,
                          focusedBorder: new OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(35.0),
                              borderSide: BorderSide(color: Colors.black)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(35.0),
                              borderSide: BorderSide(color: Colors.black)),
                        ),
                        keyboardType: TextInputType.text,
                        style: new TextStyle(
                            fontFamily: "SFUI", color: Colors.black),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: TextFormField(
                        decoration: new InputDecoration(
                          labelText: "Branch",
                          labelStyle: TextStyle(color: Colors.black),
                          fillColor: Colors.red,
                          focusedBorder: new OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(35.0),
                              borderSide: BorderSide(color: Colors.black)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(35.0),
                              borderSide: BorderSide(color: Colors.black)),
                        ),
                        keyboardType: TextInputType.text,
                        style: new TextStyle(
                            fontFamily: "SFUI", color: Colors.black),
                      ),
                    ),
                    Visibility(
                      visible: (option == false) ? false : true,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: TextFormField(
                          decoration: new InputDecoration(
                            labelText: "Year Of Study",
                            labelStyle: TextStyle(color: Colors.black),
                            fillColor: Colors.red,
                            focusedBorder: new OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(35.0),
                                borderSide: BorderSide(color: Colors.black)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(35.0),
                                borderSide: BorderSide(color: Colors.black)),
                          ),
                          keyboardType: TextInputType.number,
                          style: new TextStyle(
                              fontFamily: "SFUI", color: Colors.black),
                          validator: (text) {
                            if (text.isEmpty || text == null) {
                              return "This field cannot be empty.";
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 60.0),
                    GestureDetector(
                      onTap: () {
                        if (option == false) {
                          if ((!reg.contains("TA")) || reg.isEmpty) {
                            out = "Teacher Reg No should start with TA";
                          } else {
                            out = "";
                          }
                        } else {
                          if ((!reg.contains("RA")) || reg.isEmpty) {
                            out = "Student Reg No should start with RA";
                          } else {
                            out = "";
                          }
                        }
                        if (out != "") {
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
                              return Login();
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
                            'Register',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ClipPath(
                clipper: FooterWaveClipper(),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 8.35,
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
