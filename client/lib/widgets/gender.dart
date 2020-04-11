import 'package:flutter/material.dart';

class Gender extends StatefulWidget {
  final Function gender;

  Gender({
    this.gender,
  });

  @override
  _GenderState createState() => _GenderState(this.gender);
}

class _GenderState extends State<Gender> {
  int _value = 2;
  Function gender;
  _GenderState(this.gender);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Row(
          children: <Widget>[
            Container(
              width: 80.0,
              child: Text(
                "Gender",
                textAlign: TextAlign.left,
                style: TextStyle(color: Colors.lightBlue),
              ),
            ),
            Container(
              color: _value == 0 ? Colors.lightBlueAccent : Colors.transparent,
              child: GestureDetector(
                onTap: () => {gender("male"), setState(() => _value = 0)},
                child: Row(
                  children: <Widget>[
                    CircleAvatar(
                      backgroundColor: Colors.blue[50],
                      child: Icon(Icons.tag_faces, color: Colors.grey),
                    ),
                    SizedBox(
                      width: 30.0,
                    ),
                    Container(
                      width: 70.0,
                      child: Text(
                        "Male",
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              color: _value == 1 ? Colors.lightBlueAccent : Colors.transparent,
              child: GestureDetector(
                onTap: () => {
                  gender("female"),
                  setState(() => _value = 1),
                },
                child: Row(
                  children: <Widget>[
                    CircleAvatar(
                      backgroundColor: Colors.blue[50],
                      child: Icon(
                        Icons.face,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(
                      width: 30.0,
                    ),
                    Container(
                      width: 140.0,
                      child: Text(
                        "Female",
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
