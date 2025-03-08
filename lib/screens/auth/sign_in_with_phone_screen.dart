import 'dart:io';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:gap/gap.dart';
import 'package:taxi_booking/screens/SignInScreen.dart';
import 'package:taxi_booking/screens/auth/otp_screen.dart';
import '../../main.dart';
import '../../service/AuthService.dart';
import '../../utils/Colors.dart';
import '../../utils/Common.dart';
import '../../utils/Constants.dart';
import '../../utils/Extensions/AppButtonWidget.dart';
import '../../utils/Extensions/app_common.dart';
import '../../utils/Extensions/app_textfield.dart';
import '../../utils/images.dart';

class SignInWithPhoneScreen extends StatefulWidget {
  const SignInWithPhoneScreen({super.key});

  @override
  State<SignInWithPhoneScreen> createState() => _SignInWithPhoneScreenState();
}

class _SignInWithPhoneScreenState extends State<SignInWithPhoneScreen> {
  TextEditingController phoneController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  GoogleAuthServices googleAuthService = GoogleAuthServices();

  String verId = '';
  String otpCode = defaultCountryCode;

  Future<void> sendOTP() async {
    if (formKey.currentState!.validate()) {
      appStore.setLoading(true);

      String number = '$otpCode ${phoneController.text.trim()}';

      log('$otpCode${phoneController.text.trim()}');
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => OtpScreen(
                phoneNumber: number,
              )));
      // await loginWithOTP(context, number).then((value) {}).catchError((e) {
      //   appStore.setLoading(false);
      //   toast(e.toString());
      // });
    }
  }

  void googleSignIn() async {
    hideKeyboard(context);
    appStore.setLoading(true);

    await googleAuthService.signInWithGoogle(context).then((value) async {
      appStore.setLoading(false);
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
    });
  }

  appleLoginApi() async {
    hideKeyboard(context);
    appStore.setLoading(true);
    await appleLogIn().then((value) {
      appStore.setLoading(false);
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Gap(20),
              Align(
                alignment: Alignment.center,
                child: Image.asset(
                  'images/ic_app_logo.jpg',
                  height: 100,
                ),
              ),
              Gap(50),
              Text(
                'Enter Your Mobile Number',
                style: primaryTextStyle(size: 16),
              ),
              Gap(12),
              Form(
                key: formKey,
                child: AppTextField(
                  controller: phoneController,
                  textFieldType: TextFieldType.PHONE,
                  decoration: inputDecoration(
                    context,
                    label: language.phoneNumber,
                    prefixIcon: IntrinsicHeight(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CountryCodePicker(
                            padding: EdgeInsets.zero,
                            initialSelection: otpCode,
                            showCountryOnly: false,
                            dialogSize: Size(MediaQuery.of(context).size.width - 60, MediaQuery.of(context).size.height * 0.6),
                            showFlag: true,
                            showFlagDialog: true,
                            showOnlyCountryWhenClosed: false,
                            alignLeft: false,
                            textStyle: primaryTextStyle(),
                            dialogBackgroundColor: Theme.of(context).cardColor,
                            barrierColor: Colors.black12,
                            dialogTextStyle: primaryTextStyle(),
                            searchDecoration: InputDecoration(
                              focusColor: primaryColor,
                              iconColor: Theme.of(context).dividerColor,
                              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).dividerColor)),
                              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: primaryColor)),
                            ),
                            searchStyle: primaryTextStyle(),
                            onInit: (c) {
                              otpCode = c!.dialCode!;
                            },
                            onChanged: (c) {
                              otpCode = c.dialCode!;
                            },
                          ),
                          VerticalDivider(color: Colors.grey.withValues(alpha: 0.5)),
                        ],
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value!.trim().isEmpty) return language.thisFieldRequired;
                    return null;
                  },
                ),
              ),
              SizedBox(height: 16),
              Stack(
                alignment: Alignment.center,
                children: [
                  AppButtonWidget(
                    onTap: () {
                      if (phoneController.text.trim().isEmpty) {
                        return toast(language.thisFieldRequired);
                      } else {
                        hideKeyboard(context);
                        sendOTP();
                      }
                      // Navigator.of(context).push(
                      //   MaterialPageRoute(
                      //     builder: (context) => OtpScreen(),
                      //   ),
                      // );
                    },
                    text: language.continueD,
                    color: primaryColor,
                    textStyle: boldTextStyle(color: Colors.white),
                    width: MediaQuery.of(context).size.width,
                  ),
                  Positioned(
                    child: Observer(builder: (context) {
                      return Visibility(
                        visible: appStore.isLoading,
                        child: loaderWidget(),
                      );
                    }),
                  ),
                ],
              ),
              socialWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget socialWidget() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(child: Divider(color: dividerColor)),
              Padding(
                padding: EdgeInsets.only(left: 16, right: 16),
                child: Text(language.orLogInWith, style: primaryTextStyle()),
              ),
              Expanded(child: Divider(color: dividerColor)),
            ],
          ),
        ),
        SizedBox(height: 16),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            inkWellWidget(
              onTap: () async {
                googleSignIn();
              },
              child: socialWidgetComponent(img: ic_google),
            ),
            SizedBox(height: 12),
            InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => SignInScreen()));
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                width: MediaQuery.of(context).size.width * .90,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: radius(
                    defaultRadius,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 12,
                  children: [
                    Icon(Icons.email_outlined),
                    Text('Continue with Google'),
                  ],
                ),
              ),
            ),
            if (Platform.isIOS) SizedBox(width: 12),
            if (Platform.isIOS)
              inkWellWidget(
                onTap: () async {
                  appleLoginApi();
                },
                child: socialWidgetComponent(img: ic_apple),
              ),
          ],
        ),
      ],
    );
  }

  Widget socialWidgetComponent({required String img}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      width: MediaQuery.of(context).size.width * .90,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: radius(
          defaultRadius,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 12,
        children: [
          Image.asset(img, fit: BoxFit.cover, height: 30, width: 30),
          Text('Continue with Google'),
        ],
      ),
    );
  }
}
