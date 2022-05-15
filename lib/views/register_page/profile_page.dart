
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/control/controllers/auth_controller.dart';
import 'package:flutter_chat_app/main.dart';
import 'package:flutter_chat_app/utilities/files.dart';
import 'package:flutter_chat_app/utilities/loading.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker_widget/image_picker_widget.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:skeletons/skeletons.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({Key? key}) : super(key: key);

  final _controller1= TextEditingController();
  final _controller2= TextEditingController();

  late final Future? imageFuture = AuthController.instance.getUserPhoto();

  late final Future<Map<String, dynamic>>? nameFuture = AuthController.instance.getUserName();


  @override
  Widget build(BuildContext context)  {
    FetchContacts.getContacts();
    return GetBuilder<AuthController>(builder: (controller) {

      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text("profile".tr),
        ),
        child: SafeArea(
          child: Scaffold(
            backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
            body:  controller.isLoading ? getStretchedDotsLoading() : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24, horizontal: 32),
                child: Column(
                  children: [
                    SizedBox(
                      height: 24,
                    ),
                    Container(
                      alignment: AlignmentDirectional.centerStart,
                      padding: EdgeInsetsDirectional.only(start: 16),
                      child: Text(
                        'profile_data'.tr,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: CupertinoTheme.of(context).textTheme.textStyle.color,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 24,
                    ),
                    Container(
                      padding: EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: CupertinoTheme.of(context).barBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: FutureBuilder(
                              future: imageFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState==ConnectionState.waiting){
                                  return Skeleton(
                                    child: Container(),
                                    isLoading: true,
                                    skeleton: SkeletonAvatar(),);
                                }
                                if (snapshot.connectionState==ConnectionState.done && snapshot.hasData) {
                                  return getImagePickerWidget(controller, snapshot.data);
                                }

                                return Container();
                              },),),
                          SizedBox(
                            height: 22,
                          ),
                          Container(width: double.maxFinite,
                            child: FutureBuilder<Map<String, dynamic>>(
                              future: nameFuture,
                              builder: (BuildContext context, snapshot) {
                                if (snapshot.connectionState== ConnectionState.done && snapshot.hasData) {
                                  // print("snapshot.data.toString()=  ${snapshot.data.toString()}");
                                  _controller1.text = snapshot.data!['name'];
                                  return getTextFieldName(controller, context);
                                }
                                if (snapshot.connectionState== ConnectionState.waiting)
                                return getStretchedDotsLoading();
                                return getTextFieldName(controller, context);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Container(
                      alignment: AlignmentDirectional.centerStart,
                      padding: EdgeInsetsDirectional.only(start: 16),
                      child: Text(
                        "status".tr,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: CupertinoTheme.of(context).textTheme.textStyle.color,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    SizedBox(
                      height: 18,
                    ),
                    Container(
                      padding: EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: CupertinoTheme.of(context).barBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Container(width: double.maxFinite,
                            child: TextFormField(
                              style: TextStyle(color: CupertinoTheme.of(context).textTheme.textStyle.color),
                              controller: _controller2,
                              maxLength: 114,
                              //textInputAction: TextInputAction.send,
                              keyboardType: TextInputType.multiline,
                              decoration: InputDecoration(
                                floatingLabelStyle: TextStyle(color: CupertinoTheme.of(context).primaryColor),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(10)),
                                    borderSide: BorderSide(color: CupertinoTheme.of(context).primaryColor)
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: CupertinoColors.inactiveGray),
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(10)),
                                ),
                                labelText: "about_you".tr,
                                labelStyle: TextStyle(color: CupertinoColors.inactiveGray),
                                counterStyle: TextStyle(color: CupertinoColors.inactiveGray),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 22,
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                print(controller.userModel.name);
                                bool x=controller.userModel.photoURL.isNotEmpty;
                                if (_controller1.value.text.isNotEmpty && x) {
                                  controller.setProfileData(_controller1.value.text,_controller2.value.text);
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
                                  'send'.tr,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          )
                        ],
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



  Widget getTextFieldName(AuthController controller, context) {
    return TextField(
      controller: _controller1,
      style: TextStyle(color: CupertinoTheme.of(context).textTheme.textStyle.color),
      maxLength: 24,
      decoration: InputDecoration(
        labelText: "username".tr,
        labelStyle: TextStyle(color: CupertinoColors.inactiveGray),
        counterStyle: TextStyle(color: CupertinoColors.inactiveGray),
        floatingLabelStyle: TextStyle(color: CupertinoTheme.of(context).primaryColor),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: CupertinoColors.inactiveGray),
          borderRadius: BorderRadius.all(
              Radius.circular(10)),
        ),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
                Radius.circular(10)),
            borderSide: BorderSide(
                color: CupertinoTheme.of(context).primaryColor)
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: CupertinoColors.inactiveGray),
          borderRadius: BorderRadius.all(
              Radius.circular(10)),
        ),
      ),
      //controller: PhoneController(PhoneNumber(isoCode: "YE", nsn: '736284642')),
    );
  }



  Widget getImagePickerWidget(AuthController controller, dynamic initialImage) {
    dynamic img;
    //if(initialImage==null /*|| initialImage.isBlank*/)
      //AssetImage('assets/images/profile_placeholder.png',);
      //img=await getImageFileFromAssets('images/profile_placeholder.png', 'myProfilePhoto.jpg');
    //else {
      img = NetworkToFileImage(url: initialImage,
          file: fileFromDocsDir('myProfilePhoto.jpg'),
          debug: true);
      controller.userModel.photoURL=initialImage;
    //}
    print("initialImage= $initialImage");
    return ImagePickerWidget(
      diameter: 100,
      initialImage: img,
      shape: ImagePickerWidgetShape.circle,
      isEditable: true,
      //imagePickerOptions: ImagePickerOptions(imageQuality: 50,),
      shouldCrop: true,
      croppedImageOptions: CroppedImageOptions(
        cropStyle: CropStyle.circle,
        compressQuality: 50,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        //aspectRatioPresets:  CropAspectRatioPreset.square
        /* compressFormat: ImageCompressFormat.jpg*/
      ),
      onChange: (p0) {
        controller.uploadPhoto(p0.path);
      },);
  }
}
