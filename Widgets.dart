import 'dart:typed_data';

import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;

import 'package:vtc_ori_client/main.dart';
import 'package:vtc_ori_client/profil.dart';

import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:vtc_ori_client/status.dart';

import 'PreConfig.dart';
import 'package:google_maps_webservice/places.dart';
import 'dart:ui' as ui;

///////////////////// button bleu
Widget Button(BuildContext context, String text) {
  return Container(
    margin: EdgeInsets.only(top: 20, bottom: 20),
    padding: EdgeInsets.symmetric(vertical: 12),
    width: MediaQuery.of(context).size.width,
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10), color: Color(0xFF2D8EFF)),
    child: Center(
      child: Text(
        text,
        style: TextStyle(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
      ),
    ),
  );
}

///////////// les icons recherch et location
Widget IconWidget(IconData icn, double left, double top) {
  return Stack(
    children: [
      Container(
        padding: EdgeInsets.all(11),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: whiteColor,
        ),
        child: Icon(
          icn,
          color: greyColor2,
          size: 20,
        ),
      ),
      Positioned(
          left: left,
          top: top,
          child: Center(
            child: Text(
              "•",
              style: TextStyle(
                fontSize: 18,
                color: orangeColor,
              ),
            ),
          )),
    ],
  );
}

/////////////////// photo profil driver,client,Ori
Widget photoWidget(
  BuildContext context,
  String image,
) {
  return CircleAvatar(
    backgroundColor: Colors.white,
    radius: 20,
    backgroundImage: AssetImage(image),
  );
}

/////////////////// row qui contient recherch icon,photo de profil, price et num order

Widget TopRow(Function f, double price, int orderNumber, String image,
    BuildContext context) {
  var photoWidget2 = photoWidget(
    context,
    image,
  );

  return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState1) {
    return Positioned(
      top: 50,
      right: 20,
      left: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(onTap: f, child: IconWidget(Fontisto.search, 16, 9)),
          InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MyHomePage()));
              },
              child: Container(
                width: 95,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    border: Border.all(color: greyClor),
                    borderRadius: BorderRadius.circular(20),
                    color: whiteColor),
                child: Column(
                  children: [
                    RichText(
                      text: TextSpan(
                        text: '\$ ',
                        style: TextStyle(
                            color: orangeColor, fontWeight: FontWeight.bold),
                        children: <TextSpan>[
                          TextSpan(
                              text: price.toString(),
                              style: TextStyle(
                                  color: blackColor,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Text(orderNumber.toString() + " order",
                        style: TextStyle(color: blackColor))
                  ],
                ),
              )),
          InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Profile()));
              },
              child: photoWidget2)
        ],
      ),
    );
  });
}

//////////////////////// les icon grey dans un circle
Widget CircleIcone(IconData icn, Color color) {
  return Container(
    padding: EdgeInsets.all(11),
    decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]),
        shape: BoxShape.circle,
        color: whiteColor),
    child: Icon(
      icn,
      color: color,
      size: 20,
    ),
  );
}

///////////////////////  blanc container qui contient distance, vitesse, adresse
Widget Top_Container(double distance, double vitesse, String adresse) {
  return Positioned(
      top: 30,
      left: 20,
      right: 20,
      child: Container(
        // width: width - 40,
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: whiteColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Column(
                  children: [
                    Icon(
                      AntDesign.arrowup,
                      color: bleuColor,
                      size: 30,
                    ),
                    DottedLine(
                      direction: Axis.vertical,
                      lineLength: 18,
                      lineThickness: 2.0,
                      dashLength: 4.0,
                      dashColor: Colors.blue,
                      dashRadius: 0.0,
                      dashGapLength: 4.0,
                      dashGapColor: Colors.transparent,
                      dashGapRadius: 0,
                    ),
                  ],
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      distance.toString() + " m",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: blackColor),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      adresse,
                      style: TextStyle(fontSize: 17, color: blackColor),
                    )
                  ],
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.only(top: 7, bottom: 7),
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                  border: Border.all(
                      color: vitesse <= 60 ? greenColor : pinkColor, width: 2),
                  borderRadius: BorderRadius.circular(60),
                  color: Colors.white),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    vitesse.toString(),
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black),
                  ),
                  Text(
                    "km/h",
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black),
                  )
                ],
              ),
            )
          ],
        ),
      ));
}

Widget text_field(
    IconData icn, String text, int index, bool enable, BuildContext context) {
  return Container(
    margin: EdgeInsets.only(top: 15),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      color: whiteColor2,
    ),
    child: Theme(
      data: Theme.of(context).copyWith(
        primaryColor: bleuColor,
      ),
      child: TextField(
        cursorColor: bleuColor,
        style: TextStyle(
          color: blackColor,
        ),
        enabled: enable,
        keyboardType: index == 1
            ? TextInputType.number
            : index == 2 || index == 3
                ? TextInputType.text
                : TextInputType.emailAddress,
        decoration: InputDecoration(
            prefixIcon: Icon(
              icn,
              size: 20,
              color: blackColor == Colors.white ? greyColor2 : null,
            ),
            hintText: text,
            hintStyle: TextStyle(color: greyColor2, fontSize: 15)),
      ),
    ),
  );
}
