import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';

class ItemDetector extends StatefulWidget {
  final VoidCallback? onPressed;
  final VoidCallback? onLongPressed;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  bool get enabled => onPressed != null;
  bool get enabledLongPress => onLongPressed != null;

  const ItemDetector({
    Key? key,
    required this.child,
    this.onPressed,
    this.onLongPressed,
    this.padding,
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

  bool _buttonHeldDown = false;

  void _handleLongPressDown(LongPressDownDetails event){
    debugPrint("_handleLongPressDown");
    if (!_buttonHeldDown) {
      _buttonHeldDown = true;
      _animate();
    }
  }

  void _handleLongPressUp(){
    debugPrint("_handleLongPressUp");
    if (_buttonHeldDown) {
      _buttonHeldDown = false;
      _animate();
    }
  }

  void _handleLongPressCancel() {
    debugPrint("_handleLongPressCancel");
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
      //onHorizontalDragEnd: enabledLongPress ?(DragEndDetails details)=> _handleLongPressCancel(): null,
      /*onTapUp: (details){
        _handleLongPressUp();
      },*/
      onLongPress: widget.onLongPressed,
      onTap: widget.onPressed,
      child: Semantics(
        button: true,
        child: ConstrainedBox(
          constraints: const BoxConstraints(),
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: Padding(
              padding: widget.padding ?? EdgeInsetsDirectional.zero,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
