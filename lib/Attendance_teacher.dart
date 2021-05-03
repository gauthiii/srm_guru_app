import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class attendance_teacher extends StatefulWidget {
  @override
  _attendance_teacherState createState() => _attendance_teacherState();
}

class _attendance_teacherState extends State<attendance_teacher> {
  final items = List<String>.generate(20, (i) => "Item ${i + 1}");
  List<bool> _selected = List.generate(20, (i) => true);
  ScrollController bounce = new ScrollController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Attendance",
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
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    controller: bounce,
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (context, int index) {
                      return GestureDetector(
                        onHorizontalDragUpdate: (DragUpdateDetails direction) {
                          if (direction.delta.dx < 0) print(direction);
                          setState(() {
                            _selected[index] = !_selected[index];
                          });
                          if (direction.delta.dx > 0) {
                            setState(() {
                              _selected[index] = !_selected[index];
                            });
                          }
                        },
                        child: Container(
                          margin: EdgeInsets.fromLTRB(15, 0, 15, 5),
                          child: Card(
                            color: _selected[index]
                                ? Colors.lightGreen[100]
                                : Colors.red[100],
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0))),
                            borderOnForeground: true,
                            elevation: 5.0,
                            child: ListTile(
                              onTap: () {},
                              leading: FlutterLogo(),
                              title: Text('${items[index]}'),
                              subtitle: Text("You can do more here!"),
                              trailing: IconButton(
                                  icon: Icon(Icons.more_vert),
                                  onPressed: () {}),
                            ),
                          ),
                        ),
                      );
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
