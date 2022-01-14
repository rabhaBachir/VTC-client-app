import 'package:flutter/material.dart';

import 'package:vtc_ori_client/PreConfig.dart';
import 'package:vtc_ori_client/Widgets.dart';

class Rating extends StatefulWidget {
  const Rating({Key key}) : super(key: key);

  @override
  _RatingState createState() => _RatingState();
}

class _RatingState extends State<Rating> {
  String selectedImage = "assets/Great.gif";
  String text = "Great";
  int selected = 5;
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: whiteColor,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 20,
          ),
          margin: EdgeInsets.only(top: height / 4),
          child: Center(
            child: Column(
              children: [
                Image.asset(
                  selectedImage,
                  width: 150,
                  height: 150,
                  fit: BoxFit.fill,
                ),
                SizedBox(
                  height: 30,
                ),
                Text(
                  text,
                  style: titerStyle,
                ),
                SizedBox(
                  height: 50,
                ),
                Text(
                  "Rate your passenger",
                  style: TextStyle(fontSize: 18, color: blackColor),
                ),
                SizedBox(
                  height: 25,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon_rating("assets/Engry.gif", "Awfully", 1),
                    Icon_rating("assets/Sad.gif", "Bad", 2),
                    Icon_rating("assets/Normal.gif", "Normal", 3),
                    Icon_rating("assets/Good.gif", "Good", 4),
                    Icon_rating("assets/Great.gif", "Great", 5),
                  ],
                ),
                InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Button(context, "Send")),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget Icon_rating(String image, String txt, int index) {
    return Stack(
      children: [
        Image.asset(
          image,
          width: 50,
          height: 50,
        ),
        if (selected != index)
          Positioned(
              top: 5,
              left: 5,
              child: InkWell(
                onTap: () {
                  setState(() {
                    selected = index;
                    selectedImage = image;
                    text = txt;
                  });
                },
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white.withOpacity(0.6),
                ),
              ))
      ],
    );
  }
}
