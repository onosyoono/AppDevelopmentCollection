import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: new MyHomePage(title: 'MOVIES LIST'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key, key, this.title}) : super(key: key);

  final String title;
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<List<User>> _getUsers() async {
    var data = await http
        .get("https://limitless-fortress-81406.herokuapp.com/get_data");
    //the link is the api entered, in my case its an api that i made, present in the backend folder

    var jsonData = json.decode(data.body);

    List<User> users = [];

    for (var u in jsonData) {
      User user = User(u["id"], u["description"], u["title"], u["year"],
          u["imageUrl"], u["duration"], u["rating"]);

      users.add(user);
    }

    print(users.length);
    return users;
  }

//this is the main page homescreen
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(widget.title),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  showSearch(
                      context: context,
                      delegate: DataSearch()); //to implement search area
                })
          ],
        ),
        body: Container(
            child: FutureBuilder(
                future: _getUsers(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.data == null) {
                    return Container(child: Center(child: Text("Loading...")));
                  } else {
                    return ListView.builder(
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage:
                                  NetworkImage(snapshot.data[index].imageUrl),
                            ),
                            title: Text(snapshot.data[index].title),
                            subtitle: Text(snapshot.data[index].rating),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  new MaterialPageRoute(
                                      builder: (context) =>
                                          DetailPage(snapshot.data[index])));
                            },
                          );
                        });
                  }
                })));
  }
}

//this is the on click UI
class DetailPage extends StatelessWidget {
  final User user;
  DetailPage(this.user);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(user.title),
        ),
        body: ListView(children: <Widget>[
          SingleChildScrollView(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                  padding: EdgeInsets.all(10),
                  height: 250,
                  width: 300,
                  child: new Image(image: NetworkImage(user.imageUrl))),
              Card(
                  color: Colors.grey,
                  child: Text("Title:" + user.title,
                      style: TextStyle(fontSize: 25, color: Colors.black))),
              Card(
                  color: Colors.grey,
                  child: Text("Rating:" + user.rating,
                      style: TextStyle(fontSize: 20, color: Colors.black))),
              Card(
                  color: Colors.grey,
                  child: Text("Duration:" + user.duration,
                      style: TextStyle(fontSize: 20, color: Colors.black))),
              Card(
                  color: Colors.grey,
                  child: Text("Year of release:" + user.year,
                      style: TextStyle(fontSize: 20, color: Colors.black))),
              Card(
                  color: Colors.grey,
                  child: Text("Description:" + user.description,
                      style: TextStyle(fontSize: 20, color: Colors.black))),
            ],
          ))
        ]));
  }
}

//this is the class with all details that would be returning from the API
class User {
  final String id;
  final String description;
  final String title;
  final String year;
  final String imageUrl;
  final String duration;
  final String rating;
  User(this.id, this.description, this.title, this.year, this.imageUrl,
      this.duration, this.rating);
}

//This class is for search
class DataSearch extends SearchDelegate<String> {
  Future<List<User>> _getUsers(query) async {
    var data = await http.get(
        "https://limitless-fortress-81406.herokuapp.com/search_data/$query"); //own made API running on FLASK

    var jsonData = json.decode(data.body);

    List<User> users = [];

    for (var u in jsonData) {
      User user = User(u["id"], u["description"], u["title"], u["year"],
          u["imageUrl"], u["duration"], u["rating"]);
      users.add(user);
    }

    print(users.length);
    return users;
  }

  final mov = [];

  final recentmov = [];

  @override
  List<Widget> buildActions(BuildContext context) {
    // actions for app bar

    return [
      IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = "";
          })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    //leading icon on left of appbar
    return IconButton(
        icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow,
          progress: transitionAnimation,
        ),
        onPressed: () {
          close(context, null);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    //show some result based on the selection
    return Center(
      child: Container(
          child: FutureBuilder(
              future: _getUsers(query),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.data == null) {
                  return Container(child: Center(child: Text("Loading...")));
                } else {
                  return ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage:
                                NetworkImage(snapshot.data[index].imageUrl),
                          ),
                          title: Text(snapshot.data[index].title),
                          subtitle: Text(snapshot.data[index].rating),
                          onTap: () {
                            Navigator.push(
                                context,
                                new MaterialPageRoute(
                                    builder: (context) =>
                                        DetailPage(snapshot.data[index])));
                          },
                        );
                      });
                }
              })),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    //show when someone searches for something
    int cnt = 0;
    for (int i = 0; i < mov.length; ++i) {
      if (query == mov[i]) {
        cnt++;
        break;
      }
    }
    if (cnt == 0) {
      mov.add(query);
    } else {
      cnt = 0;
    }

    final suggestionList = query.isEmpty
        ? recentmov
        : mov.where((p) => p.startsWith(query)).toList();

    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
        onTap: () {
          if (query != "") {
            recentmov.add(query);

            showResults(context);
          } else {
            query = recentmov[index];
            showResults(context);
          }
        },
        leading: Icon(Icons.movie),
        title: RichText(
            text: TextSpan(
                text: suggestionList[index].substring(0, query.length),
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                children: [
              TextSpan(
                  text: suggestionList[index].substring(query.length),
                  style: TextStyle(color: Colors.grey))
            ])),
      ),
      itemCount: suggestionList.length,
    );
  }
}
