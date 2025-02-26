import 'dart:async';

import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../components/SearchLocationComponent.dart';
import '../components/drawer_component.dart';
import '../main.dart';
import '../model/CurrentRequestModel.dart';
import '../model/GoogleMapSearchModel.dart';
import '../model/NearByDriverListModel.dart';
import '../model/ServiceModel.dart';
import '../model/TextModel.dart';
import '../network/RestApis.dart';
import '../screens/ReviewScreen.dart';
import '../screens/RidePaymentDetailScreen.dart';
import '../utils/Colors.dart';
import '../utils/Common.dart';
import '../utils/Constants.dart';
import '../utils/DataProvider.dart';
import '../utils/Extensions/AppButtonWidget.dart';
import '../utils/Extensions/LiveStream.dart';
import '../utils/Extensions/StringExtensions.dart';
import '../utils/Extensions/app_common.dart';
import '../utils/Extensions/app_textfield.dart';
import '../utils/Extensions/context_extension.dart';
import '../utils/images.dart';
import 'GoogleMapScreen.dart';
import 'LocationPermissionScreen.dart';
import 'NewEstimateRideListWidget.dart';
import 'NotificationScreen.dart';

class DashBoardScreen extends StatefulWidget {
  @override
  DashBoardScreenState createState() => DashBoardScreenState();
  String? cancelReason;
  DashBoardScreen({this.cancelReason});
}

class DashBoardScreenState extends State<DashBoardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // LatLng? sourceLocation;

  List<TexIModel> list = getBookList();
  List<Marker> markers = [];
  Set<Polyline> _polyLines = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  late PolylinePoints polylinePoints;
  OnRideRequest? servicesListData;

  TextEditingController sourceLocationController = TextEditingController();
  TextEditingController destinationLocationController = TextEditingController();

  FocusNode sourceFocus = FocusNode();
  FocusNode desFocus = FocusNode();

  String mLocation = "";
  bool isDone = true;
  bool isPickup = true;
  bool isDrop = false;
  double? totalAmount;

  List<ServiceList> servicesList = [];
  List<Prediction> listAddress = [];

  double cameraZoom = 17.0, cameraTilt = 0;

  double cameraBearing = 30;
  int onTapIndex = 0;

  int selectIndex = 0;

  // String sourceLocationTitle = '';

  late StreamSubscription<ServiceStatus> serviceStatusStream;

  LocationPermission? permissionData;

  // late BitmapDescriptor riderIcon;
  late BitmapDescriptor driverIcon;
  List<NearByDriverListModel>? nearDriverModel;

  @override
  void initState() {
    super.initState();
    locationPermission();
    if (widget.cancelReason != null) {
      afterBuildCreated(() {
        _triggerCanceledPopup();
      });
    } else {
      getCurrentRequest();
    }
    afterBuildCreated(() {
      init();
    });
  }

  void initSearch() async {
    await getServices().then((value) {
      servicesList.addAll(value.data!);
      setState(() {});
    });

    sourceFocus.addListener(() {
      sourceLocationController.selection =
          TextSelection.collapsed(offset: sourceLocationController.text.length);
      if (sourceFocus.hasFocus) sourceLocationController.clear();
    });

    desFocus.addListener(() {
      if (desFocus.hasFocus) {
        if (mLocation.isNotEmpty) {
          sourceLocationController.text = mLocation;
          sourceLocationController.selection = TextSelection.collapsed(
              offset: sourceLocationController.text.length);
        } else {
          sourceLocationController.text = sourceLocationTitle;
          sourceLocationController.selection = TextSelection.collapsed(
              offset: sourceLocationController.text.length);
        }
      }
    });
  }

  void init() async {
    getCurrentUserLocation();
    initSearch();
    riderIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), SourceIcon);
    driverIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), MultipleDriver);
    await getAppSettingsData();

    polylinePoints = PolylinePoints();
  }

  Future<void> getCurrentUserLocation() async {
    if (permissionData != LocationPermission.denied) {
      if (sourceLocation != null) {
        polylineSource =
            LatLng(sourceLocation!.latitude, sourceLocation!.longitude);
        addMarker();
        startLocationTracking();
        await getNearByDriver();
        return;
      }
      final geoPosition = await Geolocator.getCurrentPosition(
              timeLimit: Duration(seconds: 30),
              desiredAccuracy: LocationAccuracy.high)
          .catchError((error) {
        launchScreen(navigatorKey.currentState!.overlay!.context,
            LocationPermissionScreen());
        // Navigator.push(context, MaterialPageRoute(builder: (_) => LocationPermissionScreen()));
      });
      sourceLocation = LatLng(geoPosition.latitude, geoPosition.longitude);
      List<Placemark>? placemarks = await placemarkFromCoordinates(
          geoPosition.latitude, geoPosition.longitude);
      await getNearByDriver();

      //set Country
      sharedPref.setString(COUNTRY,
          placemarks[0].isoCountryCode.validate(value: defaultCountry));

      Placemark place = placemarks[0];
      if (place != null) {
        sourceLocationTitle =
            "${place.name != null ? place.name : place.subThoroughfare}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea} ${place.postalCode}, ${place.country}";
        polylineSource = LatLng(geoPosition.latitude, geoPosition.longitude);
        sourceLocationController.text=sourceLocationTitle;
      }


      addMarker();
      startLocationTracking();

      setState(() {});
    } else {
      launchScreen(navigatorKey.currentState!.overlay!.context,
          LocationPermissionScreen());
      // Navigator.push(context, MaterialPageRoute(builder: (_) => LocationPermissionScreen()));
    }
  }

  Future<void> getCurrentRequest() async {
    await getCurrentRideRequest().then((value) {
      servicesListData = value.rideRequest ?? value.onRideRequest;
      // servicesListData = value.onRideRequest;
      print("Line124");
      if (servicesListData == null) {
        sharedPref.remove(REMAINING_TIME);
        sharedPref.remove(IS_TIME);
      }
      print("Line126:::${value.toJson()}");
      // print("Line126:::${value.onRideRequest.}");
      if (servicesListData != null) {
        print("Line126");
        if (servicesListData!.status != COMPLETED &&
            servicesListData!.status != CANCELED) {
          print("Line128");
          launchScreen(
            getContext,
            NewEstimateRideListWidget(
              sourceLatLog: LatLng(
                  double.parse(servicesListData!.startLatitude!),
                  double.parse(servicesListData!.startLongitude!)),
              destinationLatLog: LatLng(
                  double.parse(servicesListData!.endLatitude!),
                  double.parse(servicesListData!.endLongitude!)),
              sourceTitle: servicesListData!.startAddress!,
              destinationTitle: servicesListData!.endAddress!,
              isCurrentRequest: true,
              servicesId: servicesListData!.serviceId,
              id: servicesListData!.id,
            ),
            pageRouteAnimation: PageRouteAnimation.SlideBottomTop,
          );
        } else if (servicesListData!.status == COMPLETED &&
            servicesListData!.isRiderRated == 0) {
          Future.delayed(
            Duration(seconds: 1),
            () {
              launchScreen(
                  getContext,
                  ReviewScreen(
                      rideRequest: servicesListData!, driverData: value.driver),
                  pageRouteAnimation: PageRouteAnimation.SlideBottomTop,
                  isNewTask: true);
            },
          );
        }
      } else if (value.payment != null &&
          value.payment!.paymentStatus != "paid") {
        print("Line151");
        launchScreen(getContext,
            RidePaymentDetailScreen(rideId: value.payment!.rideRequestId),
            pageRouteAnimation: PageRouteAnimation.SlideBottomTop,
            isNewTask: true);
        // Future.delayed(Duration(seconds: 1),() {
        //
        // },);
      }
      print("Line157");
    }).catchError((error) {
      print("Line159");
      throw error;
      log(error.toString());
    });
  }

  Future<void> locationPermission() async {
    serviceStatusStream =
        Geolocator.getServiceStatusStream().listen((ServiceStatus status) {
      if (status == ServiceStatus.disabled) {
        launchScreen(navigatorKey.currentState!.overlay!.context,
            LocationPermissionScreen());
      } else if (status == ServiceStatus.enabled) {
        getCurrentUserLocation();
        if (locationScreenKey.currentContext != null) {
          if (Navigator.canPop(navigatorKey.currentState!.overlay!.context)) {
            Navigator.pop(navigatorKey.currentState!.overlay!.context);
          }
        }
      }
    }, onError: (error) {
      //
    });
  }

  addMarker() {
    markers.add(
      Marker(
        markerId: MarkerId('Order Detail'),
        position: sourceLocation!,
        draggable: true,
        infoWindow: InfoWindow(title: sourceLocationTitle, snippet: ''),
        icon: riderIcon,
      ),
    );
  }

  Future<void> startLocationTracking() async {
    Map req = {
      "latitude": sourceLocation!.latitude.toString(),
      "longitude": sourceLocation!.longitude.toString(),
    };
    await updateStatus(req).then((value) {}).catchError((error) {
      log(error);
    });
  }

  Future<void> getNearByDriver() async {
    await getNearByDriverList(latLng: sourceLocation).then((value) async {
      value.data!.forEach((element) {
        markers.add(
          Marker(
            markerId: MarkerId('Driver${element.id}'),
            position: LatLng(double.parse(element.latitude!.toString()),
                double.parse(element.longitude!.toString())),
            infoWindow: InfoWindow(
                title: '${element.firstName} ${element.lastName}', snippet: ''),
            icon: driverIcon,
          ),
        );
      });
      setState(() {});
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    LiveStream().on(CHANGE_LANGUAGE, (p0) {
      setState(() {});
    });
    print("titiiiiiilleee" + sourceLocationTitle);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.light,
            statusBarColor: Colors.black38,
            statusBarBrightness: Brightness.dark),
        toolbarHeight: 0,
        // leading: BackButton(color: context.iconColor),
        // title: Text(language.signUp, style: boldTextStyle()),
      ),
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      drawer: DrawerComponent(),
      body: Stack(
        children: [
          if (sharedPref.getDouble(LATITUDE) != null &&
              sharedPref.getDouble(LONGITUDE) != null)
            GoogleMap(
              padding: EdgeInsets.only(top: context.statusBarHeight + 4 + 24),
              compassEnabled: true,
              mapToolbarEnabled: false,
              zoomControlsEnabled: false,
              myLocationEnabled: false,
              mapType: MapType.normal,
              // myLocationEnabled: false,
              markers: markers.map((e) => e).toSet(),
              polylines: _polyLines,
              initialCameraPosition: CameraPosition(
                target: sourceLocation ??
                    LatLng(sharedPref.getDouble(LATITUDE)!,
                        sharedPref.getDouble(LONGITUDE)!),
                zoom: cameraZoom,
                tilt: cameraTilt,
                bearing: cameraBearing,
              ),
            ),
          Positioned(
            top: context.statusBarHeight + 4,
            right: 14,
            left: 14,
            child: topWidget(),
          ),
          Visibility(
            visible: false,
            child: SlidingUpPanel(
              padding: EdgeInsets.all(16),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(defaultRadius),
                  topRight: Radius.circular(defaultRadius)),
              backdropTapClosesPanel: true,
              minHeight: 140,
              maxHeight: 140,
              panel: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(bottom: 12),
                      height: 5,
                      width: 70,
                      decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(defaultRadius)),
                    ),
                  ),
                  Text(language.whatWouldYouLikeToGo.capitalizeFirstLetter(),
                      style: primaryTextStyle()),
                  SizedBox(height: 12),
                  AppTextField(
                    autoFocus: false,
                    readOnly: true,
                    onTap: () async {
                      showModalBottomSheet(
                        isScrollControlled: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(defaultRadius),
                              topRight: Radius.circular(defaultRadius)),
                        ),
                        context: context,
                        builder: (_) {
                          return SearchLocationComponent(
                              title: sourceLocationTitle);
                        },
                      );
                    },
                    textFieldType: TextFieldType.EMAIL,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      focusColor: primaryColor,
                      prefixIcon: Icon(Feather.search),
                      filled: false,
                      isDense: true,
                      focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(defaultRadius),
                          borderSide: BorderSide(color: dividerColor)),
                      disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(defaultRadius),
                          borderSide: BorderSide(color: dividerColor)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(defaultRadius),
                          borderSide: BorderSide(color: Colors.black)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(defaultRadius),
                          borderSide: BorderSide(color: dividerColor)),
                      errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(defaultRadius),
                          borderSide: BorderSide(color: Colors.red)),
                      alignLabelWithHint: true,
                      hintText: language.enterYourDestination,
                    ),
                  ),
                  SizedBox(height: 12),
                ],
              ),
            ),
          ),
          Visibility(
            visible: appStore.isLoading,
            child: loaderWidget(),
          ),
        ],
      ),
    );
  }

  Widget topWidget() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            inkWellWidget(
              onTap: () {
                _scaffoldKey.currentState!.openDrawer();
              },
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.2), spreadRadius: 1),
                  ],
                  borderRadius: BorderRadius.circular(defaultRadius),
                ),
                child: Icon(
                  Icons.drag_handle,
                ),
              ),
            ),
            inkWellWidget(
              onTap: () {
                launchScreen(context, NotificationScreen(),
                    pageRouteAnimation: PageRouteAnimation.Slide);
              },
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.2), spreadRadius: 1),
                  ],
                  borderRadius: BorderRadius.circular(defaultRadius),
                ),
                child: Icon(Ionicons.notifications_outline),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 6,
        ),
        SingleChildScrollView(
          child: Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Visibility(
                        visible: false,
                        child: Center(
                          child: Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.only(bottom: 16),
                            height: 5,
                            width: 70,
                            decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius:
                                    BorderRadius.circular(defaultRadius)),
                          ),
                        ),
                      ),
                      // SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.only(bottom: 16),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(defaultRadius)),
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.near_me, color: Colors.green),
                                  SizedBox(width: 4),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (isPickup == true)
                                          Text(language.lblWhereAreYou,
                                              style: secondaryTextStyle()),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextFormField(
                                                controller:
                                                    sourceLocationController,
                                                focusNode: sourceFocus,
                                                decoration:
                                                    searchInputDecoration(
                                                        hint: language
                                                            .currentLocation),
                                                onTap: () {
                                                  isPickup = false;
                                                  setState(() {});
                                                },
                                                onChanged: (val) {
                                                  if (val.isNotEmpty) {
                                                    isPickup = true;
                                                    if (val.length < 3) {
                                                      isDone = false;
                                                      listAddress.clear();
                                                      setState(() {});
                                                    } else {
                                                      searchAddressRequest(
                                                              search: val)
                                                          .then((value) {
                                                        isDone = true;
                                                        listAddress =
                                                            value.predictions!;
                                                        setState(() {});
                                                      }).catchError((error) {
                                                        log(error);
                                                      });
                                                    }
                                                  } else {
                                                    isPickup = false;
                                                    setState(() {});
                                                  }
                                                },
                                              ),
                                            ),
                                            Visibility(
                                              visible: false,
                                              child: Icon(
                                                Icons.my_location_rounded,
                                                size: 24,
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                ],
                              ),
                              Row(
                                children: [
                                  SizedBox(width: 8),
                                  SizedBox(
                                    height: 16,
                                    child: DottedLine(
                                      direction: Axis.vertical,
                                      lineLength: double.infinity,
                                      lineThickness: 1,
                                      dashLength: 3,
                                      dashColor: primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Icons.location_on, color: Colors.red),
                                  SizedBox(width: 4),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (isDrop == true)
                                          Text(language.lblDropOff,
                                              style: secondaryTextStyle()),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextFormField(
                                                controller:
                                                    destinationLocationController,
                                                focusNode: desFocus,
                                                autofocus: true,
                                                decoration: searchInputDecoration(
                                                    hint: language
                                                        .destinationLocation),
                                                onTap: () {
                                                  isDrop = false;
                                                  setState(() {});
                                                },
                                                onChanged: (val) {
                                                  if (val.isNotEmpty) {
                                                    isDrop = true;
                                                    if (val.length < 3) {
                                                      listAddress.clear();
                                                      setState(() {});
                                                    } else {
                                                      searchAddressRequest(
                                                              search: val)
                                                          .then((value) {
                                                        listAddress =
                                                            value.predictions!;
                                                        setState(() {});
                                                      }).catchError((error) {
                                                        log(error);
                                                      });
                                                    }
                                                  } else {
                                                    isDrop = false;
                                                    setState(() {});
                                                  }
                                                },
                                              ),
                                            ),
                                            InkWell(
                                                onTap: () async {
                                                  if (sourceFocus.hasFocus) {
                                                    isDone = true;
                                                    PickResult selectedPlace =
                                                        await launchScreen(
                                                            context,
                                                            GoogleMapScreen(
                                                                isDestination:
                                                                    false),
                                                            pageRouteAnimation:
                                                                PageRouteAnimation
                                                                    .SlideBottomTop);
                                                    log(selectedPlace);
                                                    mLocation = selectedPlace
                                                        .formattedAddress!;
                                                    sourceLocationController
                                                            .text =
                                                        selectedPlace
                                                            .formattedAddress!;
                                                    polylineSource = LatLng(
                                                        selectedPlace.geometry!
                                                            .location.lat,
                                                        selectedPlace.geometry!
                                                            .location.lng);

                                                    if (sourceLocationController
                                                            .text.isNotEmpty &&
                                                        destinationLocationController
                                                            .text.isNotEmpty) {
                                                      launchScreen(
                                                          context,
                                                          NewEstimateRideListWidget(
                                                              sourceLatLog:
                                                                  polylineSource,
                                                              destinationLatLog:
                                                                  polylineDestination,
                                                              sourceTitle:
                                                                  sourceLocationController
                                                                      .text,
                                                              destinationTitle:
                                                                  destinationLocationController
                                                                      .text),
                                                          pageRouteAnimation:
                                                              PageRouteAnimation
                                                                  .SlideBottomTop);

                                                      sourceLocationController
                                                          .clear();
                                                      destinationLocationController
                                                          .clear();
                                                    } else {
                                                      desFocus.nextFocus();
                                                    }
                                                  } else if (desFocus
                                                      .hasFocus) {
                                                    PickResult selectedPlace =
                                                        await launchScreen(
                                                            context,
                                                            GoogleMapScreen(
                                                                isDestination:
                                                                    true),
                                                            pageRouteAnimation:
                                                                PageRouteAnimation
                                                                    .SlideBottomTop);

                                                    destinationLocationController
                                                            .text =
                                                        selectedPlace
                                                            .formattedAddress!;
                                                    polylineDestination =
                                                        LatLng(
                                                            selectedPlace
                                                                .geometry!
                                                                .location
                                                                .lat,
                                                            selectedPlace
                                                                .geometry!
                                                                .location
                                                                .lng);

                                                    if (sourceLocationController
                                                            .text.isNotEmpty &&
                                                        destinationLocationController
                                                            .text.isNotEmpty) {
                                                      log(sourceLocationController
                                                          .text);
                                                      log(destinationLocationController
                                                          .text);

                                                      launchScreen(
                                                          context,
                                                          NewEstimateRideListWidget(
                                                              sourceLatLog:
                                                                  polylineSource,
                                                              destinationLatLog:
                                                                  polylineDestination,
                                                              sourceTitle:
                                                                  sourceLocationController
                                                                      .text,
                                                              destinationTitle:
                                                                  destinationLocationController
                                                                      .text),
                                                          pageRouteAnimation:
                                                              PageRouteAnimation
                                                                  .SlideBottomTop);

                                                      sourceLocationController
                                                          .clear();
                                                      destinationLocationController
                                                          .clear();
                                                    } else {
                                                      sourceFocus.nextFocus();
                                                    }
                                                  } else {
                                                    //
                                                  }
                                                },
                                                child: Icon(
                                                  Icons.my_location_rounded,
                                                  size: 24,
                                                ))
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        child: Column(
                          children: [
                            if (listAddress.isNotEmpty) SizedBox(height: 16),
                            ListView.builder(
                              controller: ScrollController(),
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: listAddress.length,
                              itemBuilder: (context, index) {
                                Prediction mData = listAddress[index];
                                return Container(
                                  color: Colors.white,
                                  child: ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: Icon(Icons.location_on_outlined,
                                        color: primaryColor),
                                    minLeadingWidth: 16,
                                    title: Text(mData.description ?? "",
                                        style: primaryTextStyle()),
                                    onTap: () async {
                                      await searchAddressRequestPlaceId(
                                              placeId: mData.placeId)
                                          .then((value) async {
                                        var data = value.result!.geometry;
                                        if (sourceFocus.hasFocus) {
                                          isDone = true;
                                          mLocation = mData.description!;
                                          sourceLocationController.text =
                                              mData.description!;
                                          polylineSource = LatLng(
                                              data!.location!.lat!,
                                              data.location!.lng!);

                                          if (!sourceLocationController
                                                  .text.isEmptyOrNull &&
                                              !destinationLocationController
                                                  .text.isEmptyOrNull) {
                                            launchScreen(
                                                context,
                                                NewEstimateRideListWidget(
                                                    sourceLatLog:
                                                        polylineSource,
                                                    destinationLatLog:
                                                        polylineDestination,
                                                    sourceTitle:
                                                        sourceLocationController
                                                            .text,
                                                    destinationTitle:
                                                        destinationLocationController
                                                            .text),
                                                pageRouteAnimation:
                                                    PageRouteAnimation
                                                        .SlideBottomTop);
                                            sourceLocationController.clear();
                                            destinationLocationController
                                                .clear();
                                          }
                                        } else if (desFocus.hasFocus) {
                                          destinationLocationController.text =
                                              mData.description!;
                                          polylineDestination = LatLng(
                                              data!.location!.lat!,
                                              data.location!.lng!);
                                          if (!sourceLocationController
                                                  .text.isEmptyOrNull &&
                                              !destinationLocationController
                                                  .text.isEmptyOrNull) {
                                            launchScreen(
                                                context,
                                                NewEstimateRideListWidget(
                                                    sourceLatLog:
                                                        polylineSource,
                                                    destinationLatLog:
                                                        polylineDestination,
                                                    sourceTitle:
                                                        sourceLocationController
                                                            .text,
                                                    destinationTitle:
                                                        destinationLocationController
                                                            .text),
                                                pageRouteAnimation:
                                                    PageRouteAnimation
                                                        .SlideBottomTop);
                                            sourceLocationController.clear();
                                            destinationLocationController
                                                .clear();
                                          }
                                        }
                                        listAddress.clear();
                                        setState(() {});
                                      }).catchError((error) {
                                        log(error);
                                      });
                                    },
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      Visibility(
                        visible: false,
                        child: AppButtonWidget(
                          width: MediaQuery.of(context).size.width,
                          onTap: () async {
                            if (sourceFocus.hasFocus) {
                              isDone = true;
                              PickResult selectedPlace = await launchScreen(
                                  context,
                                  GoogleMapScreen(isDestination: false),
                                  pageRouteAnimation:
                                      PageRouteAnimation.SlideBottomTop);
                              log(selectedPlace);
                              mLocation = selectedPlace.formattedAddress!;
                              sourceLocationController.text =
                                  selectedPlace.formattedAddress!;
                              polylineSource = LatLng(
                                  selectedPlace.geometry!.location.lat,
                                  selectedPlace.geometry!.location.lng);

                              if (sourceLocationController.text.isNotEmpty &&
                                  destinationLocationController
                                      .text.isNotEmpty) {
                                launchScreen(
                                    context,
                                    NewEstimateRideListWidget(
                                        sourceLatLog: polylineSource,
                                        destinationLatLog: polylineDestination,
                                        sourceTitle:
                                            sourceLocationController.text,
                                        destinationTitle:
                                            destinationLocationController.text),
                                    pageRouteAnimation:
                                        PageRouteAnimation.SlideBottomTop);

                                sourceLocationController.clear();
                                destinationLocationController.clear();
                              } else {
                                desFocus.nextFocus();
                              }
                            } else if (desFocus.hasFocus) {
                              PickResult selectedPlace = await launchScreen(
                                  context, GoogleMapScreen(isDestination: true),
                                  pageRouteAnimation:
                                      PageRouteAnimation.SlideBottomTop);

                              destinationLocationController.text =
                                  selectedPlace.formattedAddress!;
                              polylineDestination = LatLng(
                                  selectedPlace.geometry!.location.lat,
                                  selectedPlace.geometry!.location.lng);

                              if (sourceLocationController.text.isNotEmpty &&
                                  destinationLocationController
                                      .text.isNotEmpty) {
                                log(sourceLocationController.text);
                                log(destinationLocationController.text);

                                launchScreen(
                                    context,
                                    NewEstimateRideListWidget(
                                        sourceLatLog: polylineSource,
                                        destinationLatLog: polylineDestination,
                                        sourceTitle:
                                            sourceLocationController.text,
                                        destinationTitle:
                                            destinationLocationController.text),
                                    pageRouteAnimation:
                                        PageRouteAnimation.SlideBottomTop);

                                sourceLocationController.clear();
                                destinationLocationController.clear();
                              } else {
                                sourceFocus.nextFocus();
                              }
                            } else {
                              //
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.my_location_sharp,
                                  color: Colors.white),
                              SizedBox(width: 16),
                              Text(language.chooseOnMap,
                                  style: boldTextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  void _triggerCanceledPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: Text(
                "${language.rideCanceledByDriver}",
                maxLines: 2,
                style: boldTextStyle(),
              )),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(Icons.clear),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${language.cancelledReason}",
                style: secondaryTextStyle(),
              ),
              Text(
                widget.cancelReason.validate(),
                style: primaryTextStyle(),
              ),
            ],
          ),
        );
      },
    );
  }
}
