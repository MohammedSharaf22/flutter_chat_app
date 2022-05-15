

import 'package:flutter/cupertino.dart';

class MyCheckBox extends StatelessWidget {
  final bool value;

  final ValueChanged<bool> onChanged;
  const MyCheckBox({
    Key? key,
    required this.value,
    required this.onChanged
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onChanged(!value);
      },
      child: Container(
        height: 25,
        width: 25,
        margin: const EdgeInsets.symmetric(horizontal: 10.0),
        /*decoration: BoxDecoration(
          border: Border.all(color: Colors.transparent),
          //borderRadius: borderRadius,
          shape: BoxShape.circle,
          color: value?CupertinoColors.white:null,
        ),*/
        child: value
            ? Stack(
          alignment: Alignment.center,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(color: CupertinoColors.white, shape: BoxShape.circle),
                ),
                Icon(
                  CupertinoIcons.check_mark_circled_solid,
                  size: 25.0,
                  color: CupertinoColors.activeBlue,
                ),
              ]
            )
            : Icon(
          CupertinoIcons.circle,
          size: 25.0,
          //color: CupertinoColors.white,
        ),
      ),
    );
  }
}
