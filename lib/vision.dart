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

class VSplash extends StatefulWidget {
  @override
  _VSplashState createState() => _VSplashState();
}

class _VSplashState extends State<VSplash> with AfterLayoutMixin<VSplash> {
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
    bool _seen3 = (prefs.getBool('seen3') ?? false);

    if (_seen3) {
      Navigator.of(context).pushReplacement(
          new MaterialPageRoute(builder: (context) => new Vision()));

      //is there away to block any interactions until the audio finishes
      // intro to home audio
    } else {
      await prefs.setBool('seen3', true);
      _speak(
          'مرحبًا بك في صفحة، رؤيا.  في هذه الصفحة ستجد عدة نصوصٍ من كتبٍ مختلفة، لِتَسْتَمِعَ اِليْها. إلَيْكَ كيف تستعملها.  النصوص متوفرة في شَاشَتِكَ مِثل البطاقات. لِلْتَنَقُّلِ مِنْ نصٍّ اِلى اَخَرْ، قُمْ بِالسَّحْبِ أُفُقِيًّا مرَّةً على حدَا و سنقرأ لك عنوان النَّص الموافِق. لإختيار نَصِّ، يكفي ان تَنْقُرَ مُطوَّلاً على الشاشة و ستبدأ قراءةُ النَصّ. يمكنك التسريع الى الامام عبر السَّحْبِ اِلى الاََسْفَلْ اَو العودة الى الوراء عبر السَّحْبِ اِلى الاَعلى. لِايقاف القِرَائَةِ يَكفي اَن تَنْقُرَ مَرَّةً ثَانِيَةً عَلى الشاشة. و طبعاً كَكُلِّ مَرَّةٍ اِذَا نسيت اَيَّ شيئٍ هُزَّ الهاتف و سنذكرك');

      Timer(Duration(seconds: 48), () {
        Navigator.of(context).pushReplacement(
            new MaterialPageRoute(builder: (context) => new Vision()));
      });
      //home audio(simple hello)
    }
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

class Vision extends StatefulWidget {
  @override
  _VisionState createState() => _VisionState();
}

class _VisionState extends State<Vision> {
  CarouselController _scrollController = CarouselController();
  Duration duration = new Duration();
  Duration positionA = new Duration();
  double initial = 0.0;
  double added = 0.0;

  List<AudioPlayer> audioplayers = [
    AudioPlayer(playerId: 'firstplayer'),
    AudioPlayer(playerId: 'secondplayer'),
    AudioPlayer(playerId: 'third'),
  ];

  bool playing = false;
  int position;

  List<String> categories1 = [
    'لو أبْصَرْتُ ثلاثةُ ايَّام',
    'العواصف',
    'العالم كما أراهْ',
  ];
  ShakeDetector detector;
  @override
  void initState() {
    super.initState();

    //
    detector = ShakeDetector.autoStart(
        shakeThresholdGravity: 2.5,
        onPhoneShake: () {
          _speak(
              'قم بِالسَّحْبِ اُفٌقِيًّا لتغيير النص. اُنْقُرْ مرة لِبَدْإِِ القِرَائَةِ ثم مرة ثانيةً لإيقافها. إسحبْ تدريجيًّا اِلَى الأَسْفَلِ للتسريع الى الأمام و اِلى الأعلى للعودة الى الوراء');

          print('shake');
        });

    initTts();
    initAudioPlayers();
  }

  initAudioPlayers() async {
     _speak('جاري تحميل المقالات');
    for (var i = 0; i < 3; i++) {
      await audioplayers[i].setUrl(urls[i]);

      //-----------------------------------

    }
    var res = audioplayers[2].getDuration();
    print('khra');
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
        check = true;
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
    'https://firebasestorage.googleapis.com/v0/b/basari-f6b13.appspot.com/o/Text1.m4a?alt=media&token=caeca22b-e51c-461c-bfd1-841923366baf',
    'https://firebasestorage.googleapis.com/v0/b/basari-f6b13.appspot.com/o/Text2.m4a?alt=media&token=70c0e25b-6b81-4b0a-8da0-8afc191ee475',
    'https://firebasestorage.googleapis.com/v0/b/basari-f6b13.appspot.com/o/text3.aac?alt=media&token=c511fc0b-965e-491c-b283-50ffd880e9f7',
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
      var res = await audioplayers[index].play(urls[index], isLocal: false);
      Timer(Duration(seconds: 2),() {
        if(res!=1){
           _speak('جاري تحميل المقالات');
        }      
      });

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

  bool lecture = false;

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
            aspectRatio: 0.6,
            initialPage: 0,
            onPageChanged: (index, reason) {
              _speak(categories1[index]);
              print(categories1[index]);
              setState(() {
                audioplayers[index].seek(new Duration(seconds: 0));
                audioplayers[index].stop();
              });
            },
          ),
          itemCount: 3,
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
                  onTap: () {
                    getAudio(index, audioplayers[index]);
                    print(MediaQuery.of(context).size.height);
                  },
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width * 0.9,
                    color: Colors.black,
                    child: Scaffold(
                      backgroundColor: Colors.black,
                    ),
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
