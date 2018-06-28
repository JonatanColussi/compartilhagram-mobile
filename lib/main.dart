import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;

import 'like.dart';
import 'comment.dart';

Future<List> fetchPosts(http.Client client, userId) async {
  final response = await client.get('http://compartilhagram.esy.es/api/posts/' + userId.toString());
  return compute(parsePosts, response.body);
}

List parsePosts(String responseBody) {
  Map parsed = json.decode(responseBody);
  List<Post> posts = parsed['posts'].map<Post>((json) => new Post.fromJson(json)).toList();
  User user = new User.fromJson(parsed['user']);

  List response = [
    user,
    posts
  ];

  return response;
}

class User {
  final int idUser;
  final String username;
  final String name;
  final String image;

  User({
    this.idUser,
    this.username,
    this.name,
    this.image
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return new User(
      idUser: json['idUser'] as int,
      username: json['username'] as String,
      name: json['name'] as String,
      image: json['image'] as String,
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
  List<Comment> comments;

  Post({
    this.idPost,
    this.name,
    this.description,
    this.image,
    this.date,
    this.userImage,
    this.qtdLikes,
    this.liked,
    this.comments,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    List comments = json['comments'].map<Comment>((commentJson) => new Comment.fromJson(commentJson)).toList();

    return new Post(
      idPost: json['idPost'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      image: json['image'] as String,
      date: json['date'] as String,
      userImage: json['userImage'] as String,
      qtdLikes: json['qtdLikes'] as int,
      liked: json['liked'] as bool,
      comments : comments,
    );
  }
}

class Comment {
  final String comment;
  final String name;
  final String date;
  final String image;

  Comment({
    this.comment,
    this.name,
    this.date,
    this.image
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return new Comment(
      comment: json['comment'] as String,
      name: json['name'] as String,
      date: json['date'] as String,
      image: json['image'] as String,
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
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;
  final int userId = 2;

  MyHomePage({Key key, this.title}) : super(key: key);

  Future<Null> refreshList() async {
    runApp(new MyApp());
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(title),
      ),
      body: RefreshIndicator(
          child: Center(
            child: FutureBuilder<List>(
              future: fetchPosts(new http.Client(), userId),
              builder: (context, AsyncSnapshot<List> snapshot) {
                if (snapshot.hasError) print(snapshot.error);


                if (snapshot.hasData) {
                  List<dynamic> data = snapshot.data;
                  List<Post> posts = data[1];
                  User user = data[0];

                  return new PostList(photos: posts, user: user);
                } else {
                  return new Center(child: new CircularProgressIndicator());
                }

              },

            ),
          ),
          onRefresh: refreshList
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

  PostList({Key key, this.photos, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var userImage = new NetworkImage(user.image);
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
                                image: new NetworkImage(photos[index].userImage)
                            ),
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
                        new Text(
                            photos[index].date,
                            style: TextStyle(color: Colors.grey)
                        ),
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
              new FavoriteWidget(photos[index].liked, photos[index].qtdLikes, photos[index].idPost, user.idUser),
              Container(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 8.0, 16.0),
                child: Column(
                  children: new List.generate(photos[index].comments.length, (int i) {
                      return new Column(
                          children: <Widget> [
                            new Row(
                              children: <Widget>[
                                new Container(
                                    height: 40.0,
                                    width: 40.0,
                                    decoration: new BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: new DecorationImage(
                                          fit: BoxFit.fill,
                                          image: new NetworkImage(photos[index].comments[i].image)
                                      ),
                                    ),
                                ),
                                new SizedBox(
                                  width: 10.0,
                                ),
                                new Text(photos[index].comments[i].name),
                                new SizedBox(
                                  width: 10.0,
                                ),
                                new Text(
                                    photos[index].comments[i].date,
                                    style: TextStyle(color: Colors.grey)
                                ),
                              ],
                          ),
                            new Row(
                              children: <Widget>[
                                new SizedBox(
                                  height: 10.0,
                                ),
                              ],
                            ),
                            new Row(
                              children: <Widget>[
                                new Expanded(
                                  child: new Text(photos[index].comments[i].comment),
                                ),
                              ],
                            ),
                            new Row(
                              children: <Widget>[
                                new SizedBox(
                                  height: 20.0,
                                ),
                              ],
                            ),
                        ]
                      );
                    }),
                )
              ),
              new CommentWidget(
                userImage: userImage,
                postId: photos[index].idPost,
                userId: user.idUser,
              ),
              new Divider(color: Colors.black54),
            ],
          ),
    );
  }
}
