import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:vtc_ori_client/PreConfig.dart';
import 'package:vtc_ori_client/Widgets.dart';
import 'package:vtc_ori_client/status.dart';

class Profile extends StatefulWidget {
  const Profile({Key key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool enable = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: whiteColor,
      body: Container(
        padding: EdgeInsets.only(left: 10, right: 20, top: 30),
        child: Center(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Status(),
                          ));
                    },
                    child: Icon(
                      Feather.arrow_left,
                      color: blackColor,
                    ),
                  ),
                  Text(
                    "Profile",
                    style: titerStyle,
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        enable = !enable;
                      });
                    },
                    child: enable
                        ? Text(
                            "Save",
                            style: TextStyle(
                                fontSize: 18,
                                color: bleuColor,
                                fontWeight: FontWeight.w600),
                          )
                        : Text(
                            "Edit",
                            style: TextStyle(
                                fontSize: 18,
                                color: greyColor2,
                                fontWeight: FontWeight.w600),
                          ),
                  )
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                height: 105,
                width: 112,
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                            border: Border.all(color: greyClor, width: 3),
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey[300]),
                        child: Icon(
                          Icons.camera_alt,
                          color: whiteColor,
                          size: 40,
                        ),
                      ),
                    ),
                    if (enable)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: bleuColor),
                          child: InkWell(
                            onTap: () {},
                            child: Icon(
                              Feather.camera,
                              size: 15,
                              color: whiteColor,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    text_field(Feather.user, "Lastname", 3, enable, context),
                    text_field(Feather.user, "Firstname", 3, enable, context),
                    text_field(Feather.mail, "Email", 4, enable, context),
                    text_field(Feather.unlock, "Password", 3, enable, context),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 20, right: 20, top: 15),
                padding: EdgeInsets.only(left: 15),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: whiteColor2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        if (isDark == false)
                          Icon(
                            Ionicons.ios_sunny,
                            color: orangeColor,
                            size: 25,
                          )
                        else
                          Icon(
                            Ionicons.moon_sharp,
                            color: orangeColor,
                            size: 22,
                          ),
                        SizedBox(
                          width: 15,
                        ),
                        Text(
                          isDark ? "Dark" : "Light",
                          style: TextStyle(color: greyColor2, fontSize: 15),
                        )
                      ],
                    ),
                    Switch(
                        activeColor: bleuColor,
                        activeTrackColor: greyClor,
                        inactiveThumbColor: orangeColor,
                        inactiveTrackColor: greyClor,
                        value: isDark,
                        onChanged: (val) {
                          setState(() {
                            isDark = val;
                            if (isDark) {
                              blackColor = Colors.white;
                              whiteColor = Colors.black;
                              whiteColor2 = Colors.grey[850];
                              greyColor2 = Colors.white;
                              greyClor = Colors.grey[800];
                              greyColor3 = Colors.grey[850];

                              titerStyle = TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white);
                            } else {
                              blackColor = Color(0xFF020C37);

                              greyClor = Color(0xFFF0F3F8);
                              whiteColor = Colors.white;
                              whiteColor2 = Colors.white;
                              greyColor2 = Colors.grey;
                              greyColor3 = Colors.grey[100];
                              titerStyle = TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w600,
                                  color: blackColor);
                            }
                          });
                        })
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
