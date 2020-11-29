import 'dart:async';
import 'package:after_layout/after_layout.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shake/shake.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';

class GISplash extends StatefulWidget {
  @override
  _GISplashState createState() => _GISplashState();
}

class _GISplashState extends State<GISplash> with AfterLayoutMixin<GISplash> {
  FlutterTts flutterTts;

  dynamic ttsState;
  bool check = false;
  initTts() {
    flutterTts = FlutterTts();
    flutterTts.setLanguage("ar");
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

  Future _speak(String word) async {
    await flutterTts.awaitSpeakCompletion(true);
    if (ttsState == TtsState.playing) {
      var result = await flutterTts.stop();
      if (result == 1) {
        print(result);
        setState(() {
          ttsState = TtsState.stopped;
          check = true;
        });
        await new Future.delayed(const Duration(seconds: 1));
        _speak(word);
      }
    } else {
      await flutterTts.speak(word);
    }
  }

  @override
  void initState() {
    super.initState();
    initTts();
  }

  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen2 = (prefs.getBool('seen2') ?? false);

    if (_seen2) {
      Navigator.of(context).pushReplacement(
          new MaterialPageRoute(builder: (context) => new GeneralInfo()));

      //is there away to block any interactions until the audio finishes
      // intro to home audio
    } else {
      await prefs.setBool('seen2', true);
      _speak(
          'مرحبًا بك في صفحة، المعلومات العامة. في هذه الصفحة سَتَجِدُ عدة مواضيع من فِئَاتٍ مختلفة، لِتَسْتَمِعَ اِليْها. إلَيْكَ كيف تستعملها.  المواضيع متوفرة في شَاشَتِكَ مِثل البطاقات. لِلْتَنَقُّلِ مِنْ مَوضُوعٍ اِلى اَخَرْ، قُمْ بِالسَّحْبِ أُفُقِيًّا مرَّةً على حدا و سنقرأ لك الفئة الموافِقة. لإختيار فئة، يكفي ان تَضغَطَ مُطَوَّلاً على الشاشة و ستبدأ قراءة المقال. يمكنك التسريع الى الامام عبر السَّحْبِ اِلى الاََسْفَلْ اَو العودة الى الوراء عبر السَّحْبِ اِلى الاَعلى. لِايقاف القِرَائَةِ يَكفي اَن تَظغَطَ مُطوَّلاً مَرَّةً ثَانِيَةً عَلى الشاشة. و طبعاً كَكُلِّ مَرَّةٍ اِذَا نسيت اَيَّ شيئٍ هُزَّ الهاتف و سنذكرك');




      Timer(Duration(seconds: 48), () {
        Navigator.of(context).pushReplacement(
            new MaterialPageRoute(builder: (context) => new GeneralInfo()));
      });
      //home audio(simple hello)
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void afterFirstLayout(BuildContext context) => checkFirstSeen();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
    );
  }
}

class GeneralInfo extends StatefulWidget {
  @override
  _GeneralInfoState createState() => _GeneralInfoState();
}

class _GeneralInfoState extends State<GeneralInfo> {
  CarouselController _scrollController = CarouselController();
  Duration duration = new Duration();
  Duration positionA = new Duration();
  double initial = 0.0;
  double added = 0.0;

  List<AudioPlayer> audioplayers = [
    AudioPlayer(playerId: 'firstplayer'),
    AudioPlayer(playerId: 'secondplayer'),
    AudioPlayer(playerId: 'third'),
    AudioPlayer(playerId: 'forth'),
    AudioPlayer(playerId: 'fifth'),
  ];

  bool playing = false;
  int position;
  ShakeDetector detector;
  @override
  void initState() {
    super.initState();
    initTts();
    initAudioPlayers();
    detector = ShakeDetector.autoStart(
        shakeThresholdGravity: 2.5,
        onPhoneShake: () {
          _speak(
              'قم بِالسَّحْبِ اُفٌقِيًّا لتغيير الفِئَةِ. إضغَطْ مُطَوَّلاً  لِبَدْإِِ القِرَائَةِ ثم ثَانيةً لإيقافها. إسحبْ تدريجيًّا اِلَى الأَسْفَلِ للتسريع الى الأمام و اِلى الأعلى للعودة الى الوراء');

          print('shake');
        });
  }

  initAudioPlayers() async {
    _speak('جاري تحميل المقالات');

    for (var i = 0; i < 5; i++) {
      
      await audioplayers[i].setUrl(urls[i],isLocal: false);

      //-----------------------------------

    }
     
    
   
  }

  FlutterTts flutterTts;

  dynamic ttsState;
  bool check = false;
  initTts() {
    flutterTts = FlutterTts();
    flutterTts.setLanguage("ar");
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

  Future _speak(String word) async {
    await flutterTts.awaitSpeakCompletion(true);
    if (ttsState == TtsState.playing) {
      var result = await flutterTts.stop();
      if (result == 1) {
        print(result);
        setState(() {
          ttsState = TtsState.stopped;
          check = true;
        });
        await new Future.delayed(const Duration(seconds: 1));
        _speak(word);
      }
    } else {
      await flutterTts.speak(word);
    }
  }

  List<String> urls = [
    'https://firebasestorage.googleapis.com/v0/b/basari-f6b13.appspot.com/o/universe.m4a?alt=media&token=f464860f-8abd-4957-976c-8bc2a28af56e',
    'https://firebasestorage.googleapis.com/v0/b/basari-f6b13.appspot.com/o/Whale.m4a?alt=media&token=9baaf125-f2fd-4339-aa3a-a2233b4c6f11',
    'https://firebasestorage.googleapis.com/v0/b/basari-f6b13.appspot.com/o/electricity.m4a?alt=media&token=d99d78e6-56de-40ef-a0e9-1a2061ee1ef9',
    'https://firebasestorage.googleapis.com/v0/b/basari-f6b13.appspot.com/o/Rue%20Boualem%20Kaddour%205.m4a?alt=media&token=07db4d2a-9527-4f74-821b-e46c48efe088',
    'https://firebasestorage.googleapis.com/v0/b/basari-f6b13.appspot.com/o/Rue%20Boualem%20Kaddour%206%20(1).m4a?alt=media&token=199bf839-f51a-4922-be60-49c365589069'
  ];

  void getAudio(int index, AudioPlayer audioPlayer) async {
    if (playing) {
      //pause
      var res = await audioplayers[index].pause();
      if (res == 1) {
        setState(() {
          playing = false;
        });
      }
    } else {
      audioPlayer.setVolume(10);
      var res = await audioplayers[index].play(urls[index], isLocal: true);
      if (res == 1) {
        setState(() {
          playing = true;
        });
      }
    }
    audioplayers[index].onDurationChanged.listen((Duration dd) {
      setState(() {
        duration = dd;
      });
    });
    audioplayers[index].onAudioPositionChanged.listen((Duration dd) {
      setState(() {
        positionA = dd;
      });
    });

    audioplayers[index].onPlayerCompletion.listen((event) {
      if (check) {
        _speak('إنتهى المقال');
      }
    });
  }

  List<String> categories = [
    'الفلك',
    'الحياة البرية',
    'تقنيات',
    'التنمية الذاتية',
    'اَحداثٌ تاريخيّة'
  ];

  @override
  void dispose() {
    super.dispose();
    detector.stopListening();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Align(
        alignment: Alignment.center,
        child: CarouselSlider.builder(
          carouselController: _scrollController,
          options: CarouselOptions(
            
            pageSnapping: true,
            enlargeCenterPage: true,
            aspectRatio: 0.57,
            initialPage: 0,
            onPageChanged: (index, reason) {
              _speak(categories[index]);
              print(categories[index]);
              setState(() {
                audioplayers[index].seek(new Duration(seconds: 0));
              });
            },
          ),
          itemCount: 5,
          itemBuilder: (context, index) {
            return Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 0, vertical: 1),
                child: GestureDetector(
                  onDoubleTap: () {
                    Navigator.of(context).pushReplacement(new MaterialPageRoute(
                        builder: (context) => new Home()));
                  },
                  onVerticalDragStart: (DragStartDetails details) {
                    initial = details.globalPosition.dy;
                    setState(() {
                      added = positionA.inSeconds.toDouble();
                    });
                  },
                  onVerticalDragUpdate: (DragUpdateDetails details) {
                    double distance = details.globalPosition.dy - initial;
                    double addition =
                        distance / MediaQuery.of(context).size.height;
                    double sec = positionA.inSeconds.toDouble();
                    print(sec);
                    setState(() {
                      added = (added + addition)
                          .clamp(0.0, duration.inSeconds.toDouble());
                    });
                    print(details.globalPosition.dy);
                    //print(distance);
                    setState(() {
                      audioplayers[index]
                          .seek(new Duration(seconds: added.toInt()));
                    });
                  },
                  onVerticalDragEnd: (DragEndDetails details) {
                    initial = 0;
                  },
                  onLongPress: () {
                    
                    getAudio(index, audioplayers[index]);
                    
                  },
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width ,
                    color: Colors.black,
                   
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

enum TtsState {
  playing,
  stopped,
}
