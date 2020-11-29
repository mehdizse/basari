import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:sensors/sensors.dart';
import 'package:after_layout/after_layout.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';

class ChatScreen extends StatefulWidget {


  @override
  _ChatScreenState createState() => new _ChatScreenState();
}
enum TtsState { playing, stopped, paused, continued }

class _ChatScreenState extends State<ChatScreen> with AfterLayoutMixin<ChatScreen>{
  String _swipeDirection = "";
  FlutterTts flutterTts;
  String s="";
  var myDynamicAspectRatio = 1000 / 1;
  TabController _tabController;
  dynamic ttsState;
  List<double> _userAccelerometerValues;
  List<StreamSubscription<dynamic>> _streamSubscriptions = <StreamSubscription<dynamic>>[];
  double x1=0.0,y1=0.0,z1=0.0;
  double x2=0.0,y2=0.0,z2=0.0;


  @override
  void setState(fn) {
    if(mounted){
      super.setState(fn);
    }
  }

    Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen2 = (prefs.getBool('seenChat') ?? false);
    print(_seen2);
    if (_seen2) {

    } else {
      await prefs.setBool('seenChat', true);
_speak(' مَرْحَبًَا بِكَ فِي لَوْحَةِ الْمَفَاتِيحِ، اللَّوْحَةُ مُقَسَّمَةٌ لِأَرْبَعَةِ صَفَحَات، وَ كُلَّ صَفْحَةِ مُقَسَّمَةٌبالتَّساوي لِتُسْعَةِ أَجْزَاءٍ أَوْ مُرَبَّعاتٌ يَحْتَوِي كُلُّ مَرَبَعٍ عَلَى حَرْفٍ مِنْ حُروفِ الأَبْجَدِيَّةِ الْعَرَبِيَّةَ، مُرَتبََةٌ حَسَبِ التَّرْتِيبِ الْأبْجَدِيِّ مِنَ الْيَمِينِ إِلَى الْيَسَارِ هَذَا يَعْنِي أَنَّ أَوَّلَ حَرْفٍ مِنَ الأَبَجَدِيَّة، حَرْفَ الْأَلِفْ سَيَكُونُ أقْصَى يَمِينَ أَعْلَى الشَّاشَةِ، بِنَفْسُ التَّرْتِيبِ سَيَكُونُ حَرْفُ الذَّالِ، تَاسِعُ حَرْفٍ فِي الأَبَجَدِيَّة وَ آخِّرُ حَرْفٍ فِي الصَّفْحَةِ الْأوْلَى، أَقْصَى يَسَارُ أَسْفَلِ الشَّاشَةِ. بَاقِيُّ الْحُروفِ مُوَزَّعَةٌ فِي بَاقِيُّ الصَّفَحات بِنَفْسُ التَّرْتِيبِ وَ الشَّكْلُ . يُمْكِنُكَ السَّحْبُ اُفقِيَّا لِتَغْيِيرِ الصَّفْحَةِ. آخِّرُ صَفْحَةً تَحْوِي آخِّرُ حَرْفٍ مِنْ حُروفِ الأَبْجَدِيَّةِ ، حَرْفَ الْيَاء وَبَعْدَهَا تَأْتِي مُشْتَقَّاتٌ الْأَلِفُ بِالتَّرْتِيبِ . التَّالِي. هَمْزَةً.الْأَلِفُ الْمَكسورَةُ. الْأَلِفُ بِالْهَمْزَةِ . الْأَلِفُ الْمَقْصُورَةُ. الْأَلِفُ الْمَقْصُورَةُ بِالْهَمْزَةِ.وَ الْوَاو بِالْهَمْزَةِ إِذَا نَسِيتَ هَذِهِ الْمَعْلُومَاتِ هَزَّ الْهَاتِفُ وَ سَنُذَكِّرُكَ');

    }
  }


  Widget createButton(String word){
    return  InkWell(
      onTap: (){
        if(word=="ى" ){
          _speak(" الألف المقصورة");
        }else if(word=="إ"){
          _speak(" الْأَلِفُ المكسورة");
        }else{
          _speak(word);
        }
        s=s+word;
        print(s);
      },
      
        
      child: Container(
        margin: EdgeInsets.all(5),
        color: Colors.black,
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
    super.initState();
    _streamSubscriptions
        .add(userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      setState(() {
        _userAccelerometerValues = <double>[event.x, event.y, event.z];
      });
    }));
    initTts();
  }

  initTts() {
    flutterTts = FlutterTts();
    flutterTts.setLanguage("ar");
    flutterTts.setSpeechRate(0.76);
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
    if(x2-x1>3.5 || y2-y1>3.5){
          _speak(" اِسحَب أُفُقِيّا للتنقل بين الحروف. اٌنقُر مرة للضغط على الحروف. و قم بِالسَّحْب  للاعلى لقراءة الرسالة و مرة أخرى لارسال الرسالة,  ضغطة مطولة لِإِضَافَة فراغ  و سحبة لِلْأَسْفَل لحدف آخِرِ حَرْفٍ .آخر صفحة تحوي آخر حرفٍ من حروفِ الأبجدية، حرف الياء وبعدها تأتي مشتقات الألف بالترتيب التالي. الْهَمْزَة .الألف المكسورة. الألف بالهمزة. الألف المقصورة. الألف المقصورة بالهمزة. و الواو بالهمزة");
    }

    double height=MediaQuery.of(context).size.height;
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              child: GestureDetector(
                  onDoubleTap: () {
                    Navigator.of(context).pushReplacement(new MaterialPageRoute(
                        builder: (context) => new Home()));
                  },
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
                        setState(() { 
                          s="";
                        });
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
                            createButton("ء"),
                            createButton("إ"),
                            createButton("ى"),
                            createButton("ئ"),
                            createButton("ؤ"),
                          ],
                        ),
                      ] ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

