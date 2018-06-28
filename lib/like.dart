import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;

class FavoriteWidget extends StatefulWidget {
  @override
  bool _isFavorited;
  int _favoriteCount;
  final int postId;
  final int userId;

  FavoriteWidget(
    this._isFavorited,
    this._favoriteCount,
    this.postId,
    this.userId
  );

  FavoriteWidgetState createState() => new FavoriteWidgetState(this._isFavorited, this._favoriteCount, this.postId, this.userId);
}

class FavoriteWidgetState extends State<FavoriteWidget> {
  bool _isFavorited;
  int _favoriteCount;
  final int postId;
  final int userId;

  FavoriteWidgetState(
    this._isFavorited,
    this._favoriteCount,
    this.postId,
    this.userId
  );

  void _toggleFavorite() async {

    var url = "http://compartilhagram.esy.es/api/like/"+postId.toString()+"/"+userId.toString();

    var client = new http.Client();
    final response = await client.get(url);
    List parsed = json.decode(response.body);

    setState(() {
      _favoriteCount = parsed[1];
      _isFavorited = parsed[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new IconButton(
                icon: _isFavorited ? new Icon(FontAwesomeIcons.solidThumbsUp) : new Icon(FontAwesomeIcons.thumbsUp),
                onPressed: _toggleFavorite,
              ),
              new SizedBox(
                width: 16.0,
              ),
              new Text(
                '$_favoriteCount'+" Likes",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}