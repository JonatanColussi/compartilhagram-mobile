import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<List<Post>> fetchPosts(http.Client client) async {
    final response = await client.get('http://compartilhagram.esy.es/api/posts');
    return compute(parsePosts, response.body);
}

List<Post> parsePosts(String reponseBody) {
    final parsed = json.decode(reponseBody).cast<Map<String, dynamic>>();
    return parsed.map<Post>((json) => new Post.fromJson(json)).toList();
}

class Post {
    final int idPost;
    final String name;
    final String description;
    final String image;
    final int qtdLikes;

    Post({
        this.idPost,
        this.name,
        this.description,
        this.image,
        this.qtdLikes
    });

    factory Post.fromJson(Map<String, dynamic> json) {
        return new Post(
            idPost      : json['idPost'] as int,
            name        : json['name'] as String,
            description : json['description'] as String,
            image       : json['image'] as String,
            qtdLikes    : json['qtdLikes'] as int,
        );
    }
}


void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        final appTitle = 'Compartilahgram';

        return new MaterialApp(
            title: appTitle,
            home: new MyHomePage(title: appTitle),
        );
    }
}

class MyHomePage extends StatelessWidget {
    final String title;

    MyHomePage({Key key, this.title}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return new Scaffold(
            appBar: new AppBar(
                title: new Text(title),
            ),
            body: new FutureBuilder<List<Post>>(
                future: fetchPosts(new http.Client()),
                builder: (context, snapshot) {
                    if (snapshot.hasError) print(snapshot.error);

                    return snapshot.hasData ? new PostList(photos: snapshot.data) : new Center(child: new CircularProgressIndicator());
                }
            ),
        );
    }
}

class PostList extends StatelessWidget {
    final List<Post> photos;

    PostList({Key key, this.photos}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return new GridView.builder(
            gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
            ),
            itemCount: photos.length,
            itemBuilder: (context, index) {
                return new Image.network(photos[index].image);
            },
        );
    }
}