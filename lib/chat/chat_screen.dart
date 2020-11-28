import 'dart:async';
import 'dart:convert';
import 'package:after_layout/after_layout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sensors/sensors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'contact_screen.dart';
import 'dart:async';


class ChatScreen extends StatefulWidget {
  final String peerId;

  ChatScreen({@required this.peerId});

  @override
  _ChatScreenState createState() => new _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with AfterLayoutMixin<ChatScreen>{
  String _swipeDirection = "";
  FlutterTts flutterTts;
  String s="";
  var myDynamicAspectRatio = 1000 / 1;
  TabController _tabController;
  dynamic ttsState;
  int i=1;
  List<double> _userAccelerometerValues;
  List<StreamSubscription<dynamic>> _streamSubscriptions = <StreamSubscription<dynamic>>[];
  double x1=0.0,y1=0.0,z1=0.0;
  double x2=0.0,y2=0.0,z2=0.0;
  bool lecture=false;
  SharedPreferences prefs;
  String id;
  List<String> messages=[];
  final databaseReference = FirebaseFirestore.instance;
  List<String> initMessage=[],initMessageId=[];
  bool lect=true;
  CollectionReference reference;
  bool msg=true;
  Route route = MaterialPageRoute(builder: (context) =>ChatScreen());

  @override
  void setState(fn) {
    if(mounted){
      super.setState(fn);
    }
  }


  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen2 = (prefs.getBool('seen2') ?? false);
    print(_seen2);
    if (_seen2) {

    } else {
      await prefs.setBool('seen2', true);
      _speak(
          ' مرحبا بك في صفحة الرسائل. تستطيع عبر هذه الصفحة إرْسَال رسائل كتابية قم بالضغط علي الحروف و سنقرؤها لْك , لقراءة الرسالة المكتوبة اسحب الشاشة للاعلي , لبعث الرسالة اسحب الشاشة مرة اخري للاعلي , لحدف اخر حرف اسحب الشاشة للاسفل , و لاضافة فراغ اضغط ضغطة مطولة علي الشاشة');

    }
  }

  Widget createButton(String word){
    return  InkWell(
      onTap: (){
        _speak(word);
        s=s+word;
        print(s);
      },
      child: Container(
        margin: EdgeInsets.all(5),
        color: Colors.grey,
        child: Center(
          child: Text(
            '$word',
            style: Theme.of(context).textTheme.headline3,
          ),
        ),
      ),
    );
  }



  @override
  initState() {
    reference=FirebaseFirestore.instance.collection('messages');
    super.initState();
    _streamSubscriptions
        .add(userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      setState(() {
        _userAccelerometerValues = <double>[event.x, event.y, event.z];
      });
    }));

    readLocal();
    initTts();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      reference.where('idTo', isEqualTo: id)
          .where('idFrom',isEqualTo: widget.peerId)
          .where('read', isEqualTo: 0)
          .snapshots()
          .listen((querySnapshot) async {
            initMessage=[];
            initMessageId=[];
        querySnapshot.docChanges.forEach((change) {
            setState(() {
              initMessage.add(change.doc.data()['content']);
              initMessageId.add(change.doc.id);
            });
        });
        int i = 0;
        FlutterTts flutterTts = FlutterTts();
        if(initMessage.length>0 && route.isCurrent && route.isActive) {
          await flutterTts.speak("رسائلك الجديدة  ");
        await flutterTts.speak(initMessage[i]);
        flutterTts.setCompletionHandler(() async {
          if (i < initMessage.length - 1) {
            i++;
            await flutterTts.speak(initMessage[i]);
          }
        });
          for(int i=0;i<initMessage.length;i++){
            FirebaseFirestore.instance.collection("messages")
                .doc(initMessageId[i])
                .update({'read': 1})
                .then((value) => print("Message Updated"))
                .catchError((error) => print("Failed to update user: $error"));
          }
        }
      });

    });
  }

  initTts() {
    flutterTts = FlutterTts();
    flutterTts.setLanguage("ar");
    flutterTts.setSpeechRate(0.72);
    flutterTts.setStartHandler(() {
      setState(() {
        print("playing");
        ttsState = TtsState.playing;
      });
    });
    flutterTts.setCompletionHandler(() {
      setState(() {
        print("Complete");
        ttsState = TtsState.stopped;
      });
    });
    flutterTts.setErrorHandler((msg) {
      setState(() {
        print("error: $msg");
        ttsState = TtsState.stopped;
      });
    });
  }



  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future _speak(String word) async {
    await flutterTts.awaitSpeakCompletion(true);
    if (ttsState==TtsState.playing) {
      var result = await flutterTts.stop();
      if (result == 1) {
        setState(() {
          ttsState = TtsState.stopped;
        });
        await new Future.delayed(const Duration(seconds : 1));
        _speak(word);
      }

    }else {
      await flutterTts.speak(word);
    }
  }

  readLocal() async {
    prefs = await SharedPreferences.getInstance();
    id = prefs.getString('id') ?? '';

  }


  Future<void> onSendMessage(String content, int type) async {

    if (content.trim() != '') {
      DocumentReference ref = await FirebaseFirestore.instance.collection("messages").add({
        'idFrom': id,
        'idTo': widget.peerId,
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        'content': content,
        'type': type,
        'read':0
      });
      print(ref.id);
      _speak("تم ارسال الرسالة بنجاح");
      setState(() {
        s="";
      });
    } else {

    }
  }
  Future<bool> fetchData() => Future.delayed(Duration(seconds: 1), () {
    debugPrint('Step 2, fetch data');
    return true;
  });

  @override
  void afterFirstLayout(BuildContext context) => checkFirstSeen();

  @override
  Widget build(BuildContext context) {
    final List<String> userAccelerometer = _userAccelerometerValues
        ?.map((double v) => v.toStringAsFixed(1))
        ?.toList();
    x2=x1;
    y2=y1;
    z2=z1;
    if(_userAccelerometerValues!=null){
      x1=_userAccelerometerValues[0];
      y1=_userAccelerometerValues[1];
      z1=_userAccelerometerValues[2];
    }
    if(i==1){
      if(x2-x1>3.5 || y2-y1>3.5){
        _speak("اِسحَب عمودياً للتنقل بين الحروف. اٌنقُر مرة للضغط علي الحروف. و قم بالسحب للاعلي لقراءة الرسالة و مرة اخري لارسال الرسالة,  ضغطة مطولة لاضافة فراغ  و سحبة للاسفل لحدف الحروف");
      }
    }
    double height=MediaQuery.of(context).size.height;
    return WillPopScope(
        onWillPop: (){
      return Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => ContactScreen()),
      );
    },
    child: DefaultTabController(
      length: 4,
      child: Scaffold(
        body: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              child: GestureDetector(
                onLongPress: (){
                  s=s+' ';
                  print(s);
                },
                onVerticalDragEnd: (dragEndDetails) {
                  if (dragEndDetails.primaryVelocity < 0) {
                    // swipeup
                    if(!mounted) return;
                    setState(() {
                      _swipeDirection = "Swipe Up";
                    });
                      if (s.length > 0) {
                        _speak("$s");
                        onSendMessage(s, 0);
                      } else {
                        _speak("الرسالة فارغة");
                      }
                  } else if (dragEndDetails.primaryVelocity > 0) {
                    // swipedown
                    if(!mounted) return;
                    setState(() {
                      _swipeDirection = "Swipe Down";
                    });
                    if(s.length>0) {
                      _speak("تم حدف اخر حرف");
                    }else{
                      _speak("الرسالة فارغة");
                    }
                    if(!mounted) return;
                    setState(() {
                      s=s.substring(0, s.length - 1);
                      print(s);
                    });


                  }
                },
                child: TabBarView(
                      controller: _tabController,
                      children: <Widget>[
                        GridView.count(
                          childAspectRatio: height<550?0.71:height<650?0.68:height<700?0.58:0.50,
                          crossAxisCount: 3,
                          physics: NeverScrollableScrollPhysics(),
                          // Generate 100 widgets that display their index in the List.
                          children:[
                            createButton("ا"),
                            createButton("ب"),
                            createButton("ت"),
                            createButton("ث"),
                            createButton("ج"),
                            createButton("ح"),
                            createButton("خ"),
                            createButton("د"),
                            createButton("ذ"),
                          ],
                        ),

                        GridView.count(
                          childAspectRatio: height<550?0.71:height<650?0.68:height<700?0.64:0.50,
                          crossAxisCount: 3,
                          physics: NeverScrollableScrollPhysics(),
                          // Generate 100 widgets that display their index in the List.
                          children:[
                            createButton("ر"),
                            createButton("ز"),
                            createButton("س"),
                            createButton("ش"),
                            createButton("ص"),
                            createButton("ض"),
                            createButton("ط"),
                            createButton("ظ"),
                            createButton("ع"),
                          ],
                        ),
                        GridView.count(
                          childAspectRatio: height<550?0.71:height<650?0.68:height<700?0.64:0.50,
                          crossAxisCount: 3,
                          physics: NeverScrollableScrollPhysics(),
                          // Generate 100 widgets that display their index in the List.
                          children:[
                            createButton("غ"),
                            createButton("ف"),
                            createButton("ق"),
                            createButton("ك"),
                            createButton("ل"),
                            createButton("م"),
                            createButton("ن"),
                            createButton("ه"),
                            createButton("و"),
                          ],
                        ),
                        GridView.count(
                          childAspectRatio: height<550?0.71:height<650?0.68:height<700?0.64:0.50,
                          crossAxisCount: 3,
                          physics: NeverScrollableScrollPhysics(),
                          // Generate 100 widgets that display their index in the List.
                          children:[
                            createButton("ي"),
                            createButton("1"),
                            createButton("2"),
                            createButton("3"),
                            createButton("4"),
                            createButton("5"),
                            createButton("6"),
                            createButton("7"),
                            createButton("8"),
                          ],
                        ),
                      ] ),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}

