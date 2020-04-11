import 'package:final_project/providers/user.dart';
import 'package:final_project/widgets/gender.dart';
import 'package:final_project/widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:validators/validators.dart' as validate;

class EditProfileScreen extends StatefulWidget {
  static const routeName = '/edit_profile';

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _lastNameNode = FocusNode();
  final _followersNode = FocusNode();
  final _emailNode = FocusNode();
  final _avgLikesNode = FocusNode();
  final _form = GlobalKey<FormState>();

  var _user = User(
    id: '',
    firstName: '',
    lastName: '',
    email: '',
    avgLikes: '',
    followers: '',
    userName: '',
    password: '',
    gender: '',
  );

  @override
  void dispose() {
    super.dispose();
    _emailNode.dispose();
    _followersNode.dispose();
    _avgLikesNode.dispose();
    _lastNameNode.dispose();
  }

  void _saveForm() {
    _form.currentState.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: GestureDetector(
          onTap: () => {Navigator.of(context).pushReplacementNamed('/')},
          child: Text(
            'Virality',
            style: TextStyle(
                height: 500,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
        ),
      ),
      backgroundColor: Colors.blue[50],
      body: Padding(
        padding:
            EdgeInsets.only(top: 60.0, bottom: 60.0, left: 120.0, right: 120.0),
        child: Form(
          key: _form,
          child: Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40.0)),
            elevation: 5.0,
            child: Container(
              child: Row(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width / 3.3,
                    height: MediaQuery.of(context).size.height,
                    color: Colors.lightBlue[600],
                    child: Padding(
                      padding:
                          EdgeInsets.only(top: 85.0, right: 50.0, left: 50.0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: 60.0,
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
                              child: Text(
                                "Edit you're profile data",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30.0,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
                              child: Text(
                                "It should only take a couple of minutes to edit your account",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(
                              height: 50.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                        top: 15.0, right: 70.0, left: 70.0, bottom: 10.0),
                    child: Column(
                      children: <Widget>[
                        Text(
                          "Edit Profile",
                          style: TextStyle(
                              color: Colors.lightBlue,
                              fontWeight: FontWeight.w600,
                              fontSize: 35.0,
                              fontFamily: 'Merriweather'),
                        ),
                        const SizedBox(height: 21.0),

                        //InputField Widget from the widgets folder
                        InputField(
                          label: "Username",
                          content: "a_khanooo",
                          onSave: (value) {
                            _user.userName = value;
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              return "Enter user name";
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 20.0),

                        //Gender Widget from the widgets folder
                        Gender(
                          gender: this.changeGender,
                        ),

                        SizedBox(height: 20.0),

                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            InputField(
                              label: "First name",
                              content: "first name",
                              onSave: (value) {
                                _user.firstName = value;
                              },
                              validator: (value) {
                                if (value.isEmpty) {
                                  return "Enter your first name";
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20.0),
                            InputField(
                              label: "Last name",
                              content: "last name",
                              onSave: (value) {
                                _user.followers = value;
                              },
                              validator: (value) {
                                if (value.isEmpty) {
                                  return "Enter your last name";
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 20.0),

                        //InputField Widget from the widgets folder
                        Row(
                          children: <Widget>[
                            InputField(
                              label: "Number of followers",
                              content: "0",
                              onSave: (value) {
                                _user.lastName = value;
                              },
                              validator: (value) {
                                if (value.isEmpty) {
                                  return "Enter number of followers";
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20.0),
                            InputField(
                              label: "Email",
                              content: "anything@site.com",
                              onSave: (value) {
                                _user.email = value;
                              },
                              validator: (value) {
                                if (!validate.isEmail(value)) {
                                  return "Please enter a valid email";
                                }
                                return null;
                              },
                            ),
                          ],
                        ),

                        SizedBox(height: 20.0),

                        Row(
                          children: <Widget>[
                            InputField(
                              label: "Password",
                              content: "********",
                              isPassword: true,
                              onSave: (value) {
                                _user.password = value;
                              },
                              validator: (value) {
                                if (value.length < 8) {
                                  return "Password must coantoin at least 8 chars";
                                }
                                _form.currentState.save();
                                return null;
                              },
                            ),
                            InputField(
                              label: "Confirm Password",
                              content: "********",
                              isPassword: true,
                              validator: (value) {
                                if (value != _user.password) {
                                  return "Password is not match!";
                                }
                                return null;
                              },
                            ),
                          ],
                        ),

                        SizedBox(height: 20.0),

                        SizedBox(
                          height: 40.0,
                        ),

                        Row(
                          children: <Widget>[
                            SizedBox(
                              width: 170.0,
                            ),
                            FlatButton(
                              color: Colors.grey[200],
                              onPressed: () {},
                              child: Text("Cancel"),
                            ),
                            SizedBox(
                              width: 20.0,
                            ),
                            FlatButton(
                              color: Colors.lightBlue,
                              onPressed: () {
                                if (_form.currentState.validate()) {
                                  _form.currentState.save();
                                  Navigator.pop(context);
                                }
                              },
                              child: Text(
                                "Save",
                                style: TextStyle(color: Colors.white),
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
        ),
      ),
    );
  }

  changeGender(gender) {
    _user.gender = gender;
  }
}
