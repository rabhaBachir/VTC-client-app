import 'package:flutter/material.dart';
import 'package:vtc_ori_client/status.dart';

import 'PreConfig.dart';
import 'Widgets.dart';

class Login3 extends StatefulWidget {
  const Login3({Key key}) : super(key: key);

  @override
  _Login3State createState() => _Login3State();
}

class _Login3State extends State<Login3> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: whiteColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 20),
              width: width,
              height: height / 1.5,
              child: Image.asset(
                isDark ? "assets/11.PNG" : "assets/8.PNG",
                fit: BoxFit.fill,
              ),
            ),
            Text(
              "Car Connection",
              style: titerStyle,
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              "Get the latest information on the status",
              style: TextStyle(color: blackColor, fontSize: 15),
            ),
            SizedBox(
              height: 5,
            ),
            Text("of your vehicle directly in the app",
                style: TextStyle(color: blackColor, fontSize: 15)),
            SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey[300],
                  radius: 4,
                ),
                SizedBox(
                  width: 5,
                ),
                CircleAvatar(
                  backgroundColor: bleuColor,
                  radius: 4,
                ),
              ],
            ),
            Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: InkWell(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Status()));
                    },
                    child: Button(context, "Let's start")))
          ],
        ),
      ),
    );
  }
}
