import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:vtc_ori_client/PreConfig.dart';
import 'package:vtc_ori_client/Widgets.dart';
import 'package:vtc_ori_client/login2.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key key,
  }) : super(
          key: key,
        );

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int num = 0;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: whiteColor,
        body: SingleChildScrollView(
            padding: EdgeInsets.only(top: height / 4),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "Welcome!",
                      style: titerStyle,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: Container(
                      padding: EdgeInsets.only(top: 13, left: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: greyColor3,
                        ),
                        child: Container(
                          padding: EdgeInsets.all(1.5),
                          height: 47,
                          child: CustomSlidingSegmentedControl<int>(
                            children: {
                              0: Container(
                                  width: width / 6,
                                  child: Center(
                                    child: Text(
                                      'Sign In',
                                      style: TextStyle(
                                          color: blackColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )),
                              1: Container(
                                  width: 65,
                                  child: Center(
                                    child: Text('Sign Up',
                                        style: TextStyle(
                                            color: blackColor,
                                            fontWeight: FontWeight.bold)),
                                  )),
                            },
                            thumbColor: bleuColor,
                            duration: Duration(milliseconds: 200),
                            radius: 30.0,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30)),
                            onValueChanged: (index) {
                              setState(() {
                                num = index;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  if (num == 0)
                    Column(
                      children: [
                        text_field(
                            Feather.phone, "Phone Number", 1, true, context),
                        text_field(
                            Feather.unlock, "Password", 2, true, context),
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () {},
                              child: Text(
                                "Forgot your password?",
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: blackColor),
                              ),
                            )
                          ],
                        ),
                        InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Login2()));
                            },
                            child: Button(context, "Continue"))
                      ],
                    ),
                  if (num == 1)
                    Column(
                      children: [
                        text_field(Feather.user, "Lastname", 3, true, context),
                        text_field(Feather.user, "Firstname", 3, true, context),
                        text_field(
                            Feather.phone, "Phone Number", 1, true, context),
                        text_field(
                            Feather.unlock, "Password", 3, true, context),
                        SizedBox(
                          height: 20,
                        ),
                        InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Login2()));
                            },
                            child: Button(context, "Create Acount"))
                      ],
                    ),
                ],
              ),
            )));
  }
}
