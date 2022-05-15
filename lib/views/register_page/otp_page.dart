
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/control/controllers/auth_controller.dart';
import 'package:flutter_chat_app/utilities/loading.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OtpPage extends StatelessWidget {
  const OtpPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //authController.closeLoading();
    return GetBuilder<AuthController>(builder: (controller) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          leading: CupertinoNavigationBarBackButton(
            onPressed: () {
              if (controller.isLoading)
                controller.closeLoading();
              else
                Get.back();
            }, previousPageTitle: "registration".tr,
          ),
          middle: Text("verification".tr),
        ),
        child: SafeArea(
          child: Scaffold(
            backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
            body: controller.isLoading ? getStretchedDotsLoading() : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24, horizontal: 32),
                child: Column(
                  children: [
                    SizedBox(
                      height: 18,
                    ),
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        'assets/images/illustration-3.png',
                      ),
                    ),
                    SizedBox(
                      height: 24,
                    ),
                    /*Text(
                      'verification'.tr,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),*/
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "enter_verification_code".tr,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: CupertinoTheme.of(context).textTheme.textStyle.color,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 28,
                    ),
                    Container(
                      padding: EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: CupertinoTheme.of(context).barBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          PinCodeTextField(
                            keyboardType: TextInputType.number,
                            appContext: context,
                            length: 6,
                            textStyle: TextStyle(color: CupertinoTheme.of(context).textTheme.textStyle.color,),
                            obscureText: false,
                            animationType: AnimationType.fade,
                            pinTheme: PinTheme(
                              shape: PinCodeFieldShape.box,
                              borderRadius: BorderRadius.circular(12),
                              fieldHeight: 55,
                              fieldWidth: 40,
                              borderWidth: 0.5,
                              selectedColor: CupertinoTheme.of(context).primaryColor,
                              activeColor:  CupertinoColors.systemPurple,
                              inactiveColor: CupertinoColors.inactiveGray,
                            ),
                            animationDuration: Duration(milliseconds: 300),
                            //controller: otpController,
                            validator: (v){
                              if (v!.length < 6) {
                                return "I'm from validator";
                              } else {
                                return null;
                              }
                            },
                            onChanged: controller.onChangeOtp,

                          ),
                          /*Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _textFieldOTP(first: true, last: false, controller: listController[0], context: context),
                              _textFieldOTP(first: false, last: false, controller: listController[1], context: context),
                              _textFieldOTP(first: false, last: false, controller: listController[2], context: context),
                              _textFieldOTP(first: false, last: false, controller: listController[3], context: context),
                              _textFieldOTP(first: false, last: false, controller: listController[4], context: context),
                              _textFieldOTP(first: false, last: true, controller: listController[5], context: context),
                            ],
                          ),*/
                          SizedBox(
                            height: 22,
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                debugPrint("controller.otp.length= ${controller.otp.length}");
                                debugPrint("controller.otp= ${controller.otp}");
                                if(controller.otp.length==6){
                                  controller.signInWithPhoneNumber(controller.otp);
                                }
                              },
                              style: ButtonStyle(
                                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                backgroundColor: MaterialStateProperty.all<Color>(CupertinoTheme.of(context).primaryColor),
                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24.0),
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(14.0),
                                child: Text(
                                  'verify'.tr,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 18,
                    ),
                    Text(
                      "did_not_receive_code".tr,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: CupertinoTheme.of(context).textTheme.textStyle.color,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 18,
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        "resend_new_code".tr,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
