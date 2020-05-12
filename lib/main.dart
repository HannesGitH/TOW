import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

Color team1_color = Color.fromARGB(255, 255, 56, 56);
Color team2_color = Color.fromARGB(255, 62, 238, 238);

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TOW Worldwide',
      darkTheme: ThemeData(
        primaryColor: team1_color,
        accentColor: team1_color,
      ),
      theme: ThemeData(
        primaryColor: team2_color,
        accentColor: team2_color,
      ),
      home: MyHomePage(title: 'TOW : TugOfWar Worldwide'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ///0: none; 1:blue; 2:red
  Future<int> getTeam() async {
    //return 0;//only to debug
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return (await prefs.getInt('team'))??0;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getTeam(),
      initialData: 0,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return Center(child: CircularProgressIndicator());
        }
        if (snap.data == 0) {
          return TeamChoose();
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
          ),
          body: Text("you shouldn't be here"),
        );
      },
    );
  }
}

class TeamChoose extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose your team'),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            TeamButton(team: 1),
            TeamButton(team: 2),
          ],
        ),
      ),
    );
  }
}

class TeamButton extends StatelessWidget {
  int team;
  TeamButton({this.team = 1});

  _setTeam(int t) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('team', t);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: RaisedButton(
          elevation: 14,
          shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(30),),
          color: team == 1 ? team1_color : team2_color,
          onPressed: () {
            _setTeam(team);
            runApp(MyApp());
          },
          child:  Padding(
            padding: EdgeInsets.all(40),
            child: Transform(
              transform: team==1?Matrix4.identity():(Matrix4.identity()..rotateY(pi)..translate(-200.0,0,0)),
              child: SvgPicture.asset(
                'assets/tugger.svg',
                color: Colors.black54,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
