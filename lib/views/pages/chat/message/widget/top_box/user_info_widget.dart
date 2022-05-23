import 'package:badges/badges.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_chat_app/utilities/date_formatter_tools.dart';
import 'package:flutter_chat_app/utilities/presence/user_presence.dart';
import 'package:flutter_chat_app/utilities/widgets/item_detector.dart';
import 'package:flutter_chat_app/views/pages/contact/model/user_contact.dart';
import 'package:get/get.dart';

class UserInfoWidget extends StatelessWidget {
  final UserContact userContact;
  const UserInfoWidget({
    Key? key,
    required this.userContact,
  }) : super(key: key);

  String getState(PresenceType type, int lastSeen) {
    if (type == PresenceType.online)
      return type.name.tr;
    //var dateTimeSeen = Duration(milliseconds: lastSeen);
    var dateTimeSeen = DateTime.fromMillisecondsSinceEpoch(lastSeen, );
    debugPrint("dateTimeSeen= ${dateTimeSeen.toString()}");
    debugPrint("lastSeen= $lastSeen");
    return DateFormatterTools(lastSeen).formatStateTime();
  }

  getBadgeColor(PresenceType type){
    if(type == PresenceType.online)
      return CupertinoColors.systemGreen;
    else if(type == PresenceType.offline)
      return CupertinoColors.systemPink;
    return CupertinoColors.systemYellow;
  }

  @override
  Widget build(BuildContext context) {
    return UserPresence(
      uid: userContact.uid,
      builder: (PresenceType type, int lastSeen) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            getProfileAvatar(type, lastSeen),
            SizedBox(width: 10),
            getNameAndLastSeen(context, lastSeen, type),
          ],
        );
      },
    );
  }

  Widget getProfileAvatar(type, int lastSeen){
    return SizedBox(
      width: 40,
      height: 40,
      child: ItemDetector(
        onPressed: () {

        },
        child: Stack(
          children: [
            CircularProfileAvatar(
              userContact.photoURL,
              animateFromOldImageOnUrlChange: false,
              imageFit: BoxFit.cover,
              radius: 20,
            ),
            Visibility(
              visible: lastSeen != -1,
              child: Badge(
                toAnimate: false,
                shape: BadgeShape.circle,
                position: BadgePosition.bottomEnd(),
                badgeColor: getBadgeColor(type),
                child: SizedBox(height: 30, width: 30),
                elevation: 3,
                borderSide: BorderSide(width: 0.5, color: CupertinoColors.systemFill),//Colors.white10
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getNameAndLastSeen(context, int lastSeen, PresenceType type){
    var state = getState(type, lastSeen);
    var lastSeenWord = "last_seen".tr;

    return SizedBox(
      width: 150,
      child: ItemDetector(
        padding: EdgeInsets.only(top: 6, bottom: 6),
        onPressed: () {},
        child: Stack(
          children: [
            AnimatedAlign(
              alignment: lastSeen != -1? AlignmentDirectional.topStart : AlignmentDirectional.centerStart,
              duration: Duration(milliseconds: 300),
              child: Text(
                "${userContact.name}",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Visibility(
              visible: lastSeen != -1,
              child: Align(
                alignment: AlignmentDirectional.bottomStart,
                child: Text(
                  "$lastSeenWord $state",
                  style: CupertinoTheme.of(context).textTheme.tabLabelTextStyle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

