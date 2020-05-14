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
    //return 2;//only to debug
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
    dbr.once().then((s) {
      setState(() {
        team1 = s.value['team1'];
        team2 = s.value['team2'];
      });
    });
    dbr.onValue.listen((e) {
      setState(() {
        team1 = e.snapshot.value['team1'];
        team2 = e.snapshot.value['team2'];
      });
    });
  }

  bool _isdown = false;
  int clicked = 0;

  int team1 = 1;
  int team2 = 1;

  @override
  Widget build(BuildContext context) {
    Color c = widget._color;

    int team = widget.team;

    int team1n=team1;
    int team2n=team2;
    if (team==1){
      team1n+=clicked;
    }else{
      team2n+=clicked;
    }

    Widget towButton = Padding(
      padding: EdgeInsets.only(
        left: team == 1 ? 100 + (_isdown ? 20.0 : 10.0) : 10,
        right: team == 1 ? 10 : 100 + (_isdown ? 20.0 : 10.0),
        bottom: 100,
      ),
      child: RaisedButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: c,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 100),
          transform: widget.team == 1
              ? Matrix4.identity()
              : (Matrix4.identity()
                ..rotateY(pi)
                ..translate(-100.0, 0, 0)),
          child: SvgPicture.asset(
            'assets/tugger.svg',
            color: Colors.black54,
          ),
        ),
        onHighlightChanged: (bool down) {
          setState(() {
            _isdown = down;
          });
        },
        onPressed: () {
          if (clicked>=9){
            try {
              dbr.child('team$team').runTransaction((transaction) {
                int old = transaction.value;
                print("old: $old");
                dbr.child('team$team').set(old + 9);
                return;
              });
            } catch (Exception) {}
            setState(() {
              clicked=1;
            });
          }
          else{
            setState(() {
              clicked++;
            });
          }
          print("pressed");
        },
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style:
              TextStyle(color: team == 1 ? Colors.white : Colors.black),
        ),
        backgroundColor: c,
        centerTitle: true,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 30, right: 30, top: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        (team1n).toString(),
                        style: TextStyle(fontSize: 15, color: team1_color),
                      ),
                      Text(
                        (team2n).toString(),
                        style: TextStyle(fontSize: 15, color: team2_color),
                      ),
                    ],
                  ),
                ),
                Rope(percent: (team1n / (team1n + team2n)) * 100),
              ],
            ),
            Expanded(child: towButton),
          ],
        ),
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
        child: Column(
          children: <Widget>[
            ClipRRect(
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
            Icon(Icons.keyboard_arrow_up),
          ],
        ),
      ),
    );
  }
}
