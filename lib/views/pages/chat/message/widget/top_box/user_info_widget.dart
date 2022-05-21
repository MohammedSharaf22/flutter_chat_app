import 'package:badges/badges.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_chat_app/utilities/date_formatter_tools.dart';
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
        var state = getState(type, lastSeen);
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            getProfileAvatar(type),
            SizedBox(width: 10),
            getNameAndLastSeen(context, state, type),
          ],
        );
      },
    );
  }


  getProfileAvatar(type){
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        children: [
          CircularProfileAvatar(
            userContact.photoURL,
            animateFromOldImageOnUrlChange: false,
            imageFit: BoxFit.cover,
            radius: 20,
          ),
          Badge(
            toAnimate: false,
            shape: BadgeShape.circle,
            position: BadgePosition.bottomEnd(),
            badgeColor: getBadgeColor(type),
            child: SizedBox(height: 30, width: 30),
            elevation: 3,
            borderSide: BorderSide(width: 0.5, color: CupertinoColors.systemFill),//Colors.white10
          ),
        ],
      ),
    );
  }

  getNameAndLastSeen(context, state, type){
    return SizedBox(
      width: 150,
      child: ItemDetector(
        onPressed: () {},
        onLongPressed: () {},
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${userContact.name}",
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              state,
              style: CupertinoTheme.of(context).textTheme.tabLabelTextStyle,
            ),
          ],
        ),
      ),
    );
  }
}

class ItemDetector extends StatefulWidget {
  final VoidCallback? onPressed;

  final VoidCallback? onLongPressed;
  final Widget child;

  bool get enabled => onPressed != null;
  bool get enabledLongPress => onLongPressed != null;

  const ItemDetector({
    Key? key,
    required this.child,
    required this.onPressed,
    this.onLongPressed,
  }) : super(key: key);

  @override
  State<ItemDetector> createState() => _ItemDetectorState();
}

class _ItemDetectorState extends State<ItemDetector> with SingleTickerProviderStateMixin{
  static const Duration kFadeOutDuration = Duration(milliseconds: 120);
  static const Duration kFadeInDuration = Duration(milliseconds: 180);
  final Tween<double> _opacityTween = Tween<double>(begin: 1.0);

  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  final double? pressedOpacity = 0.4;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      value: 0.0,
      vsync: this,
    );
    _opacityAnimation = _animationController
        .drive(CurveTween(curve: Curves.decelerate))
        .drive(_opacityTween);
    _setTween();
  }


  @override
  void didUpdateWidget(ItemDetector oldWidget) {
    super.didUpdateWidget(oldWidget);
    _setTween();
  }

  void _setTween() {
    _opacityTween.end = pressedOpacity ?? 1.0;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool _buttonHeldDown = false;

  bool _buttonLongHeldDown = false;

  void _handleLongPressDown(LongPressDownDetails event){
    debugPrint("_handleLongPressDown");
    if (!_buttonLongHeldDown) {
      _buttonLongHeldDown = true;
      _animateLong();
    }
  }

  void _handleLongPressUp(){
    debugPrint("_handleLongPressUp");
    if (_buttonLongHeldDown) {
      _buttonLongHeldDown = false;
      _animateLong();
    }
  }

  void _handleLongPressCancel() {
    debugPrint("_handleLongPressCancel");
    if (_buttonLongHeldDown) {
      _buttonLongHeldDown = false;
      _animateLong();
    }
  }

  void _handleTapDown(TapDownDetails event) {
    if (!_buttonHeldDown) {
      _buttonHeldDown = true;
      _animate();
    }
  }

  void _handleTapUp(TapUpDetails event) {
    if (_buttonHeldDown) {
      _buttonHeldDown = false;
      _animate();
    }
  }

  void _handleTapCancel() {
    if (_buttonHeldDown) {
      _buttonHeldDown = false;
      _animate();
    }
  }

  void _animate() {
    if (_animationController.isAnimating)
      return;
    final bool wasHeldDown = _buttonHeldDown;
    final TickerFuture ticker = _buttonHeldDown
        ? _animationController.animateTo(1.0, duration: kFadeOutDuration, curve: Curves.easeInOutCubicEmphasized)
        : _animationController.animateTo(0.0, duration: kFadeInDuration, curve: Curves.easeOutCubic);
    ticker.then<void>((void value) {
      if (mounted && wasHeldDown != _buttonHeldDown)
        _animate();
    });
  }

  void _animateLong() {
    if (_animationController.isAnimating)
      return;
    final bool wasHeldDown = _buttonLongHeldDown;
    final TickerFuture ticker = _buttonLongHeldDown
        ? _animationController.animateTo(1.0, curve: Curves.easeInOutCubicEmphasized)
        : _animationController.animateTo(0.0, curve: Curves.easeOutCubic);
    ticker.then<void>((void value) {
      if (mounted && wasHeldDown != _buttonLongHeldDown)
        _animateLong();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.enabled;
    final bool enabledLongPress = widget.enabledLongPress;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? _handleTapDown : null,
      onTapUp: enabled ? _handleTapUp : null,
      onTapCancel: enabled ? _handleTapCancel : null,
      onLongPressDown: enabledLongPress ? _handleLongPressDown : null,
      onLongPressUp: enabledLongPress ? _handleLongPressUp : null,
      onLongPressCancel: enabledLongPress ? _handleLongPressCancel : null,
      onLongPress: widget.onLongPressed,
      onTap: widget.onPressed,
      child: Semantics(
        container: true,
        //header: ,
        //button: true,
        child: ConstrainedBox(
          constraints: const BoxConstraints(),
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

