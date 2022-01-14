import 'package:flutter/material.dart';
import 'package:vtc_ori_client/PreConfig.dart';
import 'package:vtc_ori_client/Widgets.dart';
import 'package:vtc_ori_client/login3.dart';

class Login2 extends StatefulWidget {
  const Login2({Key key}) : super(key: key);

  @override
  _Login2State createState() => _Login2State();
}

class _Login2State extends State<Login2> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: whiteColor,
        body: SingleChildScrollView(
          child: Column(children: [
            Container(
              margin: EdgeInsets.only(bottom: 20),
              width: width,
              height: height / 1.5,
              child: Image.asset(
                isDark ? "assets/10.PNG" : "assets/7.PNG",
                fit: BoxFit.fill,
              ),
            ),
            Text(
              "Advanced Assistant",
              style: titerStyle,
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              "Talk to Ori,he loves to chat and will be ",
              style: TextStyle(color: blackColor, fontSize: 15),
            ),
            SizedBox(
              height: 5,
            ),
            Text("happy to help you during the working day",
                style: TextStyle(color: blackColor, fontSize: 15)),
            SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: bleuColor,
                  radius: 4,
                ),
                SizedBox(
                  width: 5,
                ),
                CircleAvatar(
                  backgroundColor: Colors.grey[300],
                  radius: 4,
                ),
              ],
            ),
            Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: InkWell(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Login3()));
                    },
                    child: Button(context, "Next")))
          ]),
        ));
  }
}
