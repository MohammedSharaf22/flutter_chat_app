import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'avatar_image.dart';

class ChatItem extends StatelessWidget {
  const ChatItem(this.chatData, { Key? key, this.onTap}) : super(key: key);
  final chatData;
  final GestureTapCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Column(
          children: [
            SizedBox(height: 2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AvatarImage(
                  chatData['name'], 
                  width: 50,
                  height: 50,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: 
                  Container(
                    height: 60,
                    child:
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  child: Text(chatData['name'], maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700))
                                )
                              ),
                              SizedBox(width: 5),
                              Container(
                                child: Text(chatData['date'], maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14))
                              )
                            ],
                          ),
                          Visibility(
                            visible: chatData['chatType'] == 1 ? true : false,
                            child: SizedBox(height:  3,)
                          ),
                          Visibility(
                            visible: chatData['chatType'] == 1 ? true : false,
                            child: Row(
                              children: <Widget>[
                                Container(
                                  child: Text(chatData['last_user'], maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600))
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 3,),
                          Row(
                            children: <Widget>[
                              Container(
                                child: Text(chatData['last_text'], maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13))
                              ),
                            ],
                          ),
                        ],
                      )
                  )
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 60),
              child: Divider(color: Colors.grey.withOpacity(0.8),),
            )
          ],
        ),
      ),
    );
  }

  getc(){
    Slidable(
      // Specify a key if the Slidable is dismissible.
      //key: const ValueKey(0),
      // The start action pane is the one at the left or the top side.
      startActionPane: ActionPane(
        // A motion is a widget used to control how the pane animates.
        motion: const ScrollMotion(),

        // A pane can dismiss the Slidable.
        dismissible: DismissiblePane(onDismissed: () {}),

        // All actions are defined in the children parameter.
        children: const [
          // A SlidableAction can have an icon and/or a label.
          SlidableAction(
            onPressed: null,
            backgroundColor: Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
          SlidableAction(
            onPressed: null,
            backgroundColor: Color(0xFF21B7CA),
            foregroundColor: Colors.white,
            icon: Icons.share,
            label: 'Share',
          ),
        ],
      ),

      // The end action pane is the one at the right or the bottom side.
      endActionPane: const ActionPane(
        motion: ScrollMotion(),
        children: [
          SlidableAction(
            // An action can be bigger than the others.
            flex: 2,
            onPressed: null,
            backgroundColor: Color(0xFF7BC043),
            foregroundColor: Colors.white,
            icon: Icons.archive,
            label: 'Archive',
          ),
          SlidableAction(
            onPressed: null,
            backgroundColor: Color(0xFF0392CF),
            foregroundColor: Colors.white,
            icon: Icons.save,
            label: 'Save',
          ),
        ],
      ),

      // The child of the Slidable is what the user sees when the
      // component is not dragged.
      child: const ListTile(title: Text('Slide me')),
    );
  }
}