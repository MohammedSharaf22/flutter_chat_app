import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_chat_app/control/constants/firebase_auth_constants.dart';
import 'package:flutter_chat_app/control/controllers/language_controller.dart';
import 'package:flutter_chat_app/control/controllers/auth_controller.dart';
import 'package:flutter_chat_app/control/language/localization.g.dart';
import 'package:flutter_chat_app/utilities/presence/presence_service.dart';
import 'package:flutter_chat_app/utilities/theme/my_theme.dart';
import 'package:flutter_chat_app/utilities/collection_enum.dart';
import 'package:flutter_chat_app/views/pages/chat/message/db_helper/message_db_helper.dart';
import 'package:flutter_chat_app/views/pages/chat/message/model/message.dart';
import 'package:flutter_chat_app/views/pages/chat/room/db_helper/room_db_helper.dart';
import 'package:flutter_chat_app/views/pages/chat/room/model/room.dart';
import 'package:flutter_chat_app/views/pages/contact/controller/contacts_controller.dart';
import 'package:flutter_chat_app/views/pages/contact/model/user_contact.dart';
import 'package:flutter_chat_app/views/pages/contact/model/user_model.dart';
import 'package:flutter_chat_app/views/splash_ui.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:phone_form_field/l10n/generated/phone_field_localization.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

late Directory dir;
late List<CameraDescription> cameras;

void main() async {
  await initHive();

  await GetStorage.init();

  dir = await getApplicationDocumentsDirectory();

  Get.put<LanguageController>(LanguageController());
  //firebaseFirestore.settings=Settings(cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);
  //GetStorage().remove('language');

  WidgetsFlutterBinding.ensureInitialized();
  await firebaseInitialization.then((value) {
    Get.put<AuthController>(AuthController());
  });

  cameras = await availableCameras();

  runApp(MyApp());
}

Future<void> initHive()async {
  await Hive.initFlutter();
  Hive.registerAdapter(RoomAdapter());
  await Hive.openBox<Room>(RoomDBHelper.table,);

  Hive.registerAdapter(UserModelAdapter());
  await Hive.openBox<UserModel>(UserModelDBHelper.table);

  Hive.registerAdapter(UserContactAdapter());
  await Hive.openBox<UserContact>(userContactBox);

  Hive.registerAdapter(MessageAdapter());
  await Hive.openBox<Message>(MessageDBHelper.table, /*keyComparator: (key1, key2) {
    return (key1 as String).compareTo(key2);
  },*/);
}



Box<UserContact>? _userContactsBox;
Box<UserContact> getUserContactsBox(){
  _userContactsBox ??= Hive.box<UserContact>(userContactBox);

  return _userContactsBox!;
}


Box<UserModel>? _userModelBox;
Box<UserModel> getUserModelBox(){
  _userModelBox ??= Hive.box<UserModel>(UserModelDBHelper.table);

  return _userModelBox!;
}


class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver{
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    PresenceService.instance.activate(
      onError: (e) {
        debugPrint('--> Presence error: $e');
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    debugPrint("AppLifecycleState= ${state.name}");
    switch (state) {
      case AppLifecycleState.resumed:
        PresenceService.instance.setPresence(PresenceStatus.online);
        break;
      case AppLifecycleState.inactive:
        PresenceService.instance.setPresence(PresenceStatus.away);
        break;
      case AppLifecycleState.paused:
        PresenceService.instance.setPresence(PresenceStatus.away);
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance!.removeObserver(this);
    PresenceService.instance.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LanguageController>(
        builder: (languageController) {
      return CupertinoAdaptiveTheme(
        light: CupertinoThemeData(
          brightness: Brightness.light,
          primaryColor: MyLightTheme.primaryColor,
          barBackgroundColor: MyLightTheme.barBackgroundColor,
          scaffoldBackgroundColor: MyLightTheme.scaffoldBackgroundColor,
          primaryContrastingColor: MyLightTheme.primaryContrastingColor,
          textTheme: MyLightTheme.textTheme,
        ),
        dark: CupertinoThemeData(
          brightness: Brightness.dark,
          primaryColor: MyDarkTheme.primaryColor,
          barBackgroundColor: MyDarkTheme.barBackgroundColor,
          scaffoldBackgroundColor: MyDarkTheme.scaffoldBackgroundColor,
          primaryContrastingColor: MyDarkTheme.primaryContrastingColor,
          textTheme: MyDarkTheme.textTheme,
        ),
        initial: AdaptiveThemeMode.system,
        builder: (CupertinoThemeData theme) =>
            GetCupertinoApp(
              localizationsDelegates: const [
                /*DefaultMaterialLocalizations.delegate,
                DefaultCupertinoLocalizations.delegate,
                DefaultWidgetsLocalizations.delegate,*/
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                PhoneFieldLocalization.delegate,
              ],
              supportedLocales: const [
                Locale('ar', ''),
                Locale('en', ''),
                Locale('es', ''),
                Locale('de', ''),
                Locale('fr', ''),
                Locale('it', ''),
                Locale('ru', ''),
              ],
              /*initialBinding: AppBinding(),
              initialRoute: AppPages.INITIAL,
              getPages: AppPages.routes,*/
              /*defaultTransition: Transition.fade,
              transitionDuration: Duration(milliseconds: 500),*/
              locale: languageController.getLocale,
              translations: Localization(),
              debugShowCheckedModeBanner: false,
              theme: theme,
              home: SplashUI(),
            ),
      );
    });
  }
}


class FetchContacts{

  static Future<void> getContacts() async {
    List<UnregisteredUserContact> _allContactsList=[];
    if (await FlutterContacts.requestPermission()) {
      var _contacts = await FlutterContacts.getContacts(sorted: true,
        withProperties: true, );
      _contacts.forEach((element) {
        element.phones.forEach((e) {
          if(e.number.isNotEmpty)
            _allContactsList.add(UnregisteredUserContact(element.displayName, e.number.replaceAll(' ', '')));
        });
      });
      var myPhone=auth.currentUser!.phoneNumber!.replaceAll(' ', '');
      _allContactsList.removeWhere((element) => element.phone==myPhone);
      _allContactsList.forEach((element)  async {
        await firebaseFirestore.collection(Collections.USERS)
            .where('phone', isEqualTo: element.phone)
            .withConverter(fromFirestore: (snapshot, options) => UserContact.fromJson(snapshot.data()!), toFirestore: (UserContact user, _)=> user.toJson())
            .get().then((value){
              value.docs.forEach((e) {
                var user=e.data();
                user.name=element.name;
                getUserContactsBox().put(e.id, user);
              });
            });
      });
    }
  }
}

