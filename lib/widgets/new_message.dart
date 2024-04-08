import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NewMesage extends StatefulWidget {
  const NewMesage({super.key});

  @override
  State<NewMesage> createState() => _NewMesageState();
}

class _NewMesageState extends State<NewMesage> {
    TextEditingController _newMessageController = TextEditingController();
    String newMessage ="";

    @override
    void dispose() {
      _newMessageController.dispose();
      super.dispose();
    }


    Future<void> _submit() async {
      newMessage=_newMessageController.text.trim().toString();
      if(newMessage.trim().isEmpty ){
        return;
      }
      FocusScope.of(context).unfocus();
      _newMessageController.clear();
      final user = FirebaseAuth.instance.currentUser!;
      final userData = await FirebaseFirestore.instance.collection('user').doc(user.uid).get();
      print("this is user data $userData");
      FirebaseFirestore.instance.collection('chat').add({
        'text':newMessage,
        'createdAt':Timestamp.now(),
        'userId':user.uid,
        'username':userData.data()!['username'],
        'userImage':userData.data()!['imageurl'],
      });
    }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 30, right: 5, bottom: 20),
      child: Row(
        children: [
          Expanded(child: TextField(
            controller: _newMessageController,
            textCapitalization: TextCapitalization.sentences,
            autocorrect: true,
            decoration: InputDecoration(
              label: Text("New message...")
            ),
          )),
          IconButton(
              onPressed: _submit,
              icon: Icon(
                Icons.send,
                color: Theme.of(context).colorScheme.primary,
              ))
        ],
      ),
    );
  }
}
