import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/utilities/presence/presence_service.dart';

enum PresenceType {
  online,
  offline,
  away,
}

class UserPresence extends StatefulWidget {
  const UserPresence({
    required this.uid,
    required this.builder,
    Key? key,
  }) : super(key: key);

  final String uid;
  final Widget Function(PresenceType type, int lastSeen) builder;

  @override
  State<UserPresence> createState() => _UserPresenceState();
}

class _UserPresenceState extends State<UserPresence> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
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
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseDatabase.instance.ref('presence').child(widget.uid).onValue,
      builder: (context, AsyncSnapshot<DatabaseEvent> event) {

        if (event.hasData && event.data!.snapshot.exists) {
          final String status = (event.data!.snapshot.value! as Map)['status'];
          final int timestamp =(event.data!.snapshot.value! as Map)['timestamp'];

          if (status == PresenceStatus.online.name) {
            return widget.builder(PresenceType.online, timestamp);
          } else if (status == PresenceStatus.away.name) {
            return widget.builder(PresenceType.away, timestamp);
          } else {
            return widget.builder(PresenceType.offline, timestamp);
          }
        } else {
          return widget.builder(PresenceType.offline, -1);
        }
      },
    );
  }
}
