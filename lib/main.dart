import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:share/share.dart';
import 'dart:math';
import 'package:firebase_admob/firebase_admob.dart';

void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,

      title: 'Quote and Share',
      home: Home(),
));

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Map<String, dynamic> quotes; // initialize words
  String quote = 'Loading...';
  String author = '...';

  int _counter = 0;

  @override
  void initState() {
    super.initState();
    GetData()
        .getRandomDocument()
        .get()
        .then((datasnapshot) {
          if (datasnapshot.exists) {
            quotes = datasnapshot.data; // get data snapshot
            setState(() {
              quote = quotes['quote'];
              author = quotes['author'];
            });
        }
      });
  }

  _incrementCounter() {
    //print(_counter);
    if (_counter == 4) {
      Ads.showInterstitialAd();
      setState(() {
        _counter = 0;
      }); 
    } else {
      setState(() {
        _counter++;
        });
    }
  }

  void _displayQuote() {
    GetData()
        .getRandomDocument()
        .get()
        .then((datasnapshot) {
          if (datasnapshot.exists) {
            quotes = datasnapshot.data; // get data snapshot
            setState(() {
              quote = quotes['quote'];
              author = quotes['author'];
            });
          }
        });
  }

  void _shareApp(){
    Share.share("\"" + quote + "\"" + '\n\- ' + author, subject: 'Found this on Quote and Share App');
  }

  @override
  Widget build(BuildContext context) {
    // set the orientation
    SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            // container for app name
            Container(
              padding: EdgeInsets.fromLTRB(25.0, 0.0, 25.0, 4.0),
              margin: EdgeInsets.only(top: 40.0),
              child: Align(
                alignment: Alignment.topRight,
                child: Text("Quote and Share",
                style: TextStyle(
                  fontFamily: 'Quicksand-Bol',
                fontSize: 14.0,
                //letterSpacing: 0.0,
                color: Colors.grey[700],
                ),),
              ),
            ),

            Divider(
              color: Colors.grey[800],
            ),



            // container for quote + author
            Container(
              child: Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(25.0, 0.0, 25.0, 0.0),
                  child: Align(
                    alignment: Alignment.center,
                    child: ListView(
                      //mainAxisAlignment: MainAxisAlignment.center,                      
                      children: <Widget>[

                        // container for quote
                        Container(
                          child: Text("\"" + quote + "\"",
                          style: TextStyle(
                            fontSize: 21.0,
                            color: Color(0xffffffff),
                          ),),
                        ),
                        
                        // container for author name
                        Container(
                          margin: EdgeInsets.only(top: 15.0),
                          child: Text("- " + author.toUpperCase(),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontFamily: 'Quicksand-Bol',
                            fontSize: 15.0,
                            letterSpacing: 1.0,
                            color: Colors.grey[500],
                          ),),
                        ),

                      ],
                    ),
                  ),
                ),
              ),
            ),

            // container for buttons
            Container(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[

                        // container load random quote button
                        Container(
                          height: 65.0,
                          width: 65.0,
                          child: FloatingActionButton(
                            onPressed: () {
                              _displayQuote();
                              _incrementCounter();
                            },
                            tooltip: 'Random quote',
                            child: Icon(Icons.replay, size: 38.0,),
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16.0)))
                          ),
                        ),

                        // container share app button
                        Container(
                          height: 65.0,
                          width: 65.0,
                          child: FloatingActionButton(
                              onPressed: _shareApp,
                              tooltip: 'Share quote',
                              child: Icon(Icons.share, size: 38.0,),
                              backgroundColor: Colors.pinkAccent[400],
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16.0)))
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
            ),
          ],
        ),
    );
  }
}

// gets data from firestore database
class GetData {
  var db = Firestore.instance.collection('COLLECTION NAME HERE'); // your firebase collection name here
  
  DocumentReference getRandomDocument() {
    Random random = new Random();
    int randomNumber = random.nextInt(NUMBER OF DOCUMENTS HERE) + 1; // number of documents in firebase collection
    return db.document(randomNumber.toString().padLeft(5, '0'));
  }
}

// Interstitial class
  class Ads {
  static InterstitialAd _interstitialAd;
  static void initialize() {
    FirebaseAdMob.instance.initialize(appId: 'ca-app-pub-xxxxxxxxxxxxxxxx~xxxxxxxxxx'); // admob appid for ads here
  }

  static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    keywords: <String>['KEYWORD1', 'KEYWORD2', 'KEYWORD3'], // keywords for ads
    contentUrl: 'CONTENT URL HERE', // content url here
    childDirected: false,
    testDevices: <String>[],
  );

  static InterstitialAd _createInterstitialAd() {
    return InterstitialAd(
      adUnitId: "ca-app-pub-xxxxxxxxxxxxxxxxx/xxxxxxxxxx", //adunit id
      //adUnitId: InterstitialAd.testAdUnitId,
       targetingInfo: targetingInfo,
  listener: (MobileAdEvent event) {
    if (event == MobileAdEvent.failedToLoad) {
          _interstitialAd..load();
        } else if (event == MobileAdEvent.closed) {
          _interstitialAd = _createInterstitialAd()..load();
        }
    },);
  }

  static void showInterstitialAd() {
    if (_interstitialAd == null) _interstitialAd = _createInterstitialAd();
    _interstitialAd
      ..load()
      ..show(anchorOffset: 0.0, anchorType: AnchorType.top);
  }

  static void hideInterstitialAd() async {
    await _interstitialAd.dispose();
    _interstitialAd = null;
  }
}
