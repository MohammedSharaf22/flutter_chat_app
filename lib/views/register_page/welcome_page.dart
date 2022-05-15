import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/views/register_page/register_page.dart';
import 'package:get/get.dart';
import 'package:phone_form_field/phone_form_field.dart';



class WelcomePage extends StatelessWidget {
  // Welcome({Key key}) : super(key: key);
  final TextStyle defaultStyle = TextStyle(/*fontSize: 14,*/ fontWeight: FontWeight.bold, /*color: textSubTitleColor*/);
  final TextStyle linkStyle = TextStyle(/*fontSize: 14,*/ fontWeight: FontWeight.bold, color: CupertinoColors.link);

  @override
  Widget build(BuildContext context) {

    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: false,
      //backgroundColor: bgColor,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24, horizontal: 32),
          child: Column(
            children: [
              Expanded(
                child: Image.asset(
                  'assets/images/illustration-3.png',
                  width: 240, /*fit: BoxFit.contain,*/
                ),
              ),
              SizedBox(
                height: 18,
              ),
              Text(
                "welcome_to".tr,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 30,
              ),
              RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: defaultStyle,
                    children: <TextSpan>[
                      TextSpan(text: "read_our".tr, style: CupertinoTheme.of(context).textTheme.textStyle),
                      TextSpan(text: " "+"privacy_policy".tr, style: linkStyle),
                      TextSpan(text: " "+"tap_agree_&_continue".tr, style: CupertinoTheme.of(context).textTheme.textStyle),
                      TextSpan(text: " "+"terms_of_service".tr, style: linkStyle),

                    ],
                  )
              ),
              SizedBox(
                width: double.infinity,
                height: 38,
              ),
              TextButton(
                  onPressed: (){
                    Get.to(() => RegisterPage());
                  },
                  child: Text(
                    'agree_&_continue'.tr,
                    style: TextStyle(fontSize: 24, color: CupertinoTheme.of(context).primaryColor),
                  )
              ),
              SizedBox(
                height: 42,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
