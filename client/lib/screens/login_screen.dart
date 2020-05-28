import 'package:final_project/providers/auth.dart';
import 'package:final_project/providers/users.dart';
import 'package:final_project/widgets/http_exception.dart';
import 'package:validators/validators.dart' as validate;
import 'package:final_project/providers/user.dart';
import 'package:final_project/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/input_field.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();

  final User _user = User(
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

  void _showErrorDialog(String error) {
    showDialog(context: context,
    builder: (ctx) => AlertDialog(
      title: Text('An error occured'),
      content: Text(error),
      actions: <Widget>[
        FlatButton(onPressed: () {
          Navigator.of(ctx).pop();
        }, child: Text('OK'))
      ],
    ));
  }

  void _saveForm(context) async {
    if (!_form.currentState.validate()) {
      return;
    }
    _form.currentState.save();
    try {
      await Provider.of<Users>(context, listen: false)
          .login(_user);
      Navigator.of(context).pushNamed('/');
    } on HttpException catch (error) {
      var message = "Could not Authenticate";
      if(error.toString().contains("EMAIL_EXISTS")){
        message = "This email adsress id already exists";
      } else if (error.toString().contains("INVALID_EMAIL")){
        message = "This is not a valid email.";
      } else if (error.toString().contains("EMAIL_NOT_FOUND")) {
        message = "Could not find user with this email";
      } else if (error.toString().contains("INVALID_PASSWORD")) {
        message = "Invalid password";
      }

      _showErrorDialog(message);
    } catch (error) {
      const message = "Authenticated Failed!";
      _showErrorDialog(message);
    }
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
      body: Form(
        key: _form,
        child: Padding(
          padding: EdgeInsets.only(
              top: 60.0, bottom: 60.0, left: 120.0, right: 120.0),
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
                                "Go ahead and Login",
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
                                "It should only take a couple of seconds to login to your account",
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
                            FlatButton(
                              color: Colors.lightBlue,
                              onPressed: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return new SignUpScreen();
                                }));
                              },
                              child: Text(
                                "Create Account",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                        top: 140.0, right: 70.0, left: 70.0, bottom: 5.0),
                    child: Column(
                      children: <Widget>[
                        Text(
                          "Login",
                          style: TextStyle(
                              color: Colors.lightBlue,
                              fontWeight: FontWeight.w600,
                              fontSize: 35.0,
                              fontFamily: 'Merriweather'),
                        ),
                        const SizedBox(height: 21.0),

                        //InputField Widget from the widgets folder
                        InputField(
                          label: "Email",
                          content: "email@some.com",
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

                        SizedBox(height: 20.0),

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
                            return null;
                          },
                          isLogin: true,
                          onSubmitForLogin: (_) {
                            _saveForm(context);
                          },
                        ),

                        SizedBox(height: 20.0),

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
                                _saveForm(context);
                              },
                              child: Text(
                                "Login",
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
      drawer: AppDrawer(),
    );
  }
}
