import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../main.dart';
import '../../../utils/Colors.dart';
import '../../../utils/Common.dart';
import '../../../utils/Constants.dart';
import '../../../utils/Extensions/app_common.dart';
import '../SignInScreen.dart';

class WalkThroughScreen extends StatefulWidget {
  @override
  WalkThroughScreenState createState() => WalkThroughScreenState();
}

class WalkThroughScreenState extends State<WalkThroughScreen> {
  PageController pageController = PageController();
  int currentPage = 0;

  List<Widget> walkThroughClass = [
    FirstPage(),
    SecondPage(),
    ThirdPage(),
  ];

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.center,
              end: Alignment.centerLeft,
              colors: [
                Colors.white,
                Colors.white12,
              ],
            ),
          ),
          child: Stack(
            children: [
              PageView.builder(
                itemCount: walkThroughClass.length,
                controller: pageController,
                itemBuilder: (context, i) {
                  return walkThroughClass[i]; // Render only the current page
                },
                onPageChanged: (int i) {
                  currentPage = i;
                  setState(() {});
                },
              ),
              Positioned(
                bottom: 10,
                right: 0,
                left: 0,
                child: Column(
                  children: [
                    SizedBox(height: 32),
                    dotIndicator(walkThroughClass, currentPage),
                    SizedBox(height: 28),
                    GestureDetector(
                      onTap: () {
                        if (currentPage.toInt() >= 2) {
                          launchScreen(context, SignInScreen(), isNewTask: true);
                          sharedPref.setBool(IS_FIRST_TIME, false);
                        } else {
                          pageController.nextPage(
                            duration: Duration(seconds: 1),
                            curve: Curves.linearToEaseOut,
                          );
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryColor,
                        ),
                        padding: EdgeInsets.all(12),
                        child: Icon(Icons.arrow_forward, color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 28),
                  ],
                ),
              ),
              Positioned(
                top: 30,
                right: 0,
                child: TextButton(
                  onPressed: () {
                    launchScreen(context, SignInScreen(), isNewTask: true);
                    sharedPref.setBool(IS_FIRST_TIME, false);
                  },
                  child: Text(
                    language.skip,
                    style: boldTextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FirstPage extends StatelessWidget {
  const FirstPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: Lottie.asset(
          'images/icons/Woman using mobile phone for booking taxi.mp4.lottie.json',
          fit: BoxFit.cover,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * .35,
        ),
      ),
    );
  }
}

class SecondPage extends StatelessWidget {
  const SecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Lottie.asset('images/icons/Animation - 1741320384784.json', height: MediaQuery.sizeOf(context).height * .30),
            Column(
              spacing: 6,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '# User App Rider & Rental All types of Cars Booking Apps Service all over Bangladesh',
                  style: boldTextStyle(size: 14, color: Colors.black),
                  // textAlign: TextAlign.start,
                ),
                Text(
                  '# Female & Male Driver available to Choose your Driver',
                  style: boldTextStyle(size: 14, color: Colors.black),
                  // textAlign: TextAlign.center,
                ),
                Text(
                  '# Uber Ride Car Apps Download(android & iOS)',
                  style: boldTextStyle(size: 14, color: Colors.black),
                  // textAlign: TextAlign.center,
                ),
                Text(
                  '# Online Register Free For Users & Drivers or any types Car\'s',
                  style: boldTextStyle(size: 14, color: Colors.black),
                  // textAlign: TextAlign.center,
                ),
                Text(
                  '# Ubar Ride all types of cars available with a low Fare & commission',
                  style: boldTextStyle(size: 14, color: Colors.black),
                  // textAlign: TextAlign.center,
                ),
                Text(
                  '# Choose your Ubar Ride car & Driver Booking Now Any time',
                  style: boldTextStyle(size: 14, color: Colors.black),
                  // textAlign: TextAlign.center,
                ),
                Text(
                  '# Ubar Ride using to discount fare & referrals bonus offers reveive',
                  style: boldTextStyle(size: 14, color: Colors.black),
                  textAlign: TextAlign.start,
                ),
                Text(
                  '# Ubar Apps Car Booking Hassle free & safe your journey all time',
                  style: boldTextStyle(size: 14, color: Colors.black),
                  textAlign: TextAlign.start,
                ),
              ],
            ),
            Lottie.asset('images/icons/Animation - 1741320317392.json', height: MediaQuery.sizeOf(context).height * 0.3),
          ],
        ),
      ),
    );
  }
}

class ThirdPage extends StatelessWidget {
  const ThirdPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 8,
          children: [
            Lottie.asset('images/icons/Animation - 1741320265880.json', height: MediaQuery.sizeOf(context).height * .4),
            // First Text with Bullet Point
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 8,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '• ',
                          style: boldTextStyle(size: 20, color: Colors.black),
                        ),
                        Expanded(
                          child: Text(
                            'Ride/Rental all car App Booking Service',
                            style: boldTextStyle(size: 14, color: Colors.black),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                    // Spacing between bullet points
                    // Second Text with Bullet Point
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '• ',
                          style: boldTextStyle(size: 20, color: Colors.black),
                        ),
                        Expanded(
                          child: Text(
                            'Hourly / Schedule Car at low Commission',
                            style: boldTextStyle(size: 14, color: Colors.black),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '• ',
                          style: boldTextStyle(size: 20, color: Colors.black),
                        ),
                        Expanded(
                          child: Text(
                            'InterCity / Daily Car OneWay RoundTrips',
                            style: boldTextStyle(size: 14, color: Colors.black),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '• ',
                          style: boldTextStyle(size: 20, color: Colors.black),
                        ),
                        Expanded(
                          child: Text(
                            'Holiday / Long Tour Out of City Fare Cars',
                            style: boldTextStyle(size: 14, color: Colors.black),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '• ',
                          style: boldTextStyle(size: 20, color: Colors.black),
                        ),
                        Expanded(
                          child: Text(
                            'Ubar Ambulances / Microbus / HiessCars',
                            style: boldTextStyle(size: 14, color: Colors.black),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '• ',
                          style: boldTextStyle(size: 20, color: Colors.black),
                        ),
                        Expanded(
                          child: Text(
                            'Office Bus / Party Cars / Safe Journey',
                            style: boldTextStyle(size: 14, color: Colors.black),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '• ',
                          style: boldTextStyle(size: 20, color: Colors.black),
                        ),
                        Expanded(
                          child: Text(
                            'Pickup / Truck / Cargo Trucks App Service',
                            style: boldTextStyle(size: 14, color: Colors.black),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '• ',
                          style: boldTextStyle(size: 20, color: Colors.black),
                        ),
                        Expanded(
                          child: Text(
                            'Social Media / Google, login and Sharing',
                            style: boldTextStyle(size: 14, color: Colors.black),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '• ',
                          style: boldTextStyle(size: 20, color: Colors.black),
                        ),
                        Expanded(
                          child: Text(
                            'Hire your Drivers Booking Service',
                            style: boldTextStyle(size: 14, color: Colors.black),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '• ',
                          style: boldTextStyle(size: 20, color: Colors.black),
                        ),
                        Expanded(
                          child: Text(
                            'Self Car Driving / Helicopter Service',
                            style: boldTextStyle(size: 14, color: Colors.black),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '• ',
                          style: boldTextStyle(size: 20, color: Colors.black),
                        ),
                        Expanded(
                          child: Text(
                            'Choice your Drivers / Bidding All Cars',
                            style: boldTextStyle(size: 14, color: Colors.black),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '• ',
                          style: boldTextStyle(size: 20, color: Colors.black),
                        ),
                        Expanded(
                          child: Text(
                            'Ubar Agent Office All Time Open (24/7)',
                            style: boldTextStyle(size: 14, color: Colors.black),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
