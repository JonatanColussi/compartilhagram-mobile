import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;

import 'main.dart';

class CommentWidget extends StatefulWidget {
  @override
  final NetworkImage userImage;
  final int postId;
  final int userId;

  CommentWidget({
    this.userImage,
    this.postId,
    this.userId
  });

  CommentWidgetState createState() => new CommentWidgetState(userImage: this.userImage, postId: this.postId, userId: this.userId);
}

class CommentWidgetState extends State<CommentWidget> {
  final NetworkImage userImage;
  final int postId;
  final int userId;
  final myController = TextEditingController();

  CommentWidgetState({
    this.userImage,
    this.postId,
    this.userId
  });

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 0.0, 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          new Container(
            height: 40.0,
            width: 40.0,
            decoration: new BoxDecoration(
              shape: BoxShape.circle,
              image: new DecorationImage(
                  fit: BoxFit.fill,
                  image: userImage
              ),
            ),
          ),
          new SizedBox(
            width: 10.0,
          ),
          Expanded(
            child: new TextField(
              controller: myController,
              decoration: new InputDecoration(
                border: InputBorder.none,
                hintText: "Deixe seu comentário...",
              ),
            ),
          ),
          new IconButton(
            icon: new Icon(FontAwesomeIcons.fighterJet),
            color: Colors.black54,
            onPressed: () async {
              if (myController.text.isNotEmpty) {
                var url = "http://compartilhagram.esy.es/api/saveComment/"+postId.toString();

                Map<String, String> data = {
                  'user_id' : userId.toString(),
                  'comment' : myController.text,
                };

                var client = new http.Client();
                final response = await client.post(
                  url,
                  body: data
                );

                Map<String, dynamic> responseData = json.decode(response.body);
                String dialogText = (responseData['response']) ? 'Comentário postado On The Line' : 'Houve um erro ao postar seu comentário On The Line \n :(';

                return showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: Text(dialogText),
                      actions: [
                        new FlatButton(
                          child: const Text(":D"),
                          onPressed: () {
                            myController.clear();
                            Navigator.pop(context);
                            runApp(new MyApp());
                          }
                        ),
                      ],
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }
}