import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<List<Photo>> fetchPhotos(http.Client client) async {
  final response =
      //await client.get('https://jsonplaceholder.typicode.com/photos');
  await client.get('http://compartilhagram.esy.es/api/posts');
  return compute(parsePhotos, response.body);
}

List<Photo> parsePhotos(String reponseBody) {
  final parsed = json.decode(reponseBody).cast<Map<String, dynamic>>();

  return parsed.map<Photo>((json) => new Photo.fromJson(json)).toList();
}

class Photo {
  final String idPost;
  final String name;
  final String description;
  final String image;
  final String qtdLikes;
  //final String thumbnailUrl;

  Photo({this.idPost, this.name, this.description, this.image, this.qtdLikes});

  factory Photo.fromJson(Map<String, dynamic> json) {
    return new Photo(
      idPost: json['idPost'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      image: json['image'] as String,
      qtdLikes: json['qtdLikes'] as String,
    );
  }

}


void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final appTitle = 'Isolate Demo';

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
      body: new FutureBuilder<List<Photo>>(
          future: fetchPhotos(new http.Client()),
          builder: (context, snapshot) {
            if (snapshot.hasError) print(snapshot.error);

            return snapshot.hasData
                ? new PhotoList(photos: snapshot.data)
                : new Center(child: new CircularProgressIndicator());
          }
      ),
    );
  }
}

class PhotoList extends StatelessWidget {
  final List<Photo> photos;

  PhotoList({Key key, this.photos}) : super(key: key);

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