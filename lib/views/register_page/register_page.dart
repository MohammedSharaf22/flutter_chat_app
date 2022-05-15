import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/control/controllers/auth_controller.dart';
import 'package:flutter_chat_app/control/controllers/language_controller.dart';
import 'package:flutter_chat_app/utilities/loading.dart';
import 'package:get/get.dart';
import 'package:phone_form_field/phone_form_field.dart';


class RegisterPage extends StatelessWidget {
  const RegisterPage({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {

    //print("countryCode= ${CountryCodes.getDeviceLocale()?.countryCode}");
    return GetBuilder<AuthController>(builder: (controller) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          leading: CupertinoNavigationBarBackButton(
            onPressed: () {
              if (controller.isLoading)
                controller.closeLoading();
              else
                Get.back();
            },
          ),
          middle: Text("registration".tr),
          /*previousPageTitle: "Wel",*/
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
                          'assets/images/illustration-2.png',
                        ),
                      ),
                      SizedBox(height: 24,),
                      /*Text(
                        'registration'.tr,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: CupertinoTheme.of(context).textTheme.textStyle.color
                        ),
                      ),*/
                      SizedBox(height: 10,),
                      Text(
                        "add_your_phone".tr,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: CupertinoTheme.of(context).textTheme.textStyle.color,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 28,),
                      Card(
                        shape: BeveledRectangleBorder(borderRadius:  BorderRadius.circular(8)),
                        margin: EdgeInsetsDirectional.only(start: 10, end: 10),
                        color: CupertinoTheme.of(context).barBackgroundColor,
                        child: Padding(
                          padding: const EdgeInsets.all(28),
                          child: Column(
                            children: [
                              /*Container(*//*width: double.maxFinite,*//*
                                child: SettingItem(
                                    title: "${controller.myCountry.name}",
                                    onTap: () => Get.to(() => CountriesCodeList()),
                                ),
                              ),*/
                              SizedBox(
                                height: 15,
                              ),
                              Directionality(
                                textDirection: TextDirection.ltr,
                                child: PhoneFormField(
                                  //controller: PhoneController(PhoneNumber(isoCode: "YE", nsn: '736284642')),
                                  initialValue: controller.phoneNumber,
                                  textInputAction: TextInputAction.send,
                                  onSubmitted: (value) {
                                    var phone = controller.phoneNumber.international;
                                    debugPrint(phone);
                                    if (controller.phoneNumber.validate(type: PhoneNumberType.mobile)) {
                                      controller.verifyPhoneNumber(phone);
                                    }
                                  },
                                  //defaultCountry: controller.defaultCountry,
                                  onChanged: controller.onChangeNumber,
                                  autofillHints: const [AutofillHints.telephoneNumber],
                                  selectorNavigator: const ModalBottomSheetNavigator(sortCountries: true),
                                  validator: PhoneValidator.compose([
                                    PhoneValidator.required(errorText: "you_must_enter_phone".tr),
                                    PhoneValidator.validMobile(),
                                  ]),
                                  shouldFormat: true,
                                  textAlign: LanguageController.to.getLocale!.languageCode.contains('ar')
                                      ? TextAlign.end
                                      : TextAlign.start,
                                  decoration: InputDecoration(
                                      labelText: 'phone'.tr,
                                      filled: true,
                                      fillColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
                                      labelStyle: TextStyle(color: CupertinoColors.inactiveGray),
                                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: CupertinoTheme.of(context).primaryColor)),
                                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: CupertinoColors.inactiveGray)),
                                      border: OutlineInputBorder(borderSide: BorderSide(color: CupertinoColors.inactiveGray))
                                  ),
                                  //flagSize: 0,
                                  style: TextStyle(
                                      color: CupertinoTheme.of(context).textTheme.textStyle.color),
                                  countryCodeStyle: TextStyle(color: CupertinoTheme.of(context).textTheme.textStyle.color),
                                ),
                              ),
                              SizedBox(
                                height: 60,
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if(await controller.getStoragePermission()) {
                                      if (await controller.getContactsPermission()) {
                                        var phone = controller.phoneNumber
                                            .international;
                                        debugPrint(phone);
                                        if (controller.phoneNumber.validate(
                                            type: PhoneNumberType.mobile)) {
                                          controller.verifyPhoneNumber(phone);
                                        }
                                      }
                                    }
                                  },
                                  style: ButtonStyle(
                                    foregroundColor:
                                    MaterialStateProperty.all<Color>(Colors.white),
                                    backgroundColor: MaterialStateProperty.all<Color>(CupertinoTheme.of(context).primaryColor),
                                    shape:
                                    MaterialStateProperty.all<RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24.0),
                                      ),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(14.0),
                                    child: Text(
                                      'send'.tr,
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
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

/*child: PhoneFormField(
                                  textInputAction: TextInputAction.send,
                                  onSubmitted: (value) {
                                    var phone = controller.phoneNumber.international;
                                    print(phone);
                                    if (controller.phoneNumber.validate(type: PhoneNumberType.mobile)) {
                                      controller.verifyPhoneNumber(phone);
                                    }
                                  },
                                  //controller: PhoneController(PhoneNumber(isoCode: "YE", nsn: '736284642')),
                                  initialValue: PhoneNumber(isoCode: "YE", nsn: '736284642'),
                                  onChanged: controller.onChangeNumber,
                                  autofillHints: [AutofillHints.telephoneNumber],
                                  selectorNavigator: const ModalBottomSheetNavigator(),
                                  validator: PhoneValidator.compose([
                                    PhoneValidator.required(errorText: "you_must_enter_phone".tr),
                                    PhoneValidator.validMobile(),
                                  ]),
                                ),*/


/*Container(
                                  decoration: BoxDecoration(color: CupertinoTheme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.circular(7)),
                                  height: 46,
                                  child: CupertinoTextFormFieldRow(padding: EdgeInsets.symmetric(horizontal: 5),
                                    textAlign: TextAlign.center,
                                    cursorHeight: 30,
                                    style: TextStyle(fontSize: 15),
                                    maxLines: 1,
                                    maxLength: controller.myCountry.maxLength,
                                    keyboardType: TextInputType.phone,
                                    controller: controller.phoneController,
                                    onChanged: controller.onChangeNumber,
                                    placeholder: "phone".tr,
                                    prefix: Container(
                                      height: 46,
                                        width: 65,
                                        child: CupertinoTextFormFieldRow(
                                          maxLines: 1,
                                          maxLength: 5,
                                          onEditingComplete: ()=>controller.onSavedCountry(),
                                          textAlign: TextAlign.center,
                                          textAlignVertical: TextAlignVertical.center,
                                          padding: EdgeInsets.symmetric(horizontal: 0, vertical: 7),
                                          cursorHeight: 30,
                                          style: TextStyle(fontSize: 15),
                                          onChanged: controller.onChangeCountryCode,
                                          validator: (String? value) => controller.validatorCountryCode(value),
                                          controller: controller.countryCodeController,
                                          keyboardType: TextInputType.number,
                                        ),),
                                  ),
                                )*/
}


