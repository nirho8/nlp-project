import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final String label;
  final String content;
  final Function onSave;
  final Function validator;
  final Function onSubmitForLogin;
  final bool isPassword;
  final bool isDate;
  final isLogin;

  InputField({
    this.label,
    this.content,
    this.onSave,
    this.validator,
    this.onSubmitForLogin,
    this.isPassword = false,
    this.isDate = false,
    this.isLogin = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Row(
          children: <Widget>[
            Container(
              width: 80.0,
              child: Text(
                "$label",
                textAlign: TextAlign.left,
                style: TextStyle(color: Colors.lightBlue),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width / 7,
              color: Colors.blue[50],
              child: TextFormField(
                style: TextStyle(
                  fontSize: 15.0,
                ),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(10.0),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.blue[50],
                    ),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.blue[50],
                    ),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  hintText: "$content",
                  fillColor: Colors.blue[50],
                ),
                obscureText: isPassword ? true : false,
                onSaved: onSave,
                validator: validator,
                onFieldSubmitted: isLogin ? onSubmitForLogin : null,
              ),
            ),
            SizedBox(
              width: 20,
            ),
          ],
        );
      },
    );
  }
}
