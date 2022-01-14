import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_google_places/flutter_google_places.dart';

import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:vtc_ori_client/PreConfig.dart';
import 'package:vtc_ori_client/Widgets.dart';
import 'package:location/location.dart' as loc;

import 'package:vtc_ori_client/profil.dart';
import 'dart:ui' as ui;
import 'Rating.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class Status extends StatefulWidget {
  const Status({Key key}) : super(key: key);

  @override
  _StatusState createState() => _StatusState();
}

bool Ori = false;

class _StatusState extends State<Status> with WidgetsBindingObserver {
  void initState() {
    super.initState();
    setCustomMarker();
    setCustomMarker2();
    _geTMyLOcation();
    polylinePoints = PolylinePoints();

    WidgetsBinding.instance.addObserver(this);
    _loadMapStyles();
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  static CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  Completer<GoogleMapController> _controller = Completer();

  GoogleMapController mapController;
  loc.Location location = new loc.Location();

  loc.LocationData _locationData;
  CameraPosition _myLocation;

  Set<Marker> _marker = {};
  Set<Polyline> _polylines = {};
  BitmapDescriptor mapmarker;
  Uint8List markerIcon;
  Uint8List markerIcon2;
  String kGoogleApiKey = "AIzaSyCwmdbyw0i_VnjlQdInWdJgJMOrK4stF_U";
  double latitude1;
  double longitude1;
  ////////////////////////////between 2 location
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

////////////////////////////////////
  bool Status = true;
  bool newOrder = false;
  bool OnTheWay = false;
  bool ToTheDestination = false;
  // bool Ori = false;
  bool showPlan = false;
  bool dayPlan = false;
  String hour = "";
  bool showCarDiagnostic = false;
  bool showScanner = false;
  bool TakeBreak = false;

  ///////////////////////////////// map styles
  String _darkMapStyle;
  String _lightMapStyle;
  Future _loadMapStyles() async {
    _darkMapStyle = await rootBundle.loadString('assets/map_style/dark.json');
    _lightMapStyle = await rootBundle.loadString('assets/map_style/light.json');
  }

  Future _setMapStyle() async {
    final controller = await _controller.future;

    if (isDark)
      controller.setMapStyle(_darkMapStyle);
    else
      controller.setMapStyle(_lightMapStyle);
  }

  void changeMapStyle() {
    setState(() {
      _setMapStyle();
    });
  }

//////////////////////////////// markers and location
  Future<void> _geTMyLOcation() async {
    _locationData = await location.getLocation();
    _myLocation = CameraPosition(
        target: LatLng(_locationData.latitude, _locationData.longitude),
        zoom: 14.0);
    set_marker(LatLng(_locationData.latitude, _locationData.longitude), 'id-1',
        markerIcon);
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
  }

  void setCustomMarker() async {
    markerIcon = await getBytesFromAsset('assets/5.png', 100);
  }

  void setCustomMarker2() async {
    markerIcon2 = await getBytesFromAsset('assets/3.png', 100);
  }

  void set_marker(LatLng point, String id, Uint8List markericn) {
    _marker.add(Marker(
        markerId: MarkerId(id),
        position: point,
        icon: BitmapDescriptor.fromBytes(markericn)));
  }

  _addPolyLine() {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
        //  width: 5,
        polylineId: id,
        color: Color(0xFF2D8EFF),
        points: polylineCoordinates);
    polylines[id] = polyline;
    setState(() {});
  }

  _getPolyline() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      kGoogleApiKey,
      PointLatLng(_locationData.latitude, _locationData.longitude),
      PointLatLng(latitude1, longitude1),
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    _addPolyLine();
  }

  ///////////////////// get the search location

  void _getLatLng(
    Prediction p,
  ) async {
    GoogleMapsPlaces _places = new GoogleMapsPlaces(apiKey: kGoogleApiKey);
    PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(p.placeId);
    latitude1 = detail.result.geometry.location.lat;
    longitude1 = detail.result.geometry.location.lng;
    set_marker(LatLng(latitude1, longitude1), 'id-2', markerIcon2);

    setState(() {
      mapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(latitude1, longitude1), zoom: 14.0)));
    });
  }

  /////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: whiteColor,
      body: SingleChildScrollView(
        child: Container(
          height: height,
          child: Stack(
            children: [
              Container(
                height: height - 50,
                width: width,
                child: GoogleMap(
                    tiltGesturesEnabled: false,
                    mapType: MapType.normal,
                    buildingsEnabled: false,
                    zoomControlsEnabled: false,
                    initialCameraPosition:
                        _myLocation == null ? _kGooglePlex : _myLocation,
                    markers: _marker,
                    polylines: Set<Polyline>.of(polylines.values),
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                      mapController = controller;

                      changeMapStyle();
                    }),
              ),
              Ori_Row(context),
              if (Status) status(context, "assets/1.jpg", 142.04, 0),
              if (newOrder) New_Order(context),
              if (OnTheWay) On_TheWay(0, 40),
              if (ToTheDestination) To_TheDestination(0, 80),
              if (Ori) OriWidget(),
            ],
          ),
        ),
      ),
    );
  }

  //////////////////////////////////////////
  ///////////////////////////////////////// widgets
  Widget Ori_Row(BuildContext context) {
    return Positioned(
        top: (MediaQuery.of(context).size.height - 150) / 2,
        right: 20,
        left: 20,
        child: Row(
          mainAxisAlignment:
              Ori ? MainAxisAlignment.end : MainAxisAlignment.spaceBetween,
          children: [
            if (Ori == false)
              InkWell(
                  child: InkWell(
                onTap: () {
                  setState(() {
                    Ori = true;
                    Status = true;
                    newOrder = false;
                    OnTheWay = false;
                    ToTheDestination = false;
                  });
                },
                child: photoWidget(
                  context,
                  "assets/2.png",
                ),
              )),
            InkWell(
                onTap: () async {
                  await _geTMyLOcation();
                  setState(() {
                    mapController.animateCamera(
                      CameraUpdate.newCameraPosition(_myLocation),
                    );
                  });
                },
                child: IconWidget(MaterialIcons.location_searching, 18, 11))
          ],
        ));
  }

/////////////// first screen
  Widget status(
      BuildContext context, String image, double price, int orderNumber) {
    return Stack(
      children: [
        TopRow(() async {
          Prediction p = await PlacesAutocomplete.show(
            logo: Text(""),
            // overlayBorderRadius: BorderRadius.circular(10),
            context: context,
            apiKey: kGoogleApiKey,
            types: [],
            strictbounds: false,
            mode: Mode.overlay,
            language: "en",
            decoration: InputDecoration(
              hintText: 'Search',
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(
                  color: Colors.white,
                ),
              ),
            ),
            location: _locationData == null
                ? null
                : Location(
                    lat: _locationData.latitude, lng: _locationData.longitude),
            radius: 10000000,
            components: [Component(Component.country, "DZ")],
          );
          _getLatLng(p);
        }, price, orderNumber, image, context),
        Positioned(
            left: (MediaQuery.of(context).size.width - 90) / 2,
            bottom: 70,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                  border: Border.all(color: bleuColor),
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.transparent),
            )),
        if (newOrder == false && Ori == false)
          Positioned(
              left: (MediaQuery.of(context).size.width - 70) / 2,
              bottom: 80,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _getPolyline();
                  });
                },
                child: Container(
                  padding: EdgeInsets.only(top: 15, bottom: 15),
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                      border: Border.all(color: bleuColor, width: 3),
                      borderRadius: BorderRadius.circular(50),
                      color: whiteColor),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        "assets/5.png",
                        height: 20,
                        width: 20,
                      ),
                      Text(
                        "GO",
                        style: TextStyle(
                            fontSize: 15,
                            color: blackColor,
                            fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                ),
              )),
        if (newOrder == false)
          Positioned(
              bottom: 0,
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10)),
                    color: whiteColor),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          newOrder = true;
                        });
                      },
                      child: Icon(
                        Feather.arrow_up_circle,
                        size: 25,
                        color: greyColor2,
                      ),
                    ),
                    Text(
                      "Shift has not started",
                      style: TextStyle(
                          color: blackColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                    ),
                    Icon(
                      Feather.menu,
                      size: 25,
                      color: greyColor2,
                    ),
                  ],
                ),
              )),
      ],
    );
  } ///////////

  ///////// New order
  Widget New_Order(BuildContext context) {
    return Stack(
      children: [
        Positioned(
            bottom: 0,
            child: Container(
                height: 280,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  color: whiteColor,
                ))),
        Positioned(
            bottom: 0,
            child: Container(
                margin: EdgeInsets.all(20),
                width: MediaQuery.of(context).size.width - 40,
                child: Column(children: [
                  Container(
                    width: MediaQuery.of(context).size.width - 40,
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.grey[400],
                        ),
                        color: whiteColor2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "New Order",
                                  style: TextStyle(
                                      fontSize: 18, color: blackColor),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          color: greyClor),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Feather.clock,
                                            size: 18,
                                            color: bleuColor,
                                          ),
                                          Text(
                                            " " + "12 min",
                                            style: TextStyle(color: blackColor),
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Container(
                                        padding: EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            color: greyClor),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Ionicons.location_outline,
                                              size: 20,
                                              color: bleuColor,
                                            ),
                                            Text(" " + "4 km",
                                                style: TextStyle(
                                                    color: blackColor))
                                          ],
                                        ))
                                  ],
                                )
                              ],
                            ),
                            InkWell(
                                onTap: () {
                                  setState(() {
                                    newOrder = false;
                                  });
                                },
                                child: CircleIcone(Feather.x, greyColor2)),
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 20),
                          width: MediaQuery.of(context).size.width,
                          height: 1,
                          color: Colors.grey[200],
                        ),
                        Row(
                          children: [
                            Icon(
                              MaterialCommunityIcons.alpha_m_circle_outline,
                              color: pinkColor,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              "m.Bulerussien ",
                              style: TextStyle(fontSize: 17, color: blackColor),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 7,
                            ),
                            Icon(
                              FontAwesome.circle_o,
                              color: bleuColor,
                              size: 13,
                            ),
                            SizedBox(
                              width: 13,
                            ),
                            Text(
                              "Mitrofanovo,25,p,4 ",
                              style: TextStyle(fontSize: 17, color: blackColor),
                            )
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 20),
                          width: MediaQuery.of(context).size.width,
                          height: 1,
                          color: Colors.grey[200],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Price",
                                    style: TextStyle(
                                      color: blackColor,
                                    )),
                                SizedBox(
                                  height: 5,
                                ),
                                RichText(
                                  text: TextSpan(
                                    text: '\$ ',
                                    style: TextStyle(
                                        color: orangeColor,
                                        fontWeight: FontWeight.bold),
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: '15,44',
                                          style: TextStyle(
                                              color: blackColor,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Column(
                                  children: [
                                    Text("Rating",
                                        style: TextStyle(
                                          color: blackColor,
                                        )),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          FontAwesome.star,
                                          color: orangeColor,
                                          size: 15,
                                        ),
                                        Text(" " + "4.8",
                                            style: TextStyle(
                                                color: blackColor,
                                                fontWeight: FontWeight.bold))
                                      ],
                                    )
                                  ],
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Profile()));
                                    },
                                    child: photoWidget(
                                      context,
                                      "assets/1.jpg",
                                    )),
                              ],
                            ),
                            CircleIcone(Feather.git_pull_request, orangeColor),
                          ],
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                      onTap: () {
                        setState(() {
                          Status = false;
                          newOrder = false;
                          OnTheWay = true;
                        });
                      },
                      child: Button(context, "Accept"))
                ]))),
      ],
    );
  }

////////////////////////////
  ///after accept order (on the way to client)
  Widget On_TheWay(double distance, double vitesse) {
    return Stack(
      children: [
        Top_Container(400, 80, "Mitrofanovo "),
        Positioned(
            top: (MediaQuery.of(context).size.height - 375) / 2,
            right: 20,
            child: Column(
              children: [
                InkWell(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Profile()));
                    },
                    child: InkWell(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => Profile()));
                      },
                      child: photoWidget(
                        context,
                        "assets/1.jpg",
                      ),
                    )),
                SizedBox(
                  height: 15,
                ),
                InkWell(
                    onTap: () async {
                      Prediction p = await PlacesAutocomplete.show(
                        overlayBorderRadius: BorderRadius.circular(10),
                        context: context,
                        apiKey: kGoogleApiKey,
                        types: [],
                        strictbounds: false,
                        mode: Mode.overlay,
                        language: "en",
                        decoration: InputDecoration(
                          hintText: 'Search',
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        location: location == null
                            ? null
                            : Location(
                                lat: _locationData.latitude,
                                lng: _locationData.longitude),
                        radius: 10000000,
                        components: [Component(Component.country, "DZ")],
                      );
                      _getLatLng(p);
                    },
                    child: IconWidget(Fontisto.search, 16, 9))
              ],
            )),
        Positioned(
            bottom: 0,
            child: Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10)),
                    color: whiteColor),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (distance > 20)
                          Icon(
                            Feather.arrow_up_circle,
                            size: 25,
                            color: greyColor2,
                          )
                        else
                          InkWell(
                            onTap: () {
                              setState(() {
                                OnTheWay = false;
                                Status = true;
                              });
                            },
                            child: Icon(
                              Feather.arrow_down_circle,
                              size: 25,
                              color: greyColor2,
                            ),
                          ),
                        if (distance == 0)
                          Text(
                            "Client goes out",
                            style: TextStyle(
                              color: bleuColor,
                              fontSize: 18,
                              // fontWeight: FontWeight.w600
                            ),
                          )
                        else
                          Column(
                            children: [
                              Text(
                                "5:12",
                                style: TextStyle(
                                    color: blackColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                "Picking up client",
                                style: TextStyle(
                                  color: blackColor,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        Icon(
                          Feather.menu,
                          size: 25,
                          color: greyColor2,
                        ),
                      ],
                    ),
                    if (distance < 20)
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 20),
                        width: MediaQuery.of(context).size.width,
                        height: 1,
                        color: Colors.grey[200],
                      ),
                    if (distance < 20)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CircleIcone(Feather.phone, greyColor2),
                          Row(
                            children: [
                              Icon(
                                FontAwesome.cc_mastercard,
                                color: blackColor,
                                size: 18,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                "Payment by card",
                                style: TextStyle(
                                    color: blackColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600),
                              )
                            ],
                          ),
                          CircleIcone(Feather.info, greyColor2),
                        ],
                      ),
                    if (distance < 20 && distance != 0)
                      Button(context, "On the spot"),
                    if (distance == 0)
                      InkWell(
                          onTap: () {
                            setState(() {
                              OnTheWay = false;
                              ToTheDestination = true;
                            });
                          },
                          child: Button(context, "Start"))
                  ],
                ))),
      ],
    );
  }

  ////////////// to the destination
  Widget To_TheDestination(double distance, double vitesse) {
    return Stack(
      children: [
        Top_Container(distance, vitesse, "Builders st"),
        Positioned(
            top: (MediaQuery.of(context).size.height - 375) / 2,
            right: 20,
            child: Column(
              children: [
                InkWell(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Profile()));
                    },
                    child: photoWidget(
                      context,
                      "assets/1.jpg",
                    )),
                SizedBox(
                  height: 15,
                ),
                IconWidget(Fontisto.search, 16, 9)
              ],
            )),
        Positioned(
            bottom: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10)),
                  color: whiteColor),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (distance != 0)
                        Icon(
                          Feather.arrow_up_circle,
                          size: 25,
                          color: greyColor2,
                        )
                      else
                        InkWell(
                          onTap: () {
                            setState(() {
                              ToTheDestination = false;
                              Status = true;
                            });
                          },
                          child: Icon(
                            Feather.arrow_down_circle,
                            size: 25,
                            color: greyColor2,
                          ),
                        ),
                      if (distance == 0)
                        Text(
                          "You're on the spot",
                          style: TextStyle(
                            color: bleuColor,
                            fontSize: 18,
                          ),
                        )
                      else
                        Column(
                          children: [
                            Text(
                              "22:15",
                              style: TextStyle(
                                  color: blackColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              "To destination",
                              style: TextStyle(
                                color: blackColor,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      Icon(
                        Feather.menu,
                        size: 25,
                        color: greyColor2,
                      ),
                    ],
                  ),
                  if (distance == 0)
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 20),
                      width: MediaQuery.of(context).size.width,
                      height: 1,
                      color: Colors.grey[200],
                    ),
                  if (distance == 0)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.all(11),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[200]),
                              shape: BoxShape.circle,
                              color: whiteColor),
                          child: Icon(
                            Feather.phone,
                            color: greyColor2,
                            size: 20,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              FontAwesome.cc_mastercard,
                              color: pinkColor,
                              size: 18,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              "\$ " + "15.44",
                              style: TextStyle(
                                  color: blackColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600),
                            )
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.all(11),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[200]),
                              shape: BoxShape.circle,
                              color: whiteColor),
                          child: Icon(
                            Feather.info,
                            color: greyColor2,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  if (distance == 0)
                    InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Rating()));
                        },
                        child: Button(context, "Finich the trip"))
                ],
              ),
            )),
      ],
    );
  }

  Widget OriWidget() {
    return Stack(
      children: [
        Positioned(
            height: 292,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.only(top: 20, bottom: 20, left: 20),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15)),
                color: whiteColor,
              ),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 30),
                    width: MediaQuery.of(context).size.width,
                    height: 33,
                    // color: Colors.blue,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        item("Finish"),
                        item("Show a profitable route"),
                        InkWell(
                            onTap: () {
                              setState(() {
                                showPlan = true;
                              });
                            },
                            child: item("Day Plan")),
                        InkWell(
                            onTap: () {
                              setState(() {
                                showCarDiagnostic = true;
                              });
                            },
                            child: item("Car Diagnostic")),
                        InkWell(
                            onTap: () {
                              setState(() {
                                TakeBreak = true;
                              });
                            },
                            child: item("Take break")),
                      ],
                    ),
                  ),
                  Text(
                    "Hello " + "Morgan" + "!",
                    style: TextStyle(
                        color: blackColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 20),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  RichText(
                    text: TextSpan(
                      text:
                          "Before you start your trip, don't forget\nto buckle up and put on your glasses,\n \t\t\t\t\t\t then say ",
                      style: TextStyle(color: blackColor, fontSize: 16),
                      children: <TextSpan>[
                        TextSpan(
                            text: "\"Let's get started\"",
                            style: TextStyle(
                                color: blackColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  BottomRow(() {
                    setState(() {
                      Ori = false;
                    });
                  }),
                ],
              ),
            )),
        ////////////////////////////////////////////////////////////////////
        ////////////////////////////////////////////////////////////////////
        ///
        if (showPlan)
          Positioned(
              height: 292,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.only(top: 20, bottom: 20, left: 20),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15)),
                  color: whiteColor,
                ),
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 30),
                      width: MediaQuery.of(context).size.width,
                      height: 33,
                      // color: Colors.blue,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          InkWell(
                              onTap: () {
                                setState(() {
                                  dayPlan = true;
                                  hour = "1";
                                });
                              },
                              child: item("1:00")),
                          InkWell(
                              onTap: () {
                                setState(() {
                                  dayPlan = true;
                                  hour = "2";
                                });
                              },
                              child: item("2:00")),
                          InkWell(
                              onTap: () {
                                setState(() {
                                  dayPlan = true;
                                  hour = "3";
                                });
                              },
                              child: item("3:00")),
                          InkWell(
                              onTap: () {
                                setState(() {
                                  dayPlan = true;
                                  hour = "4";
                                });
                              },
                              child: item("4:00")),
                          InkWell(
                              onTap: () {
                                setState(() {
                                  dayPlan = true;
                                  hour = "5";
                                });
                              },
                              child: item("5:00")),
                          InkWell(
                              onTap: () {
                                setState(() {
                                  dayPlan = true;
                                  hour = "6";
                                });
                              },
                              child: item("6:00")),
                          InkWell(
                              onTap: () {
                                setState(() {
                                  dayPlan = true;
                                  hour = "7";
                                });
                              },
                              child: item("7:00")),
                        ],
                      ),
                    ),
                    Text(
                      "Shal we plan for the day?",
                      style: TextStyle(
                          color: blackColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 20),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text("How many hours do you plan",
                        style: TextStyle(color: blackColor, fontSize: 16)),
                    SizedBox(
                      height: 5,
                    ),
                    Text("to work today?",
                        style: TextStyle(color: blackColor, fontSize: 16)),
                    SizedBox(
                      height: 50,
                    ),
                    BottomRow(() {
                      setState(() {
                        showPlan = false;
                      });
                    }),
                  ],
                ),
              )),
        ////////////////////////////////////////////////////////
        //////////////////////////////////////////////////////////
        if (dayPlan)
          Positioned(
              height: 312,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.only(top: 20, bottom: 20, left: 20),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15)),
                  color: whiteColor,
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 100,
                    ),
                    Text("Display the order counter",
                        style: TextStyle(color: blackColor, fontSize: 16)),
                    SizedBox(
                      height: 5,
                    ),
                    Text("on the screen?",
                        style: TextStyle(color: blackColor, fontSize: 16)),
                    SizedBox(
                      height: 20,
                    ),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      InkWell(onTap: () {}, child: item("Yes")),
                      InkWell(onTap: () {}, child: item("No")),
                      InkWell(
                          onTap: () {
                            setState(() {
                              dayPlan = false;
                            });
                          },
                          child: item("Cancel")),
                    ]),
                    SizedBox(
                      height: 30,
                    ),
                    BottomRow(() {
                      setState(() {
                        dayPlan = false;
                      });
                    }),
                  ],
                ),
              )),
        ////////////////////////////////////////////////////////
        ///////////////////////////////////////////////////////
        if (dayPlan)
          Positioned(
              top: MediaQuery.of(context).size.height / 2.1,
              left: 20,
              right: 20,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[200]),
                  borderRadius: BorderRadius.circular(10),
                  color: whiteColor2,
                ),
                child: Column(
                  children: [
                    Text(
                      "Approximate forecast",
                      style: TextStyle(color: bleuColor, fontSize: 18),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 25, bottom: 25),
                      width: 111,
                      padding: EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: greyClor,
                      ),
                      child: Row(
                        children: [
                          Container(
                            margin: EdgeInsets.only(right: 10),
                            padding: EdgeInsets.only(
                                top: 4, bottom: 5, left: 6, right: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: whiteColor,
                            ),
                            child: Icon(
                              Ionicons.time_outline,
                              color: bleuColor,
                              size: 20,
                            ),
                          ),
                          Text(
                            hour + " hours",
                            style: TextStyle(color: blackColor, fontSize: 15),
                          )
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text("Execute",
                                style:
                                    TextStyle(color: blackColor, fontSize: 15)),
                            SizedBox(
                              height: 5,
                            ),
                            Text("10 Orders",
                                style: TextStyle(
                                    color: blackColor,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600))
                          ],
                        ),
                        Container(
                          height: 40,
                          width: 1,
                          color: Colors.grey[300],
                        ),
                        Column(
                          children: [
                            Text("Execute",
                                style:
                                    TextStyle(color: blackColor, fontSize: 15)),
                            SizedBox(
                              height: 5,
                            ),
                            RichText(
                              text: TextSpan(
                                text: "\$ ",
                                style: TextStyle(
                                    color: orangeColor,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600),
                                children: <TextSpan>[
                                  TextSpan(
                                      text: "142.44",
                                      style: TextStyle(
                                          color: blackColor,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600))
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              )),
        /////////////////////////////////////////////////////////////////////////////////
        /////////////////////////////////////////////////////////////////////////////////

        if (showCarDiagnostic)
          Positioned(
              height: 290,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.only(top: 20, bottom: 20, left: 20),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height -
                    (MediaQuery.of(context).size.height / 1.8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15)),
                  color: whiteColor,
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          showScanner = true;
                        });
                      },
                      child: Text(
                        "One moment",
                        style: TextStyle(
                            color: blackColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 20),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text("Receiving data from the car",
                        style: TextStyle(color: blackColor, fontSize: 16)),
                    SizedBox(
                      height: 40,
                    ),
                    Container(
                      width: 200,
                      child: LinearProgressIndicator(
                        backgroundColor: greyClor,
                        minHeight: 5,
                        valueColor: AlwaysStoppedAnimation<Color>(bleuColor),
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    BottomRow(() {
                      setState(() {
                        showCarDiagnostic = false;
                      });
                    }),
                  ],
                ),
              )),
        /////////////////////////////////////////////////////////////////////////////////
        /////////////////////////////////////////////////////////////////////////////////
        if (showScanner)
          Positioned(
              height: 340,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.only(top: 20, bottom: 20, left: 20),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15)),
                  color: whiteColor,
                ),
                child: Column(
                  children: [
                    Text(
                      "Checking that ",
                      style: TextStyle(
                          color: blackColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 20),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "evreything's okay ",
                      style: TextStyle(
                          color: blackColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 20),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      height: 150,
                      width: 250,
                      decoration: BoxDecoration(
                          border: Border.all(color: greyClor),
                          borderRadius: BorderRadius.circular(5)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Image.asset(
                          "assets/4.jpg",
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    BottomRow(() {
                      setState(() {
                        showScanner = false;
                      });
                    }),
                  ],
                ),
              )),
        /////////////////////////////////////////////////////////////////////////
        ////////////////////////////////////////////////////////////////////////
        if (TakeBreak)
          Positioned(
              height: 292,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.only(top: 20, bottom: 20, left: 20),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15)),
                  color: whiteColor,
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 80,
                    ),
                    Text("Why don't we take",
                        style: TextStyle(color: blackColor, fontSize: 16)),
                    SizedBox(
                      height: 5,
                    ),
                    Text("a break?",
                        style: TextStyle(color: blackColor, fontSize: 16)),
                    SizedBox(
                      height: 20,
                    ),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      InkWell(onTap: () {}, child: item("Yes")),
                      InkWell(onTap: () {}, child: item("No")),
                      InkWell(
                          onTap: () {
                            setState(() {
                              TakeBreak = false;
                            });
                          },
                          child: item("Cancel")),
                    ]),
                    SizedBox(
                      height: 30,
                    ),
                    BottomRow(() {
                      setState(() {
                        TakeBreak = false;
                      });
                    }),
                  ],
                ),
              )),

        if (TakeBreak)
          Positioned(
              top: MediaQuery.of(context).size.height / 1.9,
              left: 20,
              right: 20,
              child: Container(
                padding:
                    EdgeInsets.only(top: 20, bottom: 20, left: 30, right: 40),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[200]),
                  borderRadius: BorderRadius.circular(10),
                  color: whiteColor2,
                ),
                child: Column(
                  children: [
                    Text(
                      "You need to rest",
                      style: TextStyle(color: bleuColor, fontSize: 18),
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text("working time",
                                style:
                                    TextStyle(color: blackColor, fontSize: 15)),
                            SizedBox(
                              height: 5,
                            ),
                            Text("4 hours",
                                style: TextStyle(
                                    color: pinkColor,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600))
                          ],
                        ),
                        Container(
                          height: 40,
                          width: 1,
                          color: Colors.grey[300],
                        ),
                        Column(
                          children: [
                            Text("break",
                                style:
                                    TextStyle(color: blackColor, fontSize: 15)),
                            SizedBox(
                              height: 5,
                            ),
                            Text("20 min",
                                style: TextStyle(
                                    color: greenColor,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600))
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              )),
      ],
    );
  }

  Widget item(String text) {
    return Container(
      margin: EdgeInsets.only(right: 10),
      padding: EdgeInsets.symmetric(vertical: 9, horizontal: 15),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18), color: greyClor),
      child: Text(
        text,
        style: TextStyle(
            color: bleuColor, fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget BottomRow(Function f) {
    return Container(
      padding: EdgeInsets.only(right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(onTap: f, child: CircleIcone(Feather.x, greyColor2)),
          photoWidget(
            context,
            "assets/2.png",
          ),
          CircleIcone(AntDesign.questioncircleo, greyColor2)
        ],
      ),
    );
  }
}
