import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;

import 'like.dart';

Future<List<Post>> fetchPosts(http.Client client, userId) async {
  final response = await client
      .get('http://compartilhagram.esy.es/api/posts/' + userId.toString());
  return compute(parsePosts, response.body);
}

List<Post> parsePosts(String responseBody) {
  //final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
  Map parsed = json.decode(responseBody);
  return parsed['posts'].map<Post>((json) => new Post.fromJson(json)).toList();
}

class User {
  final int idUser;
  final String username;

  User({this.idUser, this.username});

  factory User.fromJson(Map<String, dynamic> json) {
    return new User(
      idUser: json['idUser'] as int,
      username: json['name'] as String,
    );
  }
}

class Post {
  final int idPost;
  final String name;
  final String description;
  final String image;
  final String date;
  final String userImage;
  final int qtdLikes;
  bool liked;

  // final List<Comment> comments;

  Post({
    this.idPost,
    this.name,
    this.description,
    this.image,
    this.date,
    this.userImage,
    this.qtdLikes,
    this.liked,
    // new Post.fromJson(this.comment)).toList();
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return new Post(
      idPost: json['idPost'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      image: json['image'] as String,
      date: json['date'] as String,
      userImage: json['userImage'] as String,
      qtdLikes: json['qtdLikes'] as int,
      liked: json['liked'] as bool,
      // comments    : json['comments'] as List,
    );
  }
}

class Comment {
  final String comment;
  final String name;
  final String date;

  Comment({this.comment, this.name, this.date});

  factory Comment.fromJson(Map<String, dynamic> json) {
    return new Comment(
      comment: json['comment'] as String,
      name: json['name'] as String,
      date: json['date'] as String,
    );
  }
}

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTitle = 'Compartilhagram';

    return new MaterialApp(
      title: appTitle,
      home: new MyHomePage(title: appTitle),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;
  final int userId = 2;

  MyHomePage({Key key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(title),
      ),
      body: Center(
        child: FutureBuilder<List<Post>>(
            future: fetchPosts(new http.Client(), userId),
            builder: (context, snapshot) {
              if (snapshot.hasError) print(snapshot.error);

              return snapshot.hasData ? new PostList(photos: snapshot.data) : new Center(child: new CircularProgressIndicator());
            },

        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: null,
        tooltip: 'Poste uma foto On The Line',
        child: new Icon(FontAwesomeIcons.camera),
      ),
    );
  }
}

class PostList extends StatelessWidget {
  final List<Post> photos;
  final User user;

  PostList({Key key, this.photos}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var deviceSize = MediaQuery.of(context).size;
    return ListView.builder(
      itemCount: photos.length,
      itemBuilder: (context, index) => Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 8.0, 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        new Container(
                          height: 40.0,
                          width: 40.0,
                          decoration: new BoxDecoration(
                            shape: BoxShape.circle,
                            image: new DecorationImage(
                                fit: BoxFit.fill,
                                image:
                                    new NetworkImage(photos[index].userImage)),
                          ),
                        ),
                        new SizedBox(
                          width: 10.0,
                        ),
                        new Text(
                          photos[index].name,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        new SizedBox(
                          width: 10.0,
                        ),
                        new Text(photos[index].date,
                            style: TextStyle(color: Colors.grey)),
                      ],
                    )
                  ],
                ),
              ),
              Flexible(
                fit: FlexFit.loose,
                child: CachedNetworkImage(
                  placeholder: CircularProgressIndicator(),
                  imageUrl: photos[index].image,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  photos[index].description,
                  style: TextStyle(fontWeight: FontWeight.normal),
                ),
              ),
              new FavoriteWidget(photos[index].liked, photos[index].qtdLikes, photos[index].idPost, 2),
              Padding(
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
                            image: new NetworkImage(photos[index].userImage)),
                      ),
                    ),
                    new SizedBox(
                      width: 10.0,
                    ),
                    Expanded(
                      child: new TextField(
                        decoration: new InputDecoration(
                          border: InputBorder.none,
                          hintText: "Deixe seu comentário...",
                        ),
                      ),
                    ),
                    new IconButton(
                      icon: new Icon(FontAwesomeIcons.fighterJet),
                      color: Colors.black87,
                      onPressed: null,
                    ),
                  ],
                ),
              ),
            ],
          ),
    );
  }
}
