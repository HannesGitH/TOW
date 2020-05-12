import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
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
        primaryColorBrightness: Brightness.light,
        accentColor: team1_color,
      ),
      theme: ThemeData(
        primaryColor: team2_color,
        primaryColorBrightness: Brightness.light,
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
    return (await prefs.getInt('team')) ?? 0;
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
        return Fighter(
          team: snap.data,
          title: widget.title,
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          color: team == 1 ? team1_color : team2_color,
          onPressed: () {
            _setTeam(team);
            runApp(MyApp());
          },
          child: Padding(
            padding: EdgeInsets.all(40),
            child: Transform(
              transform: team == 1
                  ? Matrix4.identity()
                  : (Matrix4.identity()
                    ..rotateY(pi)
                    ..translate(-200.0, 0, 0)),
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

class Fighter extends StatefulWidget {
  int team;
  final String title;
  Color _color;
  Fighter({this.team, this.title}) {
    this._color = (team == 1) ? team1_color : team2_color;
  }
  @override
  _FighterState createState() => _FighterState();
}

class _FighterState extends State<Fighter> {
  final dbr = FirebaseDatabase.instance.reference();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Color c = widget._color;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: c,
        centerTitle: true,
      ),
      body: StreamBuilder(
        //initialData: dbr.once(),
        stream: dbr.onValue,
        builder: (BuildContext context, AsyncSnapshot<Event> snapshot) {
          int team1 = 0;
          int team2 = 0;
          if (snapshot.connectionState == ConnectionState.active ||
              snapshot.connectionState == ConnectionState.done) {
            DataSnapshot s = snapshot.data.snapshot;
            team1 = s.value['team1'];
            team2 = s.value['team2'];
          }

          return Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      (team1).toString(),
                      style: TextStyle(fontSize: 30),
                    ),
                    Text(
                      (team2).toString(),
                      style: TextStyle(fontSize: 30),
                    ),
                  ],
                ),
                Rope(percent:(team1/(team1+team2))*100),
                FloatingActionButton(
                  child: Icon(Icons.add),
                  onPressed: () {
                    print("pressed");
                    dbr
                        .child('team${widget.team}')
                        .runTransaction((transaction) {
                      int old = transaction.value;
                      print("old: $old");
                      dbr.child('team${widget.team}').set(old + 1);
                      return;
                    });
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class Rope extends StatelessWidget {
  double percent;
  Rope({this.percent = 50});

  @override
  Widget build(BuildContext context) {
    print(percent);
    return Container(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(alignment: Alignment.centerLeft, children: [
            FractionallySizedBox(
              widthFactor: 1,
              child: Container(
                height: 40,
                color: team2_color,
              ),
            ),
            FractionallySizedBox(
              widthFactor: percent / 100,
              child: Container(
                height: 40,
                color: team1_color,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
