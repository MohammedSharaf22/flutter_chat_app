import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_chat_app/control/constants/firebase_auth_constants.dart';
import 'package:flutter_chat_app/utilities/collection_enum.dart';
import 'package:flutter_test/flutter_test.dart';


void main() async {

  test('Sets data for a document within a collection', () async {

    final instance = FakeFirebaseFirestore();
    final messageCollection = instance.collection('messages');
    instance.collection(Collections.USERS)
        .doc('KUP2csE0BhRoqaGXFyo1xNLjKPA2').collection(Collections.MESSAGES);
    var messId_1 = messageCollection
        .doc()
        .id;
    messageCollection.doc(messId_1).set(
        {
          "messageId": "messId_1",
          "senderId": "10CfP4xhvLPcSzdb4EOPhbQ4lOM2",
          "receiverId": "KUP2csE0BhRoqaGXFyo1xNLjKPA2",
          "text": """ مرحبا صديقي كيف حالك؟ 
    مرحبا صديقي كيف حالك؟""",
          "type": 0,
          "url": "",
          "time": FieldValue.serverTimestamp(),
          "isReceive": 0,
        }
    );
    var messId_2 = messageCollection
        .doc()
        .id;
    messageCollection.doc(messId_2).set(
        {
          "messageId": "$messId_2",
          "senderId": "10CfP4xhvLPcSzdb4EOPhbQ4lOM2",
          "receiverId": "KUP2csE0BhRoqaGXFyo1xNLjKPA2",
          "text": """ مرحبا صديقي كيف حالك؟ 
    مرحبا صديقي كيف حالك؟""",
          "type": 0,
          "url": "",
          "time": FieldValue.serverTimestamp(),
          "isReceive": 1,
        }
    );
  });


  final instance = FakeFirebaseFirestore();
  await instance.collection('users').add({
    'username': 'Bob',
  });
  final snapshot = await instance.collection('users').get();
  print(snapshot.docs.length); // 1
  print(snapshot.docs.first.get('username')); // 'Bob'
  print(instance.dump());

}